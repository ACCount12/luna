/mob/living/carbon/monkey/death(gibbed)
	if(stat == 2)
		return

	living_mob_list -= src
	dead_mob_list |= src

	if (healths)
		healths.icon_state = "health5"
	stat = 2
	canmove = 0
	if (blind)
		blind.layer = 0
	lying = 1
	var/h = hand
	hand = 0
	drop_item()
	hand = 1
	drop_item()
	hand = h

	if(!gibbed)
		visible_message("<b>[src]</b> lets out a faint chimper as it collapses and stops moving...")	//ded -- Urist
	return ..(gibbed)