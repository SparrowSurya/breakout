class_name EndMenu
extends TabContainer

@export var win_menu: WinMenu
@export var lose_menu: LoseMenu

const TAB_WIN: int = 0
const TAB_LOSE: int = 1


func _ready() -> void:
	hide()


## Shows win menu.
func show_win(level_no: int, time: String, lives: int) -> void:
	win_menu.update(level_no, time, lives)
	current_tab = TAB_WIN
	show()


## Shows lose menu.
func show_lose(level_no: int, time: String, progress: float) -> void:
	lose_menu.update(level_no, time, progress)
	current_tab = TAB_LOSE
	show()
