/obj/item/weapon/storage/secure/briefcase
	name = "secure briefcase"
	icon_state = "secure"
	item_state = "sec-case"
	desc = "A large briefcase with a digital locking system."
	force = 8.0
	throw_speed = 1
	throw_range = 4
	w_class = 4.0

/obj/item/weapon/storage/secure/briefcase/New()
	..()
	new /obj/item/weapon/paper(src)
	new /obj/item/weapon/pen(src)

/obj/item/weapon/storage/secure/briefcase/attack(mob/M as mob, mob/user as mob)
	var/t = user:zone_sel.selecting
	if (t == "head")
		if (M.stat < 2 && M.health < 50 && prob(90))
			var/mob/H = M
		// ******* Check
			if ((istype(H, /mob/living/carbon/human) && istype(H, /obj/item/clothing/head) && H.flags & 8 && prob(80)))
				M << "\red The helmet protects you from being hit hard in the head!"
				return
			var/time = rand(2, 6)
			if (prob(75))
				if (M.paralysis < time)// && (!M.ishulk))
					M.paralysis = time
			else
				if (M.stunned < time)// && (!M.ishulk))
					M.stunned = time
			if(M.stat != 2)	M.stat = 1
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red <B>[] has been knocked unconscious!</B>", M), 1, "\red You hear someone fall.", 2)
		else
			M << text("\red [] tried to knock you unconcious!",user)
			M.eye_blurry += 3

	return
