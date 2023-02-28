extends KinematicBody2D

const UP = Vector2(0, -1)
const GRAVITY = 20
const MAXFALLSPEED = 200
const MAXSPEED = 100
const JUMPFORCE = 400
var hasDoubleJump = true;
var facing_right = true;
var isRunning = false;
var inCombat = false;
var transitionState = false;
var inAttack = false;
var attackState = '0';
var playerState = "idle";
var isCrouched = false;
var jumpState = '0' ;
var inJump = false;
var isMovingX = false;

const ACCEL = 10
const ATTACKSTEP = 20
var motion = Vector2()


func _ready():
	pass # Replace with function body.


func _physics_process(delta):

	motion.y += GRAVITY
	
	if motion.y > MAXFALLSPEED:
		motion.y = MAXFALLSPEED
	
	if facing_right == true:
		$AnimatedSprite.flip_h = false;
	else: 
		$AnimatedSprite.flip_h = true;
	
	motion.x = clamp(motion.x, -MAXSPEED, MAXSPEED)
	
	if Input.is_action_pressed("right"):
		motion.x += ACCEL
		facing_right = true 
		isMovingX = true
		
	elif Input.is_action_pressed("left"):
		motion.x -= ACCEL
		facing_right = false
		isMovingX = true
		
	else: 
		motion.x = lerp(motion.x,0,0.3)
		if motion.x >= 0.05:
			isMovingX = false
		else:
			isMovingX = true
			if playerState == "idle":
				$AnimatedSprite.stop()
				_animationProcess(playerState)
		if !inCombat == true:
			_animationProcess(playerState)
		else:
			if(playerState == "betweenAttack1"):
				print("player attacked once")
				attackState = '1'
				_animationProcess(playerState)
				
	if Input.is_action_pressed("down"):
		attackState = '1'
		playerState = "crouch"
		isCrouched = true;
		motion.x = lerp(motion.x,0 ,0.3)
		_animationProcess(playerState)
	
	elif Input.is_action_just_released("down"):
		if is_on_floor() == true:
			isCrouched = false;
			playerState = 'idle'
			_animationProcess(playerState)
	
	if is_on_floor():
		hasDoubleJump = true
		if Input.is_action_pressed("jump"):
			jumpState = '1'
			print('jump!')
			playerState = 'jump'
			inJump = true;
			_animationProcess(playerState)
			motion.y = -JUMPFORCE
			
	if !is_on_floor() && hasDoubleJump == true:
		
		if Input.is_action_just_pressed("jump"):
			hasDoubleJump = false
			jumpState = '2'
			print('jump! jump!')
			playerState = 'jump'
			inJump = true;
			_animationProcess(playerState)
			motion.y = -JUMPFORCE
			
	if jumpState != '0' && is_on_floor() == true:
		hasDoubleJump = true
		inJump = false
		jumpState = '0'
		playerState = 'idle'
		_animationProcess(playerState)
		
	motion = move_and_slide(motion, UP)
	
	if inCombat == false:
		if Input.is_action_just_pressed("Attack"):
			inCombat = true
			attackState = '0'
			_animationProcess(playerState)
			
	
		
		
	elif inCombat == true && is_on_floor() == true:
		if Input.is_action_pressed("Attack") && isCrouched == false:
			
			print("attackState is:", attackState)
			
			if attackState == '0':
				playerState = "drawS"
				_animationProcess(playerState)
				
			if attackState == '1':
				playerState = "attack"
				_animationProcess(playerState)
				
			if attackState == '2':
				playerState = "attack"
				_animationProcess(playerState)
				
			if attackState == '3':
				playerState = "attack"
				_animationProcess(playerState)
			
		if inAttack == false && Input.is_action_just_pressed("Attack"):
			if facing_right == true:
				motion.x += ATTACKSTEP
			else:
				motion.x -= ATTACKSTEP
				
		elif Input.is_action_pressed("sheathe"):
			attackState = '4'
			print("attackState is:", attackState, " in the sheathe input area ")
			if attackState == '4':
				playerState = "attack"
				_animationProcess(playerState)
	

	
	
	
func _animationProcess(playerStatein):
	if playerStatein == "idle":
		if is_on_floor():
			if  isMovingX == true && inCombat == false:
				$AnimatedSprite.play("run1", false)
			else:
				$AnimatedSprite.play("idle1", false)
		else:
			$AnimatedSprite.play("falling", false)
	
	match (playerStatein):
		
		"jump":
			print('test this is jump')
			match (jumpState):
				'1':
					$AnimatedSprite.play("jump", false)
					
				'2':
					$AnimatedSprite.play("doubleJump", false)
					
		"drawS":
			$AnimatedSprite.play("drawS", false)
		
		"crouch":
			$AnimatedSprite.play('crouch', false)
		
		"sheaS":
			$AnimatedSprite.play("sheaS", false)
			attackState = '0'
		"attack":
			
			match (attackState):
				'1':
					inAttack = true
					$AnimatedSprite.play("attack1", false)
					
				'2':
					inAttack = true
					$AnimatedSprite.play("attack2",false)
				
				'3':
					inAttack = true
					$AnimatedSprite.play("attack3", false)
				'4':
					inCombat = false
					
	






func _on_AnimatedSprite_animation_finished():
	print('test', playerState, " | ", " in Combat? ", inCombat)
	$AnimatedSprite.stop()
	match (playerState):
		"idle":
			if isMovingX == true:
				$AnimatedSprite.stop()
				$AnimatedSprite.play('run1', false)
				playerState = 'idle'
			
		"drawS":
			attackState = '1'
			$AnimatedSprite.play("idle2", false)
			playerState = 'attack'

		"sheaS":
			
			attackState = '0'
			playerState = 'idle'
			
 
		"jump":
			print("jump state: ",jumpState)
			match (jumpState):
				'1':
					inJump = false
					
					playerState = 'idle'
					
					
				'2':
					inJump = false
					
					playerState = 'idle'
				
					return
				'3':
					inJump = false
					jumpState = '4'
					playerState = 'idle'
			print("jumpingFinished")

		"attack":
			$AnimatedSprite.play('idle2', false)
			match (attackState):
				'0':
					$AnimatedSprite.play('idle2', false)
					attackState = '1'
				'1':
					attackState = '2'
					
				'2': 
					attackState = '3'
				
				'3': 
					attackState = '1'
				'4':
					playerState = 'sheaS'
					return
			inAttack = false
			playerState = "attack"
			
			
	
	pass # Replace with function body.


func _on_AnimatedSprite_frame_changed():
	if playerState == 'attack' && inAttack == true:
		match (attackState):
			'2':
				if isCrouched == true:
					return
				else:
					if facing_right == true:
						motion.x += ATTACKSTEP
					else:
						motion.x -= ATTACKSTEP
			'3':
				if facing_right == true:
					motion.x += ATTACKSTEP * 2
				else:
					motion.x -= ATTACKSTEP * 2
				
	pass # Replace with function body.
