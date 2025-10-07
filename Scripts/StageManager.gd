extends Node

var player_scene: PackedScene = preload("res://Prefabs/Player.tscn")
@export var spawn_points : Array[Node]

const START_TIME = 3
const PROJECTILE_DISTANCE = 50
const PROJECTILE_VELOCITY = 1000

# Stage configuration
var stage_settings : StageSettings

# Stage state
var players : Array[Player]
var players_standing_nbr : int

@onready var max_stage_timer := $MaxStageTimer
@onready var start_timer := $StartTimer

func _ready():
	self.stage_settings = GameManager.game_settings.stage_settings
	self.players = GameManager.players
	self.players_standing_nbr = len(self.players)
	load_stage()

func start_stage():
	if self.stage_settings.stage_end_condition == StageSettings.StageEndCondition.TIME_LIMIT:
		max_stage_timer.wait_time = self.stage_settings.time_limit
		$GUI._on_start_stage(self.stage_settings.time_limit, $GUI.TimeType.TIME_LIMIT)
		max_stage_timer.connect("timeout", end_stage_by_kills)
		max_stage_timer.start()
	else:
		$GUI._on_start_stage(0, $GUI.TimeType.TIME_ELAPSED)
	for player in players:
		player.instance.is_freeze = false;
	print("stage started")

func load_stage():
	$GUI._on_start(START_TIME)
	start_timer.connect("timeout", start_stage)
	start_timer.start(START_TIME)
	for player in players:
		spawn_player(player.player_id)
		player.instance.is_freeze = true
	return

func spawn_player(player_id: int):
	assert(player_id < len(spawn_points), "player_id [%d] is out of spawn_points scope"%player_id)
	var player = player_scene.instantiate()
	player.set_deferred("position", spawn_points[player_id].position)

	$Players.call_deferred("add_child", player)
	players[player_id].instance = player
	players[player_id].instance.set_device_id(players[player_id].device_id)
	players[player_id].instance.set_player_id(players[player_id].player_id)
	player.connect("shoot", _on_player_shoot)
	return

func end_stage_by_kills():
	var max_kills = 0
	var max_kills_id = 0

	for player in players:
		if player.stage_enemies_killed_nbr > max_kills:
			max_kills = player.stage_enemies_killed_nbr
			max_kills_id = player.player_id
	end_stage(max_kills_id)

func end_stage(winned_id: int):
	for player in players:
		player.game_death_nbr += player.stage_death_nbr
		player.game_enemies_killed_nbr += player.stage_enemies_killed_nbr
		player.stage_death_nbr = 0
		player.stage_enemies_killed_nbr = 0
		if player.player_id == winned_id:
			player.game_stage_wins_nbr += 1
		player.instance = null
	GameManager.on_stage_end(winned_id)

func _on_player_shoot(bullet_prefab: PackedScene, direction: float, location: Vector2, player_id: int):
	var spawned_bullet = bullet_prefab.instantiate()

	add_child(spawned_bullet)
	spawned_bullet.shooter_id = player_id
	spawned_bullet.rotation = direction
	spawned_bullet.position = location + Vector2(PROJECTILE_DISTANCE, 0).rotated(direction - PI / 2)
	spawned_bullet.linear_velocity = Vector2(PROJECTILE_VELOCITY, 0).rotated(direction - PI / 2)
	spawned_bullet.connect("kill_player", _on_player_kill)

# Events
func _on_player_kill(killer_id: int, killed_id: int):
	assert(killer_id < len(players), "killer_id [%d] is out of scope"%killer_id)
	assert(killed_id < len(players), "killed_id [%d] is out of scope"%killed_id)
	self.players[killer_id].stage_enemies_killed_nbr += 1
	self.players[killed_id].stage_death_nbr += 1
	var death_nbr = self.players[killed_id].stage_death_nbr
	var enemies_killed_nbr = self.players[killed_id].stage_enemies_killed_nbr

	players[killed_id].instance.death()
	self.players[killed_id].instance = null
	match self.stage_settings.game_mode:
		StageSettings.GameMode.FREE_FOR_ALL:
			match self.stage_settings.life_mode:
				StageSettings.LifeMode.ONE_LIFE:
					players_standing_nbr -= 1
				StageSettings.LifeMode.MULTIPLE_LIVES:
					if death_nbr < self.stage_settings.lives_per_player:
						spawn_player(killed_id)
					else:
						players_standing_nbr -= 1
				StageSettings.LifeMode.INFINITE_LIVES:
					spawn_player(killed_id)
			match self.stage_settings.stage_end_condition:
				StageSettings.StageEndCondition.KILL_LIMIT:
					if enemies_killed_nbr >= stage_settings.kill_limit:
						end_stage(killer_id)
			if players_standing_nbr <= 1:
				for player in self.players:
					if player.stage_death_nbr < stage_settings.lives_per_player:
						end_stage(player.player_id)
		StageSettings.GameMode.TEAMS:
			# TODO
			return
	return
