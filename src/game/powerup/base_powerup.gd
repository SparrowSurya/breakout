class_name BasePowerup
extends RefCounted


var type: int
var duration: float = 0.0   ## 0 = instant (nothing is kept active).
var remaining: float = 0.0
var game: BaseGame          ## Set by the manager before activate().

func can_spawn(_game: BaseGame) -> bool:   # Eligibility check used when picking a drop.
	return true
func activate() -> void: pass              # Runs on collect.
func deactivate() -> void: pass            # Runs on expiry or clear (timed ones only).
func tick(_delta: float) -> void: pass     # Optional per-frame hook.
func refresh() -> void:                    # Collected again while active.
	remaining = duration
