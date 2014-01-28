/obj/effect/world_debugger
	name = "world debugger"
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield2"
	density = 1
	anchored = 1

	var/datum/controller/gameticker/gameticker
	var/gameworld

	New()
		..()
		gameticker = ticker
		gameworld = world