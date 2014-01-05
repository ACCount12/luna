/turf/proc/is_plating()
	return 0
/turf/proc/is_asteroid_floor()
	return 0
/turf/proc/is_plasteel_floor()
	return 0
/turf/proc/is_light_floor()
	return 0
/turf/proc/is_grass_floor()
	return 0
/turf/proc/is_wood_floor()
	return 0
/turf/proc/is_carpet_floor()
	return 0
/turf/proc/return_siding_icon_state()		//used for grass floors, which have siding.
	return 0



/turf
	icon = 'floors.dmi'
	var/intact = 1

	level = 1.0

	var
		//Properties for open tiles (/floor)
		oxygen = 0
		carbon_dioxide = 0
		nitrogen = 0
		toxins = 0

		//Properties for airtight tiles (/wall)
		thermal_conductivity = 0.05
		heat_capacity = 1

		//Properties for both
		temperature = T20C

		blocks_air = 0
		icon_old = null
		pathweight = 1
		list/obj/machinery/network/wirelessap/wireless = list( )
		explosionstrength = 1 //NEVER SET THIS BELOW 1
		floorstrength = 6

/turf/proc/Bless()
	if(flags & NOJAUNT)
		return
	flags |= NOJAUNT

/turf/space
	icon = 'space.dmi'
	name = "space"
	icon_state = "placeholder"
	temperature = TSPC
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000
	mouse_opacity = 2

	MaxRed = list(7)
	MaxGreen = list(7)
	MaxBlue = list(7)

/turf/space/New()
	. = ..()
	icon = 'space.dmi'
	icon_state = "[rand(1,25)]"

/turf/space/proc/Check()
	var/turf/T = locate(x, y, z + 1)
	if(T)
		if(!istype(T, /turf/space) && !istype(T, /turf/unsimulated))
			var/turf/space/S = src
			var/turf/simulated/floor/open/open = new(src)
			open.LightLevelRed = S.LightLevelRed
			open.LightLevelBlue = S.LightLevelBlue
			open.LightLevelGreen = S.LightLevelGreen
			open.ul_UpdateLight()



/turf/simulated/floor/prison			//Its good to be lazy.
	name = "Welcome to Admin Prison"
	wet = 0
	image/wet_overlay = null

	thermite = 0
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD

/turf/simulated
	name = "station"
	var/wet = 0
	var/image/wet_overlay = null

	var/thermite = 0
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD

/turf/simulated/floor/engine
	name = "reinforced floor"
	icon_state = "engine"
	thermal_conductivity = 0.025
	heat_capacity = 325000

/turf/simulated/floor/engine/cult
	name = "engraved floor"
	icon_state = "cult"

/turf/simulated/floor/engine/vacuum
	oxygen = 0
	nitrogen = 0.000
	temperature = TSPC

///turf/space/hull //TEST
/turf/space/hull
	name = "hull plating"
	icon = 'floors.dmi'
	icon_state = "engine"

/turf/space/hull/New()
	return
/*	oxygen = 0
	nitrogen = 0.000
	temperature = TSPC
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000*/


//This is so damaged or burnt tiles or platings don't get remembered as the default tile
var/list/icons_to_ignore_at_floor_init = list("damaged1","damaged2","damaged3","damaged4",
				"damaged5","panelscorched","floorscorched1","floorscorched2","platingdmg1","platingdmg2",
				"platingdmg3","plating","light_on","light_on_flicker1","light_on_flicker2",
				"light_on_clicker3","light_on_clicker4","light_on_clicker5","light_broken",
				"light_on_broken","light_off","wall_thermite","grass1","grass2","grass3","grass4",
				"asteroid","asteroid_dug",
				"asteroid0","asteroid1","asteroid2","asteroid3","asteroid4",
				"asteroid5","asteroid6","asteroid7","asteroid8","asteroid9","asteroid10","asteroid11","asteroid12",
				"oldburning","light-on-r","light-on-y","light-on-g","light-on-b", "wood", "wood-broken", "carpet",
				"carpetcorner", "carpetside", "carpet", "ironsand1", "ironsand2", "ironsand3", "ironsand4", "ironsand5",
				"ironsand6", "ironsand7", "ironsand8", "ironsand9", "ironsand10", "ironsand11",
				"ironsand12", "ironsand13", "ironsand14", "ironsand15")

var/list/plating_icons = list("plating","platingdmg1","platingdmg2","platingdmg3","asteroid","asteroid_dug",
				"ironsand1", "ironsand2", "ironsand3", "ironsand4", "ironsand5", "ironsand6", "ironsand7",
				"ironsand8", "ironsand9", "ironsand10", "ironsand11",
				"ironsand12", "ironsand13", "ironsand14", "ironsand15")
var/list/wood_icons = list("wood","wood-broken")

/turf/simulated/floor/proc/update_icon()
	if(lava)
		return
	else if(is_plasteel_floor())
		if(!broken && !burnt)
			icon_state = icon_regular_floor
	else if(is_plating())
		if(!broken && !burnt)
			icon_state = icon_plating //Because asteroids are 'platings' too.
	else if(is_grass_floor())
		if(!broken && !burnt)
			if(!(icon_state in list("grass1","grass2","grass3","grass4")))
				icon_state = "grass[pick("1","2","3","4")]"
	else if(is_carpet_floor())
		if(!broken && !burnt)
			if(icon_state != "carpetsymbol")
				var/connectdir = 0
				for(var/direction in cardinal)
					if(istype(get_step(src,direction),/turf/simulated/floor))
						var/turf/simulated/floor/FF = get_step(src,direction)
						if(FF.is_carpet_floor())
							connectdir |= direction

				//Check the diagonal connections for corners, where you have, for example, connections both north and east. In this case it checks for a north-east connection to determine whether to add a corner marker or not.
				var/diagonalconnect = 0 //1 = NE; 2 = SE; 4 = NW; 8 = SW

				//Northeast
				if(connectdir & NORTH && connectdir & EAST)
					if(istype(get_step(src,NORTHEAST),/turf/simulated/floor))
						var/turf/simulated/floor/FF = get_step(src,NORTHEAST)
						if(FF.is_carpet_floor())
							diagonalconnect |= 1

				//Southeast
				if(connectdir & SOUTH && connectdir & EAST)
					if(istype(get_step(src,SOUTHEAST),/turf/simulated/floor))
						var/turf/simulated/floor/FF = get_step(src,SOUTHEAST)
						if(FF.is_carpet_floor())
							diagonalconnect |= 2

				//Northwest
				if(connectdir & NORTH && connectdir & WEST)
					if(istype(get_step(src,NORTHWEST),/turf/simulated/floor))
						var/turf/simulated/floor/FF = get_step(src,NORTHWEST)
						if(FF.is_carpet_floor())
							diagonalconnect |= 4

				//Southwest
				if(connectdir & SOUTH && connectdir & WEST)
					if(istype(get_step(src,SOUTHWEST),/turf/simulated/floor))
						var/turf/simulated/floor/FF = get_step(src,SOUTHWEST)
						if(FF.is_carpet_floor())
							diagonalconnect |= 8

				icon_state = "carpet[connectdir]-[diagonalconnect]"

	else if(is_wood_floor())
		if(!broken && !burnt)
			if(!(icon_state in wood_icons))
				icon_state = "wood"
				//world << "[icon_state]y's got [icon_state]"
	/*spawn(1)
		if(istype(src,/turf/simulated/floor)) //Was throwing runtime errors due to a chance of it changing to space halfway through.
			if(air)
				update_visuals(air)*/

/turf/simulated/floor/superdark
	icon = 'icons/turf/floorsnew.dmi'
	icon_state = "floor"

/turf/simulated/floor/return_siding_icon_state()
	..()
	if(is_grass_floor())
		var/dir_sum = 0
		for(var/direction in cardinal)
			var/turf/T = get_step(src,direction)
			if(!(T.is_grass_floor()))
				dir_sum += direction
		if(dir_sum)
			return "wood_siding[dir_sum]"
		else
			return 0

/turf/simulated/floor/proc/break_tile_to_plating()
	if(!is_plating())
		make_plating()
	break_tile()

/turf/simulated/floor/proc/make_plating()
	if(istype(src,/turf/simulated/floor/engine)) return

	if(is_grass_floor())
		for(var/direction in cardinal)
			if(istype(get_step(src,direction),/turf/simulated/floor))
				var/turf/simulated/floor/FF = get_step(src,direction)
				FF.update_icon() //so siding get updated properly
	else if(is_carpet_floor())
		spawn(5)
			if(src)
				for(var/direction in list(1,2,4,8,5,6,9,10))
					if(istype(get_step(src,direction),/turf/simulated/floor))
						var/turf/simulated/floor/FF = get_step(src,direction)
						FF.update_icon() //so siding get updated properly

	if(!floor_tile) return
	del(floor_tile)
	icon_plating = "plating"
	ul_SetLuminosity(0)
	floor_tile = null
	intact = 0
	broken = 0
	burnt = 0

	update_icon()
	levelupdate()

/turf/simulated/floor/is_plasteel_floor()
	if(istype(floor_tile,/obj/item/stack/tile/metal))
		return 1
	else
		return 0

/turf/simulated/floor/is_light_floor()
	if(istype(floor_tile,/obj/item/stack/tile/light))
		return 1
	else
		return 0

/turf/simulated/floor/is_grass_floor()
	if(istype(floor_tile,/obj/item/stack/tile/grass))
		return 1
	else
		return 0

/turf/simulated/floor/is_wood_floor()
	if(istype(floor_tile,/obj/item/stack/tile/wood))
		return 1
	else
		return 0

/turf/simulated/floor/is_carpet_floor()
	if(istype(floor_tile,/obj/item/stack/tile/carpet))
		return 1
	else
		return 0

/turf/simulated/floor/is_plating()
	if(!floor_tile)
		return 1
	return 0

/turf/simulated/floor/proc/break_tile()
	if(istype(src,/turf/simulated/floor/engine)) return
	if(broken) return
	if(is_plasteel_floor())
		src.icon_state = "damaged[pick(1,2,3,4,5)]"
		broken = 1
	else if(is_light_floor())
		src.icon_state = "light_broken"
		broken = 1
	else if(is_plating())
		src.icon_state = "platingdmg[pick(1,2,3)]"
		broken = 1
	else if(is_wood_floor())
		src.icon_state = "wood-broken"
		broken = 1
	else if(is_carpet_floor())
		src.icon_state = "carpet-broken"
		broken = 1
	else if(is_grass_floor())
		src.icon_state = "sand[pick("1","2","3")]"
		broken = 1

/turf/simulated/floor/proc/burn_tile()
	if(istype(src,/turf/simulated/floor/engine)) return
	if(istype(src,/turf/simulated/floor/plating/airless/asteroid)) return//Asteroid tiles don't burn
	if(broken || burnt) return
	if(is_plasteel_floor())
		src.icon_state = "floorscorched[pick(1,2)]"
		burnt = 1
	else if(is_plating())
		src.icon_state = "panelscorched"
		burnt = 1
	else if(is_wood_floor())
		src.icon_state = "wood-broken"
		burnt = 1
	else if(is_carpet_floor())
		src.icon_state = "carpet-broken"
		burnt = 1
	else if(is_grass_floor())
		src.icon_state = "sand[pick("1","2","3")]"
		burnt = 1

/turf/simulated/floor
	//Note to coders, the 'intact' var can no longer be used to determine if the floor is a plating or not.
	//Use the is_plating(), is_plasteel_floor() and is_light_floor() procs instead. --Errorage
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"

	var/icon_regular_floor = "floor" //used to remember what icon the tile should have by default
	var/icon_plating = "plating"
	thermal_conductivity = 0.040
	heat_capacity = 50000
	var/lava = 0
	var/broken = 0
	var/burnt = 0
	var/mineral = "metal"
	var/obj/item/stack/tile/floor_tile = new /obj/item/stack/tile/metal
	var/turf/simulated/floor/open/open = null

	New()
		..()
		var/turf/T = locate(x,y,z-1)
		if(T)
			if(istype(T, /turf/simulated/floor/open))
				open = T
				open.update()

		if(icon_state in icons_to_ignore_at_floor_init) //so damaged/burned tiles or plating icons aren't saved as the default
			icon_regular_floor = "floor"
		else
			icon_regular_floor = icon_state

	Enter(var/atom/movable/AM)
		. = ..()
		if(open && istype(open))
			open.update()

	Exit(var/atom/movable/AM)
		. = ..()
		if(open && istype(open))
			open.update()

	airless
		name = "floor"
		oxygen = 0.01
		nitrogen = 0.01
		temperature = TSPC

	open
		name = "open space"
		intact = 0
		icon_state = "open"
		pathweight = 100000 //Seriously, don't try and path over this one numbnuts
		var/icon/darkoverlays = null
		var/turf/simulated/floorbelow
		floorstrength = 1

		mouse_opacity = 2

		New()
			..()
			if(z > 4)
				new/turf/space(src)
				return

			spawn(1)
				if(!istype(src, /turf/simulated/floor/open)) //This should not be needed but is.
					return

				floorbelow = locate(x, y, z + 1)
				if("open" in floorbelow.vars)
					floorbelow:open = src
				if(ticker)
					add_to_other_zone()
				update()
			var/turf/T = locate(x, y, z + 1)
			if(T)
				//Fortunately, I've done this before. - Aryn
				if(istype(T,/turf/space) || T.z > 4)
					new/turf/space(src)
				else if(!istype(T,/turf/simulated/floor))
					new/turf/simulated/floor/plating(src)
				/*
				switch (T.type) //Somehow, I don't think I thought this cunning plan all the way through - Sukasa
					if (/turf/simulated/floor)
						//Do nothing - valid
					if (/turf/simulated/floor/plating)
						//Do nothing - valid
					if (/turf/simulated/floor/engine)
						//Do nothing - valid
					if (/turf/simulated/floor/engine/vacuum)
						//Do nothing - valid
					if (/turf/simulated/floor/airless)
						//Do nothing - valid
					if (/turf/simulated/floor/grid)
						//Do nothing - valid
					if (/turf/simulated/floor/plating/airless)
						//Do nothing - valid
					if (/turf/simulated/floor/open)
						//Do nothing - valid
					if (/turf/space)
						var/turf/space/F = new(src)									//Then change to a Space tile (no falling into space)
						F.name = F.name
						return
					else
						var/turf/simulated/floor/plating/F = new(src)				//Then change to a floor tile (no falling into unknown crap)
						F.name = F.name
						return*/
		Del()
			if(zone)
				zone.Disconnect(src,floorbelow)
			if(floorbelow && floorbelow:open)
				floorbelow:open = null
			. = ..()


		Enter(var/atom/movable/AM)
			if (..()) //TODO make this check if gravity is active (future use) - Sukasa
				spawn(1)
					if(AM && !AM.anchored)
						AM.Move(locate(x, y, z + 1))
						if(AM.loc == locate(x, y, z + 1))
							if (istype(AM, /mob))
								AM:adjustBruteLoss(10)
								AM:weakened = max(AM:weakened,5)
								AM:updatehealth()
			return ..()


		attackby(obj/item/C as obj, mob/user as mob)
			if (istype(C, /obj/item/stack/rods))
				if(locate(/obj/structure/lattice, src)) return
				user << "\blue Constructing support lattice ..."
				playsound(src.loc, 'Genhit.ogg', 50, 1)
				new /obj/structure/lattice(src)
				C:use(1)
				return
			if (istype(C, /obj/item/stack/tile/metal))
				var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
				if(L)
					del(L)
					playsound(src.loc, 'Genhit.ogg', 50, 1)
					C:build(src)
					C:use(1)
					return

				else
					user << "\red The plating is going to need some support."
			return


		proc
			update() //Update the overlayss to make the openspace turf show what's down a level
				if(!floorbelow) return
				src.clearoverlays()
				src.addoverlay(floorbelow)

				for(var/obj/o in floorbelow.contents)
					if(!(o.pixel_x < -12 || o.pixel_y < -12 || o.pixel_x > 12 || o.pixel_y > 12 || istype(o, /obj/effect) || o.invisibility))
						src.addoverlay(image(o, dir=o.dir, layer = TURF_LAYER+0.05*o.layer))

				var/image/I = image('ULIcons.dmi', "[min(max(floorbelow.LightLevelRed - 4, 0), 7)]-[min(max(floorbelow.LightLevelGreen - 4, 0), 7)]-[min(max(floorbelow.LightLevelBlue - 4, 0), 7)]")
				I.layer = TURF_LAYER + 0.2
				src.addoverlay(I)
				I = image('ULIcons.dmi', "1-1-1")
				I.layer = TURF_LAYER + 0.2
				src.addoverlay(I)

			process_extra()
				if(!floorbelow) return
				if(istype(floorbelow,/turf/simulated)) //Infeasibly complicated gooncode for the Elder System. =P
					var/turf/simulated/FB = floorbelow
					if(parent && parent.group_processing)
						if(FB.parent && FB.parent.group_processing)
							parent.air.share(FB.parent.air)

						else
							parent.air.share(FB.air)
					else
						if(FB.parent && FB.parent.group_processing)
							air.share(FB.parent.air)
						else
							air.share(FB.air)
					//var/datum/gas_mixture/fb_air = FB.return_air(1)
					//var/datum/gas_mixture/my_air = return_air(1)
					//my_air.share(fb_air)
					//my_air.temperature_share(fb_air,FLOOR_HEAT_TRANSFER_COEFFICIENT)
				else
					air.mimic(floorbelow,1)
					air.temperature_mimic(floorbelow,FLOOR_HEAT_TRANSFER_COEFFICIENT,1)

				if(floorbelow.zone && zone)
					if(!(floorbelow.zone in zone.connections))
						zone.Connect(src,floorbelow)

	plating
		name = "plating"
		icon_state = "plating"
		intact = 0
		floor_tile = null

	plating/snow
		name = "snow"
		icon_state = "snow"

/proc/update_open()
	for(var/turf/simulated/floor/open/a in world)
		a.update()

/turf/simulated/floor/plating/airless
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TSPC

/turf/simulated/floor/grid
	icon_state = "circuit"

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

/turf/simulated/floor/wood
	name = "floor"
	icon_state = "wood"
	floor_tile = new/obj/item/stack/tile/wood

/turf/simulated/floor/carpet
	name = "carpet"
	icon_state = "carpet"
	floor_tile = new/obj/item/stack/tile/carpet

	New()
		floor_tile.New() //I guess New() isn't ran on objects spawned without the definition of a turf to house them, ah well.
		if(!icon_state)
			icon_state = "carpet"
		..()
		spawn(4)
			if(src)
				update_icon()
				for(var/direction in list(1,2,4,8,5,6,9,10))
					if(istype(get_step(src,direction),/turf/simulated/floor))
						var/turf/simulated/floor/FF = get_step(src,direction)
						FF.update_icon() //so siding get updated properly


/turf/simulated/wall
	name = "wall"
	icon = 'walls.dmi'
	icon_state = "wall0"
	opacity = 1
	density = 1
	blocks_air = 1
	explosionstrength = 2
	floorstrength = 6
	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500 //a little over 5 cm thick , 312500 for 1 m by 2.5 m by 0.25 m steel wall
	var/Zombiedamage

	var/mineral = "metal"
	var/walltype = "metal"

/turf/simulated/wall/r_wall
	name = "reinforced wall"
	icon = 'walls.dmi'
	icon_state = "r_wall"
	opacity = 1
	density = 1
	var/d_state = 0
	walltype = "rwall"
	explosionstrength = 4

/turf/simulated/wall/r_wall/explosionproof/ex_act(severity)
	return

/turf/simulated/wall/mineral
	name = "mineral wall"
	desc = "This shouldn't exist"
	icon_state = ""
	var/last_event = 0
	var/active = null

/turf/simulated/wall/mineral/gold
	name = "gold wall"
	desc = "A wall with gold plating. Swag!"
	icon_state = "gold0"
	walltype = "gold"
	mineral = "gold"
	//var/electro = 1
	//var/shocked = null

/turf/simulated/wall/mineral/silver
	name = "silver wall"
	desc = "A wall with silver plating. Shiny!"
	icon_state = "silver0"
	walltype = "silver"
	mineral = "silver"
	//var/electro = 0.75
	//var/shocked = null

/turf/simulated/wall/mineral/diamond
	name = "diamond wall"
	desc = "A wall with diamond plating. You monster."
	icon_state = "diamond0"
	walltype = "diamond"
	mineral = "diamond"

/turf/simulated/wall/mineral/clown
	name = "bananium wall"
	desc = "A wall with bananium plating. Honk!"
	icon_state = "clown0"
	walltype = "clown"
	mineral = "clown"

/turf/simulated/wall/mineral/sandstone
	name = "sandstone wall"
	desc = "A wall with sandstone plating. Cheap."
	icon_state = "sandstone0"
	walltype = "sandstone"
	mineral = "sandstone"

/turf/simulated/wall/mineral/uranium
	name = "uranium wall"
	desc = "A wall with uranium plating. This is probably a bad idea."
	icon_state = "uranium0"
	walltype = "uranium"
	mineral = "uranium"

/turf/simulated/wall/mineral/plasma
	name = "plasma wall"
	desc = "A wall with plasma plating. This is definately a bad idea."
	icon_state = "plasma0"
	walltype = "plasma"
	mineral = "plasma"



/turf/simulated/wall/cult
	name = "wall"
	desc = "The patterns engraved on the wall seem to shift as you try to focus on them. You feel sick"
	icon_state = "cult"
	walltype = "cult"

/turf/simulated/wall/heatshield
	thermal_conductivity = 0
	opacity = 0
	explosionstrength = 5
	name = "heat shield"
	icon_state = "thermal"
	walltype = "thermal"

/turf/simulated/wall/heatshield/ThermiteBurn()
	return // Thermite proof!

/turf/simulated/wall/heatshield/attackby()
	return
/turf/simulated/wall/heatshield/attack_hand()
	return

/turf/simulated/shuttle
	name = "shuttle"
	icon = 'shuttle.dmi'
	thermal_conductivity = 0.05
	heat_capacity = 10000000

/turf/simulated/shuttle/floor
	name = "floor"
	icon_state = "floor"

/turf/simulated/shuttle/wall
	name = "wall"
	icon_state = "wall"
	explosionstrength = 4
	opacity = 1
	density = 1
	blocks_air = 1

/turf/simulated/shuttle/wall/other
	icon = 'walls.dmi'
	icon_state = "riveted"














/turf/unsimulated
	name = "Command"
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD

/turf/unsimulated/shuttle
	name = "Shuttle"
	icon = 'shuttle.dmi'

/turf/unsimulated/shuttle/floor
	name = "Shuttle Floor"
	icon_state = "floor"

/turf/unsimulated/shuttle/wall
	name = "Shuttle Wall"
	icon_state = "wall"
	opacity = 1
	density = 1

/turf/unsimulated/floor
	name = "floor"
	icon = 'floors.dmi'
	icon_state = "Floor3"

/turf/unsimulated/wall
	name = "wall"
	icon = 'walls.dmi'
	icon_state = "riveted"
	opacity = 1
	density = 1

/turf/unsimulated/wall/other
	icon_state = "r_wall"

/turf/proc/AdjacentTurfs()
	var/L[] = new()
	for(var/turf/simulated/t in oview(src,1))
		if(!t.density && !LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
			L.Add(t)
	return L

/turf/proc/Railturfs()
	var/L[] = new()
	for(var/turf/simulated/t in oview(src,1))
		if(!t.density && !LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
			if(locate(/obj/rail) in t)
				L.Add(t)
	return L

/turf/proc/Distance(turf/t)
	if(!src || !t)
		return 1e31
	t = get_turf(t)
	if(get_dist(src, t) == 1 || src.z != t.z)
		var/cost = (src.x - t.x) * (src.x - t.x) + (src.y - t.y) * (src.y - t.y) + (src.z - t.z) * (src.z - t.z) * 3
		cost *= (pathweight+t.pathweight)/2
		return cost
	else
		return max(get_dist(src,t), 1)

/turf/proc/AdjacentTurfsSpace()
	var/L[] = new()
	for(var/turf/t in oview(src,1))
		if(!t.density)
			if(!LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
				L.Add(t)
	return L

/turf/proc/process()
	return