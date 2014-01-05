/obj/machinery/computer/security
	name = "security cameras"
	icon_state = "seccam"
	circuit = /obj/item/weapon/circuitboard/computer/security
	var/obj/machinery/camera/current = null
	var/last_pic = 1.0
	var/network = "Luna"
	var/maplevel = 1

/obj/machinery/computer/security/wooden_tv
	icon_state = "security_det"


/obj/machinery/computer/security/telescreen
	name = "telescreen"
	icon = 'stationobjs.dmi'
	icon_state = "telescreen"
	network = "thunder"
	density = 0

/obj/machinery/computer/security/New()
	..()
	verbs -= /obj/machinery/computer/security/verb/station_map

/obj/machinery/computer/security/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/security/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/security/check_eye(var/mob/user as mob)
	if ((get_dist(user, src) > 1 || !( user.canmove ) || user.blinded || !( src.current ) || !( src.current.status )) && (!istype(user, /mob/living/silicon)))
		return null
	user.reset_view(src.current)
	return 1

/obj/machinery/computer/security/attack_hand(var/mob/user as mob)
	if (stat & (NOPOWER|BROKEN))
		return

	user.machine = src

	var/list/L = list()
	for (var/obj/machinery/camera/C in world)
		L.Add(C)

	camera_sort(L)

	var/list/D = list()
	D["Cancel"] = "Cancel"
	for (var/obj/machinery/camera/C in L)
		if (network in C.network)
			D[text("[][]", C.c_tag, (C.status ? null : " (Deactivated)"))] = C

	var/t = input(user, "Which camera should you change to?") as null|anything in D

	if(!t)
		user.machine = null
		return 0

	var/obj/machinery/camera/C = D[t]

	if (t == "Cancel")
		user.machine = null
		return 0

	if ((get_dist(user, src) > 1 || user.machine != src || user.blinded || !user.canmove || !C.status) && !istype(user, /mob/living/silicon/ai))
		return 0
	else
		src.current = C
		use_power(50)

		spawn( 5 )
			attack_hand(user)

/*mob/living/silicon/ai/attack_ai(var/mob/user as mob)
	if (user != src)
		return

	if (stat == 2)
		return

	user.machine = src

	var/list/L = list()
	for (var/obj/machinery/camera/C in world)
		L.Add(C)

	camera_sort(L)

	var/list/D = list()
	D["Cancel"] = "Cancel"
	for (var/obj/machinery/camera/C in L)
		if (network in C.network)
			D[text("[][]", C.c_tag, (C.status ? null : " (Deactivated)"))] = C

	var/t = input(user, "Which camera should you change to?") as null|anything in D

	if (!t || t == "Cancel")
		switchCamera(null)
		return 0

	var/obj/machinery/camera/C = D[t]

	switchCamera(C)

	return*/


/obj/machinery/camera
	name = "security camera"
	desc = "It's used to monitor rooms. The wires are exposed."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "camera"
	use_power = 2
	idle_power_usage = 5
	active_power_usage = 10
	layer = 5
	anchored = 1.0
	networking = PROCESS_RPCS
	security = 1

	var/list/network = list("Luna", "Malf")
	var/c_tag = null
	var/c_tag_order = 999
	var/status = 1
	var/invuln = null
	var/bugged = 0
	var/obj/item/weapon/camera_assembly/assembly = null

	//OTHER
	var/view_range = 7
	var/short_range = 2

	var/busy = 0
	var/emped = 0  //Number of consecutive EMP's on this camera

/obj/machinery/camera/call_function(datum/function/F)
	..()
	if(uppertext(F.arg1) != net_pass)
		var/datum/function/R = new()
		R.name = "response"
		R.source_id = address
		R.destination_id = F.source_id
		R.arg1 += "Incorrect access token"
		send_packet(src,F.source_id,R)
		return 0 // send a wrong password really.
	if(F.name == "disable")
		src.status = 0
	else if(F.name == "enable")
		src.status = 1

/obj/machinery/camera/ex_act(severity)
	if(src.invuln)
		return
	else
		..(severity)
	return

/obj/machinery/camera/blob_act()
	return

/obj/machinery/camera/New()
	assembly = new(src)
	assembly.state = 4
	assembly.anchored = 1
	assembly.update_icon()
	..()

/obj/machinery/camera/emp_act(severity)
	if(!isEmpProof())
		if(prob(100/severity))
			icon_state = "[initial(icon_state)]emp"
			var/list/previous_network = network
			network = list()
			cameranet.removeCamera(src)
			stat |= EMPED
			emped = emped+1  //Increase the number of consecutive EMP's
			var/thisemp = emped //Take note of which EMP this proc is for
			spawn(900)
				if(emped == thisemp) //Only fix it if the camera hasn't been EMP'd again
					network = previous_network
					icon_state = initial(icon_state)
					stat &= ~EMPED
					if(can_use())
						cameranet.addCamera(src)
					emped = 0 //Resets the consecutive EMP count
			for(var/mob/O in mob_list)
				if (O.client && O.client.eye == src)
					O.unset_machine()
					O.reset_view(null)
					O << "The screen bursts into static."
			..()


/obj/machinery/camera/ex_act(severity)
	if(src.invuln)
		return
	else
		..(severity)
	return

/obj/machinery/camera/blob_act()
	del(src)
	return

/obj/machinery/camera/proc/setViewRange(var/num = 7)
	src.view_range = num
	cameranet.updateVisibility(src, 0)

/obj/machinery/camera/attack_paw(mob/living/carbon/alien/humanoid/user as mob)
	if(!istype(user))
		return
	status = 0
	visible_message("<span class='warning'>\The [user] slashes at [src]!</span>")
	playsound(src.loc, 'sound/weapons/slash.ogg', 100, 1)
	icon_state = "[initial(icon_state)]1"
	deactivate(user,0)

/obj/machinery/camera/attackby(W as obj, mob/living/user as mob)
	// DECONSTRUCTION
	if(istype(W, /obj/item/weapon/wirecutters))
		deactivate(user)
	else if(istype(W, /obj/item/weapon/weldingtool) && !status)
		if(weld(W, user))
			if(assembly)
				assembly.loc = src.loc
				assembly.state = 1
			del(src)

	// OTHER
	else if ((istype(W, /obj/item/weapon/paper) /*|| istype(W, /obj/item/device/pda)*/) && isliving(user))
		var/mob/living/U = user
		var/obj/item/weapon/paper/X = null
		//var/obj/item/device/pda/P = null

		var/itemname = ""
		var/info = ""
		if(istype(W, /obj/item/weapon/paper))
			X = W
			itemname = X.name
			info = X.info
		//else
		//	P = W
		//	itemname = P.name
		//	info = P.notehtml

		U << "You hold \the [itemname] up to the camera ..."
		for(var/mob/O in player_list)
			if(istype(O, /mob/living/silicon/ai))
				var/mob/living/silicon/ai/AI = O
				if(U.name == "Unknown") AI << "<b>[U]</b> holds \a [itemname] up to one of your cameras ..."
				else AI << "<b><a href='byond://?src=\ref[O];track2=\ref[O];track=\ref[U]'>[U]</a></b> holds \a [itemname] up to one of your cameras..."
				AI << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", itemname, info), text("window=[]", itemname))
			else if (O.client && O.client.eye == src)
				O << "[U] holds \a [itemname] up to one of the cameras ..."
				O << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", itemname, info), text("window=[]", itemname))

	else if (istype(W, /obj/item/device/camera_bug))
		if (!src.can_use())
			user << "\blue Camera non-functional"
			return
		if(bugged)
			user << "\blue Camera bug removed."
			bugged = 0
		else
			user << "\blue Camera bugged."
			bugged = 1
	else
		..()
	return

/obj/machinery/camera/proc/deactivate(user as mob, var/choice = 1)
	if(choice==1)
		status = !src.status
		if (!src.status)
			if(user)
				visible_message("\red [user] has deactivated [src]!")
			else
				visible_message("\red \The [src] deactivates!")
			playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
			icon_state = "[initial(icon_state)]1"

		else
			if(user)
				visible_message("\red [user] has reactivated [src]!")
			else
				visible_message("\red \the [src] reactivates!")
			playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
			icon_state = initial(icon_state)

	// now disconnect anyone using the camera
	//Apparently, this will disconnect anyone even if the camera was re-activated.
	//I guess that doesn't matter since they can't use it anyway?
	for(var/mob/O in player_list)
		if (O.client && O.client.eye == src)
			O.unset_machine()
			O.reset_view(null)
			O << "The screen bursts into static."

/obj/machinery/camera/proc/can_use()
	if(!status)
		return 0
	if(stat & EMPED)
		return 0
	return 1

/obj/machinery/camera/proc/can_see()
	var/list/see = null
	var/turf/pos = get_turf(src)
	if(isXRay())
		see = range(view_range, pos)
	else
		see = hear(view_range, pos)
	return see

/atom/proc/auto_turn()
	//Automatically turns based on nearby walls.
	var/turf/simulated/wall/T = null
	for(var/i = 1, i <= 8; i += i)
		T = get_ranged_target_turf(src, i, 1)
		if(istype(T))
			//If someone knows a better way to do this, let me know. -Giacom
			switch(i)
				if(NORTH)
					src.dir = SOUTH
				if(SOUTH)
					src.dir = NORTH
				if(WEST)
					src.dir = EAST
				if(EAST)
					src.dir = WEST
			break

//Return a working camera that can see a given mob
//or null if none
/proc/seen_by_camera(var/mob/M)
	for(var/obj/machinery/camera/C in oview(4, M))
		if(C.can_use())	// check if camera disabled
			return C
			break
	return null

/proc/near_range_camera(var/mob/M)
	for(var/obj/machinery/camera/C in range(4, M))
		if(C.can_use())	// check if camera disabled
			return C
			break
	return null

/obj/machinery/camera/proc/weld(var/obj/item/weapon/weldingtool/WT, var/mob/user)
	if(busy)
		return 0
	if(!WT.isOn())
		return 0

	// Do after stuff here
	user << "<span class='notice'>You start to weld the [src]...</span>"
	playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
	WT.eyecheck(user)
	busy = 1
	if(do_after(user, 100))
		busy = 0
		if(!WT.isOn())
			return 0
		return 1
	busy = 0
	return 0


// PRESETS

// AI SAT
/obj/machinery/camera/aimalf
	network = list("Malf")

/obj/machinery/camera/aimalf/xray/icon_state = "xraycam"
/obj/machinery/camera/aimalf/xray/New()
	..()
	upgradeXRay()

// EMP
/obj/machinery/camera/autoname/emp_proof/New()
	..()
	upgradeEmpProof()

// X-RAY
/obj/machinery/camera/autoname/xray
	icon_state = "xraycam" // Thanks to Krutchen for the icons.

/obj/machinery/camera/autoname/xray/New()
	..()
	upgradeXRay()

// MOTION
/obj/machinery/camera/autoname/motion/New()
	..()
	upgradeMotion()

// ALL UPGRADES
/obj/machinery/camera/autoname/all/New()
	..()
	upgradeEmpProof()
	upgradeXRay()
	upgradeMotion()

// AUTONAME
/obj/machinery/camera/autoname
	var/number = 0 //camera number in area

//This camera type automatically sets it's name to whatever the area that it's in is called.
/obj/machinery/camera/autoname/New()
	..()
	spawn(10)
		number = 1
		var/area/A = get_area(src)
		if(A)
			for(var/obj/machinery/camera/autoname/C in world)
				if(C == src) continue
				var/area/CA = get_area(C)
				if(CA.type == A.type)
					if(C.number)
						number = max(number, C.number+1)
			c_tag = "[A.name] #[number]"


// CHECKS
/obj/machinery/camera/proc/isEmpProof()
	var/O = locate(/obj/item/stack/sheet/mineral/plasma) in assembly.upgrades
	return O

/obj/machinery/camera/proc/isXRay()
	var/O = locate(/obj/item/weapon/reagent_containers/food/snacks/grown/carrot) in assembly.upgrades
	return O

/obj/machinery/camera/proc/isMotion()
	var/O = locate(/obj/item/device/assembly/prox_sensor) in assembly.upgrades
	return O

// UPGRADE PROCS
/obj/machinery/camera/proc/upgradeEmpProof()
	assembly.upgrades.Add(new /obj/item/stack/sheet/mineral/plasma(assembly))

/obj/machinery/camera/proc/upgradeXRay()
	assembly.upgrades.Add(new /obj/item/weapon/reagent_containers/food/snacks/grown/carrot(assembly))

// If you are upgrading Motion, and it isn't in the camera's New(), add it to the machines list.
/obj/machinery/camera/proc/upgradeMotion()
	assembly.upgrades.Add(new /obj/item/device/assembly/prox_sensor(assembly))


/obj/item/weapon/camera_assembly
	name = "camera assembly"
	desc = "The basic construction for Nanotrasen-Always-Watching-You cameras."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "cameracase"
	w_class = 2
	anchored = 0

	m_amt = 700
	g_amt = 300

	//	Motion, EMP-Proof, X-Ray
	var/list/obj/item/possible_upgrades = list(/obj/item/device/assembly/prox_sensor, /obj/item/stack/sheet/mineral/plasma, /obj/item/weapon/reagent_containers/food/snacks/grown/carrot)
	var/list/upgrades = list()
	var/state = 0
	var/busy = 0
	/*
				0 = Nothing done to it
				1 = Wrenched in place
				2 = Welded in place
				3 = Wires attached to it (you can now attach/dettach upgrades)
				4 = Screwdriver panel closed and is fully built (you cannot attach upgrades)
	*/

/obj/item/weapon/camera_assembly/attackby(obj/item/W as obj, mob/living/user as mob)
	switch(state)
		if(0)
			// State 0
			if(istype(W, /obj/item/weapon/wrench) && isturf(src.loc))
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				user << "You wrench the assembly into place."
				anchored = 1
				state = 1
				update_icon()
				auto_turn()
				return

		if(1)
			// State 1
			if(istype(W, /obj/item/weapon/weldingtool))
				if(weld(W, user))
					user << "You weld the assembly securely into place."
					anchored = 1
					state = 2
				return

			else if(istype(W, /obj/item/weapon/wrench))
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				user << "You unattach the assembly from it's place."
				anchored = 0
				update_icon()
				state = 0
				return

		if(2)
			// State 2
			if(istype(W, /obj/item/weapon/cable_coil))
				var/obj/item/weapon/cable_coil/C = W
				if(C.use(2))
					user << "You add wires to the assembly."
					state = 3
				return

			else if(istype(W, /obj/item/weapon/weldingtool))

				if(weld(W, user))
					user << "You unweld the assembly from it's place."
					state = 1
					anchored = 1
				return


		if(3)
			// State 3
			if(istype(W, /obj/item/weapon/screwdriver))
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)

				var/input = strip_html(input(usr, "Which networks would you like to connect this camera to? Seperate networks with a comma. No Spaces!\nFor example: SS13,Security,Secret ", "Set Network", "SS13"))
				if(!input)
					usr << "No input found please hang up and try your call again."
					return

				var/list/tempnetwork = text2list(input, ",")
				if(tempnetwork.len < 1)
					usr << "No network found please hang up and try your call again."
					return

				state = 4
				var/obj/machinery/camera/C = new(src.loc)
				src.loc = C
				C.assembly = src

				C.auto_turn()

				C.network = tempnetwork

				C.c_tag = "[get_area_name(src)] ([rand(1, 999)]"

				for(var/i = 5; i >= 0; i -= 1)
					var/direct = input(user, "Direction?", "Assembling Camera", null) in list("LEAVE IT", "NORTH", "EAST", "SOUTH", "WEST" )
					if(direct != "LEAVE IT")
						C.dir = text2dir(direct)
					if(i != 0)
						var/confirm = alert(user, "Is this what you want? Chances Remaining: [i]", "Confirmation", "Yes", "No")
						if(confirm == "Yes")
							break
				return

			else if(istype(W, /obj/item/weapon/wirecutters))

				new/obj/item/weapon/cable_coil(get_turf(src), 2)
				playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
				user << "You cut the wires from the circuits."
				state = 2
				return

	// Upgrades!
	if(is_type_in_list(W, possible_upgrades) && !is_type_in_list(W, upgrades)) // Is a possible upgrade and isn't in the camera already.
		user << "You attach the [W] into the assembly inner circuits."
		upgrades += W
		user.drop_item(W)
		W.loc = src
		return

	// Taking out upgrades
	else if(istype(W, /obj/item/weapon/crowbar) && upgrades.len)
		var/obj/U = locate(/obj) in upgrades
		if(U)
			user << "You unattach an upgrade from the assembly."
			playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
			U.loc = get_turf(src)
			upgrades -= U
		return

	..()

/obj/item/weapon/camera_assembly/update_icon()
	if(anchored)
		icon_state = "camera1"
	else
		icon_state = "cameracase"

/obj/item/weapon/camera_assembly/attack_hand(mob/user as mob)
	if(!anchored)
		..()

/obj/item/weapon/camera_assembly/proc/weld(var/obj/item/weapon/weldingtool/WT, var/mob/user)
	if(busy)
		return 0
	if(!WT.isOn())
		return 0

	user << "<span class='notice'>You start to weld the [src]..</span>"
	playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
	WT.eyecheck(user)
	busy = 1
	if(do_after(user, 20))
		busy = 0
		if(!WT.isOn())
			return 0
		return 1
	busy = 0
	return 0