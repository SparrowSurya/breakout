#!/usr/bin/env python3
"""
Lightweight development HTTP server with Gzip compression and Cross-Origin headers.
Ideal for testing WebAssembly / Godot Web builds (e.g. YouTube Playables test suite).

Usage:
    python3 scripts/server.py [directory] [port]
Example:
    python3 scripts/server.py build/youtube 8000
"""

import sys
import os
import gzip
import socketserver
import http.server

COMPRESSIBLE_EXTS = ('.wasm', '.pck', '.js', '.json', '.jsonl', '.html', '.svg')

class GzipHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        # Enable CORS for local testing
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "*")
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(204)
        self.end_headers()

    def do_GET(self):
        path = self.translate_path(self.path)
        accept_encoding = self.headers.get("Accept-Encoding", "")

        # Only compress existing files with compressible extensions if client supports gzip
        if os.path.isfile(path) and "gzip" in accept_encoding and path.lower().endswith(COMPRESSIBLE_EXTS):
            try:
                with open(path, "rb") as f:
                    content = f.read()

                compressed = gzip.compress(content, compresslevel=6)

                self.send_response(200)
                content_type = self.guess_type(path)
                if path.endswith(".wasm"):
                    content_type = "application/wasm"
                self.send_header("Content-Type", content_type)
                self.send_header("Content-Encoding", "gzip")
                self.send_header("Content-Length", str(len(compressed)))
                self.send_header("Vary", "Accept-Encoding")
                self.end_headers()
                self.wfile.write(compressed)
                return
            except Exception as e:
                self.log_error("Compression error: %s", str(e))

        return super().do_GET()


def run_server():
    directory = sys.argv[1] if len(sys.argv) > 1 else ""
    port = int(sys.argv[2]) if len(sys.argv) > 2 else 8000

    if not os.path.isdir(directory):
        print(f"Error: Directory '{directory}' does not exist.")
        sys.exit(1)

    os.chdir(directory)
    socketserver.TCPServer.allow_reuse_address = True

    with socketserver.TCPServer(("", port), GzipHTTPRequestHandler) as httpd:
        print(f"==================================================")
        print(f" Serving '{directory}' with GZIP compression")
        print(f" Local URL: http://localhost:{port}")
        print(f" Press Ctrl+C to stop the server")
        print(f"==================================================")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nServer stopped.")


if __name__ == "__main__":
    run_server()
