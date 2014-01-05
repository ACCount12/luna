/*
#define AIRLOCK_WIRE_IDSCAN 1
#define AIRLOCK_WIRE_MAIN_POWER1 2
#define AIRLOCK_WIRE_MAIN_POWER2 4
#define AIRLOCK_WIRE_DOOR_BOLTS 8
#define AIRLOCK_WIRE_BACKUP_POWER1 16
#define AIRLOCK_WIRE_BACKUP_POWER2 32
#define AIRLOCK_WIRE_OPEN_DOOR 64
#define AIRLOCK_WIRE_AI_CONTROL 128
#define AIRLOCK_WIRE_ELECTRIFY 256
#define AIRLOCK_WIRE_CRUSH 512
#define AIRLOCK_WIRE_SPEED 1024
#define AIRLOCK_WIRE_LIGHT 2048
*/ // Defined in wires datum


/*	New methods:
	isWireCut - returns 1 if that wire (e.g. AIRLOCK_WIRE_DOOR_BOLTS) is cut, or 0 if not
	canAIControl - 1 if the AI can control the airlock, 0 if not (then check canAIHack to see if it can hack in)
	canAIHack - 1 if the AI can hack into the airlock to recover control, 0 if not. Also returns 0 if the AI does not *need* to hack it.
	canSynControl - 1 if the hack is doable, 0 if not doable
	canSynHack - 1 if the hacktool can do it's job, 0 if it's not doable/needed
	arePowerSystemsOn - 1 if the main or backup power are functioning, 0 if not. Does not check whether the power grid is charged or an APC has equipment on or anything like that. (Check (stat & NOPOWER) for that)
	requiresIDs - 1 if the airlock is requiring IDs, 0 if not
	isAllPowerCut - 1 if the main and backup power both have cut wires.
	regainMainPower - handles the effects of main power coming back on.
	loseMainPower - handles the effects of main power going offline. Usually (if one isn't already running) spawn a thread to count down how long it will be offline - counting down won't happen if main power was completely cut along with backup power, though, the thread will just sleep.
	loseBackupPower - handles the effects of backup power going offline.
	regainBackupPower - handles the effects of backup power coming back on.
	shock - has a chance of electrocuting its target.
*/

/obj/machinery/door/airlock
	name = "Airlock"
	icon = 'doorint.dmi'
	icon_state = "door_closed"

	var/aiControlDisabled = 0 //If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
	var/synDoorHacked = 0 // Has it been hacked? bool 1 = yes / 0 = no
	var/synHacking = 0 // Is hack in process y/n?
	var/secondsMainPowerLost = 0 //The number of seconds until power is restored.
	var/secondsBackupPowerLost = 0 //The number of seconds until power is restored.
	var/spawnPowerRestoreRunning = 0
	var/welded = null
	var/datum/wires/airlock/wires = null

	secondsElectrified = 0 //How many seconds remain until the door is no longer electrified. -1 if it is permanently electrified until someone fixes it.
	var/aiDisabledIdScanner = 0
	var/aiHacking = 0
	var/obj/machinery/door/airlock/closeOther = null
	var/closeOtherId = null
	var/safetylight = 1
	var/lockdownbyai = 0
	var/air_locked = 0 //Set if the airlock was locked in an emergency seal.

	var/lights = 1 // bolt lights show by default
	var/doortype = 0
	var/justzap = 0
	var/safe = 1
	var/hasShocked = 0 //Prevents multiple shocks from happening

	autoclose = 1
	networking = PROCESS_RPCS
	security = 1

/obj/machinery/door/airlock/mining
	name = "Mining"
	icon = 'icons/obj/doors/Doormining.dmi'
	req_access = null
	req_access_txt = "43"

/obj/machinery/door/airlock/vault
	name = "vault"
	icon = 'icons/obj/doors/vault.dmi'

/obj/machinery/door/airlock/atmos
	name = "Atmospherics"
	icon = 'icons/obj/doors/Dooratmo.dmi'
	req_access = null
	req_access_txt = "24"

/obj/machinery/door/airlock/glass/atmos
	name = "Atmospherics"
	icon = 'icons/obj/doors/Dooratmoglass.dmi'
	req_access = null
	req_access_txt = "24"

/obj/machinery/door/airlock/glass/mining
	name = "Mining"
	icon = 'icons/obj/doors/Doorminingglass.dmi'
	req_access = null
	req_access_txt = "43"

/obj/machinery/door/airlock/command
	name = "Airlock"
	icon = 'Doorcom.dmi'
	req_access = list(access_heads)

/obj/machinery/door/airlock/glass/command
	icon = 'Doorcomglass.dmi'
	req_access = list(access_heads)

/obj/machinery/door/airlock/highsecurity
	name = "high tech security airlock"
	icon = 'icons/obj/doors/hightechsecurity.dmi'

/obj/machinery/door/airlock/highsecurity/black
	name = "airlock"
	icon = 'icons/obj/doors/hightechsyndie.dmi'

/obj/machinery/door/airlock/security
	explosionstrength = 3
	name = "Airlock"
	icon = 'Doorsec.dmi'
	req_access = list(access_security)

/obj/machinery/door/airlock/glass/security
	icon = 'Doorsecglass.dmi'
	req_access = list(access_security)

/obj/machinery/door/airlock/security/hatch
	icon = 'Doorhatcharmoury.dmi'

/obj/machinery/door/airlock/engineering
	name = "Airlock"
	icon = 'Dooreng.dmi'
	req_access = list(access_engine)

/obj/machinery/door/airlock/glass/engineering
	icon = 'Doorengglass.dmi'
	req_access = list(access_engine)

/obj/machinery/door/airlock/medical
	name = "Airlock"
	icon = 'Doormed.dmi'
	//req_access = list(access_medical)

/obj/machinery/door/airlock/science
	name = "Airlock"
	icon = 'Doorsci.dmi'
	//req_access = list(access_medical)

/obj/machinery/door/airlock/glass/medical
	icon = 'Doormedglass.dmi'

/obj/machinery/door/airlock/glass/science
	icon = 'Doorsciglass.dmi'

/obj/machinery/door/airlock/maintenance
	name = "Maintenance Access"
	icon = 'Doormaint.dmi'
	req_access = list(access_maint_tunnels)

/obj/machinery/door/airlock/maintenance/hatch
	name = "Maintenance Access"
	icon = 'Doorhatchmaint.dmi'
	req_access = list(access_maint_tunnels)

/obj/machinery/door/airlock/external
	name = "External Airlock"
	icon = 'Doorext.dmi'

/obj/machinery/door/airlock/glass
	name = "Glass Airlock"
	icon = 'Doorglass.dmi'
	opacity = 0

/obj/machinery/door/airlock/highsec
	explosionstrength = 4
	name = "Secure Airlock"
	icon = 'Doorhatchele.dmi'

/obj/machinery/door/airlock/freezer
	icon = 'Doorfreezer.dmi'

/obj/machinery/door/airlock/mineral
	var/mineral = null

/obj/machinery/door/airlock/mineral/gold
	name = "gold airlock"
	icon = 'icons/obj/doors/Doorgold.dmi'
	mineral = "gold"

/obj/machinery/door/airlock/mineral/silver
	name = "silver airlock"
	icon = 'icons/obj/doors/Doorsilver.dmi'
	mineral = "silver"

/obj/machinery/door/airlock/mineral/plasma
	name = "plasma airlock"
	desc = "No way this can end badly."
	icon = 'icons/obj/doors/Doorplasma.dmi'
	mineral = "plasma"

/obj/machinery/door/airlock/mineral/sandstone
	name = "sandstone airlock"
	icon = 'icons/obj/doors/Doorsand.dmi'
	mineral = "sandstone"

/obj/machinery/door/airlock/mineral/diamond
	name = "diamond airlock"
	icon = 'icons/obj/doors/Doordiamond.dmi'
	mineral = "diamond"

/obj/machinery/door/airlock/mineral/uranium
	name = "uranium airlock"
	desc = "And they said I was crazy."
	icon = 'icons/obj/doors/Dooruranium.dmi'
	mineral = "uranium"

/obj/machinery/door/airlock/mineral/clown
	name = "bananium airlock"
	desc = "Honkhonkhonk"
	icon = 'icons/obj/doors/Doorbananium.dmi'
	mineral = "clown"



/obj/machinery/door/airlock/New()
	..()
	if (src.closeOtherId != null)
		spawn (5)
			for (var/obj/machinery/door/airlock/A in machines)
				if (A.closeOtherId == src.closeOtherId && A != src)
					src.closeOther = A
					break
	wires = new(src)

/obj/machinery/door/airlock/proc/isWireCut(var/wireIndex)
	// You can find the wires in the datum folder.
	return wires.IsIndexCut(wireIndex)

/obj/machinery/door/airlock/Bumped(atom/AM)

	if(p_open || operating || !density) return

	if(istype(AM, /mob))
		var/mob/M = AM

		if(world.timeofday - M.last_bumped <= 5) return

		if(M.client && !M:handcuffed) attack_hand(M)

		if(src.secondsElectrified != 0 && istype(M, /mob/living))
			shock(M,100)
			return

		if(M.hallucination > 50 && prob(10) && src.operating == 0)
			M << "\red <B>You feel a powerful shock course through your body!</B>"
			M.halloss += 30
			M.Stun(10)
			return

	else if(istype(AM, /obj/machinery/bot))
		var/obj/machinery/bot/bot = AM
		if(src.check_access(bot.botcard))
			if(density)
				if(!locked && !air_locked)
					open()
				else
					bot.shutdowns()

	else if(istype(AM, /obj/mecha))
		var/obj/mecha/mecha = AM
		if(density)
			if(mecha.occupant && src.allowed(mecha.occupant))
				open()
		return

	else if(istype(AM, /obj/alien/facehugger))
		if(src.check_access(null))
			if(density)
				open()

	..()

/obj/machinery/door/airlock/open(var/forced=0)
	if( operating || welded || locked )
		return 0
	if(!forced)
		if( !arePowerSystemsOn() || (stat & NOPOWER) || isWireCut(AIRLOCK_WIRE_OPEN_DOOR) )
			return 0
	use_power(50)
	if(istype(src, /obj/machinery/door/airlock/glass))
		playsound(src.loc, 'sound/machines/windowdoor.ogg', 100, 1)
	if(istype(src, /obj/machinery/door/airlock/mineral/clown))
		playsound(src.loc, 'sound/items/bikehorn.ogg', 30, 1)
	else
		playsound(src.loc, 'sound/machines/airlock.ogg', 30, 1)
	if(src.closeOther != null && istype(src.closeOther, /obj/machinery/door/airlock/) && !src.closeOther.density)
		src.closeOther.close()

	if(autoclose  && normalspeed)
		spawn(150)
			autoclose()
	else if(autoclose && !normalspeed)
		spawn(5)
			autoclose()

	return ..()

/obj/machinery/door/airlock/forceopen()
	if(!density)
		return 1
	if (src.operating == 1) //doors can still open when emag-disabled
		return 0
	if (!ticker)
		return 0
	if(!src.operating) //in case of emag
		src.operating = 1

	do_animate("opening")
	sleep(10)
	src.density = 0
	update_icon()

	src.ul_SetOpacity(0)
	update_nearby_tiles()

	if(operating == 1) //emag again
		src.operating = 0
	return 1


/obj/machinery/door/airlock/close(var/forced=0)
	if(operating || welded || locked)
		return
	if(!forced)
		if(!arePowerSystemsOn() || (stat & NOPOWER) || isWireCut(AIRLOCK_WIRE_DOOR_BOLTS) )
			return
	if(safe)
		if(locate(/mob/living) in get_turf(src))
		//	playsound(src.loc, 'sound/machines/buzz-two.ogg', 50, 0)	//THE BUZZING IT NEVER STOPS	-Pete
			spawn (60)
				close()
			return
	else
		for(var/mob/living/M in get_turf(src))
			M.adjustBruteLoss(15)
			if(!isrobot(M))
				M.Stun(5)
				M.Weaken(5)
				M.emote("scream")
			var/turf/location = src.loc
			if(istype(location, /turf/simulated))
				location.add_blood(M)

	use_power(50)
	if(istype(src, /obj/machinery/door/airlock/glass))
		playsound(src.loc, 'sound/machines/windowdoor.ogg', 30, 1)
	if(istype(src, /obj/machinery/door/airlock/mineral/clown))
		playsound(src.loc, 'sound/items/bikehorn.ogg', 30, 1)
	else
		playsound(src.loc, 'sound/machines/airlock.ogg', 30, 1)
	var/obj/structure/window/killthis = (locate(/obj/structure/window) in get_turf(src))
	if(killthis)
		killthis.ex_act(2)//Smashin windows

	..()


/*
About the airlock wires panel:
*	An airlock wire dialog can be accessed by the normal way or by using wirecutters or a multitool on the door while the wire-panel is open.
	This would show the following wires, which you can either wirecut/mend or send a multitool pulse through. There are 9 wires
.
*		One wire from the ID scanner. Sending a pulse through this flashes the red light on the door (if the door has power).
			If you cut this wire, the door will stop recognizing valid IDs. (If the door has 0000 access, it still opens and closes, though)

*		Two wires for power. Sending a pulse through either one causes a breaker to trip, disabling the door for 10 seconds if backup power is connected,
		or 1 minute if not (or until backup power comes back on, whichever is shorter). Cutting either one disables the main door power,
		but unless backup power is also cut, the backup power re-powers the door in 10 seconds. While unpowered, the door may be \red open,
		but bolts-raising will not work. Cutting these wires may electrocute the user.

*		One wire for door bolts. Sending a pulse through this drops door bolts (whether the door is powered or not) or raises them (if it is).
		Cutting this wire also drops the door bolts, and mending it does not raise them. If the wire is cut, trying to raise the door bolts will not work.

*		Two wires for backup power. Sending a pulse through either one causes a breaker to trip,
		but this does not disable it unless main power is down too
		(in which case it is disabled for 1 minute or however long it takes main power to come back, whichever is shorter).
		Cutting either one disables the backup door power (allowing it to be crowbarred open, but disabling bolts-raising), but may electocute the user.

*		One wire for opening the door. Sending a pulse through this while the door has power makes it open the door if no access is required.

*		One wire for AI control. Sending a pulse through this blocks AI control for a second or so
		(which is enough to see the AI control light on the panel dialog go off and back on again).
		Cutting this prevents the AI from controlling the door unless it has hacked the door through the power connection (which takes about a minute).
		If both main and backup power are cut, as well as this wire, then the AI cannot operate or hack the door at all.

*		One wire for electrifying the door. Sending a pulse through this electrifies the door for 30 seconds.
		Cutting this wire electrifies the door, so that the next person to touch the door without insulated gloves gets electrocuted.
		(Currently it is also STAYING electrified until someone mends the wire)
*/


/obj/machinery/door/airlock/proc/isElectrified()
	if(src.secondsElectrified > 0)
		return 1
	else return 0

/*obj/machinery/door/airlock/proc/isWireColorCut(var/wireColor)
	var/wireFlag = airlockWireColorToFlag[wireColor]
	return ((src.wires & wireFlag) == 0)*/

/obj/machinery/door/airlock/proc/canAIControl()
	return ((src.aiControlDisabled!=1) && !src.isAllPowerCut())

/obj/machinery/door/airlock/proc/canAIHack()
	return ((src.aiControlDisabled==1) && !src.isAllPowerCut())

/obj/machinery/door/airlock/proc/canSynControl()
	return (src.synDoorHacked && !src.isAllPowerCut())

/obj/machinery/door/airlock/proc/canSynHack(obj/item/device/hacktool/H)
	if(in_range(src, usr) && get_dist(src, H) <= 1 && src.synDoorHacked==0 && !src.isAllPowerCut())
		return 1

/obj/machinery/door/airlock/proc/arePowerSystemsOn()
	return (powered() && (src.secondsMainPowerLost==0 || src.secondsBackupPowerLost==0))

/obj/machinery/door/airlock/requiresID()
	return !(src.isWireCut(AIRLOCK_WIRE_IDSCAN) || aiDisabledIdScanner)

/obj/machinery/door/airlock/proc/isAllPowerCut()
	var/retval=0
	if (src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1) || src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2))
		if (src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1) || src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2))
			retval=1
	return retval


/obj/machinery/door/airlock/proc/regainMainPower()
	if (src.secondsMainPowerLost > 0)
		src.secondsMainPowerLost = 0


/obj/machinery/door/airlock/proc/loseMainPower()
	if (src.secondsMainPowerLost <= 0)
		src.secondsMainPowerLost = 60
		if (src.secondsBackupPowerLost < 10)
			src.secondsBackupPowerLost = 10
	if (!src.spawnPowerRestoreRunning)
		src.spawnPowerRestoreRunning = 1
		spawn(0)
			var/cont = 1
			while (cont)
				sleep(10)
				cont = 0
				if (src.secondsMainPowerLost>0)
					if ((!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2)))
						src.secondsMainPowerLost -= 1
						src.updateDialog()
					cont = 1

				if (src.secondsBackupPowerLost>0)
					if ((!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2)))
						src.secondsBackupPowerLost -= 1
						src.updateDialog()
					cont = 1
			src.spawnPowerRestoreRunning = 0
			src.updateDialog()


/obj/machinery/door/airlock/proc/loseBackupPower()
	if (src.secondsBackupPowerLost < 60)
		src.secondsBackupPowerLost = 60


/obj/machinery/door/airlock/proc/regainBackupPower()
	if (src.secondsBackupPowerLost > 0)
		src.secondsBackupPowerLost = 0


//borrowed from the grille's get_connection
/obj/machinery/door/airlock/proc/get_connection()
	if(stat & NOPOWER)	return 0
	return 1

// shock user with probability prb (if all connections & power are working)
// returns 1 if shocked, 0 otherwise
// The preceding comment was borrowed from the grille's shock script
/atom/proc/shock(mob/user, prb)
	if(!prob(prb))
		return 0 //you lucked out, no shock for you
	if(!user)
		return 0
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	return Electrocute(user)


/obj/machinery/door/airlock/update_icon()
	if(overlays) overlays = null
	if(density)
		if(locked && safetylight)
			icon_state = "door_locked"
		else
			icon_state = "door_closed"
		if(p_open || welded)
			overlays = list()
			if(p_open)
				overlays += image(icon, "panel_open")
			if(welded)
				overlays += image(icon, "welded")
	else
		icon_state = "door_open"

	return


/obj/machinery/door/airlock/do_animate(animation)
	switch(animation)
		if("opening")
			if(overlays) overlays = null
			if(p_open)
				icon_state = "o_door_opening" //can not use flick due to BYOND bug updating overlays right before flicking
			else
				flick("door_opening", src)
		if("closing")
			if(overlays) overlays = null
			if(p_open)
				flick("o_door_closing", src)
			else
				flick("door_closing", src)
		if("spark")
			flick("door_spark", src)
		if("deny")
			flick("door_deny", src)
	return


/obj/machinery/door/airlock/attack_ai(mob/user as mob)
	if (istype(user, /mob/living/silicon/robot) && src.p_open)
		var/mob/living/silicon/robot/R = user
		if (R.module && R.module.name == "engineering robot module")
			src.attack_hand(user)
			return
	if (!src.canAIControl() && src.canAIHack())
		src.hack(user)
		return

	//Interface for the AI.
	user.machine = src
	user << browse(get_control_screen(), "window=airlock")
	onclose(user, "airlock")

//aiDisable - 1 idscan, 2 disrupt main power, 3 disrupt backup power, 4 drop door bolts, 5 un-electrify door, 7 close door
//aiEnable - 1 idscan, 4 raise door bolts, 5 electrify door for 30 seconds, 6 electrify door indefinitely, 7 open door


/obj/machinery/door/airlock/proc/attack_hack(mob/user as mob, obj/item/device/hacktool/C)
	if(C.in_use)
		user << "We are already hacking another airlock."
		return
	if (!src.canSynControl() && src.canSynHack(C))
		src.synhack(user, C)
		return

	user << browse(get_control_screen(), "window=airlock")
	onclose(user, "airlock")


/obj/machinery/door/airlock/call_function(datum/function/F)
	..()
	if(uppertext(F.arg1) != net_pass)
		var/datum/function/R = new()
		R.name = "response"
		R.source_id = address
		R.destination_id = F.source_id
		R.arg1 += "Incorrect Access token"
		send_packet(src,F.source_id,R)
		return 0 // send a wrong password really.
	if (F.name == "bolts")
		if (!src.locked)
			src.locked = 1
			src.updateUsrDialog()
		else
			if(src.arePowerSystemsOn())
				src.locked = 0
				src.air_locked = 0
				src.updateUsrDialog()
		update_icon()
	if (F.name == "power")
		src.loseMainPower()
	if (F.name == "backup_power")
		src.loseBackupPower()
	if (F.name == "electrify")
		if (src.secondsElectrified==0)
			src.secondsElectrified = 30
			spawn(10)
				//TODO: Move this into process() and make pulsing reset secondsElectrified to 30
				while (src.secondsElectrified>0)
					src.secondsElectrified-=1
					src.updateUsrDialog()
					if (src.secondsElectrified<0)
						src.secondsElectrified = 0
					src.updateUsrDialog()
					sleep(10)
	if (F.name == "open")
		if (src.density)
			open()
	if (F.name == "close")
		if (!src.density)
			close()

/obj/machinery/door/airlock/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained() )
		return
	if (href_list["close"])
		usr << browse(null, "window=airlock")
		if (usr.machine==src)
			usr.machine = null
			return

	if (istype(usr, /mob/living/silicon) || istype(usr.equipped(), /obj/item/device/hacktool))
		//AI or Syndicate using hacktool
		if (!src.canAIControl() || (istype(usr.equipped(), /obj/item/device/hacktool/) && (!src.canSynControl() || !in_range(src, usr))))
			usr << "Airlock control connection lost!"
			return
		//aiDisable - 1 idscan, 2 disrupt main power, 3 disrupt backup power, 4 drop door bolts, 5 un-electrify door, 7 close door
		//aiEnable - 1 idscan, 4 raise door bolts, 5 electrify door for 30 seconds, 6 electrify door indefinitely, 7 open door
		if(href_list["aiDisable"])
			var/code = text2num(href_list["aiDisable"])
			switch (code)
				if(1)
					//disable idscan
					if(src.isWireCut(AIRLOCK_WIRE_IDSCAN))
						usr << "The IdScan wire has been cut - So, you can't disable it, but it is already disabled anyways."
					else if(src.aiDisabledIdScanner)
						usr << "You've already disabled the IdScan feature."
					else
						src.aiDisabledIdScanner = 1
				if(2)
					//disrupt main power
					if(src.secondsMainPowerLost == 0)
						src.loseMainPower()
					else
						usr << "Main power is already offline."
				if(3)
					//disrupt backup power
					if(src.secondsBackupPowerLost == 0)
						src.loseBackupPower()
					else
						usr << "Backup power is already offline."
				if(4)
					//drop door bolts
					if(src.isWireCut(AIRLOCK_WIRE_DOOR_BOLTS))
						usr << "You can't drop the door bolts - The door bolt dropping wire has been cut."
					else if(src.locked!=1)
						src.locked = 1
						update_icon()
				if(5)
					//un-electrify door
					if(src.isWireCut(AIRLOCK_WIRE_ELECTRIFY))
						usr << text("Can't un-electrify the airlock - The electrification wire is cut.")
					else if(src.secondsElectrified==-1)
						src.secondsElectrified = 0
					else if(src.secondsElectrified>0)
						src.secondsElectrified = 0

				if(8)
					// Safeties!  We don't need no stinking safeties!
					if (src.isWireCut(AIRLOCK_WIRE_CRUSH))
						usr << text("Control to door sensors is disabled.")
					else if (src.safe)
						safe = 0
					else
						usr << text("Firmware reports safeties already overriden.")



				if(9)
					// Door speed control
					if(src.isWireCut(AIRLOCK_WIRE_SPEED))
						usr << text("Control to door timing circuitry has been severed.")
					else if (src.normalspeed)
						normalspeed = 0
					else
						usr << text("Door timing circurity already accellerated.")

				if(7)
					//close door
					if(src.welded)
						usr << text("The airlock has been welded shut!")
					else if(src.locked)
						usr << text("The door bolts are down!")
					else if(!src.density)
						close()
					else
						open()

				if(10)
					// Bolt lights
					if(src.isWireCut(AIRLOCK_WIRE_LIGHT))
						usr << text("Control to door bolt lights has been severed.</a>")
					else if (src.lights)
						lights = 0
					else
						usr << text("Door bolt lights are already disabled!")



		else if(href_list["aiEnable"])
			var/code = text2num(href_list["aiEnable"])
			switch (code)
				if(1)
					//enable idscan
					if(src.isWireCut(AIRLOCK_WIRE_IDSCAN))
						usr << "You can't enable IdScan - The IdScan wire has been cut."
					else if(src.aiDisabledIdScanner)
						src.aiDisabledIdScanner = 0
					else
						usr << "The IdScan feature is not disabled."
				if(4)
					//raise door bolts
					if(src.isWireCut(AIRLOCK_WIRE_DOOR_BOLTS))
						usr << text("The door bolt drop wire is cut - you can't raise the door bolts.<br>\n")
					else if(!src.locked)
						usr << text("The door bolts are already up.<br>\n")
					else
						if(src.arePowerSystemsOn())
							src.locked = 0
							update_icon()
						else
							usr << text("Cannot raise door bolts due to power failure.<br>\n")

				if(5)
					//electrify door for 30 seconds
					if(src.isWireCut(AIRLOCK_WIRE_ELECTRIFY))
						usr << text("The electrification wire has been cut.<br>\n")
					else if(src.secondsElectrified==-1)
						usr << text("The door is already indefinitely electrified. You'd have to un-electrify it before you can re-electrify it with a non-forever duration.<br>\n")
					else if(src.secondsElectrified!=0)
						usr << text("The door is already electrified. You can't re-electrify it while it's already electrified.<br>\n")
					else
						src.secondsElectrified = 30
						spawn(10)
							while (src.secondsElectrified>0)
								src.secondsElectrified-=1
								if(src.secondsElectrified<0)
									src.secondsElectrified = 0
								src.updateUsrDialog()
								sleep(10)
				if(6)
					//electrify door indefinitely
					if(src.isWireCut(AIRLOCK_WIRE_ELECTRIFY))
						usr << text("The electrification wire has been cut.<br>\n")
					else if(src.secondsElectrified==-1)
						usr << text("The door is already indefinitely electrified.<br>\n")
					else if(src.secondsElectrified!=0)
						usr << text("The door is already electrified. You can't re-electrify it while it's already electrified.<br>\n")
					else
						src.secondsElectrified = -1

				if (8) // Not in order >.>
					// Safeties!  Maybe we do need some stinking safeties!
					if (src.isWireCut(AIRLOCK_WIRE_CRUSH))
						usr << text("Control to door sensors is disabled.")
					else if (!src.safe)
						safe = 1
						src.updateUsrDialog()
					else
						usr << text("Firmware reports safeties already in place.")

				if(9)
					// Door speed control
					if(src.isWireCut(AIRLOCK_WIRE_SPEED))
						usr << text("Control to door timing circuitry has been severed.")
					else if (!src.normalspeed)
						normalspeed = 1
						src.updateUsrDialog()
					else
						usr << text("Door timing circurity currently operating normally.")

				if(7)
					//open door
					if(src.welded)
						usr << text("The airlock has been welded shut!")
					else if(src.locked)
						usr << text("The door bolts are down!")
					else if(src.density)
						open()
					else
						close()

				if(10)
					// Bolt lights
					if(src.isWireCut(AIRLOCK_WIRE_LIGHT))
						usr << text("Control to door bolt lights has been severed.</a>")
					else if (!src.lights)
						lights = 1
						src.updateUsrDialog()
					else
						usr << text("Door bolt lights are already enabled!")
		if(!istype(usr, /mob/living/silicon))
			add_fingerprint(usr) // Adding again in case we implement something to wipe fingeprints from things
			src.attack_hack(usr) // Because updateUsrDialog calls attack_hand, and the airlock attack_hand can't handle hacktools
		else
			src.updateUsrDialog()
		src.update_icon()

	return


/obj/machinery/door/airlock/proc/hack(mob/user as mob)
	if (src.aiHacking==0)
		src.aiHacking=1
		spawn(20 * tick_multiplier)
			user << "Airlock AI control has been blocked. Beginning fault-detection."
			sleep(50 * tick_multiplier)
			if (src.canAIControl())
				user << "Alert cancelled. Airlock control has been restored without our assistance."
				src.aiHacking=0
				return
			else if (!src.canAIHack())
				user << "We've lost our connection! Unable to hack airlock."
				src.aiHacking=0
				return
			user << "Fault confirmed: airlock control wire disabled or cut."
			sleep(20 * tick_multiplier)
			user << "Attempting to hack into airlock. This may take some time."
			sleep(240 * tick_multiplier)
			if (src.canAIControl())
				user << "Alert cancelled. Airlock control has been restored without our assistance."
				src.aiHacking=0
				return
			else if (!src.canAIHack())
				user << "We've lost our connection! Unable to hack airlock."
				src.aiHacking=0
				return
			user << "Upload access confirmed. Loading control program into airlock software."
			sleep(210 * tick_multiplier)
			if (src.canAIControl())
				user << "Alert cancelled. Airlock control has been restored without our assistance."
				src.aiHacking=0
				return
			else if (!src.canAIHack())
				user << "We've lost our connection! Unable to hack airlock."
				src.aiHacking=0
				return
			user << "Transfer complete. Forcing airlock to execute program."
			sleep(50 * tick_multiplier)
			//disable blocked control
			src.aiControlDisabled = 2
			user << "Receiving control information from airlock."
			sleep(10 * tick_multiplier)
			//bring up airlock dialog
			src.aiHacking = 0
			src.attack_ai(user)


/obj/machinery/door/airlock/attack_paw(mob/user as mob)
	return src.attack_hand(user)


/obj/machinery/door/airlock/attack_hand(mob/user as mob)
	if (!istype(usr, /mob/living/silicon))
		if (src.isElectrified())
			if(shock(user, 100))
				return

	if (ishuman(user) && prob(30) && src.density)
		var/mob/living/carbon/human/H = user
		if(H.brainloss >= 60)
			playsound(src.loc, 'bang.ogg', 25, 1)
			if(!istype(H.head, /obj/item/clothing/head/helmet))
				for(var/mob/M in viewers(src, null))
					M.show_message("\red [user] headbutts the airlock.", 1, "\red You hear a bang.", 2)
				var/datum/organ/external/affecting = H.organs["head"]
				affecting.take_damage(10, 0)
				H.stunned = 8
				H.weakened = 5
				H.UpdateDamage()
				H.UpdateDamageIcon()
			else
				for(var/mob/M in viewers(src, null))
					M.show_message("\red [user] headbutts the airlock. Good thing they're wearing a helmet.", 1, "\red You hear a bang.", 2)
			return

	if (src.p_open)
		wires.Interact(user)
	else
		..(user)
	return


/obj/machinery/door/airlock/attackby(C as obj, mob/user as mob)
	if (!istype(usr, /mob/living/silicon))
		if (src.isElectrified())
			if(shock(user, 75))
				return

	src.add_fingerprint(user)
	if ((istype(C, /obj/item/weapon/weldingtool) && !src.operating && src.density))
		var/obj/item/weapon/weldingtool/W = C
		if(W.welding)
			if (W.get_fuel() > 2)
				W.use_fuel(2)
				W.eyecheck(user)
			else
				user << "Need more welding fuel!"
				return
			if (!src.welded)
				src.welded = 1
			else
				src.welded = null
			src.update_icon()
			return
	else if (istype(C, /obj/item/weapon/screwdriver))
		src.p_open = !src.p_open
		src.update_icon()
	else if (IsWiresHackingTool(C))
		return src.attack_hand(user)
	else if (istype(C, /obj/item/device/hacktool))
		return src.attack_hack(user, C)
	else if (istype(C, /obj/item/weapon/crowbar))
		if(!welded && !locked && !operating)
			if (src.density && (!src.arePowerSystemsOn() || (stat & NOPOWER)))
				open(1)
			else
				close(1)

	else
		..()
	return


/obj/machinery/door/airlock/proc/synhack(mob/user as mob, obj/item/device/hacktool/I)
	if (src.synHacking==0)
		src.synHacking=1
		I.in_use = 1
		spawn(20 * tick_multiplier)
			user << "Jacking in. Stay close to the airlock or you'll rip the cables out and we'll have to start over."
			sleep(25 * tick_multiplier)
			if (src.canSynControl())
				user << "Hack cancelled, control already possible."
				src.synHacking=0
				I.in_use = 0
				return
			else if (!src.canSynHack(I))
				user << "\red Connection lost. Stand still and stay near the airlock!"
				src.synHacking=0
				I.in_use = 0
				return
			user << "Connection established."
			sleep(10 * tick_multiplier)
			user << "Attempting to hack into airlock. This may take some time."
			sleep(100 * tick_multiplier)

			if (!src.canSynHack(I))
				user << "\red Hack aborted: landline connection lost. Stay closer to the airlock."
				src.synHacking=0
				I.in_use = 0
				return
			else if (src.canSynControl())
				user << "Local override already in place, hack aborted."
				src.synHacking=0
				I.in_use = 0
				return
			user << "Upload access confirmed. Loading control program into airlock software."
			sleep(85 * tick_multiplier)
			if (!src.canSynHack(I))
				user << "\red Hack aborted: cable connection lost. Do not move away from the airlock."
				src.synHacking=0
				I.in_use = 0
				return
			else if (src.canSynControl())
				user << "Upload access aborted, local override already in place."
				src.synHacking=0
				I.in_use = 0
				return
			user << "Transfer complete. Forcing airlock to execute program."
			sleep(25 * tick_multiplier)
			//disable blocked control
			src.synDoorHacked = 1
			user << "Bingo! We're in. Airlock control panel coming right up."
			sleep(5 * tick_multiplier)
			//bring up airlock dialog
			src.synHacking = 0
			I.in_use = 0
			src.attack_hack(user, I)

/obj/machinery/door/airlock/proc/get_control_screen()
	var/t1 = text("<B>Airlock Control</B><br>\n")
	if(src.secondsMainPowerLost > 0)
		if((!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2)))
			t1 += text("Main power is offline for [] seconds.<br>\n", src.secondsMainPowerLost)
		else
			t1 += text("Main power is offline indefinitely.<br>\n")
	else
		t1 += text("Main power is online.")

	if(src.secondsBackupPowerLost > 0)
		if((!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2)))
			t1 += text("Backup power is offline for [] seconds.<br>\n", src.secondsBackupPowerLost)
		else
			t1 += text("Backup power is offline indefinitely.<br>\n")
	else if(src.secondsMainPowerLost > 0)
		t1 += text("Backup power is online.")
	else
		t1 += text("Backup power is offline, but will turn on if main power fails.")
	t1 += "<br>\n"

	if(src.isWireCut(AIRLOCK_WIRE_IDSCAN))
		t1 += text("IdScan wire is cut.<br>\n")
	else if(src.aiDisabledIdScanner)
		t1 += text("IdScan disabled. <A href='?src=\ref[];aiEnable=1'>Enable?</a><br>\n", src)
	else
		t1 += text("IdScan enabled. <A href='?src=\ref[];aiDisable=1'>Disable?</a><br>\n", src)

	if(src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1))
		t1 += text("Main Power Input wire is cut.<br>\n")
	if(src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2))
		t1 += text("Main Power Output wire is cut.<br>\n")
	if(src.secondsMainPowerLost == 0)
		t1 += text("<A href='?src=\ref[];aiDisable=2'>Temporarily disrupt main power?</a>.<br>\n", src)
	if(src.secondsBackupPowerLost == 0)
		t1 += text("<A href='?src=\ref[];aiDisable=3'>Temporarily disrupt backup power?</a>.<br>\n", src)

	if(src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1))
		t1 += text("Backup Power Input wire is cut.<br>\n")
	if(src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2))
		t1 += text("Backup Power Output wire is cut.<br>\n")

	if(src.isWireCut(AIRLOCK_WIRE_DOOR_BOLTS))
		t1 += text("Door bolt drop wire is cut.<br>\n")
	else if(!src.locked)
		t1 += text("Door bolts are up. <A href='?src=\ref[];aiDisable=4'>Drop them?</a><br>\n", src)
	else
		t1 += text("Door bolts are down.")
		if(src.arePowerSystemsOn())
			t1 += text(" <A href='?src=\ref[];aiEnable=4'>Raise?</a><br>\n", src)
		else
			t1 += text(" Cannot raise door bolts due to power failure.<br>\n")

	if(src.isWireCut(AIRLOCK_WIRE_LIGHT))
		t1 += text("Door bolt lights wire is cut.<br>\n")
	else if(!src.lights)
		t1 += text("Door lights are off. <A href='?src=\ref[];aiEnable=10'>Enable?</a><br>\n", src)
	else
		t1 += text("Door lights are on. <A href='?src=\ref[];aiDisable=10'>Disable?</a><br>\n", src)

	if(src.isWireCut(AIRLOCK_WIRE_ELECTRIFY))
		t1 += text("Electrification wire is cut.<br>\n")
	if(src.secondsElectrified==-1)
		t1 += text("Door is electrified indefinitely. <A href='?src=\ref[];aiDisable=5'>Un-electrify it?</a><br>\n", src)
	else if(src.secondsElectrified>0)
		t1 += text("Door is electrified temporarily ([] seconds). <A href='?src=\ref[];aiDisable=5'>Un-electrify it?</a><br>\n", src.secondsElectrified, src)
	else
		t1 += text("Door is not electrified. <A href='?src=\ref[];aiEnable=5'>Electrify it for 30 seconds?</a> Or, <A href='?src=\ref[];aiEnable=6'>Electrify it indefinitely until someone cancels the electrification?</a><br>\n", src, src)

	if(src.isWireCut(AIRLOCK_WIRE_CRUSH))
		t1 += text("Door force sensors not responding.</a><br>\n")
	else if(src.safe)
		t1 += text("Door safeties operating normally.  <A href='?src=\ref[];aiDisable=8'> Override?</a><br>\n",src)
	else
		t1 += text("Danger.  Door safeties disabled.  <A href='?src=\ref[];aiEnable=8'> Restore?</a><br>\n",src)

	if(src.isWireCut(AIRLOCK_WIRE_SPEED))
		t1 += text("Door timing circuitry not responding.</a><br>\n")
	else if(src.normalspeed)
		t1 += text("Door timing circuitry operating normally.  <A href='?src=\ref[];aiDisable=9'> Override?</a><br>\n",src)
	else
		t1 += text("Warning.  Door timing circuitry operating abnormally.  <A href='?src=\ref[];aiEnable=9'> Restore?</a><br>\n",src)


	if(src.welded)
		t1 += text("Door appears to have been welded shut.<br>\n")
	else if(!src.locked)
		if(src.density)
			t1 += text("<A href='?src=\ref[];aiEnable=7'>Open door</a><br>\n", src)
		else
			t1 += text("<A href='?src=\ref[];aiDisable=7'>Close door</a><br>\n", src)

	t1 += text("<p><a href='?src=\ref[];close=1'>Close</a></p>\n", src)

	return t1