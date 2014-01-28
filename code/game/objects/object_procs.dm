// Alters the emote of a mob from emote() - Abi79
/obj/proc/alterMobEmote(var/message, var/type, var/m_type, var/mob/living/user)
	return message

// Overrides the spoken message of a living mob from say() - Abi79
/obj/proc/overrideMobSay(var/message, var/mob/living/user)
	return "not used"

// Catches a message from say() - Headswe
obj/proc/catchMessage(msg,mob/source)
	return

/*/obj/machinery/door/catchMessage(msg,mob/source)
	if(!findtext(msg,"door,open") && !findtext(msg,"door,close"))
		return
	if(istype(source,/mob/living/carbon/human))
		if(!locate(source) in view(3,src))
			return
		if(src.allowed(source))
			for(var/mob/M in viewers(src))
				M << "[src]: Access Granted"
			if(src.density && findtext(msg,"door,open"))
				open()
			else if(findtext(msg,"door,close"))
				close()
		else
			for(var/mob/M in viewers(src))
				M << "[src]: Access Denied"*/

/obj/proc/state(var/msg, var/text_color) // Yup, hmm... need to look into how to actually change the color via text
	for(var/mob/O in hearers(src, null))
		O.show_message("\icon[src] \blue [msg]", 2)

/obj/proc/updateUsrDialog()
	if(in_use)
		var/is_in_use = 0
		var/list/nearby = viewers(1, src)
		for(var/mob/M in nearby)
			if ((M.client && M.machine == src))
				is_in_use = 1
				src.attack_hand(M)
		if (istype(usr, /mob/living/silicon/ai) || istype(usr, /mob/living/silicon/robot))
			if (!(usr in nearby))
				if (usr.client && usr.machine==src)
					is_in_use = 1
					src.attack_ai(usr)

/*		// check for TK users
		if (istype(usr, /mob/living/carbon/human))
			if(istype(usr.l_hand, /obj/item/tk_grab) || istype(usr.r_hand, /obj/item/tk_grab/))
				if(!(usr in nearby))
					if(usr.client && usr.machine==src)
						is_in_use = 1
						src.attack_hand(usr)*/
		in_use = is_in_use

/obj/proc/updateDialog()
	// Check that people are actually using the machine. If not, don't update anymore.
	if(in_use)
		var/list/nearby = viewers(1, src)
		var/is_in_use = 0
		for(var/mob/M in nearby)
			if(M.client && M.machine == src)
				is_in_use = 1
				src.interact(M)
		var/ai_in_use = AutoUpdateAI(src)

		if(!ai_in_use && !is_in_use)
			in_use = 0

/obj/machinery/updateDialog()
	if(!(stat & BROKEN)) // unbroken
		..()

/obj/item/proc/updateSelfDialog()
	var/mob/M = src.loc
	if(istype(M) && M.client && M.machine == src)
		src.attack_self(M)

