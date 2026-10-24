#!/usr/bin/env python3
"""
extras/levels.py - Breakout Levels Viewer & Inspector CLI

Usage:
  python3 extras/levels.py -v 2
  python3 extras/levels.py -v 2-10
  python3 extras/levels.py -v 3,4,5
  python3 extras/levels.py -v all
  python3 extras/levels.py -i 3
  python3 extras/levels.py -i 2-10
  python3 extras/levels.py -i all
  python3 extras/levels.py -v all -d special
  python3 extras/levels.py -i all --hits ">50" --tile-count "<20"
  python3 extras/levels.py -i 1 --color=no
"""

import sys
import os
import json
import argparse
import shutil
import re
from typing import List, Dict, Any, Optional, Set, Tuple

# Brick rendering constants matching script.py
BRICK_WIDTH: int = 8
COLUMN_GAP: int = 3
ROW_GAP: int = 2

# Catppuccin Mocha 24-bit background ANSI escapes
BG_COLORS: Dict[int, str] = {
    0: "",                        # Empty
    1: "\033[48;2;203;166;247m",  # Mauve (Purple)
    2: "\033[48;2;137;180;250m",  # Blue
    3: "\033[48;2;166;227;161m",  # Green
    4: "\033[48;2;249;226;175m",  # Yellow
    5: "\033[48;2;250;179;135m",  # Peach (Orange)
    6: "\033[48;2;243;139;168m",  # Red
    9: "\033[48;2;108;112;134m",  # Overlay 0 (Grey)
}

# Catppuccin Mocha 24-bit foreground ANSI escapes
FG_COLORS: Dict[int, str] = {
    0: "\033[38;2;108;112;134m",  # Dim overlay0 for empty tiles
    1: "\033[38;2;203;166;247m",  # Mauve
    2: "\033[38;2;137;180;250m",  # Blue
    3: "\033[38;2;166;227;161m",  # Green
    4: "\033[38;2;249;226;175m",  # Yellow
    5: "\033[38;2;250;179;135m",  # Peach
    6: "\033[38;2;243;139;168m",  # Red
    9: "\033[38;2;147;153;178m",  # Overlay2 for Metal
}

# Difficulty UI text colors
DIFFICULTY_COLORS: Dict[str, str] = {
    "easy": "\033[38;2;166;227;161m",     # Green
    "medium": "\033[38;2;249;226;175m",   # Yellow
    "hard": "\033[38;2;243;139;168m",     # Red
    "special": "\033[38;2;203;166;247m",  # Mauve
}

# Tile labels & names
TILE_NAMES: Dict[int, str] = {
    1: "1hp (Mauve)",
    2: "2hp (Blue)",
    3: "3hp (Green)",
    4: "4hp (Yellow)",
    5: "5hp (Peach)",
    6: "6hp (Red)",
    9: "metal (Silver)",
}

RESET: str = "\033[0m"
BOLD: str = "\033[1m"
DIM: str = "\033[2m"
BRICK: str = " " * BRICK_WIDTH


def load_levels(filepath: str) -> List[Dict[str, Any]]:
    if not os.path.exists(filepath):
        print(f"Error: Levels file not found at: {filepath}", file=sys.stderr)
        sys.exit(1)

    levels: List[Dict[str, Any]] = []
    with open(filepath, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or not line.startswith("{"):
                continue
            try:
                data = json.loads(line)
                levels.append(data)
            except json.JSONDecodeError as e:
                print(f"Warning: Failed to parse line in levels file: {e}", file=sys.stderr)
    return levels


def parse_targets(target_str: str, max_level: int) -> Set[int]:
    target_str = target_str.strip()
    if target_str.lower() == "all":
        return set(range(1, max_level + 1))

    results: Set[int] = set()
    parts = [p.strip() for p in target_str.split(",") if p.strip()]
    for part in parts:
        if "-" in part:
            bounds = part.split("-")
            if len(bounds) == 2 and bounds[0].strip().isdigit() and bounds[1].strip().isdigit():
                start = int(bounds[0].strip())
                end = int(bounds[1].strip())
                if start > end:
                    start, end = end, start
                for lvl in range(start, end + 1):
                    if 1 <= lvl <= max_level:
                        results.add(lvl)
            else:
                print(f"Warning: Invalid range syntax: '{part}'", file=sys.stderr)
        elif part.isdigit():
            lvl = int(part)
            if 1 <= lvl <= max_level:
                results.add(lvl)
            else:
                print(f"Warning: Level {lvl} out of bounds (1-{max_level})", file=sys.stderr)
        else:
            print(f"Warning: Unrecognized target specifier: '{part}'", file=sys.stderr)

    return results


def parse_comparison(expr: Optional[str]) -> Optional[Tuple[str, int]]:
    if not expr:
        return None
    expr = expr.strip()
    match = re.match(r"^([<>!=]=?|=)?\s*(\d+)$", expr)
    if not match:
        print(f"Warning: Invalid filter comparison expression: '{expr}'. Expected e.g. '>10', '<=20', '=16'", file=sys.stderr)
        return None
    op, val_str = match.groups()
    val = int(val_str)
    if not op or op == "=":
        op = "=="
    return (op, val)


def matches_comparison(val: int, cmp_tuple: Optional[Tuple[str, int]]) -> bool:
    if cmp_tuple is None:
        return True
    op, target = cmp_tuple
    if op in ("=", "=="):
        return val == target
    elif op == ">":
        return val > target
    elif op == ">=":
        return val >= target
    elif op == "<":
        return val < target
    elif op == "<=":
        return val <= target
    elif op == "!=":
        return val != target
    return True


def render_view(level: Dict[str, Any], use_color: bool) -> None:
    level_no = level.get("level_no", 0)
    difficulty = level.get("difficulty", "easy").lower()
    rows = level.get("rows", 0)
    cols = level.get("cols", 0)
    grid = level.get("grid", [])

    diff_str = difficulty.upper()
    if use_color:
        diff_color = DIFFICULTY_COLORS.get(difficulty, "")
        header = f"{BOLD}Level {level_no}{RESET} [{diff_color}{diff_str}{RESET}] ({rows}x{cols})"
    else:
        header = f"Level {level_no} [{diff_str}] ({rows}x{cols})"

    term_width = shutil.get_terminal_size((80, 24)).columns
    header_pad = max(0, (term_width - len(f"Level {level_no} [{diff_str}] ({rows}x{cols})")) // 2)
    print(" " * header_pad + header)
    print()

    # Split 1D grid into 2D rows
    grid_2d: List[List[int]] = []
    for r in range(rows):
        start = r * cols
        grid_2d.append(grid[start : start + cols])

    # Visual rendering matching script.py
    for row_index, row in enumerate(grid_2d):
        row_width = len(row) * BRICK_WIDTH + max(0, len(row) - 1) * COLUMN_GAP
        left_padding = max(0, (term_width - row_width) // 2)
        print(" " * left_padding, end="")

        for index, health in enumerate(row):
            if index > 0:
                print(" " * COLUMN_GAP, end="")

            if health == 0:
                print(" " * BRICK_WIDTH, end="")
            elif use_color:
                color = BG_COLORS.get(health, "")
                if color:
                    print(f"{color}{BRICK}{RESET}", end="")
                else:
                    print(BRICK, end="")
            else:
                # Monochrome representation with clear 8-char brick boundaries
                if health == 9:
                    print("[ METAL]", end="")
                else:
                    print(f"[ HP {health} ]", end="")

        print()
        if row_index < len(grid_2d) - 1:
            print("\n" * (ROW_GAP - 1), end="")

    print("\n" + "─" * min(term_width, 80) + "\n")


def render_info(level: Dict[str, Any], use_color: bool) -> None:
    level_no = level.get("level_no", 0)
    difficulty = level.get("difficulty", "easy").lower()
    rows = level.get("rows", 0)
    cols = level.get("cols", 0)
    grid = level.get("grid", [])

    diff_str = difficulty.upper()
    if use_color:
        diff_color = DIFFICULTY_COLORS.get(difficulty, "")
        diff_display = f"{diff_color}{BOLD}{diff_str}{RESET}"
        title_display = f"{BOLD}Level {level_no}{RESET}"
    else:
        diff_display = diff_str
        title_display = f"Level {level_no}"

    # Calculate statistics
    counts: Dict[int, int] = {}
    total_hits = 0
    total_tiles = 0
    destructible_tiles = 0
    metal_tiles = 0

    for tile in grid:
        if tile == 0:
            continue
        counts[tile] = counts.get(tile, 0) + 1
        total_tiles += 1
        if tile == 9:
            metal_tiles += 1
        elif 1 <= tile <= 6:
            destructible_tiles += 1
            total_hits += tile

    divider = "─" * 50
    print(divider)
    print(f"LevelNo         : {title_display}")
    print(f"Difficulty      : {diff_display}")
    print(f"Grid dimensions : {rows}x{cols}")
    print(divider)
    print("Grid Data (2D Array):")

    # Render 2D array without brackets
    for r in range(rows):
        row_tiles = grid[r * cols : (r + 1) * cols]
        formatted_row: List[str] = []
        for t in row_tiles:
            if use_color:
                fg = FG_COLORS.get(t, "")
                formatted_row.append(f"{fg}{t}{RESET}")
            else:
                formatted_row.append(str(t))
        print("  " + "  ".join(formatted_row))

    print("\nTile statistics:")
    if not counts:
        print("  (Empty grid)")
    else:
        for hp in sorted(counts.keys()):
            c = counts[hp]
            name = TILE_NAMES.get(hp, f"{hp}hp")
            if use_color:
                fg = FG_COLORS.get(hp, "")
                print(f"  • {c} {fg}{name}{RESET} tile{'s' if c > 1 else ''}")
            else:
                print(f"  • {c} {name} tile{'s' if c > 1 else ''}")

    print("\nSummary:")
    print(f"  • Total hits required : {total_hits}")
    print(f"  • Total tiles count   : {total_tiles} ({destructible_tiles} destructible, {metal_tiles} metal)")
    print(divider + "\n")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Inspect and visualize Breakout levels from data/levels.jsonl",
        add_help=True
    )

    parser.add_argument(
        "-v", "--view",
        nargs="?",
        const="all",
        default=None,
        help="Visual brick rendering of levels (e.g. '2', '2-10', '3,4,5', 'all')"
    )
    parser.add_argument(
        "-i", "--info",
        nargs="?",
        const="all",
        default=None,
        help="Detailed stats and 2D data of levels (e.g. '2', '2-10', '3,4,5', 'all')"
    )
    parser.add_argument(
        "--color",
        choices=["yes", "no"],
        default="yes",
        help="Enable/disable ANSI colors (default: yes)"
    )
    parser.add_argument(
        "-d", "--difficulty",
        default=None,
        help="Filter by difficulty ('easy', 'medium', 'hard', 'special', comma-separated)"
    )
    parser.add_argument(
        "--tile-count", "--tiles",
        dest="tile_count",
        default=None,
        help="Filter by total tile count (e.g. '>15', '<=20', '=16')"
    )
    parser.add_argument(
        "--hits", "--tile-hits",
        dest="hits",
        default=None,
        help="Filter by total hits required (e.g. '>50', '<=30', '=40')"
    )

    args = parser.parse_args()

    # Determine script location and levels.jsonl path
    script_dir = os.path.dirname(os.path.abspath(__file__))
    levels_path = os.path.normpath(os.path.join(script_dir, "..", "data", "levels.jsonl"))

    all_levels = load_levels(levels_path)
    if not all_levels:
        print("No levels found in data/levels.jsonl", file=sys.stderr)
        sys.exit(1)

    max_level = len(all_levels)
    available_range_str = f"1-{max_level} (Total: {max_level} levels)"

    # Determine target levels
    has_view = args.view is not None
    has_info = args.info is not None

    if not has_view and not has_info:
        # If neither -v nor -i specified, default to --view all
        has_view = True
        target_str = "all"
    else:
        target_str = args.view if has_view and args.view else (args.info if has_info and args.info else "all")

    target_set = parse_targets(target_str, max_level)

    # Parse filters
    diff_filter: Optional[Set[str]] = None
    if args.difficulty:
        diff_filter = {d.strip().lower() for d in args.difficulty.split(",") if d.strip()}

    tile_cmp = parse_comparison(args.tile_count)
    hits_cmp = parse_comparison(args.hits)

    # Filter levels
    matched_levels: List[Dict[str, Any]] = []
    for level in all_levels:
        lvl_no = level.get("level_no", 0)
        if lvl_no not in target_set:
            continue

        if diff_filter and level.get("difficulty", "").lower() not in diff_filter:
            continue

        grid = level.get("grid", [])
        total_tiles = sum(1 for t in grid if t != 0)
        total_hits = sum(t for t in grid if 1 <= t <= 6)

        if not matches_comparison(total_tiles, tile_cmp):
            continue

        if not matches_comparison(total_hits, hits_cmp):
            continue

        matched_levels.append(level)

    # Handle no matches
    if not matched_levels:
        print("No levels matched your filter criteria.")
        print(f"Available levels: {available_range_str}")
        return

    use_color = (args.color != "no")

    # Render matched levels
    for level in matched_levels:
        if has_info:
            render_info(level, use_color)
        if has_view:
            render_view(level, use_color)


if __name__ == "__main__":
    main()
