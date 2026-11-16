extends GutHookScript
## Before the tests (.gutconfig.json pre_run_script): a test run never writes this machine's save nor its run log
## (Save.enabled false, as with --nosave): the fights and deaths the tests play are not a person's runs.


func run() -> void:
	Save.enabled = false
