/var/security_level = SEC_LEVEL_GREEN
//0 = SEC_LEVEL_GREEN
//1 = SEC_LEVEL_BLUE
//2 = SEC_LEVEL_RED
//3 = SEC_LEVEL_DELTA

/proc/set_security_level(var/level, var/silent = 0)
	var/const/alert_desc_green = "All threats to the ship have passed. Security may not have weapons visible, privacy laws are once again fully enforced."
	var/const/alert_desc_blue_upto = "The ship has received reliable information about possible hostile activity on the ship. Security staff may have weapons visible, random searches are permitted."
	var/const/alert_desc_blue_downto = "The immediate threat has passed. Security may no longer have weapons drawn at all times, but may continue to have them visible. Random searches are still allowed."
	var/const/alert_desc_red_upto = "There is an immediate serious threat to the ship. Security may have weapons unholstered at all times. Random searches are allowed and advised."
	var/const/alert_desc_red_downto = "The self-destruct mechanism has been deactivated, there is still however an immediate serious threat to the ship. Security may have weapons unholstered at all times, random searches are allowed and advised."
	var/const/alert_desc_delta = "The ship's self-destruct mechanism has been engaged. All crew are instructed to obey all instructions given by heads of staff. Any violations of these orders can be punished by death. This is not a drill."
	switch(level)
		if("green")
			level = SEC_LEVEL_GREEN
		if("blue")
			level = SEC_LEVEL_BLUE
		if("red")
			level = SEC_LEVEL_RED
		if("delta")
			level = SEC_LEVEL_DELTA

	//Will not be announced if you try to set to the same level as it already is
	if(level >= SEC_LEVEL_GREEN && level <= SEC_LEVEL_DELTA && level != security_level)
		switch(level)
			if(SEC_LEVEL_GREEN)
				if(!silent)
					world << "<font size=4 color='red'>Attention! Security level lowered to green</font>"
					world << "<font color='red'>[alert_desc_green]</font>"
				security_level = SEC_LEVEL_GREEN
				for(var/obj/machinery/firealarm/FA in world)
					FA.overlays = list()
					FA.overlays += image('icons/obj/monitors.dmi', "overlay_green")
			if(SEC_LEVEL_BLUE)
				if(!silent)
					if(security_level < SEC_LEVEL_BLUE)
						world << "<font size=4 color='red'>Attention! Security level elevated to blue</font>"
						world << "<font color='red'>[alert_desc_blue_upto]</font>"
					else
						world << "<font size=4 color='red'>Attention! Security level lowered to blue</font>"
						world << "<font color='red'>[alert_desc_blue_downto]</font>"
				security_level = SEC_LEVEL_BLUE
				for(var/obj/machinery/firealarm/FA in world)
					FA.overlays = list()
					FA.overlays += image('icons/obj/monitors.dmi', "overlay_blue")
			if(SEC_LEVEL_RED)
				if(!silent)
					if(security_level < SEC_LEVEL_RED)
						world << "<font size=4 color='red'>Attention! Code red!</font>"
						world << "<font color='red'>[alert_desc_red_upto]</font>"
					else
						world << "<font size=4 color='red'>Attention! Code red!</font>"
						world << "<font color='red'>[alert_desc_red_downto]</font>"
				security_level = SEC_LEVEL_RED

				/*	- At the time of commit, setting status displays didn't work properly
				var/obj/machinery/computer/communications/CC = locate(/obj/machinery/computer/communications,world)
				if(CC)
					CC.post_status("alert", "redalert")*/

				for(var/obj/machinery/firealarm/FA in world)
					FA.overlays = list()
					FA.overlays += image('icons/obj/monitors.dmi', "overlay_red")
			if(SEC_LEVEL_DELTA)
				if(!silent)
					world << "<font size=4 color='red'>Attention! Delta security level reached!</font>"
					world << "<font color='red'>[alert_desc_delta]</font>"
				security_level = SEC_LEVEL_DELTA
				for(var/obj/machinery/firealarm/FA in world)
					FA.overlays = list()
					FA.overlays += image('icons/obj/monitors.dmi', "overlay_delta")
	else
		return

/proc/get_security_level()
	switch(security_level)
		if(SEC_LEVEL_GREEN)
			return "green"
		if(SEC_LEVEL_BLUE)
			return "blue"
		if(SEC_LEVEL_RED)
			return "red"
		if(SEC_LEVEL_DELTA)
			return "delta"

/proc/num2seclevel(var/num)
	switch(num)
		if(SEC_LEVEL_GREEN)
			return "green"
		if(SEC_LEVEL_BLUE)
			return "blue"
		if(SEC_LEVEL_RED)
			return "red"
		if(SEC_LEVEL_DELTA)
			return "delta"

/proc/seclevel2num(var/seclevel)
	switch( lowertext(seclevel) )
		if("green")
			return SEC_LEVEL_GREEN
		if("blue")
			return SEC_LEVEL_BLUE
		if("red")
			return SEC_LEVEL_RED
		if("delta")
			return SEC_LEVEL_DELTA


/*DEBUG
/mob/verb/set_thing0()
	set_security_level(0)
/mob/verb/set_thing1()
	set_security_level(1)
/mob/verb/set_thing2()
	set_security_level(2)
/mob/verb/set_thing3()
	set_security_level(3)
*/