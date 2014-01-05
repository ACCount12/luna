/turf/DblClick()
	if(istype(usr, /mob/living/silicon/ai))
		return move_camera_by_click()
	return ..()

/turf/New()
	..()
	for(var/atom/movable/AM as mob|obj in src)
		spawn( 0 )
			src.Entered(AM)
			return
	return

/turf/Enter(atom/movable/mover as mob|obj, atom/forget as mob|obj|turf|area)
	if (!mover || !isturf(mover.loc))
		return 1


	//First, check objects to block exit that are not on the border
	for(var/obj/obstacle in mover.loc)
		if((obstacle.flags & ~ON_BORDER) && (mover != obstacle) && (forget != obstacle))
			if(!obstacle.CheckExit(mover, src))
				mover.Bump(obstacle, 1)
				return 0

	//Now, check objects to block exit that are on the border
	for(var/obj/border_obstacle in mover.loc)
		if((border_obstacle.flags & ON_BORDER) && (mover != border_obstacle) && (forget != border_obstacle))
			if(!border_obstacle.CheckExit(mover, src))
				mover.Bump(border_obstacle, 1)
				return 0

	//Next, check objects to block entry that are on the border
	for(var/obj/border_obstacle in src)
		if(border_obstacle.flags & ON_BORDER)
			if(!border_obstacle.CanPass(mover, mover.loc, 1, 0) && (forget != border_obstacle))
				mover.Bump(border_obstacle, 1)
				return 0

	//Then, check the turf itself
	if (!src.CanPass(mover, src))
		mover.Bump(src, 1)
		return 0

	//Finally, check objects/mobs to block entry that are not on the border
	for(var/atom/movable/obstacle in src)
		if(obstacle.flags & ~ON_BORDER)
			if(!obstacle.CanPass(mover, mover.loc, 1, 0) && (forget != obstacle))
				mover.Bump(obstacle, 1)
				return 0
	return 1 //Nothing found to block so return success!


/turf/Entered(atom/movable/M as mob|obj)
	if(ismob(M) && src.type != /turf/space)
		var/mob/tmob = M
		tmob.inertia_dir = 0
	..()
	for(var/atom/A as mob|obj|turf|area in src)
		spawn( 0 )
			if ((A && M))
				A.HasEntered(M, 1)
			return
	for(var/atom/A as mob|obj|turf|area in range(1))
		spawn( 0 )
			if ((A && M))
				A.HasProximity(M, 1)
			return
	return


/turf/proc/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(src.intact)

// override for space turfs, since they should never hide anything
/turf/space/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(0)

/turf/proc/ReplaceWithOpen()
	if(!icon_old) icon_old = icon_state
	var/turf/simulated/floor/W
	var/old_icon = icon_old
	var/old_dir = dir

	W = new /turf/simulated/floor/open( locate(src.x, src.y, src.z) )

	W.dir = old_dir
	W.icon_old = old_icon
	if(old_icon) W.icon_state = old_icon
	W.opacity = !W.opacity
	W.ul_SetOpacity(!W.opacity)
	W.levelupdate()

	//var/icon/tempicon = icon_state
	//var/turf/newopen = new /turf/simulated/floor/open( locate(src.x, src.y, src.z) )
	//newopen.icon_old = tempicon
	for(var/obj/machinery/shielding/emitter/plate/P in range(src,10))
		P.AddShield(src)
		return
/turf/proc/ReplaceWithHull()
	if(!icon_old) icon_old = icon_state
	new /turf/space/hull( locate(src.x, src.y, src.z) )

/turf/proc/ReplaceWithFloor()
	if(!icon_old) icon_old = icon_state
	var/turf/simulated/floor/W
	var/old_icon = icon_old
	var/old_dir = dir

	W = new /turf/simulated/floor( locate(src.x, src.y, src.z) )

	W.dir = old_dir
	W.icon_old = old_icon
	if(old_icon) W.icon_state = old_icon
	W.opacity = !W.opacity
	W.ul_SetOpacity(!W.opacity)
	W.levelupdate()
	return W

/turf/proc/MakePlating()
	var/turf/simulated/floor/plating/W = new /turf/simulated/floor/plating( locate(src.x, src.y, src.z) )
	W.opacity = !W.opacity
	W.ul_SetOpacity(!W.opacity)
	W.levelupdate()
	update_nearby_tiles()
	return W

/turf/proc/ReplaceWithEngineFloor()
	if(!icon_old) icon_old = icon_state
	var/old_icon = icon_old
	var/old_dir = dir
	var/turf/simulated/floor/engine/E = new /turf/simulated/floor/engine( locate(src.x, src.y, src.z) )
	E.dir = old_dir
	E.icon_old = old_icon
	E.opacity = !E.opacity
	E.ul_SetOpacity(!E.opacity)
	E.levelupdate()

/turf/simulated/Entered(atom/A, atom/OL)
	if (istype(A,/mob/living/carbon))
		var/mob/living/carbon/M = A
		if(M.lying)
			if(src.wet == 2 || (src.wet == 1 && prob(40)))
				M.pulling = null

				spawn(4) step(M, M.dir)

				playsound(src.loc, 'slip.ogg', 50, 1, -3)
				M.weakened = 6*src.wet
				if(src.wet == 2)
					M:adjustBruteLoss(2)

			return
		if(istype(M, /mob/living/carbon/human) && istype(M:shoes, /obj/item/clothing/shoes/clown_shoes))
			if(M.m_intent == "run")
				if(M.footstep >= 2)
					M.footstep = 0
					playsound(src, "clownstep", 50, 1) // this will get annoying very fast.
				else
					M.footstep++.
			else
				playsound(src, "clownstep", 20, 1)
		switch(src.wet)
			if(1)
				if(!(M.m_intent != "run" || (isobj(M:shoes) && M:shoes.flags&NOSLIP)))
					M.pulling = null
					M << "\blue You slipped on the wet floor!"
					playsound(src.loc, 'slip.ogg', 50, 1, -3)
					M.weakened = 6
				else
					M.inertia_dir = 0
					return
			if(2) //lube
				if(!(M.m_intent != "run" && isobj(M:shoes) && M:shoes.flags&NOSLIP))
					M.pulling = null
					spawn(4) step(M, M.dir)
					M:adjustBruteLoss(2)
					M << "\blue You slipped on the wet floor!"
					playsound(src.loc, 'slip.ogg', 50, 1, -3)
					M.weakened = 12

	..()

/turf/proc/ReplaceWithSpace()
	if(!icon_old) icon_old = icon_state
	var/old_icon = icon_old
	var/old_dir = dir
	var/turf/space/S = new /turf/space( locate(src.x, src.y, src.z) )
	S.dir = old_dir
	S.icon_old = old_icon
	S.Check()
	return S

/turf/proc/ReplaceWithLattice()
	if(!icon_old) icon_old = icon_state
	var/turf/simulated/floor/W
	var/old_icon = icon_old
	var/old_dir = dir

	W = new /turf/simulated/floor/open( locate(src.x, src.y, src.z) )

	W.dir = old_dir
	W.icon_old = old_icon
	if(old_icon) W.icon_state = old_icon
	W.opacity = !W.opacity
	W.ul_SetOpacity(initial(W.opacity))
	W.levelupdate()
	new /obj/structure/lattice( locate(src.x, src.y, src.z) )

	//if(!icon_old) icon_old = icon_state
	//new /turf/simulated/floor/open( locate(src.x, src.y, src.z) )
	//new /obj/structure/lattice( locate(src.x, src.y, src.z) )


/turf/proc/ReplaceWithWall()
	var/turf/simulated/wall/S = new /turf/simulated/wall( locate(src.x, src.y, src.z) )
//	S.opacity = 1
	S.ul_UpdateLight()
	update_nearby_tiles()
	return S

/turf/proc/ReplaceWithRWall()
	var/turf/simulated/wall/r_wall/S = new /turf/simulated/wall/r_wall( locate(src.x, src.y, src.z) )
	S.opacity = !S.opacity
	S.ul_SetOpacity(!S.opacity)
	update_nearby_tiles()
	return S


/turf/simulated/wall/proc/dismantle_wall(devastated=0, explode=0)
	var/turf/simulated/wall/S = src
	if(istype(src,/turf/simulated/wall/r_wall))
		if(!devastated)
			playsound(src, 'sound/items/Welder.ogg', 100, 1)
			new /obj/structure/girder/reinforced(src)
			new /obj/item/stack/sheet/plasteel( src )
		else
			new /obj/item/stack/sheet/metal( src )
			new /obj/item/stack/sheet/metal( src )
			new /obj/item/stack/sheet/plasteel( src )
			new /obj/item/stack/sheet/plasteel( src )
	else if(istype(src,/turf/simulated/wall/cult))
		if(!devastated)
			playsound(src, 'sound/items/Welder.ogg', 100, 1)
			new /obj/effect/decal/cleanable/blood(src)
			new /obj/structure/cultgirder(src)
		else
			new /obj/effect/decal/cleanable/blood(src)

	else
		if(!devastated)
			playsound(src, 'sound/items/Welder.ogg', 100, 1)
			new /obj/structure/girder(src)
			if (mineral == "metal")
				new /obj/item/stack/sheet/metal( src )
				new /obj/item/stack/sheet/metal( src )
			else
				var/M = text2path("/obj/item/stack/sheet/mineral/[mineral]")
				new M( src )
				new M( src )
		else
			if (mineral == "metal")
				new /obj/item/stack/sheet/metal( src )
				new /obj/item/stack/sheet/metal( src )
				new /obj/item/stack/sheet/metal( src )
				new /obj/item/stack/sheet/metal( src )
			else
				var/M = text2path("/obj/item/stack/sheet/mineral/[mineral]")
				new M( src )
				new M( src )
				new /obj/item/stack/sheet/metal( src )
				new /obj/item/stack/sheet/metal( src )
	S.MakePlating()

/turf/simulated/wall/examine()
	set src in oview(1)

	usr << "It looks like a regular wall."
	return

/turf/simulated/wall/ex_act(severity)
	switch(severity)
		if(1.0)
			//SN src = null
			src.ReplaceWithOpen() //Used to replace with space
			return
		if(2.0)
			if (prob(50))
				dismantle_wall()
			else
				dismantle_wall(1)
		if(3.0)
			if (prob(20))
				dismantle_wall()
		else
	return

/turf/simulated/wall/blob_act()
	if(prob(20))
		dismantle_wall()

/turf/simulated/wall/attack_paw(mob/user as mob)
	if(HULK in user.mutations)
		if (prob(40))
			usr << text("\blue You smash through the wall.")
			dismantle_wall(1)
			return
		else
			usr << text("\blue You punch the wall.")
			return

	return src.attack_hand(user)

/turf/simulated/wall/attack_hand(mob/user as mob)
	if(HULK in user.mutations)
		if (prob(40))
			user << text("\blue You smash through the wall.")
			dismantle_wall(1)
			return
		else
			user << text("\blue You punch the wall.")
			return
	if(ishuman(user) && user:zombie)
		Zombiedamage += rand(5,7)
		user << text("\blue You claw the wall.")
		if(Zombiedamage > 80)
			dismantle_wall(1)
			user << text("\blue You smash through the wall.")

	user << "\blue You push the wall but nothing happens!"
	playsound(src.loc, 'Genhit.ogg', 25, 1)
	src.add_fingerprint(user)
	return

/turf/simulated/wall/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return

	if(istype(W,/obj/item/frame))
		var/obj/item/frame/AH = W
		AH.try_build(src)
		return

	if (thermite)
		if(istype(W, /obj/item/weapon/melee/energy/sword) && W:active) ThermiteBurn(user)
		if(istype(W, /obj/item/device/flashlight/flare) && W:on) ThermiteBurn(user)
		if(istype(W, /obj/item/weapon/weldingtool) && W:welding) ThermiteBurn(user)

	else if (istype(W, /obj/item/weapon/weldingtool) && W:welding)
		W:eyecheck(user)
		var/turf/T = user.loc
		if (!istype(T, /turf))
			return

		if (W:get_fuel() < 5)
			user << "\blue You need more welding fuel to complete this task."
			return
		W:use_fuel(5)

		user << "\blue Now disassembling the outer wall plating."
		playsound(src.loc, 'Welder.ogg', 100, 1)

		if(do_after(user, 100))
			user << "\blue You disassembled the outer wall plating."
			dismantle_wall()

	else
		return attack_hand(user)
	return

/turf/simulated/wall/proc/ThermiteBurn(mob/user)
	var/obj/overlay/O = new/obj/overlay( src )
	O.name = "Thermite"
	O.desc = "Looks hot."
	O.icon = 'fire.dmi'
	O.icon_state = "2"
	O.anchored = 1
	O.density = 1
	O.layer = 5
	var/turf/simulated/floor/F = ReplaceWithFloor()
	F.to_plating()
	F.burn_tile()
	user << "\red The thermite melts the wall."
	spawn(100) del(O)
	return

/turf/simulated/wall/r_wall/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (!istype(usr, /mob/living/carbon/human) && (ticker && ticker.mode.name != "monkey"))
		usr << "\red You don't have the dexterity to do this!"
		return

	if(istype(W,/obj/item/frame))
		var/obj/item/frame/AH = W
		AH.try_build(src)
		return

	if (thermite)
		if(istype(W, /obj/item/weapon/melee/energy/sword) && W:active) ThermiteBurn(user)
		if(istype(W, /obj/item/device/flashlight/flare) && W:on) ThermiteBurn(user)

	if (istype(W, /obj/item/weapon/weldingtool) && W:welding)
		W:eyecheck(user)
		var/turf/T = user.loc
		if (!istype(T, /turf))
			return

		if (thermite) ThermiteBurn(user)

		if (src.d_state == 2)
			user << "\blue Slicing metal cover."
			playsound(src.loc, 'Welder.ogg', 100, 1)
			if (do_after(user, 60))
				src.d_state = 3
				user << "\blue You removed the metal cover."

		else if(src.d_state == 5)
			user << "\blue Removing support rods."
			playsound(src.loc, 'Welder.ogg', 100, 1)
			if(do_after(user, 100))
				src.d_state = 6
				new /obj/item/stack/rods( src )
				user << "\blue You removed the support rods."

	else if(istype(W, /obj/item/weapon/wrench))
		if(src.d_state == 4)
			user << "\blue Detaching support rods."
			playsound(src.loc, 'Ratchet.ogg', 100, 1)
			if(do_after(user, 40))
				src.d_state = 5
				user << "\blue You detach the support rods."

	else if(istype(W, /obj/item/weapon/wirecutters))
		if(src.d_state == 0)
			playsound(src.loc, 'Wirecutter.ogg', 100, 1)
			src.d_state = 1
			new /obj/item/stack/rods( src )

	else if(istype(W, /obj/item/weapon/screwdriver))
		if(src.d_state == 1)
			playsound(src.loc, 'Screwdriver.ogg', 100, 1)
			user << "\blue Removing support lines."
			if (do_after(user, 40))
				src.d_state = 2
				user << "\blue You removed the support lines."

	else if(istype(W, /obj/item/weapon/crowbar))
		if(src.d_state == 3)
			user << "\blue Prying cover off."
			playsound(src.loc, 'Crowbar.ogg', 100, 1)
			if(do_after(user, 100))
				src.d_state = 4
				user << "\blue You removed the cover."

		else if(src.d_state == 6)
			user << "\blue Prying outer sheath off."
			playsound(src.loc, 'Crowbar.ogg', 100, 1)
			if(do_after(user, 100))
				user << "\blue You removed the outer sheath."
				dismantle_wall()
				return

	else if(istype(W, /obj/item/stack/sheet/metal) && src.d_state)
		user << "\blue Repairing wall."
		if(do_after(user, 100))
			src.d_state = 0
			src.icon_state = initial(src.icon_state)
			user << "\blue You repaired the wall."
			W:use(1)

	if(src.d_state > 0)
		src.icon_state = "r_wall-[d_state]"

	else
		return attack_hand(user)
	return

/turf/simulated/wall/meteorhit(obj/M as obj)
	if (M.icon_state == "flaming")
		dismantle_wall()
	return 0

/turf/simulated/floor/New()
	. = ..()
	if(type != /turf/simulated/floor/open)
		var/obj/structure/lattice/L = locate() in src
		if(L) del L

/turf/simulated/floor/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if ((istype(mover, /obj/machinery/vehicle) && !(src.burnt)))
		if (!( locate(/obj/machinery/mass_driver, src) ))
			return 0
	return ..()

/turf/simulated/floor/ex_act(severity)
	//set src in oview(1)
	switch(severity)
		if(1.0)
			src.ReplaceWithOpen() //used to be space
		if(2.0)
			switch(pick(1,2;75,3))
				if (1)
					src.ReplaceWithLattice()
					if(prob(33)) new /obj/item/stack/sheet/metal(src)
				if(2)
					src.ReplaceWithOpen()
				if(3)
					if(prob(80))
						src.break_tile_to_plating()
					else
						src.break_tile()
					src.hotspot_expose(1000,CELL_VOLUME)
					if(prob(33)) new /obj/item/stack/sheet/metal(src)
		if(3.0)
			if (prob(50))
				src.break_tile()
				src.hotspot_expose(1000,CELL_VOLUME)
	return

/turf/simulated/floor/blob_act()
	return

/turf/simulated/floor/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/turf/simulated/floor/attack_hand(mob/user as mob)

	if (!user.canmove || user.restrained() || !user.pulling)
		return
	if (user.pulling.anchored)
		return
	if ((user.pulling.loc != user.loc && get_dist(user, user.pulling) > 1))
		return
	if (ismob(user.pulling))
		var/mob/M = user.pulling
		var/mob/t = M.pulling
		M.pulling = null
		step(user.pulling, get_dir(user.pulling.loc, src))
		M.pulling = t
	else
		step(user.pulling, get_dir(user.pulling.loc, src))
	return

/turf/simulated/floor/engine/attackby(obj/item/weapon/C as obj, mob/user as mob)
	if(!C)
		return
	if(!user)
		return
	if(istype(C, /obj/item/weapon/wrench))
		user << "\blue Removing rods..."
		playsound(src.loc, 'Ratchet.ogg', 80, 1)
		if(do_after(user, 30))
			new /obj/item/stack/rods(src)
			new /obj/item/stack/rods(src)
			ReplaceWithFloor()
			var/turf/simulated/floor/F = src
			F.to_plating()
			return

/turf/simulated/floor/proc/to_plating()
	if(istype(src,/turf/simulated/floor/engine)) return
	if(!intact) return
	if(!icon_old) icon_old = icon_state
	src.icon_state = "plating"
	intact = 0
	broken = 0
	burnt = 0
	levelupdate()

/turf/simulated/floor/proc/restore_tile()
	if(intact) return
	intact = 1
	broken = 0
	burnt = 0
	if(icon_old)
		icon_state = icon_old
	else
		icon_state = "floor"
	levelupdate()

/turf/simulated/floor/attackby(obj/item/C as obj, mob/user as mob)
	if(!C || !user)
		return 0

	if(istype(C,/obj/item/weapon/light/bulb)) //only for light tiles
		if(is_light_floor())
			var/obj/item/stack/tile/light/T = floor_tile
			if(T.state)
				user.drop_item(C)
				del(C)
				T.state = C //fixing it by bashing it with a light bulb, fun eh?
				update_icon()
				user << "\blue You replace the light bulb."
			else
				user << "\blue The lightbulb seems fine, no need to replace it."

	if(istype(C, /obj/item/weapon/crowbar) && (!(is_plating())))
		if(broken || burnt)
			user << "\red You remove the broken plating."
		else
			if(is_wood_floor())
				user << "\red You forcefully pry off the planks, destroying them in the process."
			else
				user << "\red You remove the [floor_tile.name]."
				new floor_tile.type(src)

		make_plating()
		playsound(src.loc, 'sound/items/Crowbar.ogg', 80, 1)

		return

	if(istype(C, /obj/item/weapon/screwdriver) && is_wood_floor())
		if(broken || burnt)
			return
		else
			if(is_wood_floor())
				user << "\red You unscrew the planks."
				new floor_tile.type(src)

		make_plating()
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 80, 1)

		return

	if(istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = C
		if (is_plating())
			if (R.amount >= 2)
				user << "\blue Reinforcing the floor..."
				if(do_after(user, 30) && R && R.amount >= 2 && is_plating())
					ChangeTurf(/turf/simulated/floor/engine)
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 80, 1)
					R.use(2)
					return
			else
				user << "\red You need more rods."
		else
			user << "\red You must remove the plating first."
		return

	if(istype(C, /obj/item/stack/tile))
		if(is_plating())
			if(!broken && !burnt)
				var/obj/item/stack/tile/T = C
				floor_tile = new T.type
				intact = 1
				if(istype(T,/obj/item/stack/tile/light))
					var/obj/item/stack/tile/light/L = T
					var/obj/item/stack/tile/light/F = floor_tile
					F.state = L.state
					F.on = L.on
				if(istype(T,/obj/item/stack/tile/grass))
					for(var/direction in cardinal)
						if(istype(get_step(src,direction),/turf/simulated/floor))
							var/turf/simulated/floor/FF = get_step(src,direction)
							FF.update_icon() //so siding gets updated properly
				else if(istype(T,/obj/item/stack/tile/carpet))
					for(var/direction in list(1,2,4,8,5,6,9,10))
						if(istype(get_step(src,direction),/turf/simulated/floor))
							var/turf/simulated/floor/FF = get_step(src,direction)
							FF.update_icon() //so siding gets updated properly
				T.use(1)
				update_icon()
				levelupdate()
				playsound(src.loc, 'sound/weapons/Genhit.ogg', 50, 1)
			else
				user << "\blue This section is too damaged to support a tile. Use a welder to fix the damage."

	if(istype(C, /obj/item/weapon/shovel))
		if(is_grass_floor())
			new /obj/item/weapon/ore/glass(src)
			new /obj/item/weapon/ore/glass(src) //Make some sand if you shovel grass
			user << "\blue You shovel the grass."
			make_plating()
		else
			user << "\red You cannot shovel this."

	if(istype(C, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/welder = C
		if(welder.isOn() && (is_plating()))
			if(broken || burnt)
				if(welder.remove_fuel(0,user))
					user << "\red You fix some dents on the broken plating."
					playsound(src.loc, 'sound/items/Welder.ogg', 80, 1)
					icon_state = "plating"
					burnt = 0
					broken = 0
				else
					user << "\blue You need more welding fuel to complete this task."

	if(istype(C, /obj/item/weapon/table_parts))
		spawn()
			if(istype(C, /obj/item/weapon/table_parts/reinforced))
				new /datum/construction_UI/table/reinforced(src, user, C)
			else
				new /datum/construction_UI/table(src, user, C)

	if(istype(C, /obj/item/weapon/cable_coil))
		if(is_plating())
			var/obj/item/weapon/cable_coil/coil = C
			coil.LayOnTurf(src, user)
		else
			user << "\red You must remove the plating first."

/turf/unsimulated/floor/attack_paw(user as mob)
	return src.attack_hand(user)

/turf/unsimulated/floor/attack_hand(var/mob/user as mob)
	if ((!( user.canmove ) || user.restrained() || !( user.pulling )))
		return
	if (user.pulling.anchored)
		return
	if ((user.pulling.loc != user.loc && get_dist(user, user.pulling) > 1))
		return
	if (ismob(user.pulling))
		var/mob/M = user.pulling
		var/mob/t = M.pulling
		M.pulling = null
		step(user.pulling, get_dir(user.pulling.loc, src))
		M.pulling = t
	else
		step(user.pulling, get_dir(user.pulling.loc, src))
	return

// imported from space.dm

/turf/space/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/turf/space/attack_hand(mob/user as mob)
	if (user.restrained() || !user.pulling)
		return
	if (user.pulling.anchored)
		return
	if ((user.pulling.loc != user.loc && get_dist(user, user.pulling) > 1))
		return
	if (ismob(user.pulling))
		var/mob/M = user.pulling
		var/t = M.pulling
		M.pulling = null
		step(user.pulling, get_dir(user.pulling.loc, src))
		M.pulling = t
	else
		step(user.pulling, get_dir(user.pulling.loc, src))
	return

/turf/space/attackby(obj/item/C as obj, mob/user as mob)
	if (istype(C, /obj/item/stack/rods))
		if(locate(/obj/structure/lattice, src)) return
		user << "\blue Constructing support lattice ..."
		playsound(src.loc, 'Genhit.ogg', 50, 1)
		new /obj/structure/lattice(src)
		C:amount--

		if (C:amount < 1)
			user.u_equip(C)
			del(C)
			return
		return

	if (istype(C, /obj/item/stack/tile/metal))
		if(locate(/obj/structure/lattice, src))
			var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
			del(L)
			playsound(src.loc, 'Genhit.ogg', 50, 1)
			C:build(src)
			C:amount--

			if (C:amount < 1)
				user.u_equip(C)
				del(C)
				return
			return
		else
			user << "\red The plating is going to need some support."
	return

// Ported from unstable r355

/turf/space/Entered(atom/movable/A as mob|obj)
	..()
	if (!A || src != A.loc || istype(A, /obj/item/projectile))
		return

	if (!A.last_move)
		return

	if (istype(A, /mob) && src.x > 2 && src.x < world.maxx - 1)
		var/mob/M = A
		var/prob_slip = 5

		if (locate(/obj/structure/grille, orange(1, M)) || locate(/obj/structure/lattice, orange(1, M)) || locate(/turf/unsimulated, orange(1, M)) || locate(/turf/simulated, orange(1, M)))
			prob_slip = -5

		if (M.handcuffed || !M.canmove) //can't grab that wall
			prob_slip = 5

		if(istype(M,/mob/living))
			if(istype(M:back, /obj/item/weapon/tank/jetpack) && M:back:stabilization_on)
				prob_slip = 0

		prob_slip = round(prob_slip)

		if (prob_slip < 5) //next to something, but they might slip off
			if (prob(prob_slip) && !(istype(M:shoes, /obj/item/clothing/shoes) && M:shoes.flags&NOSLIP))
				M << "\blue <B>You slipped!</B>"
				M.inertia_dir = M.last_move
				step(M, M.inertia_dir)
				return
			else
				M.inertia_dir = 0 //no inertia

		else //not by a wall or anything or can't move, they just keep going
			spawn(5)
				if (A && !A.anchored && A.loc == src && !A.pulledby)
					if(!M.inertia_dir && M.last_move) //they keep moving the same direction
						M.inertia_dir = M.last_move

					if(!step(M, M.inertia_dir)) //Collided with something
						M.inertia_dir = 0 //no inertia
						M.last_move = 0   //no inertia at all

//	if(ticker && ticker.mode && ticker.mode.name == "nuclear emergency")
//		return

	//Copied from old code
	if (A.x <= 2 || A.x >= (world.maxx - 1) || A.y <= 2 || A.y >= (world.maxy - 1))
		if(istype(A, /obj/effect/meteor))
			del(A)
			return

		if(A.x <= 2)
			A.x = world.maxx - 2
		else if(A.x >= (world.maxx - 1))
			A.x = 3

		if(A.y <= 2)
			A.y = world.maxy - 2
		else if(A.y >= (world.maxy - 1))
			A.y = 3

		if(A.z == 5)
			if(prob(60))
				A.z = getZLevel(Z_SPACE)
			else
				A.z = getZLevel(Z_STATION)
		else
			A.z = getZLevel(Z_SPACE)
		spawn(0)
			if (A && A.loc)
				A.loc.Entered(A)

//Copied from old code
/proc/getZLevel(var/level)
	if(level==Z_STATION)
		return pick(1, 2, 3, 4)
	else if(level==Z_SPACE)
		return pick(5, 7, 8)
	return 1//Default

	//Old function:
	//if(level==Z_STATION)
	//	return pick(stationfloors)
	//else if(level==Z_SPACE)
	//	return pick(3,4,5)
	//else if(level==Z_CENTCOM)
	//	return pick(centcomfloors)
	//else if(level==Z_ENGINE_EJECT)
	//	return engine_eject_z_target
	//return 1//Default



//attempted bugfix for engine vent being derp, probably has other uses too
/turf/proc/RebuildZone()
	var/zone/Z = src.zone
	var/turf/T = Z.starting_tile
	del Z
	spawn(1 * tick_multiplier)
		new/zone(T)