/*
 * Multitool -- A multitool is used for hacking electronic devices.
 */
/obj/item/device/multitool
	name = "multitool"
	icon_state = "multitool"
	flags = FPRINT | CONDUCT
	force = 5.0
	w_class = 2.0
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3
	origin_tech = "magnets=1;engineering=1"
	desc = "You can use this on airlocks or APCs to try to hack them without cutting wires."
	m_amt = 50
	g_amt = 20


// Syndicate device disguised as a multitool; it will turn red when an AI camera is nearby.
/obj/item/device/multitool/ai_detect
	origin_tech = "magnets=2;engineering=1;syndicate=2"
	var/track_delay = 0

/obj/item/device/multitool/ai_detect/New()
	..()
	processing_items += src


/obj/item/device/multitool/ai_detect/Del()
	processing_items -= src
	..()

/obj/item/device/multitool/ai_detect/process()
	if(track_delay > world.time)
		return

	var/found_eye = 0
	var/turf/our_turf = get_turf(src)

	if(cameranet.chunkGenerated(our_turf.x, our_turf.y, our_turf.z))
		var/datum/camerachunk/chunk = cameranet.getCameraChunk(our_turf.x, our_turf.y, our_turf.z)

		if(chunk)
			if(chunk.seenby.len)
				for(var/mob/camera/aiEye/A in chunk.seenby)
					var/turf/eye_turf = get_turf(A)
					if(get_dist(our_turf, eye_turf) < 8)
						found_eye = 1
						break

	if(found_eye)
		icon_state = "[initial(icon_state)]_red"
	else
		icon_state = initial(icon_state)

	track_delay = world.time + 10 // 1 second
	return