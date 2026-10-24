class_name VillageQuestDirector
extends RefCounted

const QuestRules = preload("res://game/village/village_quest_rules.gd")

var state: RunState

func _init(run_state: RunState) -> void:
	state = run_state

func mark_keeper_task_talked() -> bool:
	if state.beat != RunState.Beat.PERSONAL_TASK:
		return false
	state.keeper_task_talked = true
	return true

func mark_friend_task_talked() -> bool:
	if state.beat != RunState.Beat.PERSONAL_TASK:
		return false
	state.friend_task_talked = true
	return true

func pick_up_rope() -> bool:
	if state.beat != RunState.Beat.PERSONAL_TASK or not state.keeper_task_talked or not state.friend_task_talked or state.rope_picked:
		return false
	state.rope_picked = true
	return true

func deliver_rope() -> bool:
	if state.beat != RunState.Beat.PERSONAL_TASK or not state.keeper_task_talked or not state.friend_task_talked or not state.rope_picked:
		return false
	state.task_complete = true
	state.beat = RunState.Beat.RECORD_REQUEST
	return true

func hear_visitor_request() -> bool:
	if state.beat != RunState.Beat.RECORD_REQUEST or state.visitor_request_heard:
		return false
	state.visitor_request_heard = true
	return true

func read_order() -> bool:
	if state.beat != RunState.Beat.RECORD_REQUEST or not state.visitor_request_heard:
		return false
	state.order_read = true
	return true

func hear_leader_response() -> bool:
	if state.beat != RunState.Beat.RECORD_REQUEST or not state.order_read:
		return false
	state.leader_response_heard = true
	return true

func hear_keeper_response() -> bool:
	if state.beat != RunState.Beat.RECORD_REQUEST or not state.order_read or not state.leader_response_heard:
		return false
	state.keeper_response_heard = true
	return true

func start_seizure() -> bool:
	if state.beat != RunState.Beat.RECORD_REQUEST or not state.visitor_request_heard or not state.order_read or not state.leader_response_heard or not state.keeper_response_heard:
		return false
	state.beat = RunState.Beat.SEIZURE
	return true

func trigger_awakening() -> bool:
	if state.beat != RunState.Beat.SEIZURE or state.enemy_defeated:
		return false
	state.enemy_defeated = true
	state.power_awakened = true
	state.beat = RunState.Beat.AWAKENING
	return true

func begin_power_trial() -> bool:
	if state.beat != RunState.Beat.AWAKENING or not state.power_awakened:
		return false
	state.beat = RunState.Beat.POWER_TRIAL
	return true

func complete_power_trial() -> bool:
	if state.beat != RunState.Beat.POWER_TRIAL or state.power_tried:
		return false
	state.power_tried = true
	state.beat = RunState.Beat.DECISION
	return true

func choose_custody(choice: String) -> bool:
	if state.beat != RunState.Beat.DECISION or (choice != "keeper" and choice != "visitor"):
		return false
	state.custody = choice
	return true

func choose_testimony(choice: String) -> Dictionary:
	if state.beat != RunState.Beat.DECISION or state.custody.is_empty() or (choice != "honest" and choice != "silent"):
		return {}
	state.testimony = choice
	var result: Dictionary = QuestRules.outcome(state.custody, state.testimony)
	state.acquaintance_trust += int(result["trust_delta"])
	state.consequence_shown = true
	state.beat = RunState.Beat.CONSEQUENCE
	return result

func complete_episode() -> void:
	if state.beat == RunState.Beat.CONSEQUENCE:
		state.beat = RunState.Beat.COMPLETE

func retry_encounter() -> void:
	state.enemy_defeated = false
	state.power_awakened = false
	state.power_tried = false
	state.beat = RunState.Beat.SEIZURE
