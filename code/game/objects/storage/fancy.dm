/*
 * The 'fancy' path is for objects like donut boxes that show how many items are in the storage item on the sprite itself
 * .. Sorry for the shitty path name, I couldnt think of a better one.
 *
 * WARNING: var/icon_type is used for both examine text and sprite name. Please look at the procs below and adjust your sprite names accordingly
 *		TODO: Cigarette boxes should be ported to this standard
 *
 * Contains:
 *		Donut Box
 *		Egg Box
 *		Candle Box
 *		Crayon Box
 *		Cigarette Box
 */

/obj/item/weapon/storage/fancy/
	icon = 'icons/obj/food.dmi'
	icon_state = "donutbox6"
	name = "donut box"
	var/icon_type = "donut"

/obj/item/weapon/storage/fancy/update_icon(var/itemremoved = 0)
	var/total_contents = src.contents.len - itemremoved
	src.icon_state = "[src.icon_type]box[total_contents]"
	return

/obj/item/weapon/storage/fancy/examine()
	set src in oview(1)

	if(contents.len <= 0)
		usr << "There are no [src.icon_type]s left in the box."
	else if(contents.len == 1)
		usr << "There is one [src.icon_type] left in the box."
	else
		usr << "There are [src.contents.len] [src.icon_type]s in the box."

	return



/*
 * Crayon Box
 */

/obj/item/weapon/storage/fancy/crayons
	name = "box of crayons"
	desc = "A box of crayons for all your rune drawing needs."
	icon = 'icons/obj/crayons.dmi'
	icon_state = "crayonbox"
	w_class = 2.0
	icon_type = "crayon"
	can_hold = list(/obj/item/toy/crayon)

/obj/item/weapon/storage/fancy/crayons/New()
	..()
	new /obj/item/toy/crayon/red(src)
	new /obj/item/toy/crayon/orange(src)
	new /obj/item/toy/crayon/yellow(src)
	new /obj/item/toy/crayon/green(src)
	new /obj/item/toy/crayon/blue(src)
	new /obj/item/toy/crayon/purple(src)
	update_icon()

/obj/item/weapon/storage/fancy/crayons/update_icon()
	overlays.Cut()
	overlays += image('icons/obj/crayons.dmi',"crayonbox")
	for(var/obj/item/toy/crayon/crayon in contents)
		overlays += image('icons/obj/crayons.dmi',crayon.colourName)

/obj/item/weapon/storage/fancy/crayons/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/toy/crayon))
		switch(W:colourName)
			if("mime")
				usr << "This crayon is too sad to be contained in this box."
				return
			if("rainbow")
				usr << "This crayon is too powerful to be contained in this box."
				return
	else return
	..()
	update_icon()


/*
 * Vial Box
 */

/obj/item/weapon/storage/fancy/vials
	icon = 'icons/obj/vialbox.dmi'
	icon_state = "vialbox0"
	icon_type = "vial"
	name = "vial storage box"
	desc = "A box for keeping things away from children."
	storage_slots = 6
	can_hold = list(/obj/item/weapon/reagent_containers/glass/beaker/vial)
	var/closed = 0

/obj/item/weapon/storage/fancy/vials/New()
	..()
	update_icon()

/obj/item/weapon/storage/fancy/vials/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(!istype(W, /obj/item/weapon/reagent_containers/glass/beaker/vial) || closed)
		return
	..()
	update_icon()

/obj/item/weapon/storage/fancy/vials/update_icon(var/itemremoved = 0)
	src.icon_state = "vialbox[contents.len]"
	src.overlays.Cut()
	if(closed)
		overlays += image(icon, src, "cover")
	return

/*obj/item/weapon/storage/fancy/vials/attack_self()
	..()
	if (!closed)
		usr << "<span class = 'notice'>You put the cover on \the [src]."
		closed = 1
	else
		usr << "<span class = 'notice'>You take the cover off \the [src]."
		closed = 0
	update_icon()*/


/obj/item/weapon/storage/fancy/vials/full/New()
	..()
	for(var/i=1; i <= storage_slots; i++)
		new /obj/item/weapon/reagent_containers/glass/beaker/vial(src)
	update_icon()

/obj/item/weapon/storage/fancy/vials/virusall1/New()
	..()
	new /obj/item/weapon/reagent_containers/glass/beaker/vial/virus/flu_virion(src)
	new /obj/item/weapon/reagent_containers/glass/beaker/vial/virus/cold(src)
	new /obj/item/weapon/reagent_containers/glass/beaker/vial/virus/epiglottis_virion(src)
	new /obj/item/weapon/reagent_containers/glass/beaker/vial/virus/liver_enhance_virion(src)
	new /obj/item/weapon/reagent_containers/glass/beaker/vial/virus/hullucigen_virion(src)
	new /obj/item/weapon/reagent_containers/glass/beaker/vial(src)
	update_icon()


/obj/item/weapon/storage/fancy/vials/virusall2/New()
	..()
	new /obj/item/weapon/reagent_containers/glass/beaker/vial/virus/pierrot_throat(src)
	new /obj/item/weapon/reagent_containers/glass/beaker/vial/virus/brainrot(src)
	new /obj/item/weapon/reagent_containers/glass/beaker/vial/virus/fake_gbs(src)
	new /obj/item/weapon/reagent_containers/glass/beaker/vial/virus/magnitis(src)
	new /obj/item/weapon/reagent_containers/glass/beaker/vial(src)
	new /obj/item/weapon/reagent_containers/glass/beaker/vial(src)
	update_icon()

/obj/item/weapon/storage/fancy/vials/flucold/New()
	..()
	new /obj/item/weapon/reagent_containers/glass/beaker/vial/virus/flu_virion(src)
	new /obj/item/weapon/reagent_containers/glass/beaker/vial/virus/cold(src)
	new /obj/item/weapon/reagent_containers/glass/beaker/vial/virus/flu_virion(src)
	new /obj/item/weapon/reagent_containers/glass/beaker/vial/virus/cold(src)
	new /obj/item/weapon/reagent_containers/glass/beaker/vial(src)
	new /obj/item/weapon/reagent_containers/glass/beaker/vial(src)
	update_icon()