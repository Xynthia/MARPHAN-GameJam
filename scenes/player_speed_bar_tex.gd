extends TextureProgressBar

var _time: float = 0.0
@export var pulse_amount: float = 0.25
@export var pulse_speed: float = 2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_time += delta
	if self.visible == true:
		var Pulse: float = 0.75 + pulse_amount * sin(_time * pulse_speed + float(1) * 1)
		self.tint_progress.a = Pulse
