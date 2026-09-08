extends SceneTree
var failures: int = 0
var shots: int = 0
var fails: int = 0
var last_damage: float = -1.0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
	else:
		print("PASS: ", message)

func ticks(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame

func click(controls: Node) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	controls._unhandled_input(event)

func press(controls: Node, action: String) -> void:
	var event := InputEventKey.new()
	event.pressed = true
	match action:
		"rune_1":
			event.physical_keycode = KEY_1
		"rune_2":
			event.physical_keycode = KEY_2
		"rune_3":
			event.physical_keycode = KEY_3
		"rune_clear":
			event.physical_keycode = KEY_C
	controls._unhandled_input(event)

func run() -> void:
	var scene = load("res://scenes/boot/main.tscn").instantiate()
	root.add_child(scene)
	await ticks(20)
	var player = scene.get_node("Player")
	var dummy = scene.get_node("Dummy")
	var health = dummy.get_node("Health")
	var combat = player.get_node("Combat")
	var queue = player.get_node("RuneQueue")
	var controls = player.get_node("PlayerInput")
	var view = player.get_node("View")
	combat.shot_resolved.connect(func(_point, damage): shots += 1; last_damage = damage)
	combat.cast_failed.connect(func(_reason): fails += 1)
	controls.controls_active = true
	view.look_at(dummy.position + Vector3(0, 1.3, 0))

	check(queue.is_empty(), "Queue starts empty")
	check(SpellCatalog.resolve(PackedStringArray()).get("kind") == "tag", "Empty recipe is Tag")
	check(float(SpellCatalog.resolve(PackedStringArray(["kenaz"])).get("damage")) == 16.0, "One Kenaz deals 16")
	check(float(SpellCatalog.resolve(PackedStringArray(["kenaz", "kenaz", "kenaz"])).get("damage")) == 24.0, "Three Kenaz deals 24")
	check(SpellCatalog.resolve(PackedStringArray(["kenaz", "isa"])).get("kind") == "unsupported", "Mixed queue is unsupported")

	click(controls)
	await ticks(2)
	check(health.current_health == 88.0 and last_damage == 12.0 and shots == 1, "Empty queue still fires Tag for 12")

	press(controls, "rune_2")
	press(controls, "rune_3")
	check(queue.is_empty(), "Unbound 2 and 3 do not insert")

	press(controls, "rune_1")
	check(queue.snapshot() == PackedStringArray(["kenaz"]), "Key 1 inserts Kenaz at slot 1")
	press(controls, "rune_1")
	press(controls, "rune_1")
	press(controls, "rune_1")
	check(queue.snapshot() == PackedStringArray(["kenaz", "kenaz", "kenaz"]), "Fourth insert discards slot 3")
	press(controls, "rune_clear")
	check(queue.is_empty(), "C clears the queue without casting")

	await ticks(130)
	press(controls, "rune_1")
	click(controls)
	await ticks(2)
	check(health.current_health == 72.0 and last_damage == 16.0, "Single Kenaz hitscan deals 16")
	check(queue.is_empty(), "Successful Kenaz cast consumes the queue")
	check(combat.last_kind == "kenaz", "Combat records Kenaz kind")
	check(combat.cooldown_remaining > 1.9, "Kenaz uses the two-second cooldown")

	await ticks(130)
	press(controls, "rune_1")
	press(controls, "rune_1")
	press(controls, "rune_1")
	click(controls)
	await ticks(2)
	check(health.current_health == 48.0 and last_damage == 24.0, "Triple Kenaz deals 24")
	check(queue.is_empty(), "Triple cast consumes all three slots")

	await ticks(130)
	queue.push_id("isa")
	var hp_before: float = health.current_health
	var fail_before: int = fails
	click(controls)
	await ticks(2)
	check(health.current_health == hp_before and combat.cooldown_remaining == 0.0, "Unsupported mix does not damage or start cooldown")
	check(queue.snapshot() == PackedStringArray(["isa"]), "Unsupported mix keeps the queue")
	check(fails == fail_before + 1, "Unsupported mix emits cast_failed")
	press(controls, "rune_clear")

	press(controls, "rune_1")
	check(queue.snapshot() == PackedStringArray(["kenaz"]), "Kenaz sits in queue before death")
	player.health.apply_damage(1000)
	press(controls, "rune_1")
	check(queue.snapshot() == PackedStringArray(["kenaz"]), "Dead player cannot insert runes")
	player.get_node("Respawn").remaining = 0.01
	await ticks(8)
	check(player.health.current_health == 100.0, "Respawn restores player")
	check(queue.is_empty(), "Respawn clears leftover queue")

	scene.queue_free()
	await process_frame
	print("M08 failures: ", failures)
	quit(1 if failures else 0)
