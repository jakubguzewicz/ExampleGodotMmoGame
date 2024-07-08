extends Button

signal log_in_pressed(username: String, password: String)

@onready var username_line_edit = $UsernameLineEdit
@onready var password_line_edit = $PasswordLineEdit

func _input(event):
	if event.is_action_pressed("ui_text_submit"):
		if password_line_edit.has_focus() or self.has_focus():
			self.pressed.emit()

func _on_pressed():
	password_line_edit.select_all()
	password_line_edit.grab_focus()
	log_in_pressed.emit(username_line_edit.text, password_line_edit.text)
