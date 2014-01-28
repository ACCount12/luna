/mob/living/silicon/robot/death(gibbed)
	stat = 2
	canmove = 0

	living_mob_list -= src
	dead_mob_list |= src

	camera.status = 0.0

	if(blind)
		blind.layer = 0
	sight |= SEE_TURFS
	sight |= SEE_MOBS
	sight |= SEE_OBJS

	see_in_dark = 8
	see_invisible = 2
	update_icon()

	return ..(gibbed)