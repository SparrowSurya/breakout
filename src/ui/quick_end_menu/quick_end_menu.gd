class_name QuickEndMenu
extends TabContainer

@export var win_menu: QuickWinMenu
@export var lose_menu: QuickLoseMenu

const TAB_WIN: int = 0
const TAB_LOSE: int = 1


func _ready() -> void:
	hide()


## Shows win menu.
func show_win(time: String, lives: int) -> void:
	win_menu.update(time, lives)
	current_tab = TAB_WIN
	show()


## Shows lose menu.
func show_lose(time: String, progress: float) -> void:
	lose_menu.update(time, progress)
	current_tab = TAB_LOSE
	show()
