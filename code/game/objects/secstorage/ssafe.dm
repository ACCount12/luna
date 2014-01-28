/obj/item/weapon/storage/secure/safe
	name = "secure safe"
	icon_state = "safe"
	icon_open = "safe0"
	icon_locking = "safeb"
	icon_sparking = "safespark"
	w_class = 5
	anchored = 1
	density = 0

/obj/item/weapon/storage/secure/safe/New()
	..()

/obj/item/weapon/storage/secure/safe/attack_hand(mob/user as mob)
	return attack_self(user)


/obj/item/weapon/storage/secure/safe/floor
	name = "floor safe"
//	icon_state = "floorsafe"
	density = 0
	level = 1	//underfloor
	layer = 2.5


/obj/item/weapon/storage/secure/safe/floor/initialize()
	for(var/obj/item/I in loc)
		if(contents.len >= storage_slots)
			break
		I.loc = src

	l_code = num2text(rand(10000, 99999))

	var/turf/T = loc
	hide(T.intact)

/obj/item/weapon/storage/secure/safe/floor/hide(var/intact)
	invisibility = intact ? 101 : 0