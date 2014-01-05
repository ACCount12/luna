//All devices that link into the R&D console fall into thise type for easy identification and some shared procs.

/obj/machinery/r_n_d
	name = "R&D Device"
	icon = 'icons/obj/machines/research.dmi'
	density = 1
	anchored = 1
	var/busy = 0
	var/hacked = 0
	var/disabled = 0
	var/shocked = 0
	var/datum/wires/rdm/wires = null
	var/opened = 0
	var/obj/machinery/computer/rdconsole/linked_console

/obj/machinery/r_n_d/New()
	..()
	wires = new(src)



/obj/machinery/r_n_d/shock(mob/user, prb)
	if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return 0
	if(!prob(prb))
		return 0
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	return Electrocute(user)

/obj/machinery/r_n_d/attack_hand(mob/user as mob)
	if(shocked)
		shock(user,50)
	if(opened)
		wires.Interact(user)
	return

/obj/machinery/r_n_d/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(opened && IsWiresHackingTool(O))
		wires.Interact(user)

/obj/machinery/r_n_d/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	src.updateUsrDialog()