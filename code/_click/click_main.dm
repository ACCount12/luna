/atom/Click(location,control,params)
	if(usr.client.buildmode)
		build_click(usr, usr.client.buildmode, location, control, params, src)
		return

	return DblClick(location, control, params)

/atom/DblClick(location, control, params) //TODO: DEFERRED: REWRITE
	if (world.time <= usr:lastDblClick+2)
		return
	else
		usr:lastDblClick = world.time
	..()
	var/parameters = params2list(params)

	// ------ SHIFT-CLICK -----
	if(parameters["shift"])
		ShiftClick(usr)
		return

	// It diverts stuff to the mech clicking procs.
	if(istype(usr.loc, /obj/mecha))
		if(usr.client && (src in usr.client.screen))
			return
		var/obj/mecha/Mech = usr.loc
		Mech.click_action(src,usr)
		return

	// ------- ALT-CLICK -------
	if(parameters["alt"])
		AltClick(usr)
		return

	// ------- CTRL-CLICK -------
	if(parameters["ctrl"])
		CtrlClick(usr)
		return

	usr.log_m("Clicked on [src]")
	var/obj/item/W = null

	if (istype(usr, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = usr
		W = R.selected_module()
		if(!W)
			var/count
			var/list/objects = list()
			if(usr:module_state_1)
				objects += usr:module_state_1
				count++
			if(usr:module_state_2)
				objects += usr:module_state_2
				count++
			if(usr:module_state_3)
				objects += usr:module_state_3
				count++
			if(count > 1)
				var/input = input("Please, select an item!", "Item", null, null) as obj in objects
				W = input
			else if(count != 0)
				for(var/obj in objects)
					W = obj
			else if(count == 0)
				W = null
	else
		W = usr.equipped()

	if (usr.stat)
		return

	if (usr.in_throw_mode)
		return usr:throw_item(src)

	if (W == src)
		spawn (0)
			W.attack_self(usr)
		return

	if ((usr.paralysis || usr.stunned || usr.weakened) && !istype(usr, /mob/living/silicon/ai))
		return

	if(!(src in usr.contents) && src.loc != usr.loc && !istype(src, /obj/effect/screen) && !usr.contents.Find(src.loc))
		if(!isturf(usr.loc))
			return
		if(!isturf(src) && src.loc && !isturf(src.loc) && !isturf(src.loc.loc))
			return

	var/in_range = in_range(src, usr) || src.loc == usr

	if(istype(usr, /mob/living/silicon/ai))
		in_range = 1

	if(istype(usr, /mob/living/silicon/robot) && !W)
		in_range = 1

	if(istype(src, /obj/effect/screen) || (in_range || (W && (W.flags & USEDELAY))))
		if(usr.next_move < world.time)
			usr.prev_move = usr.next_move
			usr.next_move = world.time + 10
		else
			return

	if ((in_range || (W && (W.flags & USEDELAY))) && !istype(src, /obj/effect/screen))
		if ((src.loc && (get_dist(src, usr) < 2 || src.loc == usr.loc)))
			var/direct = get_dir(usr, src)
			var/ok = 0
			if ( (direct - 1) & direct)
				var/turf/Step_1
				var/turf/Step_2
				switch(direct)
					if(EAST|NORTH)
						Step_1 = get_step(usr, NORTH)
						Step_2 = get_step(usr, EAST)
					if(EAST|SOUTH)
						Step_1 = get_step(usr, SOUTH)
						Step_2 = get_step(usr, EAST)
					if(NORTH|WEST)
						Step_1 = get_step(usr, NORTH)
						Step_2 = get_step(usr, WEST)
					if(SOUTH|WEST)
						Step_1 = get_step(usr, SOUTH)
						Step_2 = get_step(usr, WEST)

				if(Step_1 && Step_2)
					var/check_1 = CanReachThrough(get_turf(usr), Step_1, src) && CanReachThrough(Step_1, get_turf(src), src)
					var/check_2 = CanReachThrough(get_turf(usr), Step_2, src) && CanReachThrough(Step_2, get_turf(src), src)
					ok = (check_1 || check_2)
			else
				ok = CanReachThrough(get_turf(usr), get_turf(src), src)

			if (!ok)
				return 0

		if (!usr.restrained())
			if (W)
				src.AttackWeapon(usr, W, in_range)
			else
				src.AttackHandClick(usr)
		else
			src.AttackRestrainedClick(usr)

	else if(istype(src, /obj/effect/screen))
		if (!usr.restrained())
			src.AttackHandClick(usr)
		else
			src.AttackRestrainedClick(usr)
	return

	if(iscarbon(usr) && !usr.buckled)
		if(src.x && src.y && usr.x && usr.y)
			var/dx = src.x - usr.x
			var/dy = src.y - usr.y

			if(dy || dx)
				if(abs(dx) < abs(dy))
					if(dy > 0)	usr.dir = NORTH
					else		usr.dir = SOUTH
				else
					if(dx > 0)	usr.dir = EAST
					else		usr.dir = WEST
			else
				if(pixel_y > 16)		usr.dir = NORTH
				else if(pixel_y < -16)	usr.dir = SOUTH
				else if(pixel_x > 16)	usr.dir = EAST
				else if(pixel_x < -16)	usr.dir = WEST