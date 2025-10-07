extends Node

var game_settings : GameSettings

@export var gameEndConditionGroup: ButtonGroup
@export var stageEndConditionGroup: ButtonGroup
@export var stageGameModeGroup: ButtonGroup
@export var stageLifeModeGroup: ButtonGroup

@export var menu_pages: Array[Node]
var curr_page_index := 0

func _ready() -> void:
	assert(len(menu_pages) > 0, "No menu pages")
	assert(gameEndConditionGroup != null, "No game end condition group")
	assert(stageEndConditionGroup != null, "No stage end condition group")
	assert(stageGameModeGroup != null, "No stage game mode group")
	assert(stageLifeModeGroup != null, "No stage life mode group")
	game_settings = GameSettings.new()
	update_gui_game_settings(game_settings)
	update_gui_stage_settings(game_settings.stage_settings)
	gameEndConditionGroup.connect("pressed", _on_game_end_condition_button_pressed)
	stageEndConditionGroup.connect("pressed", _on_stage_end_condition_button_pressed)
	stageGameModeGroup.connect("pressed", _on_stage_game_mode_button_pressed)
	stageLifeModeGroup.connect("pressed", _on_stage_life_mode_button_pressed)
	for player in GameManager.players:
		spawn_player(player.device_id, player.player_id)

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton:
		if not GameManager.has_device(event.device):
			add_player_with_device(event.device)
	if event is InputEventKey:
		match event.as_text_key_label():
			"Z", "Q", "S", "D", "Space":
				if not GameManager.has_device(-1):
					add_player_with_device(-1)
			"Up", "Left", "Down", "Right", "Ctrl":
				if not GameManager.has_device(-2):
					add_player_with_device(-2)

func add_player_with_device(device: int) -> void:
	var player = Player.new()

	player.device_id = device
	GameManager.add_player(player)
	spawn_player(device, player.player_id)

func spawn_player(device: int, player_id: int) -> void:
	var player_instance = load("res://Prefabs/Player.tscn").instantiate()

	$Players.add_child(player_instance)
	player_instance.set_device_id(device)
	player_instance.set_player_id(player_id)
	player_instance.position.x = (int($Players/SpawnPoint.position.x) + 50 * device) % DisplayServer.screen_get_size().x
	player_instance.position.y = (int($Players/SpawnPoint.position.y) + 50 * device) % DisplayServer.screen_get_size().y

func _on_launch_game_button_pressed() -> void:
	if (len(GameManager.players) < 2):
		$ColorRect/Launcher/MarginContainer/VBoxContainer/Warning.show()
		return
	$ColorRect/Launcher/MarginContainer/VBoxContainer/Warning.hide()
	GameManager.launch_game(game_settings)

func update_gui_game_settings(game_settings: GameSettings):
	var game_end_condition: String = game_settings.GameEndCondition.keys()[game_settings.game_end_condition].to_pascal_case()
	var game_end_condition_button: CheckBox = $ColorRect/GameSettings/MarginContainer/VBoxContainer.get_node(game_end_condition)
	assert(game_end_condition_button != null, "game_end_condition_button is null")
	game_end_condition_button.set_pressed(true)
	update_game_end_condition(game_end_condition)

	($ColorRect/GameSettings/MarginContainer/VBoxContainer/StagesLimit as SpinBox).set_value_no_signal(game_settings.stages_limit)
	($ColorRect/GameSettings/MarginContainer/VBoxContainer/KillsLimit as SpinBox).set_value_no_signal(game_settings.kills_limit)
	($ColorRect/GameSettings/MarginContainer/VBoxContainer/StagesWinLimit as SpinBox).set_value_no_signal(game_settings.stage_wins_limit)

func update_gui_stage_settings(stage_settings: StageSettings):
	var stage_life_mode: String = stage_settings.LifeMode.keys()[stage_settings.life_mode].to_pascal_case()
	var stage_life_mode_button: CheckBox = $ColorRect/StageSettings/MarginContainer/VBoxContainer.get_node(stage_life_mode)
	assert(stage_life_mode_button != null, "stage_life_mode_button is null")
	stage_life_mode_button.set_pressed(true)
	update_stage_life_mode(stage_life_mode)

	var stage_end_condition: String = stage_settings.StageEndCondition.keys()[stage_settings.stage_end_condition].to_pascal_case()
	var stage_end_condition_button: CheckBox = $ColorRect/StageSettings/MarginContainer/VBoxContainer.get_node(stage_end_condition)
	assert(stage_end_condition_button != null, "stage_end_condition_button is null")
	stage_end_condition_button.set_pressed(true)
	update_stage_end_condition(stage_end_condition)

	var stage_game_mode: String = stage_settings.GameMode.keys()[stage_settings.game_mode].to_pascal_case()
	var stage_game_mode_button: CheckBox = $ColorRect/StageSettings/MarginContainer/VBoxContainer.get_node(stage_game_mode)
	assert(stage_game_mode_button != null, "stage_game_mode_button is null")
	stage_game_mode_button.set_pressed(true)
	update_stage_game_mode(stage_game_mode)

	_on_lives_per_player_value_changed(stage_settings.lives_per_player)
	($ColorRect/StageSettings/MarginContainer/VBoxContainer/LivesPerPlayer as SpinBox).set_value_no_signal(stage_settings.lives_per_player)
	($ColorRect/StageSettings/MarginContainer/VBoxContainer/LivesPerTeam as SpinBox).set_value_no_signal(stage_settings.lives_per_team)
	($ColorRect/StageSettings/MarginContainer/VBoxContainer/SetKillLimit as SpinBox).set_value_no_signal(stage_settings.kill_limit)
	($ColorRect/StageSettings/MarginContainer/VBoxContainer/SetTimeLimit as SpinBox).set_value_no_signal(stage_settings.time_limit)

func _on_next_button_pressed() -> void:
	assert(curr_page_index < len(menu_pages) - 1, "No next page")
	menu_pages[curr_page_index].hide()
	curr_page_index += 1
	menu_pages[curr_page_index].show()

func _on_back_button_pressed() -> void:
	assert(curr_page_index > 0, "No previous page")
	menu_pages[curr_page_index].hide()
	curr_page_index -= 1
	menu_pages[curr_page_index].show()

func _on_game_end_condition_button_pressed(button: Button) -> void:
	var game_end_condition = button.name
	update_game_end_condition(button.name)

func update_game_end_condition(game_end_condition: String) -> void:
	$ColorRect/GameSettings/MarginContainer/VBoxContainer/StagesLimit.hide()
	$ColorRect/GameSettings/MarginContainer/VBoxContainer/KillsLimit.hide()
	$ColorRect/GameSettings/MarginContainer/VBoxContainer/StagesWinLimit.hide()

	match game_end_condition:
		"KillNumber":
			game_settings.game_end_condition = GameSettings.GameEndCondition.KILL_NUMBER
			$ColorRect/GameSettings/MarginContainer/VBoxContainer/KillsLimit.show()
		"StageWinNumber":
			game_settings.game_end_condition = GameSettings.GameEndCondition.STAGE_WIN_NUMBER
			$ColorRect/GameSettings/MarginContainer/VBoxContainer/StagesWinLimit.show()
		"FixedStageNumber":
			game_settings.game_end_condition = GameSettings.GameEndCondition.FIXED_STAGES_NUMBER
			$ColorRect/GameSettings/MarginContainer/VBoxContainer/StagesLimit.show()
		"UserInput":
			game_settings.game_end_condition = GameSettings.GameEndCondition.USER_INPUT

func _on_stage_game_mode_button_pressed(button: Button) -> void:
	var stage_game_mode = button.name
	update_stage_life_mode(stage_game_mode)

func update_stage_game_mode(stage_game_mode: String) -> void:
	match stage_game_mode:
		"FreeForAll":
			game_settings.stage_settings.game_mode = StageSettings.GameMode.FREE_FOR_ALL
		"Teams":
			game_settings.stage_settings.game_mode = StageSettings.GameMode.TEAMS

func _on_stage_life_mode_button_pressed(button: Button) -> void:
	var stage_life_mode = button.name
	update_stage_life_mode(stage_life_mode)

func update_stage_life_mode(stage_life_mode: String) -> void:
	$ColorRect/StageSettings/MarginContainer/VBoxContainer/LivesPerPlayer.hide()
	$ColorRect/StageSettings/MarginContainer/VBoxContainer/LivesPerTeam.hide()
	($ColorRect/StageSettings/MarginContainer/VBoxContainer/KillLimit as BaseButton).set_disabled(false)
	($ColorRect/StageSettings/MarginContainer/VBoxContainer/TimeLimit as BaseButton).set_disabled(false)
	($ColorRect/StageSettings/MarginContainer/VBoxContainer/LastStanding as BaseButton).set_disabled(false)

	match stage_life_mode:
		"OneLife":
			game_settings.stage_settings.life_mode = StageSettings.LifeMode.ONE_LIFE
			if ($ColorRect/StageSettings/MarginContainer/VBoxContainer/KillLimit as BaseButton).button_pressed \
			or ($ColorRect/StageSettings/MarginContainer/VBoxContainer/TimeLimit as BaseButton).button_pressed :
				($ColorRect/StageSettings/MarginContainer/VBoxContainer/LastStanding as BaseButton).button_pressed = true
				_on_stage_end_condition_button_pressed($ColorRect/StageSettings/MarginContainer/VBoxContainer/LastStanding)
			($ColorRect/StageSettings/MarginContainer/VBoxContainer/KillLimit as BaseButton).set_disabled(true)
			($ColorRect/StageSettings/MarginContainer/VBoxContainer/TimeLimit as BaseButton).set_disabled(true)
		"MultipleLives":
			game_settings.stage_settings.life_mode = StageSettings.LifeMode.MULTIPLE_LIVES
			$ColorRect/StageSettings/MarginContainer/VBoxContainer/LivesPerPlayer.show()
			_on_lives_per_player_value_changed(game_settings.stage_settings.lives_per_player)
		"InfiniteLives":
			game_settings.stage_settings.life_mode = StageSettings.LifeMode.INFINITE_LIVES
			if ($ColorRect/StageSettings/MarginContainer/VBoxContainer/LastStanding as BaseButton).button_pressed :
				($ColorRect/StageSettings/MarginContainer/VBoxContainer/KillLimit as BaseButton).button_pressed = true
				_on_stage_end_condition_button_pressed($ColorRect/StageSettings/MarginContainer/VBoxContainer/KillLimit)
			($ColorRect/StageSettings/MarginContainer/VBoxContainer/LastStanding as BaseButton).set_disabled(true)

func _on_stage_end_condition_button_pressed(button: Button) -> void:
	var stage_end_condition = button.name
	update_stage_end_condition(stage_end_condition)

func update_stage_end_condition(stage_end_condition: String) -> void:
	$ColorRect/StageSettings/MarginContainer/VBoxContainer/SetKillLimit.hide()
	$ColorRect/StageSettings/MarginContainer/VBoxContainer/SetTimeLimit.hide()

	match stage_end_condition:
		"LastStanding":
			game_settings.stage_settings.stage_end_condition = StageSettings.StageEndCondition.LAST_STANDING
		"KillLimit":
			game_settings.stage_settings.stage_end_condition = StageSettings.StageEndCondition.KILL_LIMIT
			$ColorRect/StageSettings/MarginContainer/VBoxContainer/SetKillLimit.show()
		"TimeLimit":
			game_settings.stage_settings.stage_end_condition = StageSettings.StageEndCondition.TIME_LIMIT
			$ColorRect/StageSettings/MarginContainer/VBoxContainer/SetTimeLimit.show()
		"UserInput":
			game_settings.stage_settings.stage_end_condition = StageSettings.StageEndCondition.USER_INPUT

func _on_stages_limit_value_changed(value: float) -> void:
	game_settings.stages_limit = roundi(value)


func _on_kills_limit_value_changed(value: float) -> void:
	game_settings.kills_limit = roundi(value)


func _on_stages_win_limit_value_changed(value: float) -> void:
	game_settings.stage_wins_limit = roundi(value)


func _on_lives_per_player_value_changed(value: float) -> void:
	game_settings.stage_settings.lives_per_player = roundi(value)
	if !game_settings.stage_settings.life_mode == StageSettings.LifeMode.INFINITE_LIVES:
		($ColorRect/StageSettings/MarginContainer/VBoxContainer/SetKillLimit as SpinBox).max_value = roundi(value)


func _on_lives_per_team_value_changed(value: float) -> void:
	game_settings.stage_settings.lives_per_team = roundi(value)


func _on_set_kill_limit_value_changed(value: float) -> void:
	game_settings.stage_settings.kill_limit = roundi(value)


func _on_set_time_limit_value_changed(value: float) -> void:
	game_settings.stage_settings.time_limit = roundi(value)
