/obj/machinery/dna_scannernew
	name = "DNA Scanner"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "scanner"
	density = 1
	anchored = 1

	var/open = 0
	var/locked = 0
	var/mob/occupant = null
	var/datum/wires/dnascanner/wires = null
	var/pulsing = 0

	var/scan_level = 0
	var/damage_coeff = 0
	var/precision_coeff = 0

	var/radduration = 2
	var/radstrength = 1

/obj/machinery/dna_scannernew/New()
	..()
	wires = new(src)

	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/machine/clonescanner(null)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/cable_coil(null, 1)
	component_parts += new /obj/item/weapon/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/dna_scannernew/RefreshParts()
	scan_level = 0
	damage_coeff = 0
	precision_coeff = 0
	for(var/obj/item/weapon/stock_parts/scanning_module/P in component_parts)
		scan_level += P.rating
	for(var/obj/item/weapon/stock_parts/manipulator/P in component_parts)
		precision_coeff += P.rating
	for(var/obj/item/weapon/stock_parts/micro_laser/P in component_parts)
		damage_coeff += P.rating

/obj/machinery/dna_scannernew/relaymove(mob/user as mob)
	if (user.stat)
		return
	go_out()
	return

/obj/machinery/dna_scannernew/update_icon()
	if(occupant)
		icon_state = "scanner_occupant"
	else
		icon_state = "scanner"
	overlays.Cut()
	if(open)
		overlays.Add(image('icons/obj/Cryogenic2.dmi', src, "scanner_open"))

/obj/machinery/dna_scannernew/proc/toggle_lock()
	if(!wires.IsIndexCut(DNASCAN_WIRE_LOCK))
		locked = !locked

/obj/machinery/dna_scannernew/proc/get_occupant()
	if((NOCLONE in occupant.mutations) && scan_level < 2)
		return null
	if(wires.IsIndexCut(DNASCAN_WIRE_DATA) || !occupant)
		return null
	else
		return occupant

/obj/machinery/dna_scannernew/proc/radpulse()
	if (!occupant || wires.IsIndexCut(DNASCAN_WIRE_RAD) || pulsing)
		return 0

	pulsing = 1
	var/prevlock = locked
	locked = 1 //lock it

	sleep(10*radduration)

	if (!occupant)
		pulsing = 0
		locked = 0
		return 0

	if (prob(95))
		if(prob(75))randmutb(occupant)
		else		randmuti(occupant)
	else
		if(prob(95))randmutg(occupant)
		else		randmuti(occupant)

	pulsing = 0
	occupant.radiation += ((radstrength*3)+radduration*3)
	locked = prevlock

/obj/machinery/dna_scannernew/proc/uni_pulse(var/uniblock = 1, var/subblock = 1, var/unitarget = 1)
	if (!occupant || wires.IsIndexCut(DNASCAN_WIRE_RAD) || pulsing)
		return 0

	pulsing = 1
	var/block = getblock(getblock(occupant.dna.uni_identity,uniblock,3),subblock,1)
	var/newblock
	var/tstructure2

	var/lock_state = locked
	locked = 1//lock it

	sleep(10*radduration)
	if (!occupant)
		locked = 0
		pulsing = 0
		return 0

	if (prob((80 + (radduration / 2))))
		block = miniscrambletarget(num2text(unitarget), radstrength, radduration)
		newblock = null
		switch(subblock)
			if(1) newblock = block + getblock(getblock(occupant.dna.uni_identity,uniblock,3),2,1) + getblock(getblock(occupant.dna.uni_identity,uniblock,3),3,1)
			if(2) newblock = getblock(getblock(occupant.dna.uni_identity,uniblock,3),1,1) + block + getblock(getblock(occupant.dna.uni_identity,uniblock,3),3,1)
			if(3) newblock = getblock(getblock(occupant.dna.uni_identity,uniblock,3),1,1) + getblock(getblock(occupant.dna.uni_identity,uniblock,3),2,1) + block
		tstructure2 = setblock(occupant.dna.uni_identity, uniblock, newblock,3)
		occupant.dna.uni_identity = tstructure2
		updateappearance(occupant,occupant.dna.uni_identity)
		occupant.radiation += (radstrength+radduration)
	else
		if(prob(20 + radstrength))
			randmutb(occupant)
			domutcheck(occupant, src)
		else
			randmuti(occupant)
			updateappearance(occupant, occupant.dna.uni_identity)
		occupant.radiation += ((radstrength*2) + radduration)
	locked = lock_state
	pulsing = 0
	return 1

/obj/machinery/dna_scannernew/proc/struct_pulse(var/strucblock = 1, var/subblock = 1)
	if (!occupant || wires.IsIndexCut(DNASCAN_WIRE_RAD) || pulsing)
		return 0

	pulsing = 1
	var/block = getblock(getblock(occupant.dna.struc_enzymes,strucblock,3),subblock,1)
	var/newblock
	var/tstructure2
	var/oldblock
	var/lock_state = locked
	locked = 1//lock it

	sleep(10*radduration)

	if(!occupant)
		locked = 0
		pulsing = 0
		return 0

	if(prob((95 + (radduration / 2))))
		if(prob(10))
			oldblock = strucblock
			block = miniscramble(block, radstrength, radduration)
			newblock = null
			if (strucblock > 1 && strucblock < STRUCDNASIZE/2)
				strucblock++
			else if (strucblock > STRUCDNASIZE/2 && strucblock < STRUCDNASIZE)
				strucblock--
			switch(subblock)
				if(1) newblock = block + getblock(getblock(occupant.dna.struc_enzymes,strucblock,3),2,1) + getblock(getblock(occupant.dna.struc_enzymes,strucblock,3),3,1)
				if(2) newblock = getblock(getblock(occupant.dna.struc_enzymes,strucblock,3),1,1) + block + getblock(getblock(occupant.dna.struc_enzymes,strucblock,3),3,1)
				if(3) newblock = getblock(getblock(occupant.dna.struc_enzymes,strucblock,3),1,1) + getblock(getblock(occupant.dna.struc_enzymes,strucblock,3),2,1) + block
			tstructure2 = setblock(occupant.dna.struc_enzymes, strucblock, newblock,3)
			occupant.dna.struc_enzymes = tstructure2
			domutcheck(occupant,src)
			occupant.radiation += (radstrength+radduration)
			strucblock = oldblock
		else
			block = miniscramble(block, radstrength, radduration)
			newblock = null
			switch(subblock)
				if(1) newblock = block + getblock(getblock(occupant.dna.struc_enzymes,strucblock,3),2,1) + getblock(getblock(occupant.dna.struc_enzymes,strucblock,3),3,1)
				if(2) newblock = getblock(getblock(occupant.dna.struc_enzymes,strucblock,3),1,1) + block + getblock(getblock(occupant.dna.struc_enzymes,strucblock,3),3,1)
				if(3) newblock = getblock(getblock(occupant.dna.struc_enzymes,strucblock,3),1,1) + getblock(getblock(occupant.dna.struc_enzymes,strucblock,3),2,1) + block
			tstructure2 = setblock(occupant.dna.struc_enzymes, strucblock, newblock,3)
			occupant.dna.struc_enzymes = tstructure2
			domutcheck(occupant,src)
			occupant.radiation += (radstrength+radduration)
	else
		if(prob(80-radduration))
			randmutb(occupant)
			domutcheck(occupant,src)
		else
			randmuti(occupant)
			updateappearance(occupant,occupant.dna.uni_identity)
		occupant.radiation += ((radstrength*2)+radduration)

	locked = lock_state
	pulsing = 0
	return 1

/obj/machinery/dna_scannernew/verb/eject()
	set src in oview(1)
	if(usr.stat)
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/dna_scannernew/verb/move_inside()
	set src in oview(1)
	if (usr.stat)
		return

	if(occupant)
		usr << "\blue <B>The scanner is already occupied!</B>"
		return
	if(usr.abiotic())
		usr << "\blue <B>Subject cannot have abiotic items on.</B>"
		return
	usr.pulling = null
	usr.client.perspective = EYE_PERSPECTIVE
	usr.client.eye = src
	usr.loc = src
	src.occupant = usr
	update_icon()
	src.add_fingerprint(usr)
	return

/obj/machinery/dna_scannernew/attackby(obj/item/weapon/grab/G as obj, user as mob)
	if(istype(G, /obj/item/weapon/screwdriver))
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		open = !open
		if(open)
			user << "<span class='notice'>You open the maintenance panel of [src].</span>"
		else
			user << "<span class='notice'>You close the maintenance panel of [src].</span>"
		update_icon()
		return

	if(istype(G, /obj/item/weapon/crowbar))
		if(open)
			for(var/obj/I in contents) // in case there is something in the scanner
				I.loc = src.loc
			default_deconstruction_crowbar()
		return


	if (!istype(G, /obj/item/weapon/grab) || !ismob(G.affecting))
		return

	if (occupant)
		user << "\blue <B>The scanner is already occupied!</B>"
		return
	if (G.affecting.abiotic())
		user << "\blue <B>Subject cannot have abiotic items on.</B>"
		return
	var/mob/M = G.affecting
	if (M.client)
		M.client.perspective = EYE_PERSPECTIVE
		M.client.eye = src
	M.loc = src
	src.occupant = M
	update_icon()
	src.add_fingerprint(user)
	del(G)
	return

/obj/machinery/dna_scannernew/proc/go_out()
	if (!occupant || locked)
		return
	for(var/obj/O in src)
		O.loc = src.loc
	if (occupant.client)
		occupant.client.eye = src.occupant.client.mob
		occupant.client.perspective = MOB_PERSPECTIVE
	src.occupant.loc = src.loc
	src.occupant = null
	update_icon()
	return

/obj/machinery/dna_scannernew/ex_act(severity)
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


/obj/machinery/dna_scannernew/blob_act()
	if(prob(50))
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
		del(src)