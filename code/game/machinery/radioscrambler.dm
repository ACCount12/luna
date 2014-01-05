/obj/machinery/radioscrambler
	name = "radio scrambler"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "broadcast receiver_off"
	density = 1
	anchored = 1
	var/on = 0
	var/datum/signal_scrambler/scrambler
	var/list/freqs = list(1459,1351,1355,1357,1359,1353,1441,1349,1347)
	var/power = 80

/obj/machinery/radioscrambler/portable/anchored = 0

/obj/machinery/radioscrambler/update_icon()
	if((stat & NOPOWER) || !on )
		icon_state = "broadcast receiver"
		return

	icon_state = initial(icon_state)

/obj/machinery/radioscrambler/power_change()
	..()
	sleep(rand(1, 15))
	update_icon()

/obj/machinery/radioscrambler/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/wrench))
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		anchored = !anchored
		toggle(0)
		update_icon()
		user << "You [anchored ? "wrench" : "unwrench"] [src]."


/obj/machinery/radioscrambler/proc/toggle(var/turnon = 1)
	on = turnon

	if(!anchored)
		on = 0

	del(scrambler)
	if(on)
		scrambler = new()
		scrambler.power = power
		scrambler.freqs = freqs

/obj/machinery/radioscrambler/attack_hand(var/mob/user as mob)
	src.add_fingerprint(user)
	interact(user)

/obj/machinery/radioscrambler/interact(var/mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return

	if(!anchored)
		return

	user.set_machine(src)
	var/dat = "<B>Radio Scrambler</B><BR>"
	dat += "<HR><BR>"

	dat += on ? "On" : "Off"
	dat += "<A href='?src=\ref[src];toggle=[!on]'>Toggle</A><BR>"

	dat += "<A href='?src=\ref[src];power=-10'>---</A> "
	dat += "<A href='?src=\ref[src];power=-5'>--</A> "
	dat += "<A href='?src=\ref[src];power=-1'>-</A> "
	dat += "[power] "
	dat += "<A href='?src=\ref[src];power=10'>+++</A> "
	dat += "<A href='?src=\ref[src];power=5'>++</A> "
	dat += "<A href='?src=\ref[src];power=1'>+</A><BR>"

	dat += "<BR> Scrambled frequencies:"
	for(var/f in freqs)
		dat += "[format_frequency(f)] GHz <A href='?src=\ref[src];removefreq=[f]'>Remove</A><BR>"
	dat += "<A href='?src=\ref[src];addfreq=1'>Add</A><BR>"

	dat += "<HR>"
	dat += "<A href='?src=\ref[src];close=1'>Close<BR>"
	user << browse(dat, "window=scrambler;size=450x500")
	onclose(user, "scrambler")


/obj/machinery/radioscrambler/Topic(href, href_list)
	if(..())
		return 1
	if(!anchored)
		return 1

	if (href_list["toggle"])
		toggle(href_list["toggle"])

	if (href_list["power"])
		power = min(100, max(1, power + text2num(href_list["power"])))
		if(scrambler)
			scrambler.power = power

	if (href_list["removefreq"])
		freqs -= text2num(href_list["removefreq"])

	if (href_list["addfreq"])
		var/newfreq = input(usr, "Specify a new frequency to scramble. Decimals assigned automatically.", src, 0) as null|num
		if(newfreq)
			if(findtext(num2text(newfreq), "."))
				newfreq *= 10 // shift the decimal one place
			if(newfreq < 10000)
				freqs += newfreq

	if(href_list["close"])
		usr << browse(null, "window=scrambler")
		usr.unset_machine(src)
	updateDialog()