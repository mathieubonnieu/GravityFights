extends CanvasLayer

enum TimeType { TIME_LIMIT, TIME_ELAPSED }

@onready var stopwatch := $StopwatchTimer
var time: int = 0
var time_type := TimeType.TIME_ELAPSED
var is_stage_started = false

func _ready() -> void:
	stopwatch.connect("timeout", _on_stopwatch_timeout)

func _on_start(start_time: int):
	time = start_time
	stopwatch.start()
	update_timer_label($StartTimeLabel, time)
	$TimeLabel.hide()

func _on_start_stage(start_time: int, new_time_type: TimeType) -> void:
	is_stage_started = true
	time = start_time
	self.time_type = new_time_type
	$StartTimeLabel.hide()
	update_timer_label($TimeLabel, time)
	$TimeLabel.show()

func _on_go_to_main_menu_pressed() -> void:
	GameManager.load_main_menu()

func _on_stopwatch_timeout():
	if !is_stage_started:
		if time > 0:
			time -= 1
			update_timer_label($StartTimeLabel, time)
	else:
		if self.time_type == TimeType.TIME_LIMIT:
			time -= 1
			if time <= 0:
				stopwatch.stop()
			else:
				update_timer_label($TimeLabel, time)
		else:
			time += 1
			update_timer_label($TimeLabel, time)

func update_timer_label(label, new_time: int):
	var str_time: String = str(new_time)

	if new_time > 60:
		str_time = "%o:%o" % [new_time / 60, new_time % 60]
	label.text = str_time

func _on_end_game_pressed() -> void:
	GameManager.load_end_game()
