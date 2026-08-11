extends CanvasLayer

const MAX_STUDENT_NAME_LENGTH := 50
const GLOBAL_UI_LAYER := 100
const DEFAULT_FONT_SIZE := 10
const MIN_FONT_SIZE := 7
const HORIZONTAL_SAFE_MARGIN := 32.0

@onready var name_plate: PanelContainer = $TopCenter/NamePlate
@onready var student_name_label: Label = $TopCenter/NamePlate/Margin/StudentName

var _student_name := ""


func _ready() -> void:
	layer = GLOBAL_UI_LAYER
	get_viewport().size_changed.connect(_fit_label_to_viewport)
	clear_student()


func show_student(student_name: String) -> void:
	var clean_name := student_name.strip_edges()
	if clean_name.is_empty() or clean_name.length() > MAX_STUDENT_NAME_LENGTH:
		clear_student()
		return

	_student_name = clean_name
	student_name_label.text = "Aluno: %s" % clean_name
	visible = true
	_fit_label_to_viewport()


func clear_student() -> void:
	_student_name = ""
	visible = false


func get_student_name() -> String:
	return _student_name


func _fit_label_to_viewport() -> void:
	if not visible or student_name_label == null:
		return

	var available_width := maxf(160.0, get_viewport().get_visible_rect().size.x - HORIZONTAL_SAFE_MARGIN)
	var font := student_name_label.get_theme_font("font")
	var font_size := DEFAULT_FONT_SIZE
	while font_size > MIN_FONT_SIZE and font.get_string_size(student_name_label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x + 28.0 > available_width:
		font_size -= 1
	student_name_label.add_theme_font_size_override("font_size", font_size)
	name_plate.custom_minimum_size.x = minf(190.0, available_width)
