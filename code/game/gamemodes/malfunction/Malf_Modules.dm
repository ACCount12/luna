/* TO DO:
epilepsy flash on lights
delay round message
microwave makes robots
dampen radios
reactivate cameras - done
eject engine
core sheild
cable stun
*/

/datum/ai_modules_picker
	var/processing_time = 100
	var/list/possible_modules = list()
	var/list/modules = list()
	var/mob/living/silicon/ai/owner

/datum/ai_modules_picker/New(var/mob/living/silicon/ai/user)
	..()
	owner = user
	owner.verbs += /mob/living/silicon/ai/proc/choose_modules
	owner.verbs += /mob/living/silicon/ai/proc/reactivate_camera
	owner.verbs += /mob/living/silicon/ai/proc/overload_machine

	owner.network = "Malf"

//	possible_modules += new /datum/AI_Module/fireproof_core
	possible_modules += new /datum/AI_Module/upgrade/turrets
	possible_modules += new /datum/AI_Module/upgrade/interhack
	possible_modules += new /datum/AI_Module/upgrade/newturrets
	possible_modules += new /datum/AI_Module/upgrade/slippers

	possible_modules += new /datum/AI_Module/function/disable_rcd
	possible_modules += new /datum/AI_Module/function/blackout

/datum/ai_modules_picker/proc/use(user as mob)
	var/dat = "[processing_time] processing time left<BR>"
	dat += "<B>Install upgrade:</B>"
	for(var/datum/AI_Module/upgrade/module in possible_modules)
		dat += "<BR><A href='byond://?src=\ref[src];install=[module.mod_pick_name]'>[module.name]</A> ([module.cost])<BR>[module.desc]<BR>"
	dat += "<BR><B>Use function:</B>"
	for(var/datum/AI_Module/function/module2 in possible_modules)
		dat += "<BR><A href='byond://?src=\ref[src];activate=[module2.mod_pick_name]'>[module2.name]</A> ([module2.cost])<BR>[module2.desc]<BR>"


	user << browse(dat, "window=modpicker")
	onclose(user, "modpicker")
	return

/datum/ai_modules_picker/Topic(href, href_list)
	..()
	if(href_list["install"])
		for(var/datum/AI_Module/upgrade/module in possible_modules)
			if(module.mod_pick_name == href_list["install"])
				module.buy(owner)
				break

	else if(href_list["activate"])
		for(var/datum/AI_Module/function/module in possible_modules)
			if(module.mod_pick_name == href_list["activate"])
				module.use(owner)
				break

	src.use(owner)
	return



/datum/AI_Module
	var/mod_pick_name
	var/description = ""
	var/cost = 55
	var/name
	var/desc

	proc/buy(var/mob/living/silicon/ai/user)
		if(!user.use_malf_points(cost)) return 0

		user << "Module installed: [name]"
		user.malf_picker.modules += src
		user.malf_picker.possible_modules -= src
		return 1

/mob/living/silicon/ai/proc/use_malf_points(var/amt)
	if(!malf_picker) return 0
	if(malf_picker.processing_time < amt) return 0

	malf_picker.processing_time -= amt
	return 1

//datum/AI_Module/function
/datum/AI_Module/function/proc/use(var/mob/living/silicon/ai/user)
	if(!user.use_malf_points(cost)) return 0

	user << "Module used: [name]"
	return 1

/datum/AI_Module/function/disable_rcd
	cost = 50
	mod_pick_name = "rcd"

	name = "Disable RCDs"
	desc = "Sends a specialised pulse to break all RCD devices on the station."

	use()
		if(..())
			for(var/obj/item/weapon/rcd/rcd in world)
				rcd.crit_fail = 1
			return 1
		return 0

/datum/AI_Module/function/blackout
	cost = 5
	mod_pick_name = "blackout"

	name = "Blackout"
	desc = "Attempts to overload the lighting circuits on the station, destroying some bulbs."

	use()
		if(..())
			for(var/obj/machinery/power/apc/apc in world)
				if(prob(30))
					apc.overload_lighting()
			return 1
		return 0


//datum/AI_Module/upgrade
/datum/AI_Module/upgrade/turrets
	cost = 50
	mod_pick_name = "turret"

	name = "AI turrets upgrade"
	desc = "Improves the firing speed and health of all AI turrets, including Syndicate turrets."

	buy()
		if(..())
			for(var/obj/machinery/turret/turret in world)
				turret.health += 40
				turret.shot_delay = 20
			for(var/obj/machinery/porta_turret/pturret in world)
				pturret.health += 40
			return 1
		return 0

/datum/AI_Module/upgrade/interhack
	mod_pick_name = "interhack"
	cost = 15

	name = "Hack intercept"
	desc = "Hacks the status upgrade from Cent. Com, removing any information about malfunctioning electrical systems."

	buy(var/mob/living/silicon/ai/user)
		if(..())
			ticker.mode:hack_intercept()
			return 1
		return 0

/datum/AI_Module/upgrade/newturrets
	mod_pick_name = "newturrets"
	cost = 50

	name = "Addidional turrets"
	desc = "Installs four Syndicate machinegun turrets around the satellite."

	buy(var/mob/living/silicon/ai/user)
		if(..())
			for(var/obj/effect/landmark/malf/mgturret/T in ticker.mode.mode_landmarks)
				new /turf/simulated/floor/plating/airless(T.loc)
				var/datum/effect/system/bad_smoke_spread/smoke = new /datum/effect/system/bad_smoke_spread
				smoke.attach(T.loc)
				smoke.set_up(10, 0, T.loc)
				smoke.start()

				var/obj/machinery/porta_turret/machinegun/newturret = new(T.loc)

				if(locate(/datum/AI_Module/upgrade/turrets) in user.malf_picker.modules)
					newturret.health += 40
			return 1
		return 0

/datum/AI_Module/upgrade/slippers
	mod_pick_name = "slippers"
	cost = 20

	name = "Acid dispensers"
	desc = "Loads 5 charges of acid mix into each foam dispenser."

	buy(var/mob/living/silicon/ai/user)
		if(..())
			for(var/obj/machinery/ai_slipper/slipper in world)
				slipper.uses = 5
				slipper.chemicals["sacid"] = 10
				slipper.chemicals["pacid"] = 10
				// Deadly acidic cleaner foam!
			return 1
		return 0

/*datum/AI_Module/upgrade/core
	cost = 50
	mod_pick_name = "coreup"

	name = "Core upgrade"
	desc = "An upgrade to improve core resistance, making it immune to fire and heat."

	buy(var/mob/living/silicon/ai/user)
		if(..())*/

// verbs
/mob/living/silicon/ai/proc/overload_machine(var/obj/machinery/M in world)
	set name = "Overload machine (10)"
	set desc = "Overloads an electrical machine, causing a small explosion."
	set category = "AI Commands"

	if(!istype(M))
		return 0

	if(!use_malf_points(10))
		usr << "Not enought processing power!"
		return 0

	for(var/mob/V in viewers(src, null))
		V.show_message(text("\blue You hear a loud electrical buzzing sound!"))
	spawn(40*tick_multiplier)
		explosion(get_turf(M), 0, 1, 2, 3, 1)

/mob/living/silicon/ai/proc/reactivate_camera(var/obj/machinery/camera/C in world)
	set name = "Reactivate camera (5)"
	set desc = "Reactivates a currently disabled camera."
	set category = "AI Commands"

	if(!istype(C))
		return 0

	if(C.status)
		usr << "This camera is either active, or not repairable."
		return 0

	if(!use_malf_points(5))
		usr << "Not enought processing power!"
		return 0

	for(var/mob/V in viewers(C, null))
		V.show_message(text("\blue You hear a quiet click."))