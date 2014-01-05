/**********************Satchel**************************/

/obj/item/weapon/satchel
	icon = 'icons/obj/mining.dmi'
	icon_state = "satchel"
	name = "satchel"
	flags = FPRINT | NOHIT
	slot_flags = SLOT_BELT
	w_class = 1

	var/capacity = 50 //the number of items it can carry.
	var/list/can_hold = list() //the number of items it can carry.

/obj/item/weapon/satchel/proc/can_hold(var/obj/item/I)
	if(!istype(I))
		return 0

	if(can_hold.len)
		for(var/holdtype in can_hold)
			if(istype(I, holdtype))
				return 1
	else
		return (I.w_class < w_class)
	return 0

/obj/item/weapon/satchel/proc/insert(var/obj/item/I)
	if(contents.len < capacity)
		src.contents += I
		return 1
	return 0


/obj/item/weapon/satchel/attackby(var/obj/item/I as obj, mob/user as mob)
	if(can_hold(I))
		if(insert(I))
			update_icon()
		return
	..()

/obj/item/weapon/satchel/attack_self(mob/user as mob)
	for (var/obj/item/O in contents)
		contents -= O
		O.loc = user.loc
	user << "\blue You empty [src]."
	update_icon()
	return

/obj/item/weapon/satchel/afterattack(atom/A, mob/user as mob)
	for(var/obj/item/I in get_turf(A))
		if(can_hold(I))
			if(!insert(I))
				user << "\blue The [src.name] is full."
				update_icon()
				return
	update_icon()
	..()


/obj/item/weapon/satchel/ore
	name = "mining satchel"
	can_hold = list(/obj/item/weapon/ore)

/obj/item/weapon/satchel/ore/borg
	name = "cyborg mining satchel"
	capacity = 100 //the number of ore pieces it can carry.

/obj/item/weapon/satchel/plants
	icon = 'icons/obj/hydroponics2.dmi'
	icon_state = "plantbag"
	name = "plant bag"
	can_hold = list(/obj/item/weapon/reagent_containers/food/snacks/grown, /obj/item/seeds, /obj/item/weapon/grown)

/obj/item/weapon/satchel/trash
	name = "trash bag"
	desc = "It's the heavy-duty black polymer kind. Time to take out the trash!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "trashbag0"
	item_state = "trashbag"

	w_class = 3
	capacity = 21

/obj/item/weapon/satchel/trash/update_icon()
	if(contents.len == 0)
		icon_state = "trashbag0"
	else if(contents.len < 12)
		icon_state = "trashbag1"
	else if(contents.len < 21)
		icon_state = "trashbag2"
	else icon_state = "trashbag3"


/obj/item/weapon/satchel/sheetsnatcher
	icon_state = "sheetsnatcher"
	name = "sheet snatcher"
	desc = "A patented Nanotrasen storage system designed for any kind of mineral sheet."

	capacity = 300 //the number of sheets it can carry.
	w_class = 3

	can_hold(var/obj/item/stack/sheet/I)
		if(!istype(I) || istype(I,/obj/item/stack/sheet/mineral/sandstone) || istype(I,/obj/item/stack/sheet/wood))
			return 0 //I don't care, but the existing code rejects them for not being "sheets" *shrug* -Sayu
		return 1


	insert(var/obj/item/stack/sheet/I)
		var/transferamt = 0
		for(var/obj/item/stack/sheet/S in contents)
			transferamt += S.amount

		transferamt = min(capacity - transferamt, I.amount)
		if(transferamt <= 0) // No amount, no transfer
			return 0

		for(var/obj/item/stack/sheet/sheet in contents)
			if(istype(I, sheet.type)) // we are violating the amount limitation because these are not sane objects
				sheet.amount += transferamt	// they should only be removed through procs in this file, which split them up.
				I.use(transferamt)
				update_icon()
				return 1

		if(transferamt < I.amount)
			new I.type(src, transferamt)
			I.use(transferamt)
		else
			src.contents += I

		update_icon()
		return 1


/**********************Ore box**************************/

/obj/structure/ore_box
	icon = 'icons/obj/mining.dmi'
	icon_state = "orebox0"
	name = "ore box"
	desc = "A heavy box used for storing ore."
	density = 1
	var/amt_gold = 0
	var/amt_silver = 0
	var/amt_diamond = 0
	var/amt_glass = 0
	var/amt_iron = 0
	var/amt_plasma = 0
	var/amt_uranium = 0
	var/amt_clown = 0
	var/amt_other = 0

	New()
		..()
		if(prob(50))
			icon_state = "orebox1"

/obj/structure/ore_box/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/ore))
		src.contents += W
		update_contents()
	else if (istype(W, /obj/item/weapon/satchel/ore))
		src.contents += W.contents
		update_contents()
		user << "\blue You empty the satchel into the box."
	return

/obj/structure/ore_box/proc/update_contents()
	amt_gold = 0
	amt_silver = 0
	amt_diamond = 0
	amt_glass = 0
	amt_iron = 0
	amt_plasma = 0
	amt_uranium = 0
	amt_clown = 0
	amt_other = 0

	for (var/obj/item/weapon/ore/C in contents)
		if (istype(C,/obj/item/weapon/ore/diamond))
			amt_diamond++
		else if (istype(C,/obj/item/weapon/ore/glass))
			amt_glass++
		else if (istype(C,/obj/item/weapon/ore/plasma))
			amt_plasma++
		else if (istype(C,/obj/item/weapon/ore/iron))
			amt_iron++
		else if (istype(C,/obj/item/weapon/ore/silver))
			amt_silver++
		else if (istype(C,/obj/item/weapon/ore/gold))
			amt_gold++
		else if (istype(C,/obj/item/weapon/ore/uranium))
			amt_uranium++
		else if (istype(C,/obj/item/weapon/ore/clown))
			amt_clown++
		else
			amt_other++

		src.updateUsrDialog()

/obj/structure/ore_box/attack_hand(obj, mob/user as mob)
	var/dat = text("<b>The contents of the ore box reveal...</b><br>")
	if(amt_gold)
		dat += text("Gold ore: [amt_gold]<br>")
	if(amt_silver)
		dat += text("Silver ore: [amt_silver]<br>")
	if(amt_iron)
		dat += text("Metal ore: [amt_iron]<br>")
	if(amt_glass)
		dat += text("Sand: [amt_glass]<br>")
	if(amt_diamond)
		dat += text("Diamond ore: [amt_diamond]<br>")
	if(amt_plasma)
		dat += text("Plasma ore: [amt_plasma]<br>")
	if(amt_uranium)
		dat += text("Uranium ore: [amt_uranium]<br>")
	if(amt_clown)
		dat += text("Bananium ore: [amt_clown]<br>")
	if(amt_other)
		dat += text("Other ore: [amt_other]<br>")

	dat += text("<br><br><A href='?src=\ref[src];removeall=1'>Empty box</A>")
	user << browse("[dat]", "window=orebox")
	return


/obj/structure/ore_box/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["removeall"])
		for (var/obj/item/weapon/ore/O in contents)
			contents -= O
			O.loc = src.loc
		usr << "\blue You empty the box."
	update_contents()
	return