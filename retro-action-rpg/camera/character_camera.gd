class_name CharacterCamera
extends Camera2D

const FRAME_HORIZONTAL_MARGIN := 28
const FRAME_VERTICAL_MARGIN := 6

# we don't want anything directly accessing the camera target
var _target: RemoteTransform2D : set = set_target

func set_target(value: RemoteTransform2D):
	if _target is RemoteTransform2D:
		_target.remote_path = ""
	_target = value
	_target.remote_path = get_path()
	reset_smoothing()

func _ready() -> void:
	Events.request_camera_target.connect(set_target)
	Events.request_camera_limits.connect(update_limits)
	Events.request_camera_screenshake.connect(apply_screenshake)

func apply_screenshake(amount: float, duration := 0.3) -> void:
	var tween = create_tween()
	tween.tween_method(shake, amount, 0.0, duration)
	await tween.finished

func shake(amount: float) -> void:
	offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * amount

func update_limits(camera_limits: CameraLimits) -> void:
	limit_left = camera_limits.position.x - FRAME_HORIZONTAL_MARGIN
	limit_right = camera_limits.position.x + camera_limits.size.x + FRAME_HORIZONTAL_MARGIN
	limit_top = camera_limits.position.y - FRAME_VERTICAL_MARGIN
	limit_bottom = camera_limits.position.y + camera_limits.size.y + FRAME_VERTICAL_MARGIN
