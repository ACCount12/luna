/atom/MouseDrop(var/atom/over)
	if(!usr || !over) return

	spawn(0)
		if(istype(over))
			over.MouseDrop_T(src, usr)
	return

/atom/proc/MouseDrop_T(atom/dropping, mob/user)
	return