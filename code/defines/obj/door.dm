/obj/machinery/door
	name = "Door"
	icon = 'doorint.dmi'
	icon_state = "door1"
	opacity = 1
	density = 1
	var/secondsElectrified = 0
	var/visible = 1
	var/p_open = 0
	var/operating = 0
	anchored = 1
	var/autoclose = 0
	var/autoopen = 1
	var/locked = 0 // Currently in use for airlocks and window doors (alien weeds forcing the window doors open)
	var/forcecrush = 0
	var/normalspeed = 1

/obj/machinery/door/firedoor
	name = "firelock"
	explosionstrength = 4
	icon = 'Doorfire.dmi'
	icon_state = "door0"
	var/blocked = null
	opacity = 0
	density = 0
	var/nextstate = null

/obj/machinery/door/firedoor/border_only
	icon = 'door_fire2.dmi'
	icon_state = "door0"

/obj/machinery/door/poddoor
	explosionstrength = 3
	name = "podlock"
	icon = 'rapid_pdoor.dmi'
	icon_state = "pdoor1"
	var/id = 1.0

	newicon
		icon = 'blastdoor.dmi'

		black
			icon = 'blastdoors.dmi'

/obj/machinery/door/poddoor/ex_act(severity)
	return