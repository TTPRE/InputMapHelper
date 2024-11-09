@tool
class_name PluginUpdateDefaultInputMap extends Node


var editor_file_dialog : EditorFileDialog

func _enter_tree() -> void:
	editor_file_dialog = EditorFileDialog.new()
	self.add_child(editor_file_dialog)
	
	editor_file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	editor_file_dialog.get_line_edit().editable = false
	editor_file_dialog.disable_overwrite_warning = true
	editor_file_dialog.title = "Update Default Input Map"
	editor_file_dialog.filters = PackedStringArray(["*.gd"]) 
	editor_file_dialog.confirmed.connect(update_default_input_map)
	pass


func show_editor_file_dialog(id: int) -> void:
	if id != PluginIMHConfigHelper.ID_UPDATE_DEFAULT_INPUT_MAP:
		return
	
	editor_file_dialog.popup_file_dialog()
	pass


func update_default_input_map() -> void:
	if editor_file_dialog.current_file != PluginIMHConfigHelper.INPUT_MANAGER_SCRIPT_NAME:
		return
	
	var file_r : FileAccess = FileAccess.open(editor_file_dialog.current_path, FileAccess.READ)
	var str_file_data = file_r.get_as_text()
	file_r.close()
	
	var str_old_input_map : String = ""
	var input_map_regex : RegEx = RegEx.new()
	input_map_regex.compile("const DICT_DEFAULT_INPUT_MAP : Dictionary[\\s\\S]*?\n}")
	var reg_ex_match_input_map : RegExMatch = input_map_regex.search(str_file_data)
	if reg_ex_match_input_map:
		str_old_input_map = reg_ex_match_input_map.get_string()
	
	if str_old_input_map.is_empty():
		return
	
	str_file_data = str_file_data.replace(str_old_input_map, PluginIMHConfigHelper.get_default_input_map_str())
	
	var file_w : FileAccess = FileAccess.open(editor_file_dialog.current_path, FileAccess.WRITE)
	file_w.store_line(str_file_data)
	file_w.close()
	
	EditorInterface.get_resource_filesystem().scan()
	pass
