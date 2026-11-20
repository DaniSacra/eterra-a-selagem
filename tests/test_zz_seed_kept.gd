extends GutTest
## BUG-109: every game a test opens plays on the hook's seed (tests/hooks/pre_run.gd). A file that took --seed away
## in its after_each left every later file on randomize()d dice, and their assertion counts changed from run to run.
## Named to run last: no file before it may leave the suite without a seed.


func test_the_seed_is_still_there() -> void:
	assert_true(Dev.has("seed"), "a test file took --seed away (put it back to \"1\" in its after_each)")
