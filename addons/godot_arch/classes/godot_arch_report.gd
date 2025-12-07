class_name GodotArchReport

var files_checked: int
var files_failed: int
var warnings: Array[GodotArchWarning]
var failed_reports: Array[GodotArchReportEntry]
var successful_reports: Array[GodotArchReportEntry]

static func from_json(json: Dictionary) -> GodotArchReport:
	var report := GodotArchReport.new()
	
	if not json.has("files_checked") or json.files_checked is not float:
		push_error("Malformed JSON Output: Files Checked")
		return
	report.files_checked = json.files_checked
	
	if not json.has("files_failed") or json.files_failed is not float:
		push_error("Malformed JSON Output: Files Failed")
		return
	report.files_failed = json.files_failed

	if not json.has("warnings") or json.warnings is not Array:
		push_error("Malformed JSON Output: Warnings")
		return
	for warning in json.warnings:
		var arch_warning := GodotArchWarning.from_json(warning)
		if not arch_warning:
			return
		report.warnings.push_back(arch_warning)
		
	for entry in json.failed_reports:
		var failed_report := GodotArchReportEntry.from_json(entry)
		if not failed_report:
			return
		report.failed_reports.push_back(failed_report)
			
	for entry in json.successful_reports:
		var successful_report := GodotArchReportEntry.from_json(entry)
		if not successful_report:
			return
		report.successful_reports.push_back(successful_report)
	return report
