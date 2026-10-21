class_name PageNav
extends HBoxContainer

# Signal emited when page config values change
signal page_update(total_pages: int, current_page: int)

@export var prev_button_node: CustomIconButton
@export var next_button_node: CustomIconButton

@export var indicator_left_node: ColorRect
@export var indicator_mid_node: ColorRect
@export var indicator_right_node: ColorRect

@export var total_pages: int = 1:
	set(value):
		total_pages = max(1, value)
		current_page = clampi(current_page, 1, total_pages)
		
		if is_node_ready():
			_update()

@export var current_page: int = 1:
	set(value):
		if value < 1 or value > total_pages:
			return

		current_page = value
		if is_node_ready():
			_update()


func _ready() -> void:
	prev_button_node.pressed.connect(_on_prev_pressed)
	next_button_node.pressed.connect(_on_next_pressed)


func _update() -> void:
	_update_buttons()
	_update_indicators()
	page_update.emit(total_pages, current_page)


func _update_buttons() -> void:
	prev_button_node.disabled = current_page == 1
	next_button_node.disabled = current_page == total_pages


func _update_indicators() -> void:
	var indicators: Array[ColorRect] = [indicator_left_node, indicator_mid_node, indicator_right_node]
	for i in range(indicators.size()):
		var indicator = indicators[i]
		indicator.size = Vector2(8.0, 8.0)
		indicator.color = Palette.SURFACE1

		if i < total_pages:
			indicator.show()
		else:
			indicator.hide()

	if current_page == 1:
		indicator_left_node.size = Vector2(16.0, 8.0)
		indicator_left_node.color = Palette.LAVENDER
	elif current_page == total_pages:
		indicator_right_node.size = Vector2(16.0, 8.0)
		indicator_right_node.color = Palette.LAVENDER
	else:
		indicator_mid_node.size = Vector2(16.0, 8.0)
		indicator_mid_node.color = Palette.LAVENDER


func _on_prev_pressed() -> void:
	current_page = current_page-1


func _on_next_pressed() -> void:
	current_page = current_page+1
