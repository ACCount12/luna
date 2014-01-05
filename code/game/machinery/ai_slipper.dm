/obj/machinery/ai_slipper
	name = "foam dispenser"
	desc = "Dispenses cleaning foam."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "gsensor1"
	layer = 3
	anchored = 1
	var/uses = 10
	var/list/chemicals = list("fluorosurfactant" = 10, "water" = 10, "cleaner" = 10)
	var/locked = 1
	var/cooldown_time = 0

/obj/machinery/ai_slipper/New()
	create_reagents(100)
	..()

/obj/machinery/ai_slipper/power_change()
	if(stat & BROKEN)
		return
	else
		if( powered() )
			stat &= ~NOPOWER
		else
			icon_state = "gsensor0"
			stat |= NOPOWER

/obj/machinery/ai_slipper/attackby(obj/item/weapon/W, mob/user)
	if(stat & (NOPOWER|BROKEN))
		return
	if (istype(user, /mob/living/silicon))
		return src.attack_hand(user)
	else // trying to unlock the interface
		if (src.allowed(usr))
			locked = !locked
			user << "You [ locked ? "lock" : "unlock"] the device."
			if (locked)
				if (user.machine==src)
					user.unset_machine()
					user << browse(null, "window=ai_slipper")
			else
				if (user.machine==src)
					src.attack_hand(usr)
		else
			user << "\red Access denied."
			return
	return

/obj/machinery/ai_slipper/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/ai_slipper/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	if (get_dist(src, user) > 1 && !istype(user, /mob/living/silicon))
		user.unset_machine()
		user << browse(null, "window=ai_slipper")
		return

	user.set_machine(src)
	var/loc = src.loc
	if (istype(loc, /turf))
		loc = loc:loc
	if (!istype(loc, /area))
		user << text("Turret badly positioned - loc.loc is [].", loc)
		return

	var/area/area = loc
	var/t = "<TT><B>Liquid Dispenser</B> ([format_text(area.name)])<HR>"

	if(src.locked && (!istype(user, /mob/living/silicon)))
		t += "<I>(Swipe ID card to unlock control panel.)</I><BR>"
	else
		t += text("Uses Left: [uses]. <A href='?src=\ref[src];toggleUse=1'>Activate?</A><br>\n")

	user << browse(t, "window=ai_slipper;size=575x450")
	onclose(user, "ai_slipper")
	return

/obj/machinery/ai_slipper/Topic(href, href_list)
	if(..())
		return
	if (src.locked)
		if (!istype(usr, /mob/living/silicon))
			usr << "Control panel is locked!"
			return
	if (href_list["toggleUse"])
		if(world.timeofday < cooldown_time)
			return
		else
			flags |= NOREACT
			for(var/reagent in chemicals)
				reagents.add_reagent(reagent, chemicals[reagent])
			flags &= ~NOREACT
			reagents.handle_reactions()
			uses--

	src.attack_hand(usr)
	return