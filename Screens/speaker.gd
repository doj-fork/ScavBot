extends Node2D

# ─────────────────────────────────────────────
# Speaker — Tutorial controller/dialogue
# Handles: glow highlight (collectible-style), floating labels, full tutorial state machine.
# ─────────────────────────────────────────────

enum Phase {
	IDLE,
	WAIT_E,
	DIALOGUE_INTRO,
	COLLECT1,
	DIALOGUE_CRAFT1,
	CRAFT1,
	DIALOGUE_DUMMY1,
	DUMMY1_FIGHT,
	DIALOGUE_BATCH2,
	COLLECT2,
	DIALOGUE_CRAFT2,
	CRAFT2,
	DIALOGUE_DUMMY2,
	DUMMY2_FIGHT,
	BRANCH,
	WAIT_HEAL,
	DIALOGUE_HEAL,
	WAIT_UPGRADE,
	DIALOGUE_FINAL,
	DONE
}

var phase: Phase = Phase.IDLE
var entered: bool = false
var _flashTween: Tween = null
var _prompt_label: Label = null
var _dummy2_killed: bool = false
var _upgrades_was_visible: bool = false
var _blip_normal: AudioStreamPlayer = null
var _blip_radio: AudioStreamPlayer = null
var _dialogue_tween: Tween = null
var _speaker_name: String = "[???]"

@onready var sprite: Sprite2D = $Sprite

const FONT_PATH: String = "res://Assets/Fonts/SunkenMini.ttf"
const SPRITE_TINT: Color = Color(1.0, 0.95, 0.72, 1.0)

func _ready() -> void:
	Stats.health = 75
	Global.hudActive = true
	sprite.modulate = SPRITE_TINT
	# entrance_door.gd already sets cannotShootIntermission = true and plays intermission BGM
	_create_prompt_label()
	_setup_blip_players()
	# Show the exit door sprite from the start, but keep it non-interactable
	var exit: Node = get_node_or_null("../ExitDoor")
	if exit:
		exit.visible = true
		var collision: Area2D = exit.get_node_or_null("Collision")
		if collision:
			collision.monitoring = false
			collision.monitorable = false
	run_tutorial()

# ─────────────────────────────────────────────
# Area callbacks; glow highlight
# ─────────────────────────────────────────────

func areaEntered(_area: Area2D) -> void:
	entered = true
	if phase == Phase.WAIT_E:
		_startFlash()
		_show_prompt("Press [E]")

func areaExited(_area: Area2D) -> void:
	entered = false
	_stopFlash()
	_hide_prompt()

func _startFlash() -> void:
	if _flashTween:
		_flashTween.kill()
	_flashTween = create_tween().set_loops()
	_flashTween.tween_property(sprite, "modulate", Color(1.4, 1.4, 1.4, 1.0), 0.4)
	_flashTween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.4)

func _stopFlash() -> void:
	if _flashTween:
		_flashTween.kill()
		_flashTween = null
	if is_instance_valid(sprite):
		sprite.modulate = SPRITE_TINT

# ─────────────────────────────────────────────
# Persistent prompt label above the Speaker sprite
# ─────────────────────────────────────────────

func _create_prompt_label() -> void:
	_prompt_label = Label.new()
	_prompt_label.add_theme_font_override("font", load(FONT_PATH))
	_prompt_label.add_theme_font_size_override("font_size", 32)
	_prompt_label.add_theme_color_override("font_color", Color.WHITE)
	_prompt_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_prompt_label.add_theme_constant_override("outline_size", 3)
	_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt_label.custom_minimum_size = Vector2(200, 0)
	_prompt_label.visible = false
	add_child(_prompt_label)

func _show_prompt(text: String) -> void:
	if _prompt_label == null:
		return
	_prompt_label.text = text
	_prompt_label.position = sprite.position + Vector2(-100, -60)
	_prompt_label.visible = true

func _hide_prompt() -> void:
	if _prompt_label != null:
		_prompt_label.visible = false

# ─────────────────────────────────────────────
# Blip dialogue audio
# ─────────────────────────────────────────────

func _setup_blip_players() -> void:
	_blip_normal = AudioStreamPlayer.new()
	_blip_normal.stream = load("res://Assets/SFX/UI/blip2.mp3")
	_blip_normal.volume_db = -20.0
	add_child(_blip_normal)
	_blip_radio = AudioStreamPlayer.new()
	_blip_radio.stream = load("res://Assets/SFX/UI/blip1.mp3")
	_blip_radio.volume_db = -20.0
	add_child(_blip_radio)

func _play_blips(is_radio: bool, duration: float) -> void:
	if is_radio:
		if _blip_radio != null:
			_blip_radio.play()
	else:
		if _blip_normal == null:
			return
		var elapsed: float = 0.0
		while elapsed < duration:
			_blip_normal.play()
			await get_tree().create_timer(0.1, false).timeout
			elapsed += 0.1

# ─────────────────────────────────────────────
# HUD dialogue label (fixed bottom-right, right of GunType)
# ─────────────────────────────────────────────

func _popup(text: String, hold_secs: float = 3.0) -> void:
	var is_radio: bool = text.begins_with("*") and text.ends_with("*")
	_play_blips(is_radio, 3.0)
	var dlabel: Label = Hud.tutorial_dialogue
	var slabel: Label = Hud.tutorial_speaker
	if dlabel == null:
		return
	# Cancel any in-progress fade before starting a new line
	if _dialogue_tween:
		_dialogue_tween.kill()
		_dialogue_tween = null
	dlabel.text = text
	dlabel.modulate = Color(1.0, 1.0, 1.0, 1.0)
	dlabel.visible = true
	slabel.text = _speaker_name
	slabel.modulate = Color(1.0, 1.0, 1.0, 1.0)
	slabel.visible = true
	var fade_duration: float = 3.0
	var hold_delay: float = maxf(0.0, hold_secs - fade_duration)
	_dialogue_tween = create_tween().set_parallel(true)
	_dialogue_tween.tween_property(dlabel, "modulate:a", 0.0, fade_duration).set_delay(hold_delay)
	_dialogue_tween.tween_property(slabel, "modulate:a", 0.0, fade_duration).set_delay(hold_delay)
	_dialogue_tween.finished.connect(func():
		dlabel.visible = false
		slabel.visible = false
		_dialogue_tween = null
	)

# Show a line and wait for it to finish floating
func _say(text: String, hold_secs: float = -1.0) -> void:
	var duration: float = hold_secs if hold_secs >= 0.0 else \
		maxf(2.5, float(text.split(" ").size()) * 0.25 + 2.0)
	var was_blocked: bool = Global.cannotCraftCollecting
	var was_shoot_blocked: bool = Global.cannotShootIntermission
	Global.cannotCraftCollecting = true
	Global.cannotShootIntermission = true
	_popup(text, duration)
	await get_tree().create_timer(duration, false).timeout
	Global.cannotCraftCollecting = was_blocked
	Global.cannotShootIntermission = was_shoot_blocked

# ─────────────────────────────────────────────
# _process — poll-based phase transitions
# ─────────────────────────────────────────────

func _process(_delta: float) -> void:
	match phase:
		Phase.WAIT_E:
			if entered and Input.is_action_just_pressed("Interact"):
				phase = Phase.DIALOGUE_INTRO
		Phase.COLLECT1:
			if get_tree().get_nodes_in_group("TutorialBatch1").is_empty():
				phase = Phase.DIALOGUE_CRAFT1
		Phase.DUMMY1_FIGHT:
			if Gun.type == "Null" and Gun.ammo <= 0:
				phase = Phase.DIALOGUE_BATCH2
				Global.cannotShootIntermission = true
		Phase.COLLECT2:
			if get_tree().get_nodes_in_group("TutorialBatch2").is_empty():
				phase = Phase.DIALOGUE_CRAFT2
		Phase.DUMMY2_FIGHT:
			if _dummy2_killed or (Gun.type == "Null" and Gun.ammo <= 0):
				phase = Phase.BRANCH
				Global.cannotShootIntermission = true
		Phase.WAIT_UPGRADE:
			if _upgrades_was_visible and not Upgrades.visible:
				phase = Phase.DIALOGUE_FINAL
				_upgrades_was_visible = false
			elif Upgrades.visible:
				_upgrades_was_visible = true

func _on_dummy2_died() -> void:
	_dummy2_killed = true

# ─────────────────────────────────────────────
# Main tutorial coroutine
# ─────────────────────────────────────────────

func run_tutorial() -> void:
	# ── WAIT_E: glow + prompt, await E press ──
	phase = Phase.WAIT_E

	await _wait_for_phase_change(Phase.DIALOGUE_INTRO)
	_stopFlash()
	_hide_prompt()

	# ── Initial radio dialogue ──
	phase = Phase.DIALOGUE_INTRO
	await _say("*bzzzt*", 2.0)
	await _say("*connecting*", 2.5)
	_speaker_name = "[T.R.E.M.B.L.E. CMD]"
	await _say("Connected to Tactical Response, Enforcement, Mobilization, and Battlefield Logistics Executive (T.R.E.M.B.L.E.)")
	await _say("Connection redirected to nearest command center (T.R.E.M.B.L.E. Third Central Command).")
	await _say("Please send the required quantum key authentication to proceed.")
	await _say("*...*", 2.0)
	await _say("Authentication confirmed \u2014")
	await _say("Unit 0029144, of the TRAPPIST-1 branch of T.R.E.M.B.L.E.")
	await _say("Orders confirmed \u2014 Unit 0029144.")
	await _say("T.R.E.M.B.L.E. has ordered a full retreat to TRAPPIST-1E.")
	await _say("Your location, TRAPPIST-1D, has been fully occupied by the New Emergent Robotic Forces (N.E.R.F.).")
	await _say("T.R.E.M.B.L.E. can not provide any extraction for you.")
	await _say("Your new directive is to survive and eliminate hostiles if necessary.")
	await _say("Follow the instructions given.")
	await _say("To survive, your collection module [E] and crafting module [C] have been activated.")
	await _say("Try using your collection module with nearby collectibles.")

	# ── Spawn first batch of trees ──
	_spawn_batch1()
	Global.cannotCraftGeneral = true
	phase = Phase.COLLECT1

	await _wait_for_phase_change(Phase.DIALOGUE_CRAFT1)

	# ── Post-collect dialogue ──
	phase = Phase.DIALOGUE_CRAFT1
	await _say("Data confirmed \u2014 4 Wood collected.")
	await _say("Unit 0029144, you are now instructed to craft a weapon.")
	await _say("Your crafting module has several built-in gun blueprints.")
	await _say("Press [C] to open the menu and drag wood to each slot of the blueprint, then press \"Craft\".")

	# ── Wait for Handgun craft ──
	Global.cannotCraftGeneral = false
	phase = Phase.CRAFT1
	await _wait_for_handgun_craft()

	phase = Phase.DIALOGUE_DUMMY1
	await _say("Data confirmed \u2014 WW-2 Pistol Crafted.")
	await _say("Unit 0029144, please fire at the dummy target until it has been eliminated.")

	# ── Spawn dummy 1 (9999 hp), enable shooting ──
	_spawn_dummy1()
	Global.cannotShootIntermission = false
	phase = Phase.DUMMY1_FIGHT

	await _wait_for_phase_change(Phase.DIALOGUE_BATCH2)

	# ── Gun broke dialogue + spawn second batch ──
	phase = Phase.DIALOGUE_BATCH2
	_spawn_batch2()
	await _say("Unit 0029144, your gun has run out of durability.")
	await _say("You must craft a new weapon.")
	await _say("Use your collection module with nearby collectibles again.")

	Global.cannotCraftGeneral = true
	phase = Phase.COLLECT2

	await _wait_for_phase_change(Phase.DIALOGUE_CRAFT2)

	phase = Phase.DIALOGUE_CRAFT2
	await _say("Use your crafting module to craft any weapon of your choosing.")
	await _say("The center of your gun, the chamber, determines weapon type.")

	# ── Wait for any weapon crafted ──
	Global.cannotCraftGeneral = false
	phase = Phase.CRAFT2
	await _wait_for_any_craft()

	phase = Phase.DIALOGUE_DUMMY2
	await _say("Unit 0029144, continue firing at the dummy target until it has been eliminated.")

	# ── Spawn dummy 2 (100 hp), enable shooting ──
	_spawn_dummy2()
	Global.cannotShootIntermission = false
	phase = Phase.DUMMY2_FIGHT

	await _wait_for_phase_change(Phase.BRANCH)

	# ── Branch dialogue ──
	phase = Phase.BRANCH
	if _dummy2_killed:
		await _say("Unit 0029144, good work at eliminating the dummy.")
	else:
		await _say("Unit 0029144, your aiming module must target the enemy dummy.")
		await _say("Please remember this when engaging hostiles, as they will be more dangerous than the dummy target.")
	# Remove gun
	Gun.ammo = 0

	await _say("Interact with the Regenerative Repair First Aid device to heal.")
	_enable_device("../HealDevice")

	# ── Wait for heal interaction ──
	phase = Phase.WAIT_HEAL
	await Signals.charge

	# ── Post-heal dialogue ──
	phase = Phase.DIALOGUE_HEAL
	await _say("Your robotic core determines your health, and you must protect the asset at all costs.")
	await _say("Keep in mind that hostiles can damage you over time with either ranged or melee attacks.")
	await _say("Please also interact with the Progressive Upgrade Device and choose any upgrade.")
	_enable_device("../UpgradeDevice")

	# ── Wait for upgrade ──
	phase = Phase.WAIT_UPGRADE
	await _wait_for_phase_change(Phase.DIALOGUE_FINAL)

	# ── Final dialogue ──
	phase = Phase.DIALOGUE_FINAL
	await _say("N.E.R.F. forces encroach on your position in waves.")
	await _say("Over time, N.E.R.F. hostiles also improve to adapt to your new upgrades.")
	await _say("Every wave, you must head north to escape to safety.")
	await _say("Please keep all of these instructions in mind.")
	await _say("Unit 0029144, you are now clear to enter the area of operations. Good luck.")

	# ── Done: unlock exit door ──
	phase = Phase.DONE
	_unlock_exit()

# ─────────────────────────────────────────────
# Wait helpers
# ─────────────────────────────────────────────

func _wait_for_phase_change(target_phase: Phase) -> void:
	while phase != target_phase:
		await get_tree().process_frame

func _wait_for_handgun_craft() -> void:
	while true:
		await Signals.gun_crafted
		if Gun.type == "Handgun":
			break
		_popup("A Handgun (Wood chamber) is required.")

func _wait_for_any_craft() -> void:
	await Signals.gun_crafted

# ─────────────────────────────────────────────
# Spawn helpers
# ─────────────────────────────────────────────

func _spawn_batch1() -> void:
	var batch: Node = get_node_or_null("../TutorialBatch1")
	if batch:
		batch.visible = true
		batch.process_mode = Node.PROCESS_MODE_INHERIT
		for child in batch.get_children():
			child.add_to_group("TutorialBatch1")

func _spawn_batch2() -> void:
	var batch: Node = get_node_or_null("../TutorialBatch2")
	if batch:
		batch.visible = true
		batch.process_mode = Node.PROCESS_MODE_INHERIT
		for child in batch.get_children():
			child.add_to_group("TutorialBatch2")

func _spawn_dummy1() -> void:
	var dummy: Node = get_node_or_null("../TutorialDummy1")
	if dummy:
		dummy.visible = true
		dummy.process_mode = Node.PROCESS_MODE_INHERIT

func _spawn_dummy2() -> void:
	var dummy1: Node = get_node_or_null("../TutorialDummy1")
	var dummy: Node = get_node_or_null("../TutorialDummy2")
	if is_instance_valid(dummy1) and is_instance_valid(dummy):
		dummy.global_position = dummy1.global_position
	if is_instance_valid(dummy1):
		dummy1.queue_free()
	if is_instance_valid(dummy):
		dummy.visible = true
		dummy.process_mode = Node.PROCESS_MODE_INHERIT
		if dummy.has_signal("died") and not dummy.died.is_connected(_on_dummy2_died):
			dummy.died.connect(_on_dummy2_died)

func _unlock_exit() -> void:
	var exit: Node = get_node_or_null("../ExitDoor")
	if exit:
		var collision: Area2D = exit.get_node_or_null("Collision")
		if collision:
			collision.monitoring = true
			collision.monitorable = true
	_popup("Head north to the exit when ready.")

func _enable_device(path: String) -> void:
	var node: Node = get_node_or_null(path)
	if node:
		node.visible = true
		node.process_mode = Node.PROCESS_MODE_INHERIT
