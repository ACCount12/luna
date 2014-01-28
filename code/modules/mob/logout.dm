/mob/Logout()
	player_list -= src
	log_access("Logout: [key_name(src)]")
	if (admins[src.ckey])
		message_admins("Admin logout: [key_name(src)]")
	logged_in = 0
	..()

	return 1