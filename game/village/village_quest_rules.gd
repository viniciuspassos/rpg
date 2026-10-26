class_name VillageQuestRules
extends RefCounted

static func outcome(custody: String, testimony: String) -> Dictionary:
	var witnessed_account: bool = testimony == "honest"
	var trust_change: int = 1 if witnessed_account else -1
	var relationship: String = "relationship_friend_trust" if witnessed_account else "relationship_friend_distrust"
	if custody == "keeper":
		return {
			"trust_delta": trust_change,
			"response": "outcome_keeper_honest" if witnessed_account else "outcome_keeper_silent",
			"relationship": relationship,
			"access": "access_keeper"
		}
	return {
		"trust_delta": trust_change,
		"response": "outcome_visitor_honest" if witnessed_account else "outcome_visitor_silent",
		"relationship": relationship,
		"access": "access_visitor"
	}
