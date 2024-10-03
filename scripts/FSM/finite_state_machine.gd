class_name FiniteStateMachine
extends Node

@export var state: State

func _ready():
	change_state(state)

func change_state(new_state: State, from_state: State = null):
	if state is State:
		state._exit()
	
	new_state._enter(from_state)
	
	state = new_state
