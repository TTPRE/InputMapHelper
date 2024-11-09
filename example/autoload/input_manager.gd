extends Node

enum EventType{
	INPUT_EVENT_KEY = 0,
	INPUT_EVENT_MOUSE_BUTTON,
	INPUT_EVENT_JOYPAD_BUTTON,
	INPUT_EVENT_JOYPAD_MOTION,
}

const STRN_EVENT_TYPE : StringName = "event_type"
const STRN_PHYSICAL_KEYCODE : StringName = "physical_keycode"
const STRN_MOUSE_BUTTON_INDEX : StringName = "mouse_button_index"
const STRN_JOY_BUTTON_INDEX : StringName = "joy_button_index"
const STRN_JOY_AXIS : StringName = "joy_axis"

# 项目设置中配置的默认输入映射
const DICT_DEFAULT_INPUT_MAP : Dictionary = {
	"up" : [{
		"event_type" : EventType.INPUT_EVENT_KEY,
		"physical_keycode" : 87,
	}],
}

# 自定义输入映射 默认输入映射副本 用于修改和保存
var dict_custom_input_map : Dictionary = DICT_DEFAULT_INPUT_MAP.duplicate(true)


func _enter_tree() -> void:
	init_input_map_from_setting()
	pass


func _exit_tree() -> void:
	save_input_map_to_setting()
	pass


# 从统一管理设置信息位置加载输入映射
func init_input_map_from_setting() -> void:
	# TODO:自行实现获取设置中的输入映射对 dict_custom_input_map 进行覆盖
	if SettingConfigManager.setting_data.dict_input_map.is_empty(): 
		return
	dict_custom_input_map = SettingConfigManager.setting_data.dict_input_map
	
	load_input_map_from_dict(dict_custom_input_map)
	pass


# 保存输入映射到统一管理设置位置
func save_input_map_to_setting() -> void:
	# TODO:自行实现将 dict_custom_input_map 保存到设置中进行持久化
	SettingConfigManager.setting_data.dict_input_map = dict_custom_input_map
	pass


# 从字典加载按键映射
func load_input_map_from_dict(dict_input_map: Dictionary) -> void:
	if dict_input_map.is_empty():
		return
	
	for str_action : String in dict_input_map.keys():
		if not InputMap.has_action(str_action):
			continue
		InputMap.action_erase_events(str_action)
	
	for str_action : String in dict_input_map.keys():
		for dict_event : Dictionary in dict_input_map.get(str_action):
			var event : InputEvent = get_input_event_from_dict(dict_event)
			if event == null:
				continue
			InputMap.action_add_event(str_action, event)
	pass


# 设置动作的输入事件
func set_action_event(str_action: String, event: InputEvent) -> void:
	if not dict_custom_input_map.has(str_action):
		return
	
	if not InputMap.has_action(str_action):
		return
	
	if not (event is InputEventKey 
			or event is InputEventMouseButton 
			or event is InputEventJoypadButton 
			or event is InputEventJoypadMotion):
		return
	
	var arr_old_input_event : Array[InputEvent]
	var arr_input_event : Array[InputEvent] = InputMap.action_get_events(str_action)
	for temp_event : InputEvent in arr_input_event:
		if ((event is InputEventKey or event is InputEventMouseButton) 
				and (temp_event is InputEventKey or temp_event is InputEventMouseButton)):
			arr_old_input_event.append(temp_event)
		elif ((event.is_class("InputEventJoypadButton") or event.is_class("InputEventJoypadMotion")) 
				and (temp_event.is_class("InputEventJoypadButton") or temp_event.is_class("InputEventJoypadMotion"))):
			arr_old_input_event.append(temp_event)
	
	for old_input_event : InputEvent in arr_old_input_event:
		if old_input_event and InputMap.action_has_event(str_action, old_input_event):
			InputMap.action_erase_event(str_action, old_input_event)
	InputMap.action_add_event(str_action, event)
	
	var dict_event : Dictionary = get_dict_from_input_event(event)
	if dict_event.is_empty() or not dict_event.has(STRN_EVENT_TYPE):
		return
	
	var arr_old_dict_input_event : Array[Dictionary]
	var arr_dict_input_event : Array = dict_custom_input_map.get(str_action)
	for temp_dict_input_event : Dictionary in arr_dict_input_event:
		if not temp_dict_input_event.has(STRN_EVENT_TYPE):
			continue
		
		if ((dict_event.get(STRN_EVENT_TYPE) == EventType.INPUT_EVENT_KEY 
				or dict_event.get(STRN_EVENT_TYPE) == EventType.INPUT_EVENT_MOUSE_BUTTON) 
				and (temp_dict_input_event.get(STRN_EVENT_TYPE) == EventType.INPUT_EVENT_KEY 
				or temp_dict_input_event.get(STRN_EVENT_TYPE) == EventType.INPUT_EVENT_MOUSE_BUTTON)):
			arr_old_dict_input_event.append(temp_dict_input_event)
		elif ((dict_event.get(STRN_EVENT_TYPE) == EventType.INPUT_EVENT_JOYPAD_BUTTON 
				or dict_event.get(STRN_EVENT_TYPE) == EventType.INPUT_EVENT_JOYPAD_MOTION) 
				and (temp_dict_input_event.get(STRN_EVENT_TYPE) == EventType.INPUT_EVENT_JOYPAD_BUTTON 
				or temp_dict_input_event.get(STRN_EVENT_TYPE) == EventType.INPUT_EVENT_JOYPAD_MOTION)):
			arr_old_dict_input_event.append(temp_dict_input_event)
		
		if temp_dict_input_event.get(STRN_EVENT_TYPE) == dict_event.get(STRN_EVENT_TYPE):
			arr_old_dict_input_event.append(temp_dict_input_event)
	
	for old_dict_input_event : Dictionary in arr_old_dict_input_event:
		dict_custom_input_map[str_action].erase(old_dict_input_event)
	
	dict_custom_input_map[str_action].append(dict_event)
	pass


# 获取输入事件InputEvent从字典
func get_input_event_from_dict(dict_event: Dictionary) -> InputEvent:
	if not dict_event.has(STRN_EVENT_TYPE):
		return null
	
	var event : InputEvent
	match dict_event.get(STRN_EVENT_TYPE):
		EventType.INPUT_EVENT_KEY:
			if not dict_event.has(STRN_PHYSICAL_KEYCODE):
				return null
			event = InputEventKey.new()
			event.physical_keycode = dict_event.get(STRN_PHYSICAL_KEYCODE)
		EventType.INPUT_EVENT_MOUSE_BUTTON:
			if not dict_event.has(STRN_MOUSE_BUTTON_INDEX):
				return null
			event = InputEventMouseButton.new()
			event.button_index = dict_event.get(STRN_MOUSE_BUTTON_INDEX)
		EventType.INPUT_EVENT_JOYPAD_BUTTON:
			if not dict_event.has(STRN_JOY_BUTTON_INDEX):
				return null
			event = InputEventJoypadButton.new()
			event.button_index = dict_event.get(STRN_JOY_BUTTON_INDEX)
		EventType.INPUT_EVENT_JOYPAD_MOTION:
			if not dict_event.has(STRN_JOY_AXIS):
				return null
			event = InputEventJoypadMotion.new()
			event.axis = dict_event.get(STRN_JOY_AXIS)
		_:
			return null
	
	return event


# 获取输入事件的字典形式
func get_dict_from_input_event(event: InputEvent) -> Dictionary:
	var dict_event : Dictionary
	
	if event is InputEventKey:
		dict_event[STRN_EVENT_TYPE] = EventType.INPUT_EVENT_KEY
		dict_event[STRN_PHYSICAL_KEYCODE] = event.physical_keycode
	elif event is InputEventMouseButton:
		dict_event[STRN_EVENT_TYPE] = EventType.INPUT_EVENT_MOUSE_BUTTON
		dict_event[STRN_MOUSE_BUTTON_INDEX] = event.button_index
	elif event is InputEventJoypadButton:
		dict_event[STRN_EVENT_TYPE] = EventType.INPUT_EVENT_JOYPAD_BUTTON
		dict_event[STRN_JOY_BUTTON_INDEX] = event.button_index
	elif event is InputEventJoypadMotion:
		dict_event[STRN_EVENT_TYPE] = EventType.INPUT_EVENT_JOYPAD_MOTION
		dict_event[STRN_JOY_AXIS] = event.axis
	else:
		dict_event = {}
	
	return dict_event
