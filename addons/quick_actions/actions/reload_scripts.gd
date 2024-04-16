const label = "Reload scripts"
const key: Key = KEY_R

func run(plugin: QuickActions, menu: PopupMenu, id: int):
	plugin.unload_scripts()
	plugin.load_scripts()
