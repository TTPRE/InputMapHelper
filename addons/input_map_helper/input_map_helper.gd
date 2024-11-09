##----------------------------------------------------##
##   #######     #######      #######      #######    ##
##  ##     ##  ##       ##  ##       ##  ##       ##  ##
##         ##  ##       ##  ##       ##  ##       ##  ##
##   #######   ##       ##  ##       ##  ##       ##  ##
##  ##         ##       ##  ##       ##  ##       ##  ##
##  ##         ##       ##  ##       ##  ##       ##  ##
##  #########    #######      #######      #######    ##
##----------------------------------------------------##
## @Description: 输入映射插件，生成输入管理者脚本来控制输入映射
## 
## 1.生成输入管理器脚本
## 项目 -> 工具 -> Input Map Helper -> Create Input Manager
## 选择 input_manager.gd 生成路径生成该脚本
## 请自行实现该脚本中的函数 init_input_map_from_setting() 和函
## 数 save_input_map_to_setting()
## 
## 2.跟新默认输入映射
## 项目 -> 工具 -> Input Map Helper -> Update Default Input Map
## 根据项目设置中的输入映射更新所选路径的 input_manager.gd 脚本中的 
## DICT_DEFAULT_INPUT_MAP 常量
##
## *注:
##  ①.键盘按键是基于键盘中按键的物理位置，在项目设置时注意切换为物理按键
##     在项目自定义按键设置时也确保获取的是物理按键
##  ②.确保 input_manager.gd 单例初始化时晚于持久化初始化，保证正确
##     初始化修改后的输入映射
##  ③.自行实现生成脚本中的两个函数 init_input_map_from_setting() 
##     和 save_input_map_to_setting()
##----------------------------------------------------##
## @Auther: 2000
## @Date: 2024-11-08
## @LastEditTime: 2024-11-09
## @Tags: 输入, InputMap, 自定义按键
## @Version: 1.0.0
## @License: MIT license
## @ContactInformation:
##----------------------------------------------------##
@tool
extends EditorPlugin


var plugin_create_input_manager : PluginCreateInputManager
var plugin_update_default_input_map : PluginUpdateDefaultInputMap

func _enter_tree() -> void:
	initialize()
	add_tool_menu()
	print("Enable InputMapHelper")
	pass


func _exit_tree() -> void:
	remove_tool_menu()
	destroy()
	print("Disable InputMapHelper")
	pass


func initialize() -> void:
	plugin_create_input_manager = PluginCreateInputManager.new()
	self.add_child(plugin_create_input_manager)
	
	plugin_update_default_input_map = PluginUpdateDefaultInputMap.new()
	self.add_child(plugin_update_default_input_map)
	pass


func destroy() -> void:
	plugin_create_input_manager.free()
	plugin_update_default_input_map.free()
	pass


func add_tool_menu() -> void:
	var popup_menu_config_table_csv : PopupMenu = PopupMenu.new()
	
	popup_menu_config_table_csv.add_item("Create Input Manager", PluginIMHConfigHelper.ID_CREATE_INPUT_MANAGER)
	popup_menu_config_table_csv.id_pressed.connect(plugin_create_input_manager.show_editor_file_dialog)
	
	popup_menu_config_table_csv.add_item("Update Default Input Map", PluginIMHConfigHelper.ID_UPDATE_DEFAULT_INPUT_MAP)
	popup_menu_config_table_csv.id_pressed.connect(plugin_update_default_input_map.show_editor_file_dialog)
	
	add_tool_submenu_item("Input Map Helper", popup_menu_config_table_csv)
	pass


func remove_tool_menu() -> void:
	remove_tool_menu_item("Input Map Helper")
	pass
