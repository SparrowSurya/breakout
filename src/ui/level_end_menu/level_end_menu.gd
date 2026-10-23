class_name LevelEndMenu
extends TabContainer

@export var win_menu: LevelWinMenu
@export var lose_menu: LevelLoseMenu

const TAB_WIN: int = 0
const TAB_LOSE: int = 1


func _ready() -> void:
	hide()


## Shows win menu.
func show_win() -> void:
	current_tab = TAB_WIN
	show()


## Shows lose menu.
func show_lose() -> void:
	current_tab = TAB_LOSE
	show()
