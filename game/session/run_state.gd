class_name RunState
extends RefCounted

enum Beat { SETUP, PERSONAL_TASK, RECORD_REQUEST, SEIZURE, AWAKENING, POWER_TRIAL, DECISION, CONSEQUENCE, COMPLETE }

var protagonist: String = "female"
var origin: String = "foundling"
var motivation: String = "leave"
var beat: Beat = Beat.SETUP
var task_complete: bool = false
var keeper_task_talked: bool = false
var friend_task_talked: bool = false
var rope_picked: bool = false
var visitor_request_heard: bool = false
var order_read: bool = false
var leader_response_heard: bool = false
var keeper_response_heard: bool = false
var enemy_defeated: bool = false
var power_awakened: bool = false
var power_tried: bool = false
var custody: String = ""
var testimony: String = ""
var acquaintance_trust: int = 0
var consequence_shown: bool = false

func reset() -> void:
	protagonist = "female"
	origin = "foundling"
	motivation = "leave"
	beat = Beat.SETUP
	task_complete = false
	keeper_task_talked = false
	friend_task_talked = false
	rope_picked = false
	visitor_request_heard = false
	order_read = false
	leader_response_heard = false
	keeper_response_heard = false
	enemy_defeated = false
	power_awakened = false
	power_tried = false
	custody = ""
	testimony = ""
	acquaintance_trust = 0
	consequence_shown = false
