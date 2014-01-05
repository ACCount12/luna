/mob/living/silicon/ai/Logout()
	..()
	for(var/obj/machinery/ai_status_display/O in world) //change status
		spawn( 0 )
		O.mode = 0

	if(!isturf(loc))
		if (client)
			client.eye = loc
			client.perspective = EYE_PERSPECTIVE
	src.view_core()
	return

	if (stat == DEAD)
		verbs += /mob/living/proc/ghostize
	return