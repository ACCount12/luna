/mob/living/Login()
	..()

	mind_initialize()	//updates the mind (or creates and initializes one if one doesn't exist)

	if (!isturf(loc))
		client.eye = loc
		client.perspective = EYE_PERSPECTIVE

	update_clothing()

	if(ticker && ticker.mode) // Updating game mode icons
		if(mind in ticker.mode.get_all_revolutionaries())
			ticker.mode.update_rev_icons_login(mind)

	if(stat == DEAD)
		verbs += /mob/living/proc/ghostize

	if(iscarbon(src))
		var/mob/living/carbon/C = src
		if(!C.hand)
			C.hands.dir = NORTH
		else
			C.hands.dir = SOUTH
