/atom/proc/hitby(atom/movable/AM as mob|obj)
	return

/atom/proc/add_fingerprint(mob/living/carbon/human/M as mob)
	if (!istype(M, /mob/living/carbon/human) || !istype(M.dna, /datum/dna))
		return 0
	add_fibers(M)
	if (!(src.flags & FPRINT))
		return
	if (M.gloves)
		if(src.fingerprintslast != M.key)
			src.fingerprintshidden += "(Wearing gloves). Real name: [M.real_name], Key: [M.key]"
			src.fingerprintslast = M.key
		return 0
	if (mFingerprints in M.mutations)
		if(src.fingerprintslast != M.key)
			src.fingerprintshidden += "(Has no fingerprints) Real name: [M.real_name], Key: [M.key]"
			src.fingerprintslast = M.key
		return 0
	if (!src.fingerprints)
		src.fingerprints = text("[]", md5(M.dna.uni_identity))
		if(src.fingerprintslast != M.key)
			src.fingerprintshidden += "Real name: [M.real_name], Key: [M.key]"
			src.fingerprintslast = M.key
		return 1
	else
		var/list/L = params2list(src.fingerprints)
		L -= md5(M.dna.uni_identity)
		while(L.len >= 3)
			L -= L[1]
		L += md5(M.dna.uni_identity)
		src.fingerprints = list2params(L)

		if(src.fingerprintslast != M.key)
			src.fingerprintshidden += "Real name: [M.real_name], Key: [M.key]"
			src.fingerprintslast = M.key
	return


//returns 1 if made bloody, returns 0 otherwise
/atom/proc/add_blood(mob/living/carbon/human/M as mob)
	if (!istype(M, /mob/living/carbon/human))
		return 0

	if (!(src.flags & FPRINT))
		return 0

	if(!blood_DNA || !istype(blood_DNA, /list))	//if our list of DNA doesn't exist yet (or isn't a list) initialise it.
		blood_DNA = list()

	//adding blood to items
	if (istype(src, /obj/item)&&!istype(src, /obj/item/weapon/melee/energy))//Only regular items. Energy melee weapon are not affected.
		var/obj/item/O = src

		//if we haven't made our blood_overlay already
		if(!O.blood_overlay)
			var/icon/I = new /icon(O.icon, O.icon_state)
			I.Blend(new /icon('icons/effects/blood.dmi', "thisisfuckingstupid"), ICON_ADD) //fills the icon_state with white (except where it's transparent)
			I.Blend(new /icon('icons/effects/blood.dmi', "itemblood"), ICON_MULTIPLY) //adds blood and the remaining white areas become transparant

			//not sure if this is worth it. It attaches the blood_overlay to every item of the same type if they don't have one already made.
			for(var/obj/item/A in world)
				if(A.type == O.type && !A.blood_overlay)
					A.blood_overlay = I

		//apply the blood-splatter overlay if it isn't already in there
		if(!blood_DNA.len)
			O.overlays += O.blood_overlay

		//if this blood isn't already in the list, add it

		if(blood_DNA[M.dna.unique_enzymes])
			return 0 //already bloodied with this blood. Cannot add more.
		blood_DNA[M.dna.unique_enzymes] = M.dna.blood_type
		return 1 //we applied blood to the item

	//adding blood to turfs
	else if (istype(src, /turf/simulated))
		var/turf/simulated/T = src

		//get one blood decal and infect it with virus from M.viruses
		for(var/obj/effect/decal/cleanable/blood/B in T.contents)
			if(!B.blood_DNA[M.dna.unique_enzymes])
				B.blood_DNA[M.dna.unique_enzymes] = M.dna.blood_type
			for(var/datum/disease/D in M.viruses)
				var/datum/disease/newDisease = D.Copy(1)
				B.viruses += newDisease
				newDisease.holder = B
			return 1 //we bloodied the floor

		//if there isn't a blood decal already, make one.
		var/obj/effect/decal/cleanable/blood/newblood = new /obj/effect/decal/cleanable/blood(T)
		newblood.blood_DNA[M.dna.unique_enzymes] = M.dna.blood_type
		for(var/datum/disease/D in M.viruses)
			var/datum/disease/newDisease = D.Copy(1)
			newblood.viruses += newDisease
			newDisease.holder = newblood
		return 1 //we bloodied the floor

	//adding blood to humans
	else if (istype(src, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = src
		//if this blood isn't already in the list, add it
		if(blood_DNA[H.dna.unique_enzymes])
			return 0 //already bloodied with this blood. Cannot add more.
		blood_DNA[H.dna.unique_enzymes] = H.dna.blood_type
		H.update_clothing()	//handles bloody hands overlays and updating
		return 1 //we applied blood to the item
	return

/atom/proc/clean_blood()
	if(istype(src, /obj))
		src:contaminated = 0
	if (!(src.flags & FPRINT))
		return
	if(blood_DNA.len)
		if(istype(src, /obj/item))
			var/obj/item/source2 = src
			source2.overlays -= source2.blood_overlay
			src.blood_DNA = list()
	return

/atom/proc/CanReachThrough(turf/srcturf, turf/targetturf, atom/target, pass_flags = PASSTABLE)
	var/obj/item/weapon/dummy/D = new /obj/item/weapon/dummy( srcturf )
	D.pass_flags = pass_flags

	if(targetturf.density && targetturf != get_turf(target))
		return 0

	//Now, check objects to block exit that are on the border
	for(var/obj/border_obstacle in srcturf)
		if(border_obstacle.flags & ON_BORDER)
			if(!border_obstacle.CheckExit(D, targetturf))
				del D
				return 0

	//Next, check objects to block entry that are on the border
	for(var/obj/border_obstacle in targetturf)
		if((border_obstacle.flags & ON_BORDER) && (src != border_obstacle))
			if(!border_obstacle.CanPass(D, srcturf, 1, 0))
				del D
				return 0

	del D
	return 1


/atom/proc/alog(var/atom/device,var/mob/mb)
	src.logs += "[src.name] used by a [device.name] by [mb.real_name]([mb.key])"
	mb.log_m("[src.name] used by a [device.name]")


/atom/proc/addoverlay(var/overlays)
	src.overlayslist += overlays
	src.overlays += overlays

/atom/proc/removeoverlay(var/overlays)
	if (istype(overlays, /image)) // This is needed due to the way overlayss work. The overlays being passed to this proc is in most instances not the same object, so we need to compare their attributes
		var/image/I = overlays
		for (var/image/L in src.overlayslist)
			if (L.icon == I.icon && L.icon_state == I.icon_state && L.dir == I.dir && L.layer == I.layer)
				src.overlayslist -= L
				break
	else
		src.overlayslist -= overlays
	src.overlays -= overlays // Seems that the overlayss list is special and is able to remove them. Suspect it does similar to the if block above.

/atom/proc/clearoverlays()
	src.overlayslist = new/list()
	src.overlays = null

/atom/proc/addalloverlays(var/list/overlayss)
	src.overlayslist = overlayss
	src.overlays = overlayss

/atom/movable/proc/forceMove(atom/destination)
	if(destination)
		if(loc)	loc.Exited(src)
		loc = destination
		loc.Entered(src)
		return 1
	return 0

/atom/proc/add_vomit_floor(mob/living/carbon/M as mob, var/toxvomit = 0)
	if( istype(src, /turf/simulated) )
		var/obj/effect/decal/cleanable/vomit/this = new /obj/effect/decal/cleanable/vomit(src)

		// Make toxins vomit look different
		if(toxvomit)
			this.icon_state = "vomittox_[pick(1,4)]"

		for(var/datum/disease/D in M.viruses)
			var/datum/disease/newDisease = D.Copy(1)
			this.viruses += newDisease
			newDisease.holder = this

// Only adds blood on the floor -- Skie
/atom/proc/add_blood_floor(mob/living/carbon/M as mob)
	if(istype(src, /turf/simulated))
		if(M.dna)	//mobs with dna = (monkeys + humans at time of writing)
			var/obj/effect/decal/cleanable/blood/B = locate() in contents
			if(!B)	B = new(src)
			B.blood_DNA[M.dna.unique_enzymes] = M.dna.blood_type

			for(var/datum/disease/D in M.viruses)
				var/datum/disease/newDisease = D.Copy(1)
				B.viruses += newDisease
				newDisease.holder = B

		else if(istype(M, /mob/living/carbon/alien))
			var/obj/effect/decal/cleanable/xenoblood/B = locate() in contents
			if(!B)	B = new(src)
			B.blood_DNA["UNKNOWN BLOOD"] = "X*"
		else if(istype(M, /mob/living/silicon/robot))
			var/obj/effect/decal/cleanable/oil/B = locate() in contents
			if(!B)	B = new(src)