/* Diffrent misc types of tiles
 * Contains:
 *		Grass
 *		Wood
 *		Carpet
 */
/obj/item/stack/tile
	w_class = 3.0
	throw_speed = 5
	throw_range = 20
	max_amount = 60
	force = 1.0
	throwforce = 1.0
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "smashed")

/*
 * Grass
 */
/obj/item/stack/tile/grass
	name = "grass tiles"
	singular_name = "grass floor tile"
	desc = "A patch of grass like they often use on golf courses"
	icon_state = "tile_grass"
	origin_tech = "biotech=1"


/turf/simulated/floor/grass
	name = "grass patch"
	icon_state = "grass1"
	floor_tile = new/obj/item/stack/tile/grass

	New()
		floor_tile.New() //I guess New() isn't ran on objects spawned without the definition of a turf to house them, ah well.
		icon_state = "grass[pick("1","2","3","4")]"
		..()
		spawn(4)
			if(src)
				update_icon()
				for(var/direction in cardinal)
					if(istype(get_step(src,direction),/turf/simulated/floor))
						var/turf/simulated/floor/FF = get_step(src,direction)
						FF.update_icon() //so siding get updated properly

/*
 * Wood
 */
/obj/item/stack/tile/wood
	name = "wood floor tiles"
	singular_name = "wood floor tile"
	desc = "An easy to fit wood floor tile"
	icon_state = "tile-wood"
	origin_tech = "biotech=1"

/*
 * Carpets
 */
/obj/item/stack/tile/carpet
	name = "carpet"
	singular_name = "carpet"
	desc = "A piece of carpet. It is the same size as a floor tile"
	icon_state = "tile-carpet"