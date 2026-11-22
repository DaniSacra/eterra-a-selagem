extends GutHookScript
## Before the tests (.gutconfig.json pre_run_script): a test run never writes this machine's save nor its run log
## (Save.enabled false, as with --nosave): the fights and deaths the tests play are not a person's runs. BUG-109:
## every game a test opens plays on the same seed (--seed=1 unless the command line gives one), so its map, its fights
## and the count of assertions are the same on every run.


func run() -> void:
	Save.enabled = false
	# the fights the tests count on are the ones where every blow stuns (the experiment has its own test, test_stun_rule)
	StunRule.live = StunRule.Mode.ALL
	if not Dev.has("seed"):
		Dev.put("seed", "1")
	# the Santuário's stations open by stages (HubGate); the hub tests built before that use them all (test_hub_gate drops it)
	Dev.put("hub-open", "all")
