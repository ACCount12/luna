/obj/machinery/clonepod
	anchored = 1
	name = "cloning pod"
	desc = "An electronically-lockable pod for growing organic tissue."
	density = 1
	icon = 'cloning.dmi'
	icon_state = "pod"
	req_access = list(access_medlab) //For premature unlocking.
	var/mob/living/occupant
	var/heal_level = 80 //The clone is released once its health reaches this level.
	var/locked = 0
	var/obj/machinery/computer/cloning/connected = null //So we remember the connected clone machine.
	var/mess = 0 //Need to clean out it if it's full of exploded clone.
	var/attempting = 0 //One clone attempt at a time thanks
	var/eject_wait = 0 //Don't eject them as soon as they are created fuckkk

/obj/machinery/clonepod/attack_hand(mob/user as mob)
	if (isnull(occupant) || (stat & NOPOWER))
		return
	if (occupant.stat != DEAD)
		var/completion = (100 * ((occupant.health + 100) / (heal_level + 100)))
		user << "Current clone cycle is [round(completion)]% complete."
	return

/obj/machinery/clonepod/update_icon()
	icon_state = "pod"
	if(mess)
		icon_state = "pod_gibs"
	else if(occupant)
		icon_state = "pod_clone"

//Start growing a human clone in the pod!
/obj/machinery/clonepod/proc/growclone(mob/ghost as mob, var/clonename, var/ui, var/se, var/mindref, var/mutantrace)
	if (!ghost || !ghost.client || mess || attempting)
		return 0

	attempting = 1 //One at a time!!
	locked = 1

	eject_wait = 1
	spawn(30)
		src.eject_wait = 0

	occupant = new /mob/living/carbon/human(src)
	ghost.client.mob = src.occupant

	update_icon()
	//Get the clone body ready
	occupant.rejuv = 10
	occupant.bruteloss += rand(60, 90)
	occupant.toxloss += 30
	occupant.oxyloss += 40
	occupant.brainloss += rand(60, 90)
	occupant.paralysis += 4

	//Here let's calculate their health so the pod doesn't immediately eject them!!!
	occupant.health = (occupant.bruteloss + occupant.toxloss + occupant.oxyloss)

	occupant << "\blue <b>Clone generation process initiated.</b>"
	occupant << "\blue This will take a moment, please hold."

	if (clonename)
		occupant.real_name = clonename
	else
		occupant.real_name = "Unknown"  //No null names!!

	var/datum/mind/clonemind = (locate(mindref) in ticker.minds)

	if (clonemind && istype(clonemind)) //Move that mind over!!
		clonemind.transfer_to(src.occupant)
	else //welp
		occupant.mind = new /datum/mind(  )
		occupant.mind.key = src.occupant.key
		occupant.mind.current = src.occupant
		occupant.mind.transfer_to(src.occupant)
		ticker.minds += src.occupant.mind

	// -- Mode/mind specific stuff goes here
	if ((occupant.mind in ticker.mode.revolutionaries) || (occupant.mind in ticker.mode.head_revolutionaries))
		//ticker.mode.add_revolutionary(occupant.mind)
		ticker.mode.update_rev_icons_added(occupant.mind)

	// -- End mode specific stuff

	if(istype(ghost, /mob/dead/observer))
		del(ghost) //Don't leave ghosts everywhere!!

	if(!occupant.dna)
		occupant.dna = new /datum/dna(  )
	if(ui)
		occupant.dna.uni_identity = ui
		updateappearance(src.occupant, ui)
	if(se)
		occupant.dna.struc_enzymes = se
		//Cloning now causes ALOT more genetic defects
		for(var/i = 0 to 20)
			randmutb(src.occupant) //Sometimes the clones come out wrong.
	if(mutantrace)
		occupant.dna.mutantrace = mutantrace

	src.attempting = 0
	return 1

//Grow clones to maturity then kick them out. FREELOADERS
/obj/machinery/clonepod/process()
	if (stat & NOPOWER) //Autoeject if power is lost
		if (occupant)
			locked = 0
			go_out()
		return

	if (occupant && (occupant.loc == src))
		if(occupant.stat == DEAD || occupant.suiciding)  //Autoeject corpses and suiciding dudes.
			locked = 0
			go_out()
			connected_message("Clone Rejected: Deceased.")
			return

		else if(occupant.health < heal_level)
			occupant.paralysis = 4

			 //Slowly get that clone healed and finished.
			occupant.bruteloss = max(src.occupant.bruteloss-1, 0)

			//At this rate one clone takes about 95 seconds to produce.(with heal_level 90)
			occupant.toxloss = max(src.occupant.toxloss-0.1, 0)

			//Premature clones may have brain damage.
			occupant.brainloss = max(src.occupant.brainloss-1, 0)

			//So clones don't die of oxyloss in a running pod.
			if(occupant.reagents.get_reagent_amount("inaprovaline") < 30)
				occupant.reagents.add_reagent("inaprovaline", 60)

			//Stop baking in the tubes you jerks.
			occupant.adjustFireLoss(-2)

			use_power(65000) //This might need tweaking.
			return

		else if((occupant.health >= heal_level) && !eject_wait)
			connected_message("Cloning Process Complete.")
			locked = 0
			occupant.toxloss = 150
			go_out()
			return

	else
		occupant = null
		if(locked)
			locked = 0
		use_power(200)
		return

	return

//Let's unlock this early I guess.  Might be too early, needs tweaking.
/obj/machinery/clonepod/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))
		if (!src.check_access(W))
			user << "\red Access Denied."
			return
		if (!locked || isnull(src.occupant))
			return
		if ((src.occupant.health < -20) && (src.occupant.stat != DEAD))
			user << "\red Access Refused."
			return
		else
			locked = 0
			user << "System unlocked."
	else if (istype(W, /obj/item/weapon/card/emag))
		if (isnull(occupant))
			return
		user << "You force an emergency ejection."
		src.locked = 0
		src.go_out()
		return
	else
		..()

//Put messages in the connected computer's temp var for display.
/obj/machinery/clonepod/proc/connected_message(var/message)
	if ((isnull(src.connected)) || (!istype(src.connected, /obj/machinery/computer/cloning)))
		return 0
	if (!message)
		return 0

	src.connected.temp = message
	src.connected.updateUsrDialog()
	return 1

/obj/machinery/clonepod/verb/eject()
	set src in oview(1)

	if (usr.stat)
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/clonepod/proc/go_out()
	if(locked)
		return

	if(mess) //Clean that mess and dump those gibs!
		mess = 0
		gibs(src.loc)
		update_icon()
		for(var/obj/O in src)
			O.loc = src.loc
		return

	if(!occupant)
		return
	for(var/obj/O in src)
		O.loc = src.loc

	if(occupant.client)
		occupant.client.eye = src.occupant.client.mob
		occupant.client.perspective = MOB_PERSPECTIVE
	occupant.loc = src.loc
	update_icon()
	eject_wait = 0 //If it's still set somehow.
	occupant.toxloss = max(occupant.toxloss,101)
	domutcheck(occupant) //Waiting until they're out before possible monkeyizing.
	occupant = null
	return

/obj/machinery/clonepod/proc/malfunction()
	if (occupant)
		connected_message("Critical Error!")
		mess = 1
		update_icon()
		occupant.ghostize()
		spawn(5)
			del(occupant)
	return

/obj/machinery/clonepod/relaymove(mob/user as mob)
	if (user.stat)
		return
	src.go_out()
	return

/obj/machinery/clonepod/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
			del(src)
			return
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				del(src)
				return
		if(3.0)
			if (prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				del(src)
				return
		else
	return

/obj/machinery/clonepod/emp_act(severity)
	if(prob(90/severity))
		malfunction()