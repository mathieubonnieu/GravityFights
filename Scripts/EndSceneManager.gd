extends Node


func _on_go_to_main_menu_timer_timeout() -> void:
	GameManager.load_main_menu()
