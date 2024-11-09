extends Node2D


var is_input_map_change : bool = false

@onready var button_change_input_map: Button = $ButtonChangeInputMap

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_button_text()
	pass # Replace with function body.


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("up"):
		print("up pressed")
	
	change_input_map(event)
	pass


func change_input_map(event: InputEvent) -> void:
	if not is_input_map_change:
		return
	
	if not (event is InputEventKey 
			or event is InputEventMouseButton 
			or event is InputEventJoypadButton 
			or event is InputEventJoypadMotion):
		return
	
	InputManager.set_action_event("up", event)
	change_button_text()
	
	is_input_map_change = false
	pass


func change_button_text() -> void:
	var arr_input_event : Array[InputEvent] = InputMap.action_get_events("up")
	for event : InputEvent in arr_input_event:
		if event is InputEventKey:
			var keycode = DisplayServer.keyboard_get_keycode_from_physical(event.physical_keycode)
			button_change_input_map.text = OS.get_keycode_string(keycode)
			break
		
		if event is InputEventMouseButton:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					button_change_input_map.text = "mouse left button"
				MOUSE_BUTTON_RIGHT:
					button_change_input_map.text = "mouse right button"
				MOUSE_BUTTON_MIDDLE:
					button_change_input_map.text = "mouse middle button"
			break
	pass

func _on_button_change_input_map_pressed() -> void:
	is_input_map_change = true
	pass # Replace with function body.
