/mob/living/silicon/decoy
	name = "AI"
	icon = 'icons/mob/ai.dmi'
	icon_state = "ai"
	anchored = 1 // -- TLE
	canmove = 0

/mob/living/silicon/decoy/Life()
	if (src.stat == 2)
		return
	else
		if (src.health <= -100 && src.stat != DEAD)
			death()
			return

/mob/living/silicon/decoy/updatehealth()
	if(status_flags & GODMODE)
		health = maxHealth
		stat = CONSCIOUS
		return
	health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()

/mob/living/silicon/decoy/death(gibbed)
	if(stat == DEAD)	return
	stat = DEAD
	icon_state = "ai-crash"

	for(var/obj/machinery/ai_status_display/O in world) //change status
		O.mode = 2
	return ..(gibbed)