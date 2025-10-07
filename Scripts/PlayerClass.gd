extends Node
class_name Player

# Instage State
var stage_death_nbr := 0
var stage_enemies_killed_nbr := 0

# Ingame State
var game_death_nbr := 0
var game_enemies_killed_nbr := 0
var game_stage_wins_nbr := 0
var instance: CharacterBody2D

# General informations
var team: int
var player_name: String
var player_id: int
var device_id: int
