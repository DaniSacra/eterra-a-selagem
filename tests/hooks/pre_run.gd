extends GutHookScript
## Before the tests (.gutconfig.json pre_run_script): a test run never writes this machine's save nor its run log
## (Save.enabled false, as with --nosave): the fights and deaths the tests play are not a person's runs. BUG-109:
## every game a test opens plays on the same seed (--seed=1 unless the command line gives one), so its map, its fights
## and the count of assertions are the same on every run.


func run() -> void:
	Save.enabled = false
	if not Dev.has("seed"):
		Dev.put("seed", "1")
