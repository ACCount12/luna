/obj/mecha/working/hoverpod
	name = "hover pod"
	icon_state = "engineering_pod"
	desc = "Stubby and round, it has a human sized access hatch on the top."
	wreckage = /obj/effect/decal/mecha_wreckage/hoverpod
	step_in = 3
	thrusters = 1

/obj/mecha/working/hoverpod/check_for_support()
	return 1

//duplicate of parent proc, but without space drifting
/obj/mecha/working/hoverpod/dyndomove(direction)
	if(!can_move)
		return 0
	if(src.pr_inertial_movement.active())
		return 0
	if(!has_charge(step_energy_drain))
		return 0
	var/move_result = 0
	if(hasInternalDamage(MECHA_INT_CONTROL_LOST))
		move_result = mechsteprand()
	else if(src.dir!=direction)
		move_result = mechturn(direction)
	else
		move_result	= mechstep(direction)
	if(move_result)
		can_move = 0
		use_power(step_energy_drain)
		if(do_after(step_in))
			can_move = 1
		return 1
	return 0

/obj/mecha/working/hoverpod/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/T

	T = new /obj/item/mecha_parts/mecha_equipment/tool/rcd
	T.attach(src)

	T = new /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
	T.attach(src)

//these three procs overriden to play different sounds
/obj/mecha/working/hoverpod/mechturn(direction)
	dir = direction
	//playsound(src,'sound/machines/hiss.ogg',40,1)
	return 1

/obj/mecha/working/hoverpod/mechstep(direction)
	var/result = step(src,direction)
	if(result)
		playsound(src,'sound/machines/hiss.ogg',40,1)
	return result

/obj/mecha/working/hoverpod/mechsteprand()
	var/result = step_rand(src)
	if(result)
		playsound(src,'sound/machines/hiss.ogg',40,1)
	return result

/obj/effect/decal/mecha_wreckage/hoverpod
	name = "hover pod wreckage"
	icon_state = "engineering_pod-broken"