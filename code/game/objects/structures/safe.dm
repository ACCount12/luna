/*
CONTAINS:
SAFES
FLOOR SAFES
*/

//SAFES
/obj/structure/safe
	name = "safe"
	desc = "A huge chunk of metal with a dial embedded in it. Fine print on the dial reads \"Scarborough Arms - 4 numbers safe, guaranteed thermite resistant, explosion resistant, and assistant resistant.\""
	icon = 'icons/obj/structures.dmi'
	icon_state = "safe"
	anchored = 1
	density = 1
	var/open = 0		//is the safe open?
	var/num_current = "0000"
	var/num_open = "0000"


	var/space = 0		//the combined w_class of everything in the safe
	var/maxspace = 24	//the maximum combined w_class of stuff in the safe


/obj/structure/safe/New()
	..()
	num_open = num2text(rand(0001, 9999))

/obj/structure/safe/initialize()
	for(var/obj/item/I in loc)
		if(space >= maxspace)
			return
		if(I.w_class + space <= maxspace)
			space += I.w_class
			I.loc = src


/obj/structure/safe/proc/check_unlocked(mob/user as mob, canhear)
	if(user && canhear && prob(20))
		if(copytext(num_current, 1, 1) == copytext(num_open, 1, 1))
			user << "<span class='notice'>You hear a [pick("tonk", "krunk", "plunk")] from [src].</span>"
		if(copytext(num_current, 2, 2) == copytext(num_open, 2, 2))
			user << "<span class='notice'>You hear a [pick("tink", "krink", "plink")] from [src].</span>"
		if(copytext(num_current, 3, 3) == copytext(num_open, 3, 3))
			user << "<span class='notice'>You hear a [pick("tonk", "krunk", "plunk")] from [src].</span>"
		if(copytext(num_current, 4, 4) == copytext(num_open, 4, 4))
			user << "<span class='notice'>You hear a [pick("tink", "krink", "plink")] from [src].</span>"

	if(num_current == num_open)
		if(user) visible_message("<b>[pick("Spring", "Sprang", "Sproing", "Clunk", "Krunk")]!</b>")
		return 1
	return 0


/obj/structure/safe/update_icon()
	if(open)
		icon_state = "[initial(icon_state)]-open"
	else
		icon_state = initial(icon_state)


/obj/structure/safe/attack_hand(mob/user as mob)
	user.set_machine(src)
	var/dat = "<center>"
	dat += "<a href='?src=\ref[src];open=1'>[open ? "Close" : "Open"] [src]</a><BR>"

	dat += "<BR><a href='?src=\ref[src];number=1'>[num_current]</a>"

	if(open)
		dat += "<table>"
		for(var/i = contents.len, i>=1, i--)
			var/obj/item/P = contents[i]
			dat += "<tr><td><a href='?src=\ref[src];retrieve=\ref[P]'>[P.name]</a></td></tr>"
		dat += "</table></center>"
	user << browse("<html><head><title>[name]</title></head><body>[dat]</body></html>", "window=safe;size=350x300")


/obj/structure/safe/Topic(href, href_list)
	if(!ishuman(usr))	return
	var/mob/living/carbon/human/user = usr

	var/canhear = 0
	if(istype(user.l_hand, /obj/item/device/radio) || istype(user.r_hand, /obj/item/device/radio))
		canhear = 1

	if(href_list["open"])
		if(check_unlocked())
			user << "<span class='notice'>You [open ? "close" : "open"] [src].</span>"
			open = !open
			update_icon()
			updateUsrDialog()
			return
		else
			user << "<span class='notice'>You can't [open ? "close" : "open"] [src], the lock is engaged!</span>"
			return

	if(href_list["number"])
		if(canhear)
			user << "<span class='notice'>You hear a [pick("clack", "scrape", "clank")] from [src].</span>"

		num_current = text2num(num_current)

		num_current = num_current + text2num(href_list["number"])

		if(num_current > 9999)
			num_current = num_current - 10000
			if(canhear)
				user << "<span class='notice'>You hear a [pick("click", "chink", "clink")] from [src].</span>"

		if(num_current < 0)
			num_current = num_current + 10000
			if(canhear)
				user << "<span class='notice'>You hear a [pick("click", "chink", "clink")] from [src].</span>"

		num_current += 10000

		num_current = num2text(copytext(num_current, 2, 5))

		check_unlocked(user, canhear)
		updateUsrDialog()
		return

	if(href_list["retrieve"])
		user << browse("", "window=safe") // Close the menu

		var/obj/item/P = locate(href_list["retrieve"]) in src
		if(open)
			if(P && in_range(src, user))
				user.put_in_hands(P)
				updateUsrDialog()


/obj/structure/safe/attackby(obj/item/I as obj, mob/user as mob)
	if(open)
		if(I.w_class + space <= maxspace)
			space += I.w_class
			user.drop_item()
			I.loc = src
			user << "<span class='notice'>You put [I] in [src].</span>"
			updateUsrDialog()
			return
		else
			user << "<span class='notice'>[I] won't fit in [src].</span>"
			return
	else
		if(istype(I, /obj/item/device/radio))
			user << "Hold [I] in one of your hands while you manipulate the dial."
			return


obj/structure/safe/blob_act()
	return


obj/structure/safe/ex_act(severity)
	return


obj/structure/safe/meteorhit(obj/O as obj)
	return


//FLOOR SAFES
/obj/structure/safe/floor
	name = "floor safe"
	icon_state = "floorsafe"
	density = 0
	level = 1	//underfloor
	layer = 2.5


/obj/structure/safe/floor/initialize()
	..()
	var/turf/T = loc
	hide(T.intact)


/obj/structure/safe/floor/hide(var/intact)
	invisibility = intact ? 101 : 0