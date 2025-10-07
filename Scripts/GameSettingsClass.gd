# This class holds the customizable game rule settings
extends Object
class_name GameSettings

# Enumerations for different game options

# Game end conditions
enum GameEndCondition {
	KILL_NUMBER,      # Game ends when a player reaches a set number of kills
	STAGE_WIN_NUMBER,       # Game ends when a player reaches a set number of wins
	FIXED_STAGES_NUMBER,     # Game ends after a predetermined number of stages
	USER_INPUT        # Game ends when manually triggered (e.g., by the user)
}

# Default game settings

# Stage number limit for ending the game (used if game_end_condition is FIXED_STAGES_NUMBER)
var stages_limit: int = 5

# Game end condition (e.g., based on score or fixed number of stages)
var game_end_condition: GameEndCondition = GameEndCondition.STAGE_WIN_NUMBER

# Kills limit for ending the game (used if game_end_condition is KILL_NUMBER)
var kills_limit: int = 10

# Stage win limit for ending the game (used if game_end_condition is STAGE_WIN_NUMBER)
var stage_wins_limit: int = 3

# Store settings about the how should be generated each stage
var stage_settings: StageSettings = StageSettings.new()
