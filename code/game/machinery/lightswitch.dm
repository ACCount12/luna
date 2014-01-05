// the switches

/obj/machinery/switch
	icon = 'power.dmi'
	anchored = 1
	density = 0
	icon_state = "light1"
	var/area/area = null
	var/area/otherarea = null
	var/id
	var/use_area = 0

	attack_paw(mob/user)
		return attack_hand(user)

	attack_ai(mob/user as mob)
		return src.attack_hand(user)

	attack_paw(mob/user as mob)
		return src.attack_hand(user)

	attackby(obj/item/weapon/W, mob/user as mob)
		if(istype(W, /obj/item/device/detective_scanner))
			return
		return src.attack_hand(user)

/obj/machinery/switch/New()
	..()
	spawn(5)
		area = get_turf(src)
		area = area.loc

		if(otherarea)
			area = locate(text2path("/area/[otherarea]"))

// Light switch
/obj/machinery/switch/light_switch
	desc = "A light switch"
	name = "light switch"
	var/on = 1

/obj/machinery/switch/light_switch/New()
	..()
	spawn(6)
		if(!name)
			name = "light switch ([area.name])"

		src.on = src.area.lightswitch
		update_icon()

/obj/machinery/switch/light_switch/update_icon()
	if(stat & NOPOWER)
		icon_state = "light-p"
	else
		if(on)
			icon_state = "light1"
		else
			icon_state = "light0"

/obj/machinery/switch/light_switch/examine()
	..()
	usr << "It is [on? "on" : "off"]."

/obj/machinery/switch/light_switch/attack_hand(mob/user)
	on = !on

	for(var/area/A in area.master.related)
		A.lightswitch = on
		A.update_icon()

		for(var/obj/machinery/switch/light_switch/L in A)
			L.on = on
			L.update_icon()

	area.master.power_change()

/obj/machinery/switch/light_switch/power_change()
	if(powered(LIGHT))
		stat &= ~NOPOWER
	else
		stat |= NOPOWER

	update_icon()


/obj/machinery/switch/crema_switch
	desc = "Burn baby burn!"
	name = "crematorium igniter"
	icon_state = "crema_switch"
	req_access = list(access_crematorium)
	use_area = 1
	id = 1

/obj/machinery/switch/crema_switch/attack_hand(mob/user as mob)
	if(allowed(usr))
		var/location = world
		if(use_area)
			location = area

		for(var/obj/structure/crematorium/C in location)
			if(C.id == id)
				if(!C.cremating)
					C.cremate(user)
	else
		usr << "\red Access denied."
	return


/obj/machinery/switch/shieldsbutton
	name = "toggle shields"
	icon = 'airlock_machines.dmi'
	icon_state = "access_button_standby"
	var/toggle = 0

	attack_hand(mob/user)
		if(!toggle)
			ShieldNetwork.startshields()
			icon_state = "access_button_standby"
			toggle = 1
		else
			ShieldNetwork.stopshields()
			toggle = 0
			icon_state = "access_button_standby"
		flick("access_button_cycle", src)


/obj/machinery/switch/door_control
	name = "remote door control"
	icon = 'stationobjs.dmi'
	icon_state = "doorctrl00"
	desc = "A remote control switch for a door."
	var/icon_toggled = "doorctrl1"
	var/icon_normal = "doorctrl0"
	var/icon_nopower = "doorctrl-p"
	var/needspower = 1
	var/toggled = "0"

/obj/machinery/switch/door_control/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	if(!allowed(usr))
		usr << "\red Access denied."
		return

	if(needspower)
		use_power(5)
	icon_state = icon_toggled
	if(toggled == "1")
		toggled = "0"
	else
		toggled = "1"

	var/location = machines
	if(use_area)
		location = area

	for(var/obj/machinery/door/poddoor/M in location)
		if(M.id == src.id)
			if (M.density)
				M.open()
				//TransmitNetworkPacket(PrependNetworkAddress("[M.get_password()] OPEN", M))
			else
				M.close()
				//TransmitNetworkPacket(PrependNetworkAddress("[M.get_password()] CLOSE", M))

	src.add_fingerprint(usr)
	sleep(10)
	icon_state = icon_normal + toggled

/obj/machinery/switch/door_control/power_change()
	..()
	if(!needspower)
		return
	if(stat & NOPOWER)
		icon_state = icon_nopower
	else
		icon_state = icon_normal + toggled

/obj/machinery/switch/door_control/area
	use_area = 1

/obj/machinery/switch/door_control/vent_control
	name = "remote vent control"
	icon_state = "leverbig00"
	desc = "A heavy hydraulic control switch for the core vents. Pushing it towards the reactor opens the vents, pulling it away from the reactor closes the vents."
	icon_toggled = "leverbig01"
	icon_normal = "leverbig0"
	needspower = 0

/obj/machinery/switch/door_control/vent_control/attack_ai(mob/user as mob)
	if (in_range(src, user) && get_dist(src, user) <= 1 && istype(user, /mob/living/silicon/robot))
		src.attack_hand(user)
		return
	else
		user << "This switch is operated by hydraulics, you cannot use it remotely."
		return	//lolno
	return

/obj/machinery/switch/door_control/vent_control/attack_hand(mob/user as mob)
	radioalert("Core control computer", "CORE VENTS CYCLING")
	playsound(src.loc, 'warning-buzzer.ogg', 75)
	..()
	icon_state = icon_normal + toggled

	for(var/obj/machinery/engine/supermatter/S in world)
		var/turf/T = S.loc
		T.RebuildZone()



/obj/machinery/switch/driver_button
	name = "mass driver button"
	icon = 'objects.dmi'
	icon_state = "launcherbtt"
	desc = "A remote control switch for a mass driver."
	var/active = 0
	use_area = 1

/obj/machinery/switch/driver_button/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		return

	use_power(5)
	active = 1
	icon_state = "launcheract"

	var/location = machines
	if(use_area)
		location = area

	for(var/obj/machinery/door/poddoor/M in location)
		if(M.id == src.id)
			spawn(0)
				M.open()
				return

	sleep(20)

	for(var/obj/machinery/mass_driver/M in location)
		if(M.id == src.id)
			M.drive()

	sleep(50)

	for(var/obj/machinery/door/poddoor/M in location)
		if (M.id == src.id)
			spawn(0)
				M.close()
				return

	icon_state = "launcherbtt"
	active = 0

	return



/obj/machinery/switch/ignition_switch
	name = "ignition switch"
	icon = 'objects.dmi'
	icon_state = "launcherbtt"
	desc = "A remote control switch for a mounted igniter."
	var/active = 0

/obj/machinery/switch/ignition_switch/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		return

	use_power(5)

	active = 1
	icon_state = "launcheract"

	var/location = machines
	if(use_area)
		location = area

	for(var/obj/machinery/sparker/M in location)
		if (M.id == src.id)
			spawn(0)
				M.ignite()

	for(var/obj/machinery/igniter/M in location)
		if(M.id == src.id)
			use_power(50)
			M.on = !M.on
			M.icon_state = text("igniter[]", M.on)

	sleep(40)

	icon_state = "launcherbtt"
	active = 0

	return