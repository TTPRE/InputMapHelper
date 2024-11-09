extends Node

const setting_file_path : String = "user://setting.ini"

var setting_data : SetData = SetData.new()


func _enter_tree() -> void:
	load_setting_config_data()
	pass


func _exit_tree() -> void:
	save_setting_config_data()
	pass


# 加载设置配置信息
func load_setting_config_data() -> void:
	var setting_file : ConfigFile = ConfigFile.new()
	var err : Error = setting_file.load(setting_file_path)
	if err != OK:
		return
	
	if setting_file.has_section_key("setting", "dict_input_map"):
		setting_data.dict_input_map = Dictionary(setting_file.get_value("setting", "dict_input_map"))
	
	pass


# 保存设置配置信息
func save_setting_config_data() -> void:
	var setting_file : ConfigFile = ConfigFile.new()
	
	setting_file.set_value("setting", "dict_input_map", setting_data.dict_input_map)
	
	setting_file.save(setting_file_path)
	pass
