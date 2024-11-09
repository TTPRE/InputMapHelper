@tool
class_name PluginCreateInputManager extends Node


var editor_file_dialog : EditorFileDialog

func _enter_tree() -> void:
	editor_file_dialog = EditorFileDialog.new()
	self.add_child(editor_file_dialog)
	
	editor_file_dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	editor_file_dialog.get_line_edit().editable = false
	editor_file_dialog.get_line_edit().text = PluginIMHConfigHelper.INPUT_MANAGER_SCRIPT_NAME
	editor_file_dialog.disable_overwrite_warning = true
	editor_file_dialog.title = "Create Input Manager"
	editor_file_dialog.filters = PackedStringArray(["*.gd"]) 
	editor_file_dialog.confirmed.connect(create_input_manager)
	pass


func show_editor_file_dialog(id: int) -> void:
	if id != PluginIMHConfigHelper.ID_CREATE_INPUT_MANAGER:
		return
	
	editor_file_dialog.popup_file_dialog()
	pass


func create_input_manager() -> void:
	editor_file_dialog.get_line_edit().text = PluginIMHConfigHelper.INPUT_MANAGER_SCRIPT_NAME
	
	var file_r : FileAccess = FileAccess.open(editor_file_dialog.current_path, FileAccess.WRITE)
	file_r.store_line(PluginIMHConfigHelper.FILE_DATA_INPUT_MANAGER.format({"default_input_map":PluginIMHConfigHelper.get_default_input_map_str()}))
	file_r.close()
	
	EditorInterface.get_resource_filesystem().scan()
	
	var editor_plugin : EditorPlugin = EditorPlugin.new()
	editor_plugin.add_autoload_singleton("InputManager", editor_file_dialog.current_path)
	pass
