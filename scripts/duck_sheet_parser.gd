class_name DuckSheetParser
extends RefCounted
const SHEET_SIZE := Vector2i(414, 528)
const IDLE_REGION := Rect2i(0, 0, 100, 100)
const WALK_REGIONS := [
	Rect2i(0, 128, 100, 100),
	Rect2i(100, 128, 100, 100)
]
const RUN_REGIONS := [
	Rect2i(0, 256, 100, 100),
	Rect2i(100, 256, 100, 100)
]
const PFP_REGION := Rect2i(19, 407, 100, 100)
static func validate(image: Image) -> Dictionary:
	if image == null:
		return {
			"valid": false,
			"error": "The image could not be loaded."
		}
	if image.get_width() != SHEET_SIZE.x or image.get_height() != SHEET_SIZE.y:
		return {
			"valid": false,
			"error": "Sprite sheet must be exactly 414 x 528 pixels."
		}
	return {
		"valid": true,
		"error": ""
	}
static func extract(image: Image) -> Dictionary:
	var validation := validate(image)
	if not validation["valid"]:
		return {
			"valid": false,
			"error": validation["error"]
		}
	return {
		"valid": true,
		"error": "",
		"idle": image.get_region(IDLE_REGION),
		"walk": [
			image.get_region(WALK_REGIONS[0]),
			image.get_region(WALK_REGIONS[1])
		],
		"run": [
			image.get_region(RUN_REGIONS[0]),
			image.get_region(RUN_REGIONS[1])
		],
		"pfp": image.get_region(PFP_REGION)
	}
static func create_sprite_frames(image: Image) -> SpriteFrames:
	var data := extract(image)
	if not data["valid"]:
		return null
	var frames := SpriteFrames.new()
	#IDLE
	frames.add_animation("idle")
	frames.set_animation_speed("idle", 1.0)
	frames.set_animation_loop("idle", true)
	frames.add_frame(
		"idle",
		ImageTexture.create_from_image(data["idle"])
	)
	#WALK
	frames.add_animation("walk")
	frames.set_animation_speed("walk", 6.0)
	frames.set_animation_loop("walk", true)
	for frame_image in data["walk"]:
		frames.add_frame(
			"walk",
			ImageTexture.create_from_image(frame_image)
		)
	#RUN
	frames.add_animation("run")
	frames.set_animation_speed("run", 10.0)
	frames.set_animation_loop("run", true)
	for frame_image in data["run"]:
		frames.add_frame(
			"run",
			ImageTexture.create_from_image(frame_image)
		)
	return frames
