class_name BasePowerup
extends RefCounted


var type: PowerupRegistry.PowerType  ## Type of power
var duration: float = 0.0            ## 0 = instant (nothing is kept active).
var remaining: float = 0.0
var game: BaseGame                   ## Set by the manager before activate().
var collect_pos: Vector2 = Vector2.ZERO  ## Position where powerup was collected.


## Eligibility check used when picking a drop.
func can_spawn(_game: BaseGame) -> bool:
	return true


## Runs when collected.
func activate() -> void:
	pass


## Runs on when expires or cleard.
func deactivate() -> void:
	pass


## Optional per-frame hook.
func tick(_delta: float) -> void:
	pass     
