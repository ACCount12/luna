#define OXYGEN
atom/proc/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return null

turf/proc/hotspot_expose(exposed_temperature, exposed_volume, soh = 0)

turf/simulated/hotspot_expose(exposed_temperature, exposed_volume, soh)
	var/datum/gas_mixture/air_contents = return_air(1)
	if(!air_contents)
		return 0

  /*if(active_hotspot)
		if(soh)
			if(air_contents.toxins > 0.5 && air_contents.oxygen > 0.5)
				if(active_hotspot.temperature < exposed_temperature)
					active_hotspot.temperature = exposed_temperature
				if(active_hotspot.volume < exposed_volume)
					active_hotspot.volume = exposed_volume
		return 1*/
	var/igniting = 0
	if(locate(/obj/effect/fire) in src)
		return 1

	if((exposed_temperature > PLASMA_MINIMUM_BURN_TEMPERATURE) && air_contents.toxins > 0.5)
		igniting = 1
	if(igniting)
		if(air_contents.oxygen < 0.5 || air_contents.toxins < 0.5)
			return 0

		if(parent&&parent.group_processing)
			parent.suspend_group_processing()

		var/obj/effect/fire/F = new(src)
		F.temperature = exposed_temperature
		F.volume = exposed_volume

		//active_hotspot.just_spawned = (current_cycle < air_master.current_cycle)
		//remove just_spawned protection if no longer processing this cell

	return igniting

obj/effect/hotspot
	//Icon for fire on turfs, also helps for nurturing small fires until they are full tile

	anchored = 1

	mouse_opacity = 0

	//luminosity = 3

	icon = 'fire.dmi'
	icon_state = "1"

	layer = TURF_LAYER

	var
		volume = 125
		temperature = FIRE_MINIMUM_TEMPERATURE_TO_EXIST

		just_spawned = 1

		bypassing = 0

obj/effect/hotspot/proc/perform_exposure()
	var/turf/simulated/floor/location = loc
	if(!istype(location))
		return 0

	if(volume > CELL_VOLUME*0.95)
		bypassing = 1
	else bypassing = 0

	if(bypassing)
		if(!just_spawned)
			volume = location.air.fuel_burnt*FIRE_GROWTH_RATE
			temperature = location.air.temperature
	else
		var/datum/gas_mixture/affected = location.air.remove_ratio(volume/location.air.volume)

		affected.temperature = temperature

		affected.react()

		temperature = affected.temperature
		volume = affected.fuel_burnt*FIRE_GROWTH_RATE

		location.assume_air(affected)

		for(var/atom/item in loc)
			item.temperature_expose(null, temperature, volume)

obj/effect/hotspot/process(turf/simulated/list/possible_spread)
	if(just_spawned)
		just_spawned = 0
		return 0

	var/turf/simulated/floor/location = loc
	if(!istype(location))
		del(src)

	if((temperature < FIRE_MINIMUM_TEMPERATURE_TO_EXIST) || (volume <= 1))
		del(src)

	if(location.air.toxins < 0.5 || location.air.oxygen < 0.5)
		del(src)


	perform_exposure()

	if(location.wet) location.wet = 0

	if(bypassing)
		icon_state = "3"
		location.burn_tile()

		//Possible spread due to radiated heat
		if(location.air.temperature > FIRE_MINIMUM_TEMPERATURE_TO_SPREAD)
			var/radiated_temperature = location.air.temperature*FIRE_SPREAD_RADIOSITY_SCALE

			for(var/turf/simulated/possible_target in possible_spread)
				if(!possible_target.active_hotspot)
					possible_target.hotspot_expose(radiated_temperature, CELL_VOLUME/4)

	else
		if(volume > CELL_VOLUME*0.4)
			icon_state = "2"
		else
			icon_state = "1"

	return 1

obj/effect/hotspot/New()
	..()
	dir = pick(cardinal)
	ul_SetLuminosity(3)

obj/effect/hotspot/Del()
	loc:active_hotspot = null
	src.ul_SetLuminosity(0)
	loc = null
	..()


/obj/effect/fire
	anchored = 1
	mouse_opacity = 0
	icon = 'fire.dmi'
	icon_state = "3"
	layer = OBJ_LAYER
	opacity = 1
	var
		temperature = FIRE_MINIMUM_TEMPERATURE_TO_EXIST
		just_spawned = 1
		volume = 125
		bypassing = 0

	//				for(var/atom/item in loc)
	//				item.temperature_expose(null, temperature, volume)


/obj/effect/fire/process()
	if(just_spawned)
		just_spawned = 0
		return
	var/turf/simulated/floor/T = src.loc
	if(!istype(src.loc,/turf/simulated/floor))
		del(src)
	if(T.air.temperature < FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		//world << "NOT HOT ENOUGH [T.air.temperature] : [FIRE_MINIMUM_TEMPERATURE_TO_EXIST]"
		del(src)
		return
	if(T.air.toxins <= 0.5 || T.air.oxygen <= 0.5)
		//world << "NOT HOT ENOUGH shit"
		del(src)
	if(T.wet) T.wet = 0
	burn(0.5,0.5)
	T.burn_tile()
	for(var/dirs in cardinal)
		if(prob(50))
			continue
		var/turf/simulated/floor/TS = get_step(src,dirs)
		if(!istype(TS))
			continue
		if(!TS || !TS.air)
			continue
		if(locate(/obj/effect/fire) in TS)
			continue
		if(TS.air.temperature >= 250  && TS.air.toxins > 0.5 && TS.air.oxygen > 0.5 )
			new/obj/effect/fire(TS)
	for(var/atom/item in loc)
		item.temperature_expose(null, T.air.temperature, volume)

/obj/effect/fire/proc/burn(tox,oxy)
	var/turf/simulated/floor/T = src.loc
//	var/datum/gas_mixture/affected = T.air.remove_ratio(volume/T.air.volume)
	T.air.oxygen -= round(oxy)
	T.air.toxins -= round(tox)
	var/newco = round(oxy + tox)
	T.air.carbon_dioxide += newco/4
	T.air.temperature += round(tox)

/*mob/verb/createfire()
	src.loc:air:temperature += round(FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
	new/obj/effect/fire(src.loc)*/

/obj/effect/fire/New()
	..()
	processing_fires.Add(src)
	var/turf/simulated/floor/T = src.loc
	T.air.temperature += temperature
	dir = pick(cardinal)
	ul_SetLuminosity(7,3,0)

/obj/effect/fire/Del()
	processing_fires.Remove(src)
	ul_SetLuminosity(0)
	loc = null
	..()