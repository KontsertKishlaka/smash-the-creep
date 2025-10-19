extends State

func enter():
	if state_machine and state_machine.player:
		var velocity = state_machine.player.velocity
		velocity.x = 0
		velocity.z = 0
		state_machine.player.velocity = velocity

func physics_update(delta):
	#Отладка связей узлов
	if not state_machine or not state_machine.player:
		return
		
	var input_dir = Vector3.ZERO

	if Input.is_action_pressed("move_forwards"):
		input_dir.z -= 1
	if Input.is_action_pressed("move_backwards"):
		input_dir.z += 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1

	if input_dir.length() > 0:
		if Input.is_action_pressed("sprint"):
			state_machine.change_state("run")
		else:
			state_machine.change_state("walk")

	if Input.is_action_pressed("jump") and state_machine.player.is_on_floor():
		state_machine.change_state("jump")
		
		#Гравитация
		
	var velocity = state_machine.player.velocity
	if not state_machine.player.is_on_floor():
		velocity.y -= state_machine.player.GRAVITY * delta
	state_machine.player.velocity = velocity

	state_machine.player.move_and_slide()
