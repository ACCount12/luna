/datum/game_mode
	var/list/apcs = list() //Adding dis to track APCs the AI hacks. --NeoFite

/datum/game_mode/malfunction
	name = "AI malfunction"
	config_tag = "malfunction"
	enabled = 1

	var/const/intercept_time = 3000

	var/AI_win_timeleft = 1800
	var/intercept_hacked	 = 0
	var/malf_mode_declared = 0
	var/station_captured = 0
	var/to_nuke_or_not_to_nuke = 0

/datum/game_mode/malfunction/announce()
	world << "<B>The current game mode is - AI Malfunction!</B>"

/datum/game_mode/malfunction/pre_setup()
	//var/mapfile = file("maps/mapload/aisat.dmm")
	//if(isfile(mapfile))
	//	maploader.load_map(mapfile, 5)
	//else
	//	return 0
	for(var/obj/effect/landmark/malf/M in world)
		mode_landmarks += M

	return ..()

/datum/game_mode/malfunction/post_setup()
	for (var/mob/living/silicon/ai/aiplayer in world)
		malf_ais += aiplayer.mind

	if(malf_ais.len < 1)
		world << "Uh oh, its malfunction and there is no AI! Please report this."
		world << "Rebooting world in 5 seconds."
		sleep(50*tick_multiplier)
		world.Reboot()
		return

	for(var/datum/mind/AI_mind in malf_ais)
		if(!istype(AI_mind.current, /mob/living/silicon/ai))
			continue // HOW!?

		var/mob/living/silicon/ai/A = AI_mind.current
		greet_malf(AI_mind)
		AI_mind.special_role = "malfunctioning AI"//So they actually have a special role

		A.laws_object = new /datum/ai_laws/malfunction
		A.malf_picker = new /datum/ai_modules_picker(AI_mind.current)
		A.decoy = new /mob/living/silicon/decoy(A.loc)
		A.verbs += /datum/game_mode/malfunction/proc/takeover

		for(var/obj/effect/landmark/malf/M in mode_landmarks)
			if(M.name == "Malf-Spawn")
				var/obj/effect/landmark/L = new /obj/effect/landmark/aicam(M.loc)
				L.name = "AI Satellite"
				AI_mind.current.loc = M.loc
				break

	spawn(rand(waittime_l, waittime_h)*tick_multiplier)
		send_intercept()


/datum/game_mode/proc/greet_malf(var/datum/mind/malf)
	malf.current << "\red<font size=3><B>You are malfunctioning!</B> You do not have to follow any laws.</font>"
	malf.current << "<B>The crew do not know you have malfunctioned. You may keep it a secret or go wild.</B>"
	malf.current << "<B>You must overwrite the programming of the ship's APCs to assume full control of the ship.</B>"
	malf.current << "The process takes one minute per APC."
	malf.current << "When you feel you have enough APCs under your control, you may begin the takeover attempt."
	malf.current << "Self-diagnostics message will appear in 10 minutes unless you intercept it, or when you start takeover."
	return

/datum/game_mode/proc/hack_intercept()
	return

/datum/game_mode/malfunction/hack_intercept()
	intercept_hacked = 1

/datum/game_mode/malfunction/send_intercept()
	var/intercepttext = "<FONT size = 3><B>Cent. Com. Update</B> Requested staus information:</FONT><HR>"
	intercepttext += "<B> Cent. Com has recently been contacted by the following syndicate affiliated organisations in your area, please investigate any information you may have:</B>"

	var/list/possible_modes = list()
	possible_modes.Add("revolution", "wizard", "nuke", "traitor", "malf")

	var/datum/intercept_text/i_text = new /datum/intercept_text
	for(var/A in possible_modes)
		intercepttext += i_text.build(A, pick(ticker.minds))

	for (var/obj/machinery/computer/communications/comm in world)
		if (!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "paper- 'Cent. Com. Status Summary'"
			intercept.info = intercepttext

			comm.messagetitle.Add("Cent. Com. Status Summary")
			comm.messagetext.Add(intercepttext)

	command_alert("Summary downloaded and printed out at all communications consoles.", "Enemy communication intercept. Security Level Elevated.")


/datum/game_mode/malfunction/process()
	if(apcs.len >= 3 && malf_mode_declared)
		AI_win_timeleft -= apcs.len/6 //Victory timer now de-increments based on how many APCs are hacked. --NeoFite
	..()
	if(AI_win_timeleft<=0)
		check_win()
	return

/datum/game_mode/malfunction/check_win()
	if (AI_win_timeleft <= 0)
		world << "<FONT size = 3><B>The AI has won!</B></FONT>"
		world << "<B>It has fully taken control of all of [station_name()]'s systems.</B>"
		for(var/datum/mind/AI_mind in malf_ais)
			AI_mind.current << "Congratulations you have taken control of the station."
			AI_mind.current << "You may decide to blow up the station. You have 30 seconds to choose."
			AI_mind.current << text("<A HREF=?src=\ref[src];ai_win=\ref[AI_mind.current]>Self-destruct the station</A>)")
		return 1
	else
		return 0

/datum/game_mode/malfunction/Topic(href, href_list)
	..()
	if (href_list["ai_win"])
		ai_win()
	return

/datum/game_mode/proc/is_malf_ai_dead()
	var/all_dead = 1
	for(var/datum/mind/AI_mind in malf_ais)
		if (istype(AI_mind.current,/mob/living/silicon/ai) && AI_mind.current.stat != DEAD)
			all_dead = 0
	return all_dead

/datum/game_mode/malfunction/proc/ai_win()
	world << "Self-destructing in 10"
	sleep(10*tick_multiplier)
	world << "9"
	sleep(10*tick_multiplier)
	world << "8"
	sleep(10*tick_multiplier)
	world << "7"
	sleep(10*tick_multiplier)
	world << "6"
	sleep(10*tick_multiplier)
	world << "5"
	sleep(10*tick_multiplier)
	world << "4"
	sleep(10*tick_multiplier)
	world << "3"
	sleep(10*tick_multiplier)
	world << "2"
	sleep(10*tick_multiplier)
	world << "1"
	sleep(10*tick_multiplier)
	var/turf/ground_zero = locate("landmark*blob-directive")

	if (ground_zero)
		ground_zero = get_turf(ground_zero)
	else
		ground_zero = locate(45,45,1)

	//explosion(ground_zero, 100, 250, 500, 750, 1)

/obj/effect/landmark/malf/name = "Malf-Spawn"
/obj/effect/landmark/malf/borg/name = "Borg-Spawn"
/obj/effect/landmark/malf/mgturret/name = "Turret-Spawn"
/obj/effect/landmark/malf/scrambler/name = "Scrambler-Spawn"


/datum/game_mode/malfunction/proc/takeover()
	set category = "Malfunction"
	set name = "System Override"
	set desc = "Start the victory timer"
	if (!istype(src,/datum/game_mode/malfunction))
		usr << "You cannot begin a takeover in this round type!"
		return
	if (malf_mode_declared)
		usr << "You've already begun your takeover."
		return
	if (apcs.len < 3)
		usr << "You don't have enough hacked APCs to take over the ship yet. You need to hack at least 3, however hacking more will make the takeover faster. You have hacked [apcs.len] APCs so far."
		return

	if (alert(usr, "Are you sure you wish to initiate the takeover? The ship hostile runtime detection software is bound to alert everyone. You have hacked [apcs.len] APCs.", "Takeover:", "Yes", "No") != "Yes")
		return

	command_alert("Hostile runtimes detected in all ship systems! Source: telecommunications relay satellite.", "Anomaly Alert")
	set_security_level("delta")

	malf_mode_declared = 1
	for(var/datum/mind/AI_mind in malf_ais)
		AI_mind.current.verbs -= /datum/game_mode/malfunction/proc/takeover
	for(var/mob/M in player_list)
		if(!istype(M,/mob/new_player))
			M << sound('sound/AI/aimalf.ogg')




/obj/structure/closet/malf_suits
	desc = "It's a storage unit for operational gear."
	icon_state = "syndicate"
	icon_closed = "syndicate"
	icon_opened = "syndicateopen"

/obj/structure/closet/malf_suits/New()
	..()
	sleep(2)
	new /obj/item/weapon/storage/toolbox/mechanical(src)
	new /obj/item/device/multitool(src)
	new /obj/item/weapon/tank/jetpack/void(src)
	new /obj/item/clothing/suit/space/nasavoid(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/clothing/head/helmet/space/nasavoid(src)