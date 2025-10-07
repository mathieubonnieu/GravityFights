extends Node

# Stages scenes
@export var stage_scenes := ["res://Scenes/GameScene.tscn"]
@export var game_end_scene := "res://Scenes/GameEndScene.tscn"
@export var main_menu_scene := "res://Scenes/MainMenu.tscn"

# Game Settings
var game_settings : GameSettings

# Game State
var curr_stage_nbr := 0
var players : Array[Player]

# Functions
func _ready():
	randomize()

"""
Takes a `GameSettings` class instance and load the game accordingly
"""
func launch_game(settings : GameSettings):
	assert(len(players) != 0, "no player defined")
	self.game_settings = settings
	var stage_scene_index := randi_range(0, len(stage_scenes) - 1)

	get_tree().change_scene_to_file(stage_scenes[stage_scene_index]) # The settings are loaded by the StageManager when the scene is loaded
	return

func load_main_menu():
	get_tree().change_scene_to_file(main_menu_scene)

func load_end_game():
	get_tree().change_scene_to_file(game_end_scene)
	return

func add_player(player: Player):
	player.player_id = len(players)
	self.players.append(player)
	print("player {playerId} added".format({"playerId": player.player_id}))

func has_device(device_id: int) -> bool:
	for player in players:
		if player.device_id == device_id:
			return true
	return false

# Events
func on_stage_end(winned_id: int):
	curr_stage_nbr += 1
	match game_settings.game_end_condition:
		game_settings.GameEndCondition.FIXED_STAGES_NUMBER:
			if curr_stage_nbr >= game_settings.stages_limit:
				load_end_game()
				return
		game_settings.GameEndCondition.KILL_NUMBER:
			for player in players:
				if player.game_enemies_killed_nbr >= game_settings.kills_limit:
					load_end_game()
					return
		game_settings.GameEndCondition.STAGE_WIN_NUMBER:
			if players[winned_id].game_stage_wins_nbr >= game_settings.stage_wins_limit:
				load_end_game()
				return
	var stage_scene_index := randi_range(0, len(stage_scenes) - 1)
	get_tree().change_scene_to_file.bind(stage_scenes[stage_scene_index]).call_deferred()
	return
