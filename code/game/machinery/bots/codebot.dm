/obj/machinery/bot/code
	name = "codebot"
	desc = "A little programmable robot."
	icon_state = "codebot1"
	density = 1
	anchored = 0
	var/health = 40

	var/emote_cooldown = 0
	var/say_cooldown = 0
	var/mv_cooldown = 0

// Code procs start
	proc/mv(var/dir)
		if(!(dir in cardinal))
			return 0

		if(!on)
			return 0

		var/mv = step(src, dir)
		if(mv)
			mv_cooldown = 1
		return mv

	proc/emote(var/emote)
		if(emote_cooldown)
			return 0

		if(!on)
			return 0

		var/message
		var/m_type = 2

		switch(emote)
			if ("alarm")
				message = "<B>[src]</B> sounds an alarm."
			if ("alert")
				message = "<B>[src]</B> lets out a distressed noise."
			if ("notice")
				message = "<B>[src]</B> plays a loud tone."
			if ("flash")
				message = "The lights on <B>[src]</B> flash quickly."
				m_type = 1
			if ("beep")
				message = "<B>[src]</B> beeps."
			if ("boop")
				message = "<B>[src]</B> boops."
			else
				return 0

		if (message)
			if (m_type & 1)
				for (var/mob/O in viewers(src, null))
					O.show_message(message, m_type)
			else if (m_type & 2)
				for (var/mob/O in hearers(src, null))
					O.show_message(message, m_type)
			return 1
		else
			return 0
// Code procs end

	update_icon()
		icon_state = "codebot[on]"

	proc/adjust_damage(var/dmg = 0)
		health -= dmg

		if(health <= 0)
			on = 0
			if(health < -10)
				destroy()

		update_icon()

	proc/destroy()
		del(src)