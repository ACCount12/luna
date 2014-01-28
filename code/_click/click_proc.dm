/atom/proc/AttackHandClick(var/mob/living/user)
	if(istype(user, /mob/living/carbon/human))
		if(!istype(user.gloves))
			src.attack_hand(user, user.hand)
		else if(!user.gloves.attack_gloved(src, user, user.hand))
			src.attack_hand(user, user.hand)

	else if(istype(user, /mob/living/carbon/monkey))
		src.attack_paw(user, user.hand)
	else if(istype(user, /mob/living/carbon/alien/humanoid))
		src.attack_alien(user, user.hand)
	else if(istype(user, /mob/living/silicon))
		src.attack_ai(user, user.hand)
	else if(isslime(user))
		src.attack_slime(usr)
	else if(isanimal(user))
		src.attack_animal(usr)

/atom/proc/AttackRestrainedClick(var/mob/living/user)
	if(istype(user, /mob/living/carbon/human))
		src.hand_h(user, user.hand)
	else if(istype(user, /mob/living/carbon/monkey))
		src.hand_p(user, user.hand)
	else if(istype(user, /mob/living/carbon/alien/humanoid))
		src.hand_al(user, user.hand)
	else if(istype(user, /mob/living/silicon))
		src.hand_a(user, user.hand)


/atom/proc/AltClick()
	if(hascall(src,"pull") && !isAI(usr))
		src:pull()
	return

/atom/proc/CtrlClick()
	if(hascall(src,"pull") && !isAI(usr))
		src:pull()
	return

/atom/proc/ShiftClick(var/mob/M as mob)
	if(!istype(M.machine, /obj/machinery/computer/security) && !isAI(usr))
		examine() //No examining by looking through cameras
	return

/atom/proc/AttackWeapon(var/mob/user, var/obj/item/W, var/in_range)
	if(!W) return 0

	if (in_range)
		src.alog(W, user)
		src.attackby(W, user)

	if (W) // Still here, not deleted
		W.afterattack(src, user, (in_range ? 1 : 0))

/atom/proc/attack_hand(mob/user as mob)
	return

/atom/proc/attack_paw(mob/user as mob)
	return

/atom/proc/attack_ai(mob/user as mob)
	return

/atom/proc/attack_animal(mob/user as mob)
	return

/atom/proc/attack_alien(mob/user as mob)
	src.attack_paw(user)
	return


/atom/proc/hand_h(mob/user as mob)
	return

/atom/proc/hand_p(mob/user as mob)
	return

/atom/proc/hand_a(mob/user as mob)
	return

/atom/proc/hand_al(mob/user as mob)
	src.hand_p(user)
	return


/atom/proc/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(!(W.flags & NOHIT))
		for(var/mob/O in viewers(src, null))
			if (O.client && !O.blinded)
				O << "\red <B>[src] has been hit by [user] with [W]</B>"
	return