/mob/living/silicon/ai
	name = "AI"
	voice_name = "synthesized voice"
	icon = 'icons/mob/ai.dmi'
	icon_state = "ai"
	anchored = 1

	var/network = "Luna"
	var/list/connected_robots = list()
	var/aiRestorePowerRoutine = 0
	var/obj/item/device/pda/aiPDA = null
	var/viewalerts = 0
	var/datum/trackable/track = null
	var/alarms = list("Motion"=list(), "Fire"=list(), "Atmosphere"=list(), "Power"=list(), "Camera"=list())
	var/list/ai_screens = list("Blue" = "ai", "Red" = "ai-red", "Green" = "ai-wierd",
							"Monochrome" = "ai-mono", "Clown" = "ai-clown",
							"Inverted" = "ai-u", "Firewall" = "ai-magma",
							"Static" = "ai-static", "Red October" = "ai-redoctober",
							"dWine" = "ai-dorf","Matrix" = "ai-matrix",
							"Malfunction" = "ai-malf", "Bliss" = "ai-bliss",
							"Console" = "ai-text", "Smiley" = "ai-smiley")

	var/mob/living/silicon/decoy/decoy
	var/datum/ai_modules_picker/malf_picker
	var/fire_res_on_core = 0

/mob/living/silicon/ai/New(loc, var/datum/ai_laws/L)
	..()
	spawn(10)
		aiPDA = new /obj/item/device/pda(src)
		aiPDA.owner = name
		aiPDA.ownjob = "AI"
		aiPDA.name += " ([aiPDA.ownjob])"

/mob/living/silicon/ai/Stat()
	..()
	statpanel("Status")
	if (client.statpanel == "Status")
		if(LaunchControl.online && main_shuttle.location < 2)
			var/timeleft = LaunchControl.timeleft()
			if (timeleft)
				stat("ETA-[(timeleft / 60) % 60]", "[add_zero(num2text(timeleft % 60), 2)]")

/mob/living/silicon/ai/verb/pick_icon()
	set category = "AI Commands"
	set name = "Set AI Core Display"
	if(stat || aiRestorePowerRoutine)
		return

	var/icontype = input("Please, select a display!", "AI", null) in ai_screens
	icon_state = ai_screens[icontype]
	if(decoy)
		decoy.icon_state = ai_screens[icontype]

/mob/living/silicon/ai/verb/ai_alerts()
	set category = "AI Commands"
	set name = "Show Alerts"

	var/dat = "<HEAD><TITLE>Current Ship Alerts</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n"
	dat += "<A HREF='?src=\ref[src];mach_close=aialerts'>Close</A><BR><BR>"
	for (var/cat in alarms)
		dat += text("<B>[]</B><BR>\n", cat)
		var/list/L = alarms[cat]
		if (L.len)
			for (var/alarm in L)
				var/list/alm = L[alarm]
				var/area/A = alm[1]
				var/C = alm[2]
				var/list/sources = alm[3]
				dat += "<NOBR>"
				if (C && istype(C, /list))
					var/dat2 = ""
					for (var/obj/machinery/camera/I in C)
						dat2 += text("[]<A HREF=?src=\ref[];switchcamera=\ref[]>[]</A>", (dat2=="") ? "" : " | ", src, I, I.c_tag)
					dat += text("-- [] ([])", A.name, (dat2!="") ? dat2 : "No Camera")
				else if (C && istype(C, /obj/machinery/camera))
					var/obj/machinery/camera/Ctmp = C
					dat += text("-- [] (<A HREF=?src=\ref[];switchcamera=\ref[]>[]</A>)", A.name, src, C, Ctmp.c_tag)
				else
					dat += text("-- [] (No Camera)", A.name)
				if (sources.len > 1)
					dat += text("- [] sources", sources.len)
				dat += "</NOBR><BR>\n"
		else
			dat += "-- All Systems Nominal<BR>\n"
		dat += "<BR>\n"

	viewalerts = 1
	src << browse(dat, "window=aialerts&can_close=0")

/mob/living/silicon/ai/proc/ai_cancel_call()
	set category = "AI Commands"
	if(usr.stat == 2)
		usr << "You can't send the shuttle back because you are dead!"
		return
	cancel_call_proc(src)
	return

/mob/living/silicon/ai/blob_act()
	if (stat != 2)
		bruteloss += 30
		updatehealth()
		return 1
	return 0

/mob/living/silicon/ai/restrained()
	return 0

/mob/living/silicon/ai/ex_act(severity)
	flick("flash", flash)

	var/b_loss = bruteloss
	var/f_loss = fireloss
	switch(severity)
		if(1.0)
			if (stat != 2)
				b_loss += 100
				f_loss += 100
		if(2.0)
			if (stat != 2)
				b_loss += 60
				f_loss += 60
		if(3.0)
			if (stat != 2)
				b_loss += 30
	bruteloss = b_loss
	fireloss = f_loss
	updatehealth()


/mob/living/silicon/ai/Topic(href, href_list)
	..()
	if (href_list["mach_close"])
		if (href_list["mach_close"] == "aialerts")
			viewalerts = 0
		var/t1 = text("window=[]", href_list["mach_close"])
		unset_machine()
		src << browse(null, t1)
	if (href_list["switchcamera"])
		switchCamera(locate(href_list["switchcamera"]) in cameranet.cameras)
	if (href_list["showalerts"])
		ai_alerts()
	if (href_list["showalerts"])
		ai_alerts()
	//Carn: holopad requests
/*	if (href_list["jumptoholopad"])
		var/obj/machinery/hologram/holopad/H = locate(href_list["jumptoholopad"])
		if(stat == CONSCIOUS)
			if(H)
				H.attack_ai(src) //may as well recycle
			else
				src << "<span class='notice'>Unable to locate the holopad.</span>"*/

	if (href_list["track"])
		var/mob/target = locate(href_list["track"]) in mob_list
		var/mob/living/silicon/ai/A = locate(href_list["track2"]) in mob_list
		if(A && target)
			A.ai_actual_track(target)
		return

	else if (href_list["faketrack"])
		var/mob/target = locate(href_list["track"]) in mob_list
		var/mob/living/silicon/ai/A = locate(href_list["track2"]) in mob_list
		if(A && target)

			A.cameraFollow = target
			A << text("Now tracking [] on camera.", target.name)
			if (usr.machine == null)
				usr.machine = usr

			while (src.cameraFollow == target)
				usr << "Target is not on or near any active cameras on the station. We'll check again in 5 seconds (unless you use the cancel-camera verb)."
				sleep(40)
				continue
		return
	return


/mob/living/silicon/ai/meteorhit(obj/O as obj)
	for(var/mob/M in viewers(src, null))
		M.show_message(text("\red [] has been hit by []", src, O), 1)
	if (health > 0)
		bruteloss += 30
		if ((O.icon_state == "flaming"))
			fireloss += 40
		updatehealth()
	return

/mob/living/silicon/ai/bullet_act(var/obj/item/projectile/Proj)
	..(Proj)
	updatehealth()
	return 2

/mob/living/silicon/ai/verb/show_laws_verb()
	set category = "AI Commands"
	set name = "Show Laws"
	show_laws()

/mob/living/silicon/ai/proc/switchCamera(var/obj/machinery/camera/C)
	src.cameraFollow = null

	if (!C || stat == 2) //C.can_use())
		return 0

	if(!src.eyeobj)
		view_core()
		return
	// ok, we're alive, camera is good and in our network...
	eyeobj.setLoc(get_turf(C))
	//machine = src
	return 1

/mob/living/silicon/ai/show_laws(var/everyone = 0)
	var/who

	if (everyone)
		who = world
	else
		who = src
		who << "<b>Obey these laws:</b>"

	laws_sanity_check()
	laws_object.show_laws(who)
/mob/living/silicon/ai/proc/laws_sanity_check()
	if (!laws_object)
		laws_object = new /datum/ai_laws/nanotrasen

/mob/living/silicon/ai/proc/set_zeroth_law(var/law)
	laws_sanity_check()
	laws_object.set_zeroth_law(law)

/mob/living/silicon/ai/proc/add_supplied_law(var/number, var/law)
	laws_sanity_check()
	laws_object.add_supplied_law(number, law)

/mob/living/silicon/ai/proc/clear_supplied_laws()
	laws_sanity_check()
	laws_object.clear_supplied_laws()

// This alarm does not show on the "Show Alerts" menu
/mob/living/silicon/ai/proc/triggerUnmarkedAlarm(var/class, area/A, var/O)
	if(stat == 2) // stat = 2 = dead AI
		return 1
	var/obj/machinery/camera/C = null
	var/list/CL = null
	var/alarmtext = ""
	if(class == "AirlockHacking") // In case more unmarked alerts would be added eventually;
		alarmtext = "--- Unauthorized remote access detected"
	if (O && istype(O, /list))
		CL = O
		if (CL.len == 1)
			C = CL[1]
	else if (O && istype(O, /obj/machinery/camera))
		C = O
	if (A)
		alarmtext += " in " + A.name
		if (O)
			if (C && C.status)
				alarmtext += text("! (<A HREF=?src=\ref[];switchcamera=\ref[]>[]</A>)", src, C, C.c_tag)
			else if (CL && CL.len)
				var/foo = 0
				var/dat2 = ""
				for (var/obj/machinery/camera/I in CL)
					dat2 += text("[]<A HREF=?src=\ref[];switchcamera=\ref[]>[]</A>", (!foo) ? "" : " | ", src, I, I.c_tag)
					foo = 1
				alarmtext += text("! ([])", dat2)
			else
				alarmtext += "! (No Camera)"
		else
			alarmtext += "! (No Camera)"
	else
		alarmtext += "!"
	src << alarmtext
	return 1

/mob/living/silicon/ai/triggerAlarm(var/class, area/A, var/O, var/alarmsource)
	if (stat == 2)
		return 1
	var/list/L = alarms[class]
	for (var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/sources = alarm[3]
			if (!(alarmsource in sources))
				sources += alarmsource
			return 1
	var/obj/machinery/camera/C = null
	var/list/CL = null
	if (O && istype(O, /list))
		CL = O
		if (CL.len == 1)
			C = CL[1]
	else if (O && istype(O, /obj/machinery/camera))
		C = O
	L[A.name] = list(A, (C) ? C : O, list(alarmsource))
	if (O)
		if (C && C.can_use())
			queueAlarm("--- [class] alarm detected in [A.name]! (<A HREF=?src=\ref[src];switchcamera=\ref[C]>[C.c_tag]</A>)", class)
		else if (CL && CL.len)
			var/foo = 0
			var/dat2 = ""
			for (var/obj/machinery/camera/I in CL)
				dat2 += text("[]<A HREF=?src=\ref[];switchcamera=\ref[]>[]</A>", (!foo) ? "" : " | ", src, I, I.c_tag)	//I'm not fixing this shit...
				foo = 1
			queueAlarm(text ("--- [] alarm detected in []! ([])", class, A.name, dat2), class)
		else
			queueAlarm(text("--- [] alarm detected in []! (No Camera)", class, A.name), class)
	else
		queueAlarm(text("--- [] alarm detected in []! (No Camera)", class, A.name), class)
	if (viewalerts) ai_alerts()
	return 1

/mob/living/silicon/ai/cancelAlarm(var/class, area/A as area, obj/origin)
	var/list/L = alarms[class]
	var/cleared = 0
	for (var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/srcs  = alarm[3]
			if (origin in srcs)
				srcs -= origin
			if (srcs.len == 0)
				cleared = 1
				L -= I
	if (cleared)
		queueAlarm(text("--- [] alarm in [] has been cleared.", class, A.name), class, 0)
		if (viewalerts) ai_alerts()
	return !cleared

/mob/living/silicon/ai/verb/change_network()
	set category = "AI Commands"
	set name = "Change Camera Subnetwork"

	var/net = input("Select a subnetwork", "AI", null) in ai_cam_marks
	var/turf/T = get_turf(ai_cam_marks[net])
	if(istype(T))
		src << "\blue Switched to [net] camera subnetwork."
		eyeobj.setLoc(T)

/mob/living/silicon/ai/proc/choose_modules()
	set category = "AI Commands"
	set name = "Choose Module"

	malf_picker.use(src)