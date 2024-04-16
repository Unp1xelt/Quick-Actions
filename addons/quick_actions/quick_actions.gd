@tool
class_name QuickActions
extends EditorPlugin

## Hotkey/Shortcut for open the quick action menu.
const QUICK_ACTION_KEY: Key = KEY_F3

var _menu: PopupMenu
var _scripts: Dictionary = {}

func _enter_tree() -> void:
	_menu = PopupMenu.new()
	_menu.allow_search = false
	_menu.theme = preload("res://addons/quick_actions/theme.tres")
	_menu.id_pressed.connect(func(id: int): _item_clicked(_menu, id))
	_menu.window_input.connect(func(event: InputEvent): _handle_hotkeys(_menu, event))
	_menu.submenu_popup_delay = 0.1
	
	add_child(_menu)
	load_scripts()


func _exit_tree() -> void:
	unload_scripts()
	_menu.queue_free()


## Loads the scripts and adds them to the quickmenu. 
## This method is automatically run on activating the plugin.[br][br]
## The [param path] is where scripts and underlying subfolders are searched for.
## The [b]default[/b] value of the [param menu] is the quickmenu. 
## When a subfolder is found this is used as a submenu.
## The [param id] argument keeps track of the current id count for the menus.
func load_scripts(path: String = "", menu: PopupMenu = _menu, id: int = 0) -> int: 
	var dir := DirAccess.open("res://addons/quick_actions/actions/" + path)
	if dir:
		# Folders are converted to submenus
		for directory in dir.get_directories():
			var submenu = PopupMenu.new()
			submenu.name = directory
			submenu.allow_search = false
			submenu.id_pressed.connect(func(_id: int): _item_clicked(submenu, _id))
			submenu.window_input.connect(func(event: InputEvent): _handle_hotkeys(submenu, event))
			
			id += 1
			menu.add_submenu_item(directory, directory, id)
			menu.add_child(submenu)
			
			id = load_scripts(path + "/" + directory, submenu, id)
		
		for file in dir.get_files():
			# Only load gd scripts
			if file.get_extension() == 'gd':
				var script_path: String = dir.get_current_dir() + "/" + file
				var script = load(script_path).new()
				
				if script.has_method("run"): # Add script if it has the run method
					id += 1
					
					if script.has_method("init_menu"): # Init menu item self
						script.init_menu(self, menu, id)
					else:
						var label = file
						var key := 0
						
						if "label" in script:
							label = script.label
						
						if "key" in script:
							key = script.key
						
						menu.add_item(label, id, key)
					
					_scripts[id] = script
				else:
					push_warning("Not found init or run method in script: " + script_path)
	
	return id


## Unloads all scripts and removes every item from the quickmenu.
## All resources will automatically be freed.
func unload_scripts() -> void:
	_scripts.clear()
	_menu.clear(true)


func _item_clicked(menu: PopupMenu, id: int) -> void: 
	_scripts[id].run(self, menu, id)


func _handle_hotkeys(menu: PopupMenu, event: InputEvent) -> void:
	if event.is_released():
		menu.activate_item_by_event(event)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_released():
			if event.keycode == QUICK_ACTION_KEY:
				var viewport = EditorInterface.get_editor_viewport_3d()
				var view_size = Rect2(Vector2.ZERO, viewport.size)
				var mouse_pos = viewport.get_mouse_position()
				
				if view_size.has_point(mouse_pos):
					_menu.position = Vector2i(EditorInterface.get_base_control().get_screen_position() + viewport.get_screen_transform().get_origin() + mouse_pos)
					_menu.show()
