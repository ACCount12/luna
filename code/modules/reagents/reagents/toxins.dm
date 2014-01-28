////////////////////
/// Poison stuff ///
////////////////////

/datum/reagent/toxin
	name = "Toxin"
	id = "toxin"
	description = "A toxic chemical."
	reagent_state = LIQUID
	reagent_color = "#CF3600" // rgb: 207, 54, 0
	var/toxpwr = 1

	on_mob_life(var/mob/living/M as mob)
		if(!M) M = holder.my_atom
		if(toxpwr)
			M.adjustToxLoss(toxpwr)
		..()
		return


	amatoxin
		name = "Amatoxin"
		id = "amatoxin"
		description = "A powerful poison derived from certain species of mushroom."
		reagent_color = "#792300"
		toxpwr = 2

	nicotine
		name = "Nicotine"
		id = "nicotine"
		description = "A highly addictive stimulant extracted from the tobacco plant."
		toxpwr = 0.1
		reagent_state = LIQUID

	carpotoxin
		name = "Carpotoxin"
		id = "carpotoxin"
		description = "A deadly neurotoxin produced by the dreaded spess carp."
		reagent_state = LIQUID
		reagent_color = "#003333"
		toxpwr = 2

		on_mob_life(var/mob/living/M as mob)
			if(!M) M = holder.my_atom
			if(prob(20)) M.Weaken(2)
			..()
			return

	cyanide
		name = "Cyanide"
		id = "cyanide"
		description = "A highly toxic chemical."
		reagent_state = LIQUID
		reagent_color = "#CF3600"
		toxpwr = 4

		on_mob_life(var/mob/living/M)
			if(!M) M = holder.my_atom
			M.adjustOxyLoss(7)
			..()
			return

	plantbgone
		name = "Plant-B-Gone"
		id = "plantbgone"
		description = "A harmful toxic mixture to kill plantlife. Do not ingest!"
		reagent_state = LIQUID
		reagent_color = "#49002E" // rgb: 73, 0, 46

		reaction_obj(var/obj/O, var/volume)
	//		if(istype(O,/obj/plant/vine/))
	//			O:life -= rand(15,35) // Kills vines nicely // Not tested as vines don't work in R41
			if(istype(O,/obj/alien/weeds/))
				O:health -= rand(15,35) // Kills alien weeds pretty fast
				O:healthcheck()
				del(O)
			// Damage that is done to growing plants is separately
			// at code/game/machinery/hydroponics at obj/item/hydroponics

		reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
			src = null
			if(istype(M, /mob/living/carbon))
				if(!M.wear_mask) // If not wearing a mask
					M.adjustToxLoss(4) // 4 toxic damage per application, doubled for some reason
				if(istype(M,/mob/living/carbon/human) && M:dna && M:dna.mutantrace == "plant") //plantmen take a LOT of damage
					M.adjustToxLoss(10)

	plasma
		name = "Plasma"
		id = "plasma"
		description = "Plasma in its liquid form."
		reagent_state = LIQUID
		reagent_color = "#E71B00" // rgb: 231, 27, 0
		toxpwr = 3

		on_mob_life(var/mob/living/M)
			if(!M) M = holder.my_atom
			if(holder.has_reagent("inaprovaline"))
				holder.remove_reagent("inaprovaline", 2)
			..()
			return

		reaction_obj(var/obj/O, var/volume)
			src = null
			var/turf/the_turf = get_turf(O)
			if(the_turf)
				var/datum/gas_mixture/napalm = new
				var/datum/gas/volatile_fuel/fuel = new
				fuel.moles = 5
				napalm.trace_gases += fuel
				the_turf.assume_air(napalm)

		reaction_turf(var/turf/T, var/volume)
			src = null
			var/datum/gas_mixture/napalm = new
			var/datum/gas/volatile_fuel/fuel = new
			fuel.moles = 5
			napalm.trace_gases += fuel
			T.assume_air(napalm)
			return

	chloralhydrate							//Otherwise known as a "Mickey Finn"
		name = "Chloral Hydrate"
		id = "chloralhydrate"
		description = "A powerful sedative."
		reagent_state = SOLID
		reagent_color = "#000067"
		toxpwr = 0

		on_mob_life(var/mob/living/M as mob)
			if(!M) M = holder.my_atom
			if(!data) data = 1
			data++
			switch(data)
				if(2 to 10)
					M.confused += 2
					M.drowsyness += 2
					M.sleeping += 2
				if(11 to 70)
					M.sleeping += 3
				if(71 to INFINITY)
					M.sleeping += 4
					M.adjustToxLoss(3)
			..()
			return