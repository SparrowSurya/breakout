extends Node


## Formats the time as mm:ss
func format_time(p_time: float) -> String:
	var minutes: int = int(p_time / 60.0)
	var seconds: int = int(p_time) % 60
	# Isolate the decimal portion and convert to 2-digit centiseconds
	#var centiseconds: int = int((time - int(time)) * 100)
	
	return "%02d:%02d" % [minutes, seconds]


## Waits for given seconds.
func wait(secs: float, process_always: bool = false) -> void:
	await get_tree().create_timer(secs, process_always).timeout
