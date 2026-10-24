extends SceneTree

const QuestRules = preload("res://game/village/village_quest_rules.gd")
const State = preload("res://game/session/run_state.gd")
const DirectorScript = preload("res://game/village/village_quest_director.gd")

func _initialize() -> void:
	_check_outcome_mapping()
	_check_quest_transitions()
	_check_fresh_state_reset()
	_check_localization_catalog()
	print("Village quest rules and fresh-run reset passed.")
	quit()

func _check_outcome_mapping() -> void:
	var keeper_honest: Dictionary = QuestRules.outcome("keeper", "honest")
	assert(keeper_honest["response"] == "outcome_keeper_honest")
	assert(keeper_honest["access"] == "access_keeper")
	assert(keeper_honest["trust_delta"] == 1)
	var keeper_silent: Dictionary = QuestRules.outcome("keeper", "silent")
	assert(keeper_silent["response"] == "outcome_keeper_silent")
	assert(keeper_silent["trust_delta"] == -1)
	var visitor_honest: Dictionary = QuestRules.outcome("visitor", "honest")
	assert(visitor_honest["response"] == "outcome_visitor_honest")
	assert(visitor_honest["trust_delta"] == 1)
	var visitor_silent: Dictionary = QuestRules.outcome("visitor", "silent")
	assert(visitor_silent["response"] == "outcome_visitor_silent")
	assert(visitor_silent["trust_delta"] == -1)

func _check_fresh_state_reset() -> void:
	var state: RunState = State.new() as RunState
	state.custody = "visitor"
	state.testimony = "silent"
	state.power_awakened = true
	state.rope_picked = true
	state.reset()
	assert(state.custody.is_empty())
	assert(state.testimony.is_empty())
	assert(not state.power_awakened)
	assert(not state.rope_picked)

func _check_quest_transitions() -> void:
	var state: RunState = State.new() as RunState
	state.beat = RunState.Beat.PERSONAL_TASK
	var director: VillageQuestDirector = DirectorScript.new(state) as VillageQuestDirector
	assert(not director.pick_up_rope())
	assert(not director.deliver_rope())
	assert(director.mark_keeper_task_talked())
	assert(director.mark_friend_task_talked())
	assert(director.pick_up_rope())
	assert(director.deliver_rope())
	assert(state.task_complete)
	assert(not director.start_seizure())
	assert(director.hear_visitor_request())
	assert(not director.start_seizure())
	assert(director.read_order())
	assert(director.hear_leader_response())
	assert(director.hear_keeper_response())
	assert(director.start_seizure())
	assert(director.trigger_awakening())
	assert(state.beat == RunState.Beat.AWAKENING)
	assert(director.begin_power_trial())
	assert(director.complete_power_trial())
	assert(director.choose_custody("keeper"))
	var result: Dictionary = director.choose_testimony("honest")
	assert(result["response"] == "outcome_keeper_honest")
	assert(state.consequence_shown)
	director.complete_episode()
	assert(state.beat == RunState.Beat.COMPLETE)
	director.retry_encounter()
	assert(state.beat == RunState.Beat.SEIZURE)
	assert(not state.power_awakened and not state.enemy_defeated)

func _check_localization_catalog() -> void:
	var translations: PackedStringArray = ProjectSettings.get_setting(
		"internationalization/locale/translations",
		PackedStringArray()
	)
	assert(translations == PackedStringArray([
		"res://game/i18n/strings.en.translation",
		"res://game/i18n/strings.pt_BR.translation"
	]))
	var catalog: FileAccess = FileAccess.open("res://game/i18n/strings.csv", FileAccess.READ)
	assert(catalog != null)
	var header: PackedStringArray = catalog.get_csv_line()
	assert(header == PackedStringArray(["keys", "en", "pt_BR"]))
	var seen: Dictionary = {}
	while not catalog.eof_reached():
		var row: PackedStringArray = catalog.get_csv_line()
		if row.is_empty() or (row.size() == 1 and row[0].is_empty()):
			continue
		assert(row.size() == 3)
		assert(not seen.has(row[0]))
		assert(not row[1].is_empty() and not row[2].is_empty())
		seen[row[0]] = true
