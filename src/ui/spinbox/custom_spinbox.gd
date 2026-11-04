class_name CustomSpinbox
extends VBoxContainer

## Emitted when value changes
signal value_changed(new_value: int)

@export var label_text: Label               ## Label name.
@export var label_value: Label              ## Value of the node.
@export var indicator: HBoxContainer        ## Node showing levels.
@export var minus_button: CustomIconButton  ## Value decrement button.
@export var plus_button: CustomIconButton   ## Value increment button.

@export var length: int = 10:
	set(p_length):
		length = maxi(0, p_length)
		value = clampi(value, 0, length)
		_render()

@export var value: int = 5:
	set(p_value):
		value = clampi(p_value, 0, length)
		_render()
		value_changed.emit(value)


func _ready() -> void:
	minus_button.pressed.connect(_decrement_value)
	plus_button.pressed.connect(_increment_value)
	setup("Label", 10, 5)


func setup(label: String, p_length: int, p_value: int) -> void:
	if label_text:
		label_text.text = label
	length = p_length
	value = p_value
	_render()


func _render() -> void:
	if not is_node_ready():
		return

	if label_value:
		label_value.text = str(value)

	if indicator:
		while indicator.get_child_count() > length:
			var child = indicator.get_child(indicator.get_child_count() - 1)
			indicator.remove_child(child)
			child.queue_free()

		while indicator.get_child_count() < length:
			var node = ColorRect.new()
			node.custom_minimum_size = Vector2(14.0, 14.0)
			node.custom_maximum_size = Vector2(14.0, 14.0)
			node.mouse_filter = Control.MOUSE_FILTER_STOP
			node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			node.gui_input.connect(_on_indicator_clicked.bind(node))
			indicator.add_child(node)

		# Color active (LAVENDER) and inactive (SURFACE1) boxes
		for i in range(indicator.get_child_count()):
			var node = indicator.get_child(i)
			node.modulate = Palette.LAVENDER if i < value else Palette.SURFACE1


func _on_indicator_clicked(event: InputEvent, node: Control) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		value = node.get_index() + 1


func _set_value(p_value: int) -> void:
	value = p_value

func _increment_value() -> void:
	value += 1


func _decrement_value() -> void:
	value -= 1
