extends Node

enum INSTRUCTION_TYPES {KEYBOARD, JOYPAD}

@onready var demo_page_root: Control = $CanvasLayer/DemoPageRoot
@onready var resume_button: Button = $CanvasLayer/DemoPageRoot/Content/MarginContainer/Buttons/Resume
@onready var exit_button: Button = $CanvasLayer/DemoPageRoot/Content/MarginContainer/Buttons/Exit
@onready var keyboard_button: Button = %KeyboardButton
@onready var joypad_button: Button = %JoypadButton
@onready var grid_container_keyboard: GridContainer = %GridContainerKeyboard
@onready var grid_container_joypad: GridContainer = %GridContainerJoypad

var _stored_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_VISIBLE
## True while the intro or pause UI should treat Esc as "resume" (not open pause).
var _menu_open := true


func _ready() -> void:
	# Runs after Player etc.; ensure overlay is on-screen and readable.
	demo_page_root.visible = true
	demo_page_root.modulate = Color.WHITE
	_menu_open = true
	_stored_mouse_mode = Input.mouse_mode
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	resume_button.pressed.connect(resume_demo)
	exit_button.pressed.connect(get_tree().quit)
	keyboard_button.pressed.connect(change_instruction.bind(INSTRUCTION_TYPES.KEYBOARD))
	joypad_button.pressed.connect(change_instruction.bind(INSTRUCTION_TYPES.JOYPAD))

	if Input.get_connected_joypads().size() > 0:
		change_instruction(INSTRUCTION_TYPES.JOYPAD)
	else:
		change_instruction(INSTRUCTION_TYPES.KEYBOARD)


func _process(_delta: float) -> void:
	# Poll pause action so it still works when the tree is paused (PROCESS_MODE_ALWAYS on this node).
	if not Input.is_action_just_pressed("pause"):
		return
	if _menu_open:
		resume_demo()
	else:
		pause_demo()


func change_instruction(type: int) -> void:
	match type:
		INSTRUCTION_TYPES.KEYBOARD:
			keyboard_button.modulate.a = 1.0
			joypad_button.modulate.a = 0.3
			grid_container_keyboard.show()
			grid_container_joypad.hide()
		INSTRUCTION_TYPES.JOYPAD:
			keyboard_button.modulate.a = 0.3
			joypad_button.modulate.a = 1.0
			grid_container_keyboard.hide()
			grid_container_joypad.show()

	keyboard_button.release_focus()
	joypad_button.release_focus()


func pause_demo() -> void:
	_menu_open = true
	_stored_mouse_mode = Input.mouse_mode
	get_tree().paused = true
	demo_page_root.show()
	var tween := create_tween()
	tween.tween_property(demo_page_root, "modulate", Color.WHITE, 0.3)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func resume_demo() -> void:
	_menu_open = false
	get_tree().paused = false
	var tween := create_tween()
	tween.tween_property(demo_page_root, "modulate", Color.TRANSPARENT, 0.3)
	tween.tween_callback(demo_page_root.hide)
	Input.mouse_mode = _stored_mouse_mode
