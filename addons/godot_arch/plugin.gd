@tool
extends EditorPlugin

var inspector_panel: GodotArchInspector

func _enter_tree():
	_setup_ui()
	_setup_settings()
	
	get_editor_interface().get_resource_filesystem().filesystem_changed.connect(on_filesystem_changed)
	
	resource_saved.connect(on_resource_saved)
	
func _exit_tree():
	_remove_ui()
	_remove_settings()
	
signal report_generated(report: GodotArchReport)
	
func on_resource_saved(resource: Resource) -> void:
	if GodotArchSettings.get_setting(GodotArchSettings.RUN_ON_SAVE, false):
		execute_godotarch()
		
func on_filesystem_changed() -> void:
	# Hier ggf. neue Setting mit "run on filesystem change" etc
	if GodotArchSettings.get_setting(GodotArchSettings.RUN_ON_SAVE, false):
		execute_godotarch()
		
func execute_godotarch() -> void:
	var executable_name: String;
	match OS.get_name():
		"Windows":
			executable_name = "godot-arch.exe"
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			executable_name = "godot-arch"
		_:
			push_error("godot-arch is only supported on Windows and Linux")
			return
			
	var file_path: String = ProjectSettings.globalize_path(GodotArchSettings.BINARY_LOCATION + "/" + executable_name)
	var path_to_report_location = ProjectSettings.globalize_path(GodotArchSettings.ADDON_FILE_PATH + "/report")
	var path_to_report_file = ProjectSettings.globalize_path(GodotArchSettings.ADDON_FILE_PATH + "/report" + "/godot-arch-report.json")
	var path_to_project_root: String = ProjectSettings.globalize_path("res://")
	var path_to_configuration_file: String = ProjectSettings.globalize_path("res://godot-arch.config.yaml")
	
	print("Running godot-arch ...")
	
	if FileAccess.file_exists(path_to_report_file):
		DirAccess.remove_absolute(path_to_report_file)
	
	if not FileAccess.file_exists(file_path):
		push_error("Binary file for godot arch was not found at " + file_path)
		return
	if not FileAccess.file_exists(path_to_configuration_file):
		push_error("Unable to locate configuration file at " + path_to_configuration_file)
		return
	var exit_code = OS.execute(file_path,
		[
			"-p", path_to_project_root,
			"--report", path_to_report_location,
			"-c", path_to_configuration_file
		]
	)

	handle_exit_codes(exit_code)

	# Dont continue when we didn't exit gracefully
	if exit_code > 1: return

	if not FileAccess.file_exists(path_to_report_file):
		push_error("Unable to locate report file at " + path_to_report_file)
		return
	var json_output: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path_to_report_file))
	var report := GodotArchReport.from_json(json_output)
	if report:
		report_generated.emit(report)
	
func _setup_ui():
	inspector_panel = (load("res://addons/godot_arch/controls/inspector/godot_arch_inspector.tscn") as PackedScene).instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, inspector_panel)
	inspector_panel.execute_button.pressed.connect(execute_godotarch)
	report_generated.connect(inspector_panel.update_from_report_data)

func handle_exit_codes(error_code: int):
	match (error_code):
		0: print("Succesfully executed godot-arch without check failures! 🎉");
		1: print("Succesfully executed godot-arch with check failures. 🚩");
		# TODO: Could add a setting to optionally print the stdout to the console to show handled errors
		2: push_error("There was a handled error running godot-arch.")
		# Special Cases
		126:
			if ["Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD"].has(OS.get_name()):
				push_error("Unable to execute godot-arch binary due to missing permissions. Running `chmod +x ./addons/godot_arch/bin/godot-arch` may resolve this issue.");
		_: push_error("There was an unhandled error running godot-arch.")

func _remove_ui():
	if inspector_panel:
		report_generated.disconnect(inspector_panel.update_from_report_data)
		remove_control_from_docks(inspector_panel)
		inspector_panel.queue_free()
		inspector_panel = null
		
func _setup_settings():
	GodotArchSettings.setup()
	
func _remove_settings():
	pass
