/client/proc/reset_eye(var/mob/M)
	view = 7
	eye = M

/mob/dead/verb/change_view(var/size as num)
	set name = "Set View Size"
	set desc = "Change view radius, from 7 to 16 tiles. Use with ''Icons -> 32x32'' option."
	set category = "OOC"

	if(!istype(src, /mob/dead/))
		src << "Ghosts only, thanks!"
		return 0

	if(!client)
		return 0

	if(!isnum(size))
		size = 7

	size = min(max(size, 7), 16)

	client.view = size