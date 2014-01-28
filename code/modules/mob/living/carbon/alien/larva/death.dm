/mob/living/carbon/alien/larva/death(gibbed)
	if(stat == 2)
		return

	living_mob_list -= src
	dead_mob_list |= src

	if(healths)
		healths.icon_state = "health6"
	icon_state = "larva_l"
	stat = 2

	if (!gibbed)

		canmove = 0
		if(src.client)
			blind.layer = 0
		lying = 1

	return ..(gibbed)
