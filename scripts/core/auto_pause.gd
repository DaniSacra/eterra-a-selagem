class_name AutoPause
## C20 (GP P2-3): the run pauses by itself when the window loses its focus or the controller in use is unplugged,
## as a PC game must; never for the robot, a smoke run, a capture (--shot) nor outside of play (a screen already
## open, the ending, the run over). Pure rule; Game listens (Game._notification, Input.joy_connection_changed).

enum Why { FOCUS, PAD }


## Whether a lost focus or an unplugged pad pauses now. playing: the run is in play (Game.Mode.PLAY);
## robot: the robot plays it (or a smoke or capture run); pad_in_use: the controller was what he was playing with
## (only for Why.PAD).
static func wanted(why: Why, playing: bool, robot: bool, pad_in_use: bool = true) -> bool:
	if not playing or robot:
		return false
	if why == Why.PAD:
		return pad_in_use
	return true


## True for the runs nobody plays by hand: the robot, --smoke, captures (--shot, --frames) and --no-auto-pause.
static func robot_run(has_bot: bool) -> bool:
	return has_bot or Dev.has("smoke") or Dev.has("shot") or Dev.has("frames") or Dev.has("no-auto-pause")
