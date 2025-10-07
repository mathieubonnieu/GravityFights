extends Label


# Speed of the pulsing effect
var pulse_speed: float = 2.0
# Maximum scale of the text
var max_scale: float = 1.5
# Minimum scale of the text
var min_scale: float = 1.0

func _ready() -> void:
	self.pivot_offset = self.get_rect().size / 2

func _process(_delta):
	# Calculate the scale factor using a sine wave
	var calculated_scale = min_scale + (max_scale - min_scale) * 0.5 * (1 + sin(pulse_speed * Time.get_ticks_msec() / 1000.0))
	self.scale = Vector2(calculated_scale, calculated_scale)
