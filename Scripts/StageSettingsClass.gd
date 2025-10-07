extends Node
class_name StageSettings

# Enumerations for different stage options

# Game mode options
enum GameMode {
	FREE_FOR_ALL, # Each player is on their own
	TEAMS         # Players are divided into teams
}

# Life configuration options
enum LifeMode {
	ONE_LIFE,        # Each player has only one life
	MULTIPLE_LIVES,  # Each player or team has a set number of lives
	INFINITE_LIVES   # Players have unlimited lives
}

# Stage end conditions
enum StageEndCondition {
	LAST_STANDING,   # Stage ends when only one player/team remains
	KILL_LIMIT,      # Stage ends when a certain number of kills is reached
	TIME_LIMIT,      # Stage ends when the time limit is reached
	USER_INPUT       # Stage ends when triggered manually (e.g., by the user)
}

# Default stage settings

# Game mode (Free-for-all or Teams)
var game_mode: GameMode = GameMode.FREE_FOR_ALL

# Life mode (One life, X lives per player, X lives per team, or infinite lives)
var life_mode: LifeMode = LifeMode.MULTIPLE_LIVES

# Number of lives per player (used if life_mode is MULTIPLE_LIVES)
var lives_per_player: int = 3

# Number of lives per team (used if life_mode is MULTIPLE_LIVES and in team mode)
var lives_per_team: int = 3

# Time limit for each stage (in seconds; -1 means infinite time)
var time_limit: float = 100

# Stage end condition (e.g., last standing, kill limit)
var stage_end_condition: StageEndCondition = StageEndCondition.LAST_STANDING

# Kill limit for ending a stage (used if stage_end_condition is KILL_LIMIT)
var kill_limit: int = 10
