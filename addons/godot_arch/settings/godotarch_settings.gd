@tool
class_name GodotArchSettings
extends RefCounted

# Liberately lifted from gdUnit4
# See: https://github.com/MikeSchulze/gdUnit4/blob/master/addons/gdUnit4/src/core/GdUnitSettings.gd

const MAIN_CATEGORY = "Godot-Arch"

const COMMON_SETTINGS = MAIN_CATEGORY + "/settings"

# General
const ADDON_FILE_PATH = "res://addons/godot_arch"
const BINARY_LOCATION = ADDON_FILE_PATH + "/bin"
const GROUP_GENERAL = COMMON_SETTINGS + "/general"
const RUN_ON_SAVE = GROUP_GENERAL + "/run_on_save"

const _VALUE_SET_SEPARATOR = "\f" # ASCII Form-feed character (AKA page break)

static func setup() -> void:
	create_property_if_need(RUN_ON_SAVE, false, "Execute on save")
	
static func get_setting(name: String, default: Variant) -> Variant:
	if ProjectSettings.has_setting(name):
		return ProjectSettings.get_setting(name)
	return default
	
static func create_property_if_need(name: String, default: Variant, help := "", value_set := PackedStringArray()) -> void:
	if not ProjectSettings.has_setting(name):
		ProjectSettings.set_setting(name, default)

	ProjectSettings.set_initial_value(name, default)
	help = help if value_set.is_empty() else "%s%s%s" % [help, _VALUE_SET_SEPARATOR, value_set]
	set_help(name, default, help)
	
static func set_help(property_name: String, value: Variant, help: String) -> void:
	ProjectSettings.add_property_info({
		"name": property_name,
		"type": typeof(value),
		"hint": PROPERTY_HINT_TYPE_STRING,
		"hint_string": help
	})
