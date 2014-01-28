/world/New()
	..()

	//

	diary = file("data/logs/[time2text(world.realtime, "YYYY/MM-Month/DD-Day")].log")
	diary << ""
	diary << ""
	diary << "Starting up. [time2text(world.timeofday, "hh:mm.ss")]"
	diary << "---------------------"
	diary << ""

	//jobban_loadbanfile()
	//jobban_updatelegacybans()

	setuptitles()
	spawn
		SetupAnomalies()
		//tgrid.Setup() //Part of Alfie's travel code
	spawn(30 * tick_multiplier)
		//EXPERIMENTAL
		Optimize()
		sleep_offline = 1
		//EXPERIMENTAL

	spawn(0)
		SetupOccupationsList()
		return


/// EXPERIMENTAL STUFF
var/opt_inactive = null
/world/proc/Optimize()
	if(!opt_inactive) opt_inactive  = world.timeofday

	if(world.timeofday - opt_inactive >= 600)
		KickInactiveClients()
		opt_inactive = world.timeofday

	spawn(100 * tick_multiplier) Optimize()

/world/proc/KickInactiveClients()
	for(var/client/C)
		if(!C.holder && ((C.inactivity/10)/60) >= 15)
			C << "\red You have been inactive for more than 15 minutes and have been disconnected."
			del(C)

/// EXPERIMENTAL STUFF

// This function counts a passed job.
proc/countJob(rank)
	var/jobCount = 0
	for(var/mob/H in world)
		if(H.mind && H.mind.assigned_role == rank)
			jobCount++
	return jobCount

/mob/living/carbon/human/proc/equip_if_possible(obj/item/weapon/W, slot) // since byond doesn't seem to have pointers, this seems like the best way to do this :/
	//warning: icky code
	var/equipped = 0
	if((slot == l_store || slot == r_store || slot == belt || slot == wear_id) && !w_uniform)
		del(W)
		return
	switch(slot)
		if(slot_back)
			if(!back)
				back = W
				equipped = 1
		if(slot_wear_mask)
			if(!wear_mask)
				wear_mask = W
				equipped = 1
		if(slot_handcuffed)
			if(!handcuffed)
				handcuffed = W
				equipped = 1
		if(slot_l_hand)
			if(!src.l_hand)
				src.l_hand = W
				equipped = 1
		if(slot_r_hand)
			if(!src.r_hand)
				src.r_hand = W
				equipped = 1
		if(slot_belt)
			if(!belt)
				belt = W
				equipped = 1
		if(slot_wear_id)
			if(!wear_id)
				wear_id = W
				equipped = 1
		if(slot_ears)
			if(!ears)
				ears = W
				equipped = 1
		if(slot_glasses)
			if(!glasses)
				glasses = W
				equipped = 1
		if(slot_gloves)
			if(!gloves)
				gloves = W
				equipped = 1
		if(slot_head)
			if(!head)
				head = W
				equipped = 1
		if(slot_shoes)
			if(!shoes)
				shoes = W
				equipped = 1
		if(slot_wear_suit)
			if(!wear_suit)
				wear_suit = W
				equipped = 1
		if(slot_w_uniform)
			if(!w_uniform)
				w_uniform = W
				equipped = 1
		if(slot_l_store)
			if(!l_store)
				l_store = W
				equipped = 1
		if(slot_r_store)
			if(!r_store)
				r_store = W
				equipped = 1
		if(slot_in_backpack)
			if (back && istype(back, /obj/item/weapon/storage/backpack))
				var/obj/item/weapon/storage/backpack/B = back
				if(B.contents.len < 7 && W.w_class <= 3)
					W.loc = B
					equipped = 1
					W.loc = B

	if(equipped)
		W.layer = 20
		if(!(slot == slot_in_backpack))
			W.loc = src
	else
		del(W)


/proc/AutoUpdateAI(obj/subject)
	var/is_in_use = 0
	if (subject!=null)
		for(var/mob/living/silicon/ai/M in mob_list)
			if(M.client && M.machine == subject)
				is_in_use = 1
				subject.attack_ai(M)
	return is_in_use