/obj/item/weapon/storage/secure
	name = "secstorage"
	var/icon_locking = "secureb"
	var/icon_sparking = "securespark"
	var/icon_open = "secure0"
	var/locked = 1
	var/code = ""
	var/l_code = null
	var/l_set = 0
	var/l_setshort = 0
	var/l_hacking = 0
	var/emagged = 0
	var/open = 0
	w_class = 3.0

/obj/item/weapon/storage/secure/examine()
	set src in oview(1)

	..()
	usr << text("The service panel is [src.open ? "open" : "closed"].")
	return


/obj/item/weapon/storage/secure/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if ((W.w_class > 3 || istype(W, /obj/item/weapon/storage/secure)))
		return
	if ((istype(W, /obj/item/weapon/card/emag)) && (src.locked == 1) && (!src.emagged))
		emagged = 1
		src.overlays += image('storage.dmi', icon_sparking)
		sleep(6)
		src.overlays = null
		overlays += image('storage.dmi', icon_locking)
		locked = 0
		user << "You short out the lock on [src]."
		return
	if ((istype(W, /obj/item/weapon/screwdriver)) && (src.locked == 1))
		sleep(6)
		src.open =! src.open
		user.show_message(text("\blue You [] the service panel.", (src.open ? "open" : "close")))
		return
	if ((istype(W, /obj/item/device/multitool)) && (src.open == 1) && (src.locked ==1) && (!src.l_hacking))
		user.show_message(text("\red Now attempting to reset internal memory, please hold."), 1)
		src.l_hacking = 1
		spawn(100)
			if (prob(40))
				src.l_setshort = 1
				src.l_set = 0
				user.show_message(text("\red Internal memory reset.  Please give it a few seconds to reinitialize."), 1)
				sleep(80)
				src.l_setshort = 0
				src.l_hacking = 0
			else
				user.show_message(text("\red Unable to reset internal memory."), 1)
				src.l_hacking = 0
		return
	if (src.contents.len >= 7)
		return
	if (src.locked == 1)
		return
	user.u_equip(W)
	W.loc = src
	if ((user.client && user.s_active != src))
		user.client.screen -= W
	src.orient2hud(user)
	W.dropped(user)
	add_fingerprint(user)
	//if (istype(W, /obj/item/weapon/gun/energy/crossbow)) return //STEALTHY
	for(var/mob/O in viewers(user, null))
		O.show_message(text("\blue [] has added [] to []!", user, W, src), 1)
		//Foreach goto(139)
	return

/obj/item/weapon/storage/secure/dropped(mob/user as mob)

	src.orient_objs(7, 8, 10, 7)
	return

/obj/item/weapon/storage/secure/MouseDrop(over_object, src_location, over_location)
	..()
	if (src.locked == 1)
		return

	if ((over_object == usr && ((get_dist(src, usr) <= 1 ||src.locked == 0) || usr.contents.Find(src))))  //|| usr.telekinesis == 1
		if (usr.s_active)
			usr.s_active.close(usr)
		src.show_to(usr)
	return

/obj/item/weapon/storage/secure/attack_paw(mob/user as mob)
	playsound(src.loc, "rustle", 50, 1, -5)
	return src.attack_hand(user)
	return

/obj/item/weapon/storage/secure/attack_hand(mob/user as mob)
	if ((src.loc == user) && (src.locked == 1))
		usr << "\red [src] is locked and cannot be opened!"
	else if ((src.loc == user) && (!src.locked))
		playsound(src.loc, "rustle", 50, 1, -5)
		if (user.s_active)
			user.s_active.close(user)
		src.show_to(user)
	else
		..()
		for(var/mob/M in range(1))
			if (M.s_active == src)
				src.close(M)
		src.orient2hud(user)
	src.add_fingerprint(user)
	return

/obj/item/weapon/storage/secure/attack_self(mob/user as mob)
	user.set_machine(src)
	var/dat = text("<TT><B>[]</B><BR>\n\nLock Status: []",src, (src.locked ? "LOCKED" : "UNLOCKED"))
	var/message = "Code"
	if ((src.l_set == 0) && (!src.emagged) && (!src.l_setshort))
		dat += text("<p>\n<b>5-DIGIT PASSCODE NOT SET.<br>ENTER NEW PASSCODE.</b>")
	if (src.emagged)
		dat += text("<p>\n<font color=red><b>LOCKING SYSTEM ERROR - 1701</b></font>")
	if (src.l_setshort)
		dat += text("<p>\n<font color=red><b>ALERT: MEMORY SYSTEM ERROR - 6040 201</b></font>")
	message = text("[]", src.code)
	if (!src.locked)
		message = "*****"
	dat += text("<HR>\n>[]<BR>\n<A href='?src=\ref[];type=1'>1</A>-<A href='?src=\ref[];type=2'>2</A>-<A href='?src=\ref[];type=3'>3</A><BR>\n<A href='?src=\ref[];type=4'>4</A>-<A href='?src=\ref[];type=5'>5</A>-<A href='?src=\ref[];type=6'>6</A><BR>\n<A href='?src=\ref[];type=7'>7</A>-<A href='?src=\ref[];type=8'>8</A>-<A href='?src=\ref[];type=9'>9</A><BR>\n<A href='?src=\ref[];type=R'>R</A>-<A href='?src=\ref[];type=0'>0</A>-<A href='?src=\ref[];type=E'>E</A><BR>\n</TT>", message, src, src, src, src, src, src, src, src, src, src, src, src)
	user << browse(dat, "window=caselock;size=300x280")

/obj/item/weapon/storage/secure/Topic(href, href_list)
	..()
	if ((usr.stat || usr.restrained()) || (get_dist(src, usr) > 1))
		return
	if (href_list["type"])
		if (href_list["type"] == "E")
			if ((src.l_set == 0) && (length(src.code) == 5) && (!src.l_setshort) && (src.code != "ERROR"))
				src.l_code = src.code
				src.l_set = 1
			else if ((src.code == src.l_code) && (src.emagged == 0) && (src.l_set == 1))
				src.locked = 0
				src.overlays = null
				overlays += image('storage.dmi', icon_open)
				src.code = null
			else
				src.code = "ERROR"
		else
			if ((href_list["type"] == "R") && (src.emagged == 0) && (!src.l_setshort))
				src.locked = 1
				src.overlays = null
				src.code = null
				src.close(usr)
			else
				src.code += text("[]", href_list["type"])
				if (length(src.code) > 5)
					src.code = "ERROR"
		src.add_fingerprint(usr)
		for(var/mob/M in viewers(1, src.loc))
			if ((M.client && M.machine == src))
				src.attack_self(M)
			return
	return

/obj/item/weapon/storage/secure/New()
	src.boxes = new /obj/effect/screen/storage(  )
	src.boxes.name = "storage"
	src.boxes.master = src
	src.boxes.icon_state = "block"
	src.boxes.screen_loc = "7,7 to 10,8"
	src.boxes.layer = 19
	src.closer = new /obj/effect/screen/close(  )
	src.closer.master = src
	src.closer.icon_state = "x"
	src.closer.layer = 20
	spawn( 5 )
		src.orient_objs(7, 8, 10, 7)
		return
 	return

/obj/effect/screen/storage/attackby(W, mob/user as mob)
	src.master.attackby(W, user)
	return
