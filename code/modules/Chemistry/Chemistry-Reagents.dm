#define SOLID 1
#define LIQUID 2
#define GAS 3

#define	REAGENTS_METABOLISM 0.4	//How many units of reagent are consumed per tick, by default.
#define REAGENTS_EFFECT_MULTIPLIER (REAGENTS_METABOLISM / 0.4)
// By defining the effect multiplier this way, it'll exactly adjust all effects according to how they originally were with the 0.4 metabolism

//The reaction procs must ALWAYS set src = null, this detaches the proc from the object (the reagent)
//so that it can continue working when the reagent is deleted while the proc is still active.

/datum/reagent
	var/name = "Reagent"
	var/id = "reagent"
	var/description = ""
	var/datum/reagents/holder = null
	var/reagent_state = SOLID
	var/list/data = null
	var/volume = 0
	var/red = 255
	var/green = 255
	var/blue = 255
	var/alpha = 255
	var/nutriment_factor = 0
	var/reagent_color = "#000000"
	proc
		reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume) //By default we have a chance to transfer some
			var/datum/reagent/self = src
			src = null										  //of the reagent to the mob on TOUCHING it.
			if(method == TOUCH)

				var/chance = 1
				for(var/obj/item/clothing/C in M.get_equipped_items())
					if(C.permeability_coefficient < chance) chance = C.permeability_coefficient
				chance = chance * 100

				if(prob(chance))
					if(M.reagents)
						M.reagents.add_reagent(self.id,self.volume/2)
			return

		reaction_obj(var/obj/O, var/volume)
		//	var/datum/reagent/self = src
		//	src = null
		//	if(O.reagents)
		//		O.reagents.add_reagent(self.id,self.volume)
			return

		reaction_turf(var/turf/T, var/volume)
			src = null
			return

		on_mob_life(var/mob/living/M)
			holder.remove_reagent(src.id, 0.4) //By default it slowly disappears.
			return

		on_move(var/mob/living/M)
			return

		// Called after add_reagents creates a new reagent.
		on_new(var/data)
			return

		// Called when two reagents of the same are mixing.
		on_merge(var/data)
			return

		on_update(var/atom/A)
			return

		getcolour()
			return rgb(red,green,blue)


/////////////////////////////////////////////////////////////////CHIM////////////////////////////////////////
	water
		name = "Water"
		id = "water"
		description = "A ubiquitous chemical substance that is composed of hydrogen and oxygen."
		reagent_state = LIQUID
		reagent_color = "#0064C8" // rgb: 0, 100, 200

		reaction_turf(var/turf/T, var/volume)
			src = null
			for(var/mob/living/carbon/slime/M in T)
				M.adjustToxLoss(rand(15,20))
			if(istype(T, /turf/simulated) && volume >= 3)
				var/turf/simulated/turf = T
				if(turf.wet >= 1) return
				turf.wet = 1
				if(turf.wet_overlay)
					turf.overlays -= T:wet_overlay
					turf.wet_overlay = null
				turf.wet_overlay = image('water.dmi',T,"wet_floor")
				turf.overlays += T:wet_overlay

				spawn(800)
					if(!istype(turf)) return
					if(turf.wet >= 2) return
					turf.wet = 0
					if(turf.wet_overlay)
						turf.overlays -= T:wet_overlay
						turf.wet_overlay = null

			var/hotspot = (locate(/obj/effect/hotspot) in T)
			if(hotspot)
				var/datum/gas_mixture/lowertemp = T.remove_air( T:air:total_moles() )
				lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
				lowertemp.react()
				T.assume_air(lowertemp)
				del(hotspot)
			return

		reaction_obj(var/obj/O, var/volume)
			src = null
			var/turf/T = get_turf(O)
			var/hotspot = (locate(/obj/effect/hotspot) in T)
			if(hotspot)
				var/datum/gas_mixture/lowertemp = T.remove_air( T:air:total_moles() )
				lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
				lowertemp.react()
				T.assume_air(lowertemp)
				del(hotspot)
			return

		reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
			if(isslime(M))
				M.adjustToxLoss(rand(15,20))

	water/holywater
		name = "Holy Water"
		id = "holywater"
		description = "Water blessed by some deity."
		reagent_color = "#E0E8EF" // rgb: 224, 232, 239

		on_mob_life(var/mob/living/M as mob)
			if(!data) data = 1
			data++
			M.jitteriness = max(M.jitteriness-5,0)
			if(data >= 30)
				if (!M.stuttering) M.stuttering = 1
				M.stuttering += 4
				M.make_dizzy(5)
			if(data >= 30*2.5 && prob(33))
				if (!M.confused) M.confused = 1
				M.confused += 3
			..()
			return

		reaction_turf(var/turf/simulated/T, var/volume)
			..()
			if(!istype(T)) return
			T.Bless()

	blood
		data = new/list("donor"=null,"viruses"=null,"blood_DNA"=null,"blood_type"="A+","resistances"=null,"trace_chem"=null)
		name = "Blood"
		id = "blood"
		reagent_state = LIQUID
		reagent_color = "#C80000" // rgb: 200, 0, 0

		reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
			var/datum/reagent/blood/self = src
			src = null
			if(self.data && self.data["viruses"])
				for(var/datum/disease/D in self.data["viruses"])

					if(D.spread_type == SPECIAL || D.spread_type == NON_CONTAGIOUS) continue

					if(method == TOUCH)
						M.contract_disease(D)
					else //injected
						M.contract_disease(D, 1, 0)

		on_new(var/list/data)
			if(istype(data))
				SetViruses(src, data)

		on_mob_life(mob/M)
			if (ishuman(M) && data && blood_incompatible(data["blood_type"],M.dna.blood_type))
				if(prob(40)) M:toxloss += 1
				M:oxyloss += 2
			..()
			return

		on_merge(var/list/data)
			if(src.data && data)
				if(src.data["viruses"] || data["viruses"])

					var/list/mix1 = src.data["viruses"]
					var/list/mix2 = data["viruses"]

					// Stop issues with the list changing during mixing.
					var/list/to_mix = list()

					for(var/datum/disease/advance/AD in mix1)
						to_mix += AD
					for(var/datum/disease/advance/AD in mix2)
						to_mix += AD

					var/datum/disease/advance/AD = Advance_Mix(to_mix)
					if(AD)
						var/list/preserve = list(AD)
						for(var/D in src.data["viruses"])
							if(!istype(D, /datum/disease/advance))
								preserve += D
						src.data["viruses"] = preserve
			return 1

	vaccine
		//data must contain virus type
		name = "Vaccine"
		id = "vaccine"
		reagent_state = LIQUID
		reagent_color = "#C81040" // rgb: 200, 16, 64

		reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
			var/datum/reagent/vaccine/self = src
			src = null
			if(islist(self.data) && method == INGEST)
				for(var/datum/disease/D in M.viruses)
					if(D.GetDiseaseID() in self.data)
						D.cure()
				M.resistances |= self.data
			return

		on_merge(var/list/data)
			if(istype(data))
				src.data |= data.Copy()

	lube
		name = "Space Lube"
		id = "lube"
		description = "Lubricant is a substance introduced between two moving surfaces to reduce the friction and wear between them. Giggity."
		reagent_state = LIQUID
		reagent_color = "#009CA8" // rgb: 0, 156, 168

		reaction_turf(var/turf/simulated/T, var/volume)
			if(!istype(T)) return
			src = null
			if(T.wet >= 2) return
			T.wet = 2
			T.wet_overlay = image('effects.dmi', "slube")
			T.overlays += T:wet_overlay
			spawn(1600)
				if(!istype(T)) return
				T.wet = 0
				if(T.wet_overlay)
					T:overlays -= T:wet_overlay

			return

	anti_toxin
		name = "Anti-Toxin (Dylovene)"
		id = "anti_toxin"
		description = "Dylovene is a broad-spectrum antitoxin."
		reagent_state = LIQUID
		reagent_color = "#C8A5DC" // rgb: 200, 165, 220

		on_mob_life(var/mob/living/M)
			if(!M) M = holder.my_atom
			M:drowsyness = max(M:drowsyness-2, 0)
			if(holder.has_reagent("toxin"))
				holder.remove_reagent("toxin", 2)
			if(holder.has_reagent("stoxin"))
				holder.remove_reagent("stoxin", 2)
			if(holder.has_reagent("plasma"))
				holder.remove_reagent("plasma", 1)
			if(holder.has_reagent("sacid"))
				holder.remove_reagent("sacid", 1)
			if(holder.has_reagent("pacid"))
				holder.remove_reagent("pacid", 1)
			if(holder.has_reagent("cyanide"))
				holder.remove_reagent("cyanide", 1)
			M:toxloss = max(M:toxloss-2,0)
			..()
			return

	stoxin
		name = "Sleep Toxin"
		id = "stoxin"
		description = "An effective hypnotic used to treat insomnia."
		reagent_state = LIQUID
		reagent_color = "#E895CC"

		on_mob_life(var/mob/living/M)
			if(!M) M = holder.my_atom
			if(!data) data = 1
			switch(data)
				if(1 to 20)
					M.eye_blurry = max(M.eye_blurry, 10)
				if(20 to 35)
					M:drowsyness  = max(M:drowsyness, 20)
				if(35 to INFINITY)
					M:paralysis = max(M:paralysis, 20)
					M:drowsyness  = max(M:drowsyness, 30)
			data++
			..()
			return

	penstoxin //for Sleepy Pen
		name = "Sleep Toxin"
		id = "penstoxin"
		description = "An effective hypnotic used to treat insomnia."
		reagent_state = LIQUID
		reagent_color = "#E895CC"

		on_mob_life(var/mob/living/M)
			if(!M) M = holder.my_atom
			if(!data) data = 1
			switch(data)
				if(1 to 8)
					M.eye_blurry = max(M.eye_blurry, 10)
				if(8 to 16)
					M:drowsyness  = max(M:drowsyness, 20)
				if(16 to INFINITY)
					M:paralysis = max(M:paralysis, 20)
					M:drowsyness  = max(M:drowsyness, 30)
			data++
			..()
			return

	srejuvinate
		name = "Sleep Rejuvinate"
		id = "stoxin2"
		description = "Put people to sleep, and heals them."
		reagent_state = LIQUID
		reagent_color = "#C8A5DC"

		on_mob_life(var/mob/living/M as mob)
			if(!M) M = holder.my_atom
			if(!data) data = 1
			data++
			if(M.losebreath >= 10)
				M.losebreath = max(10, M.losebreath-10)
			holder.remove_reagent(src.id, 0.2)
			switch(data)
				if(1 to 15)
					M.eye_blurry = max(M.eye_blurry, 10)
				if(15 to 25)
					M.drowsyness  = max(M.drowsyness, 20)
				if(25 to INFINITY)
					M.sleeping += 1
					M.adjustOxyLoss(-M.getOxyLoss())
					M.SetWeakened(0)
					M.SetStunned(0)
					M.SetParalysis(0)
					M.dizziness = 0
					M.drowsyness = 0
					M.stuttering = 0
					M.confused = 0
					M.jitteriness = 0
			..()
			return

	space_drugs
		name = "Space drugs"
		id = "space_drugs"
		description = "An illegal chemical compound used as drug."
		reagent_state = LIQUID
		reagent_color = "#60A584"

		on_mob_life(var/mob/living/M)
			if(!M) M = holder.my_atom
			M.druggy = max(M.druggy, 15)
			if(M.canmove) step(M, pick(cardinal))
			if(prob(7)) M:emote(pick("twitch","drool","moan","giggle"))
			holder.remove_reagent(src.id, 0.2)
			return

	serotrotium
		name = "Serotrotium"
		id = "serotrotium"
		description = "A chemical compound that promotes concentrated production of the serotonin neurotransmitter in humans."
		reagent_state = LIQUID
		reagent_color = "#202040"

		on_mob_life(var/mob/living/M as mob)
			if(ishuman(M))
				if(prob(7)) M.emote(pick("twitch","drool","moan","gasp"))
				holder.remove_reagent(src.id, 0.1)
			return

	silicate
		name = "Silicate"
		id = "silicate"
		description = "A compound that can be used to reinforce glass."
		reagent_state = LIQUID
		reagent_color = "#C7FFFF" // rgb: 199, 255, 255

		reaction_obj(var/obj/O, var/volume)
			src = null
			if(istype(O,/obj/structure/window))
				O:health = O:health * 2
				var/icon/I = icon(O.icon,O.icon_state,O.dir)
				I.SetIntensity(1.15,1.50,1.75)
				O.icon = I
			return

	oxygen
		name = "Oxygen"
		id = "oxygen"
		description = "A reagent_colorless, odorless gas."
		reagent_state = GAS
		reagent_color = "#808080" // rgb: 128, 128, 128

	copper
		name = "Copper"
		id = "copper"
		description = "A highly ductile metal."
		reagent_color = "#6E3B08" // rgb: 110, 59, 8

	nitrogen
		name = "Nitrogen"
		id = "nitrogen"
		description = "A reagent_colorless, odorless, tasteless gas."
		reagent_state = GAS
		reagent_color = "#808080" // rgb: 128, 128, 128

	hydrogen
		name = "Hydrogen"
		id = "hydrogen"
		description = "A reagent_colorless, odorless, nonmetallic, tasteless, highly combustible diatomic gas."
		reagent_state = GAS
		reagent_color = "#808080" // rgb: 128, 128, 128

	potassium
		name = "Potassium"
		id = "potassium"
		description = "A soft, low-melting solid that can easily be cut with a knife. Reacts violently with water."
		reagent_state = SOLID
		reagent_color = "#A0A0A0" // rgb: 160, 160, 160

	mercury
		name = "Mercury"
		id = "mercury"
		description = "A chemical element."
		reagent_state = LIQUID
		reagent_color = "#484848" // rgb: 72, 72, 72

		on_mob_life(var/mob/living/M as mob)
			if(!M) M = holder.my_atom
			if(M.canmove && istype(M.loc, /turf/space))
				step(M, pick(cardinal))
			if(prob(5)) M.emote(pick("twitch","drool","moan"))
			..()
			return

	sulfur
		name = "Sulfur"
		id = "sulfur"
		description = "A chemical element."
		reagent_state = SOLID
		reagent_color = "#BF8C00" // rgb: 191, 140, 0

	carbon
		name = "Carbon"
		id = "carbon"
		description = "A chemical element."
		reagent_state = SOLID
		reagent_color = "#1C1300" // rgb: 30, 20, 0

		reaction_turf(var/turf/T, var/volume)
			src = null
			if(!istype(T, /turf/space))
				new /obj/effect/decal/cleanable/dirt(T)

	chlorine
		name = "Chlorine"
		id = "chlorine"
		description = "A chemical element."
		reagent_state = GAS
		reagent_color = "#808080" // rgb: 128, 128, 128

		on_mob_life(var/mob/living/M)
			if(!M) M = holder.my_atom
			M:toxloss++
			..()
			return

	fluorine
		name = "Fluorine"
		id = "fluorine"
		description = "A highly-reactive chemical element."
		reagent_state = GAS
		reagent_color = "#808080" // rgb: 128, 128, 128
		on_mob_life(var/mob.M)
			if(!M) M = holder.my_atom
			M:toxloss++
			..()
			return

	sodium
		name = "Sodium"
		id = "sodium"
		description = "A chemical element."
		reagent_state = SOLID
		reagent_color = "#808080" // rgb: 128, 128, 128

	phosphorus
		name = "Phosphorus"
		id = "phosphorus"
		description = "A chemical element."
		reagent_state = SOLID
		reagent_color = "#832828" // rgb: 131, 40, 40

	lithium
		name = "Lithium"
		id = "lithium"
		description = "A chemical element."
		reagent_state = SOLID
		reagent_color = "#808080" // rgb: 128, 128, 128

		on_mob_life(var/mob/living/M as mob)
			if(!M) M = holder.my_atom
			if(M.canmove && istype(M.loc, /turf/space))
				step(M, pick(cardinal))
			if(prob(5)) M.emote(pick("twitch","drool","moan"))
			..()
			return

	sugar
		name = "Sugar"
		id = "sugar"
		description = "The organic compound commonly known as table sugar and sometimes called saccharose. This white, odorless, crystalline powder has a pleasing, sweet taste."
		reagent_state = SOLID
		reagent_color = "#FFFFFF" // rgb: 255, 255, 255

		on_mob_life(var/mob/living/M as mob)
			M.nutrition += 1
			..()
			return

	glycerol
		name = "Glycerol"
		id = "glycerol"
		description = "Glycerol is a simple polyol compound. Glycerol is sweet-tasting and of low toxicity."
		reagent_state = LIQUID
		reagent_color = "#808080" // rgb: 128, 128, 128

	nitroglycerin
		name = "Nitroglycerin"
		id = "nitroglycerin"
		description = "Nitroglycerin is a heavy, reagent_colorless, oily, explosive liquid obtained by nitrating glycerol."
		reagent_state = LIQUID
		reagent_color = "#808080" // rgb: 128, 128, 128

	radium
		name = "Radium"
		id = "radium"
		description = "Radium is an alkaline earth metal. It is extremely radioactive."
		reagent_state = SOLID
		reagent_color = "#C7C7C7" // rgb: 199,199,199

		on_mob_life(var/mob/living/M)
			if(!M) M = holder.my_atom
			M.radiation += 3
			..()
			return

		reaction_turf(var/turf/T, var/volume)
			src = null
			if(!istype(T, /turf/space))
				new /obj/effect/decal/cleanable/greenglow(T)


	ryetalyn
		name = "Ryetalyn"
		id = "ryetalyn"
		description = "Ryetalyn can cure all genetic abnomalities."
		reagent_state = SOLID
		reagent_color = "#C8A5DC" // rgb: 200, 165, 220

		on_mob_life(var/mob/living/M)
			if(!M) M = holder.my_atom
			M.mutations = list()
			M.disabilities = 0
			M.sdisabilities = 0
			..()
			return

	thermite
		name = "Thermite"
		id = "thermite"
		description = "Thermite produces an aluminothermic reaction known as a thermite reaction. Can be used to melt walls."
		reagent_state = SOLID
		reagent_color = "#673910" // rgb: 103, 57, 16

		reaction_turf(var/turf/T, var/volume)
			src = null
			if(istype(T, /turf/simulated/wall))
				T:thermite = 1
				T.overlays = null
				T.overlays = image('effects.dmi',icon_state = "thermite")
			return

	mutagen
		name = "Unstable mutagen"
		id = "mutagen"
		description = "Might cause unpredictable mutations. Keep away from children."
		reagent_state = LIQUID
		reagent_color = "#13BC5E" // rgb: 19, 188, 94

		reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
			src = null
			if ( (method==TOUCH && prob(33)) || method==INGEST)
				randmuti(M)
				if(prob(90))
					randmutb(M)
				else
					randmutg(M)
				domutcheck(M, null, 1)
				updateappearance(M,M.dna.uni_identity)
			return
		on_mob_life(var/mob/living/M)
			if(!M) M = holder.my_atom
			M.radiation += 2
			..()
			return

	iron
		name = "Iron"
		id = "iron"
		description = "Pure iron is a metal."
		reagent_state = SOLID
		reagent_color = "#C8A5DC" // rgb: 200, 165, 220

	gold
		name = "Gold"
		id = "gold"
		description = "Gold is a dense, soft, shiny metal and the most malleable and ductile metal known."
		reagent_state = SOLID
		reagent_color = "#F7C430" // rgb: 247, 196, 48

	silver
		name = "Silver"
		id = "silver"
		description = "A soft, white, lustrous transition metal, it has the highest electrical conductivity of any element and the highest thermal conductivity of any metal."
		reagent_state = SOLID
		reagent_color = "#D0D0D0" // rgb: 208, 208, 208

	uranium
		name ="Uranium"
		id = "uranium"
		description = "A silvery-white metallic chemical element in the actinide series, weakly radioactive."
		reagent_state = SOLID
		reagent_color = "#B8B8C0" // rgb: 184, 184, 192

		on_mob_life(var/mob/living/M)
			if(!M) M = holder.my_atom
			M.radiation += 2
			..()
			return

	aluminium
		name = "Aluminium"
		id = "aluminium"
		description = "A silvery white and ductile member of the boron group of chemical elements."
		reagent_state = SOLID
		reagent_color = "#A8A8A8" // rgb: 168, 168, 168

	silicon
		name = "Silicon"
		id = "silicon"
		description = "A tetravalent metalloid, silicon is less reactive than its chemical analog carbon."
		reagent_state = SOLID
		reagent_color = "#A8A8A8" // rgb: 168, 168, 168

	fuel
		name = "Welding fuel"
		id = "fuel"
		description = "Required for welders. Flamable."
		reagent_state = LIQUID
		reagent_color = "#660000" // rgb: 102, 0, 0

		reaction_obj(var/obj/O, var/volume)
			src = null
			var/turf/the_turf = get_turf(O)
			var/datum/gas_mixture/napalm = new
			var/datum/gas/volatile_fuel/fuel = new
			fuel.moles = 15
			napalm.trace_gases += fuel
			the_turf.assume_air(napalm)
		reaction_turf(var/turf/T, var/volume)
			src = null
			var/datum/gas_mixture/napalm = new
			var/datum/gas/volatile_fuel/fuel = new
			fuel.moles = 15
			napalm.trace_gases += fuel
			T.assume_air(napalm)
			return
		on_mob_life(var/mob/living/M as mob)
			if(!M) M = holder.my_atom
			M.adjustToxLoss(1)
			..()
			return

	space_cleaner
		name = "Space cleaner"
		id = "cleaner"
		description = "A compound used to clean things. Now with 50% more sodium hypochlorite!"
		reagent_state = LIQUID
		reagent_color = "#A5F0EE" // rgb: 165, 240, 238

		reaction_obj(var/obj/O, var/volume)
			if(!O) return
			if(istype(O,/obj/effect/decal/cleanable))
				del(O)
			else
				O.clean_blood()
		reaction_turf(var/turf/T, var/volume)
			T.overlays = null
			T.clean_blood()
			for(var/obj/effect/decal/cleanable/C in src)
				del(C)
		reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
			M.clean_blood()
			if(istype(M, /mob/living/carbon))
				var/mob/living/carbon/C = M
				if(C.r_hand)
					C.r_hand.clean_blood()
				if(C.l_hand)
					C.l_hand.clean_blood()
				if(C.wear_mask)
					C.wear_mask.clean_blood()
				if(istype(M, /mob/living/carbon/human))
					if(C:w_uniform)
						C:w_uniform.clean_blood()
					if(C:wear_suit)
						C:wear_suit.clean_blood()
					if(C:shoes)
						C:shoes.clean_blood()
					if(C:gloves)
						C:gloves.clean_blood()
					if(C:glasses)
						C:glasses.clean_blood()
					if(C:head)
						C:head.clean_blood()
					if(C:back)
						C:back.clean_blood()
						C:update_clothing()

	leporazine
		name = "Leporazine"
		id = "leporazine"
		description = "Leporazine can be use to stabilize an individuals body temperature."
		reagent_state = LIQUID
		reagent_color = "#C8A5DC" // rgb: 200, 165, 220

		on_mob_life(var/mob/living/M as mob)
			if(!M) M = holder.my_atom
			if(M.bodytemperature > 310)
				M.bodytemperature = max(310, M.bodytemperature - (60))
			else if(M.bodytemperature < 311)
				M.bodytemperature = min(310, M.bodytemperature + (60))
			..()
			return

	cryptobiolin
		name = "Cryptobiolin"
		id = "cryptobiolin"
		description = "Cryptobiolin causes confusion and dizzyness."
		reagent_state = LIQUID
		reagent_color = "#C8A5DC" // rgb: 200, 165, 220

		on_mob_life(var/mob/living/M as mob)
			if(!M) M = holder.my_atom
			M.make_dizzy(1)
			if(!M.confused) M.confused = 1
			M.confused = max(M.confused, 20)
			holder.remove_reagent(src.id, 0.2)
			..()
			return

	lexorin
		name = "Lexorin"
		id = "lexorin"
		description = "Lexorin temporarily stops respiration. Causes tissue damage."
		reagent_state = LIQUID
		reagent_color = "#C8A5DC" // rgb: 200, 165, 220

		on_mob_life(var/mob/living/M)
			if(!M) M = holder.my_atom
			if(prob(20)) M:adjustBruteLoss(1)
			holder.remove_reagent(src.id, 0.4)
			return

	kelotane
		name = "Kelotane"
		id = "kelotane"
		description = "Kelotane is a drug used to treat burns."
		reagent_state = LIQUID
		reagent_color = "#C8A5DC" // rgb: 200, 165, 220

		on_mob_life(var/mob/living/M as mob)
			if(!M) M = holder.my_atom
			M.heal_organ_damage(0,2)
			..()
			return

	dermaline
		name = "Dermaline"
		id = "dermaline"
		description = "Dermaline is the next step in burn medication. Works twice as good as kelotane and enables the body to restore even the direst heat-damaged tissue."
		reagent_state = LIQUID
		reagent_color = "#C8A5DC" // rgb: 200, 165, 220

		on_mob_life(var/mob/living/M as mob)
			if(!M) M = holder.my_atom
			M.heal_organ_damage(0,3)
			..()
			return

	dexalin
		name = "Dexalin"
		id = "dexalin"
		description = "Dexalin is used in the treatment of oxygen deprivation."
		reagent_state = LIQUID
		reagent_color = "#C8A5DC" // rgb: 200, 165, 220

		on_mob_life(var/mob/living/M)
			if(!M) M = holder.my_atom
			M.adjustOxyLoss(-3)
			..()
			return

	dexalinp
		name = "Dexalin Plus"
		id = "dexalinp"
		description = "Dexalin Plus is used in the treatment of oxygen deprivation. Its highly effective."
		reagent_state = LIQUID
		reagent_color = "#C8A5DC"

		on_mob_life(var/mob/living/M)
			if(!M) M = holder.my_atom
			M:adjustOxyLoss(-max((M:oxyloss * 0.5), 4))
			..()
			return

	tricordrazine
		name = "Tricordrazine"
		id = "tricordrazine"
		description = "Tricordrazine is a highly potent stimulant, originally derived from cordrazine. Can be used to treat a wide range of injuries."
		reagent_state = LIQUID
		reagent_color = "#C8A5DC" // rgb: 200, 165, 220

		on_mob_life(var/mob/living/M)
			if(!M) M = holder.my_atom
			M.adjustOxyLoss(-1)
			M.heal_organ_damage(1,1)
			M.adjustToxLoss(-1)
			if(prob(20))
				M.adjustOxyLoss(-1)
				M.heal_organ_damage(1,1)
				M.adjustToxLoss(-1)
			..()
			return

	adminordrazine //An OP chemical for badmins
		name = "Adminordrazine"
		id = "adminordrazine"
		description = "It's magic. We don't have to explain it."
		reagent_state = LIQUID
		reagent_color = "#C8A5DC"

		on_mob_life(var/mob/living/M as mob)
			if(!M) M = holder.my_atom ///This can even heal dead people.
			M.radiation = 0
			M.adjustToxLoss(-5)
			if(holder.has_reagent("toxin"))
				holder.remove_reagent("toxin", 5)
			if(holder.has_reagent("stoxin"))
				holder.remove_reagent("stoxin", 5)
			if(holder.has_reagent("plasma"))
				holder.remove_reagent("plasma", 5)
			if(holder.has_reagent("sacid"))
				holder.remove_reagent("sacid", 5)
			if(holder.has_reagent("pacid"))
				holder.remove_reagent("pacid", 5)
			if(holder.has_reagent("cyanide"))
				holder.remove_reagent("cyanide", 5)
			if(holder.has_reagent("lexorin"))
				holder.remove_reagent("lexorin", 5)
			if(holder.has_reagent("amatoxin"))
				holder.remove_reagent("amatoxin", 5)
			if(holder.has_reagent("chloralhydrate"))
				holder.remove_reagent("chloralhydrate", 5)
			if(holder.has_reagent("carpotoxin"))
				holder.remove_reagent("carpotoxin", 5)
			if(holder.has_reagent("zombiepowder"))
				holder.remove_reagent("zombiepowder", 5)
			M.brainloss -= 3
			M.disabilities = 0
			M.eye_blurry = 0
			M.eye_blind = 0
			M.disabilities &= ~1
			M.dizziness = 0
			M.drowsyness = 0
			M.stuttering = 0
			M.confused = 0
			M.weakened=0
			M.stunned=0
			M.paralysis=0
			M.jitteriness = 0
			..()
			return

	synaptizine
		name = "Synaptizine"
		id = "synaptizine"
		description = "Synaptizine is used to treat neuroleptic shock. Can be used to help remove disabling symptoms such as paralysis."
		reagent_state = LIQUID
		reagent_color = "#C8A5DC" // rgb: 200, 165, 220

		on_mob_life(var/mob/living/M)
			if(!M) M = holder.my_atom
			M:drowsyness = max(M:drowsyness-5, 0)
			if(M:paralysis) M:paralysis = 0
			if(M:stunned) M:stunned = 0
			if(M:weakened) M:weakened = 0
			if(holder.has_reagent("LSD"))
				holder.remove_reagent("LSD", 5)
			M.hallucination = max(0, M.hallucination - 10)
			..()
			return

	impedrezene
		name = "Impedrezene"
		id = "impedrezene"
		description = "Impedrezene is a narcotic that impedes one's ability by slowing down the higher brain cell functions."
		reagent_state = LIQUID
		reagent_color = "#C8A5DC" // rgb: 200, 165, 220

		on_mob_life(var/mob/living/M)
			if(!M) M = holder.my_atom
			M:jitteriness = max(M:jitteriness-5,0)
			if(prob(80)) M:brainloss++
			if(prob(50)) M:drowsyness = max(M:drowsyness, 3)
			if(prob(10)) M:emote("drool")
			..()
			return

	hyronalin
		name = "Hyronalin"
		id = "hyronalin"
		description = "Hyronalin is a medicinal drug used to counter the effects of radiation poisoning."
		reagent_state = LIQUID
		reagent_color = "#C8A5DC"

		on_mob_life(var/mob/living/M)
			if(!M) M = holder.my_atom
			if(M:radiation) M:radiation--
			if(M:radiation && prob(50)) M:radiation--
			..()
			return

	arithrazine
		name = "Arithrazine"
		id = "arithrazine"
		description = "Arithrazine is an unstable medication used for the most extreme cases of radiation poisoning."
		reagent_state = LIQUID
		reagent_color = "#C8A5DC"

		on_mob_life(var/mob/living/M)
			if(!M) M = holder.my_atom
			M:radiation = max(M:radiation-7,0)
			if(M:toxloss && prob(50)) M:toxloss--
			if(prob(10)) M:adjustBruteLoss(1)
			..()
			return

	alkysine
		name = "Alkysine"
		id = "alkysine"
		description = "Alkysine is a drug used to lessen the damage to neurological tissue after a catastrophic injury. Can heal brain tissue."
		reagent_state = LIQUID
		reagent_color = "#C8A5DC"

		on_mob_life(var/mob/living/M)
			if(!M) M = holder.my_atom
			M.adjustBrainLoss(-3)
			..()
			return

	imidazoline
		name = "Imidazoline"
		id = "imidazoline"
		description = "Heals eye damage"
		reagent_state = LIQUID
		reagent_color = "#C8A5DC" // rgb: 200, 165, 220

		on_mob_life(var/mob/living/M as mob)
			if(!M) M = holder.my_atom
			if(!data) data = 1
			data++
			switch(data)
				if(1 to 5)
					M:eye_blurry = max(M:eye_blurry-5 , 0)
				if(5 to 10)
					M:eye_blind = max(M:eye_blind-5 , 0)
				if(10 to 20)
					M:eye_stat = max(M:eye_stat-5, 0)
				if(20 to INFINITY)
					M:disabilities &= ~1
					M:eye_stat = max(M:eye_stat-5, 0)
			..()
			return

	bicaridine
		name = "Bicaridine"
		id = "bicaridine"
		description = "Bicaridine is an analgesic medication and can be used to treat blunt trauma."
		reagent_state = LIQUID
		reagent_color = "#C8A5DC"

		on_mob_life(var/mob/living/M)
			if(!M) M = holder.my_atom
			M.adjustBruteLoss(-1)
			..()
			return

	hyperzine
		name = "Hyperzine"
		id = "hyperzine"
		description = "Hyperzine is a highly effective, long lasting, muscle stimulant."
		reagent_state = LIQUID
		reagent_color = "#C8A5DC"

		on_mob_life(var/mob/living/M)
			if(!M) M = holder.my_atom
			if(prob(2)) M:emote(pick("twitch","blink_r","shiver"))
			holder.remove_reagent(src.id, 0.2)
			return

	cryoxadone
		name = "Cryoxadone"
		id = "cryoxadone"
		description = "A chemical mixture with almost magical healing powers. Its main limitation is that the targets body temperature must be under 170K for it to metabolise correctly."
		reagent_state = LIQUID
		reagent_color = "#C8A5DC"

		on_mob_life(var/mob/living/M)
			if(!M) M = holder.my_atom
			if(M.bodytemperature < 170)
				M.adjustOxyLoss(-3)
				M.heal_organ_damage(3,3)
				M.adjustToxLoss(-3)
			..()
			return

	clonexadone
		name = "Clonexadone"
		id = "clonexadone"
		description = "A liquid compound similar to that used in the cloning process. Can be used to 'finish' clones that get ejected early when used in conjunction with a cryo tube."
		reagent_state = LIQUID
		reagent_color = "#C8A5DC" // rgb: 200, 165, 220

		on_mob_life(var/mob/living/M as mob)
			if(!M) M = holder.my_atom
			if(M.bodytemperature < 170)
				M.adjustOxyLoss(-4)
				M.heal_organ_damage(5,5)
				M.adjustToxLoss(-4)
				if(prob(5) && M.face_dmg)
					M.face_dmg = 0
					//M << "\blue You can feel your face again!"
			..()
			return

	spaceacillin
		name = "Spaceacillin"
		id = "spaceacillin"
		description = "An all-purpose antiviral agent."
		reagent_state = LIQUID
		reagent_color = "#C8A5DC"

	LSD
		name = "LSD"
		id = "LSD"
		description = "A powerful hallucinogen. Not a thing to be messed with."
		reagent_state = LIQUID
		reagent_color = "#B31008"

		on_mob_life(var/mob/living/M)
			if(!M) M = holder.my_atom
			M:hallucination += 5
			..()
			return

///////////////////////////////////////////////////////////////////////////////////////////////////////////////

	nanites
		name = "Nanomachines"
		id = "nanites"
		description = "Microscopic construction robots."
		reagent_state = LIQUID
		reagent_color = "#535E66"

		reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
			src = null
			if((prob(50) && method==TOUCH) || method==INGEST)
				M.contract_disease(new /datum/disease/robotic_transformation(0),1)

	xenomicrobes
		name = "Xenomicrobes"
		id = "xenomicrobes"
		description = "Microbes with an entirely alien cellular structure."
		reagent_state = LIQUID
		reagent_color = "#535E66"

		reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
			src = null
			if( (prob(50) && method==TOUCH) || method==INGEST)
				M.contract_disease(new /datum/disease/xeno_transformation(0),1)

	slimetoxin
		name = "Mutation Toxin"
		id = "mutationtoxin"
		description = "A corruptive toxin produced by slimes."
		reagent_state = LIQUID
		reagent_color = "#13BC5E" // rgb: 19, 188, 94

		on_mob_life(var/mob/living/M as mob)
			if(!M) M = holder.my_atom
			if(ishuman(M))
				var/mob/living/carbon/human/human = M
				if(human.dna.mutantrace == null)
					M << "\red Your flesh rapidly mutates!"
					human.dna.mutantrace = "slime"
					human.update_clothing()
			..()
			return

	aslimetoxin
		name = "Advanced Mutation Toxin"
		id = "amutationtoxin"
		description = "An advanced corruptive toxin produced by slimes."
		reagent_state = LIQUID
		reagent_color = "#13BC5E" // rgb: 19, 188, 94

		on_mob_life(var/mob/living/M as mob)
			if(!M) M = holder.my_atom
			if(istype(M, /mob/living/carbon) && M.stat != DEAD)
				M << "\red Your flesh rapidly mutates!"
				if(M.monkeyizing)	return
				M.monkeyizing = 1
				M.canmove = 0
				M.icon = null
				M.overlays.Cut()
				M.invisibility = 101

				for(var/obj/item/weapon/W in M)
					M.u_equip(W)

				M.clearHUD()
				var/mob/living/carbon/slime/new_mob = new /mob/living/carbon/slime(M.loc)
				new_mob.a_intent = "harm"
				if(M.mind)
					M.mind.transfer_to(new_mob)
				else
					new_mob.key = M.key
				del(M)
			..()
			return
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

//foam precursor

	fluorosurfactant
		name = "Fluorosurfactant"
		id = "fluorosurfactant"
		description = "A perfluoronated sulfonic acid that forms a foam when mixed with water."
		reagent_state = LIQUID
		reagent_color = "#9E6B38"


// metal foaming agent
// this is lithium hydride. Add other recipies (e.g. LiH + H2O -> LiOH + H2) eventually

	foaming_agent
		name = "Foaming agent"
		id = "foaming_agent"
		description = "A agent that yields metallic foam when mixed with light metal and a strong acid."
		reagent_state = SOLID
		reagent_color = "#664B63"

	ultraglue
		name = "Ulta Glue"
		id = "glue"
		description = "An extremely powerful bonding agent."

	diethylamine
		name = "Diethylamine"
		id = "diethylamine"
		description = "A secondary amine, mildly corrosive."
		reagent_state = LIQUID
		reagent_color = "#604030"

	ethylredoxrazine						// FUCK YOU, ALCOHOL
		name = "Ethylredoxrazine"
		id = "ethylredoxrazine"
		description = "A powerfuld oxidizer that reacts with ethanol."
		reagent_state = SOLID
		reagent_color = "#605048"

		on_mob_life(var/mob/living/M as mob)
			if(!M) M = holder.my_atom
			M.dizziness = 0
			M:drowsyness = 0
			M:confused = 0
			M.eye_blurry = 0
			..()
			return

	ammonia
		name = "Ammonia"
		id = "ammonia"
		description = "A caustic substance commonly used in fertilizer or household cleaners."
		reagent_state = GAS
		reagent_color = "#404030"

	diethylamine
		name = "Diethylamine"
		id = "diethylamine"
		description = "A secondary amine, mildly corrosive."
		reagent_state = LIQUID
		reagent_color = "#604030"

	sacid
		name = "Sulphuric acid"
		id = "sacid"
		description = "A strong mineral acid with the molecular formula H2SO4."
		reagent_state = LIQUID
		reagent_color = "#DB5008"

		on_mob_life(var/mob/living/M)
			if(!M) M = holder.my_atom

			if(prob(50)) M:toxloss++
			if(prob(50)) M.adjustFireLoss(1)
			..()
			return

		reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
			if(method == TOUCH)
				if(istype(M, /mob/living/carbon/human))
					if(M:wear_mask)
						del (M:wear_mask)
						M << "\red Your mask melts away but protects you from the acid!"
						return
					if(M:head)
						del (M:head)
						M << "\red Your helmet melts into uselessness but protects you from the acid!"
						return
					if(prob(20) && !M.face_dmg)
						var/datum/organ/external/affecting = M:organs["head"]
						if (affecting)
							affecting.take_damage(12, 0)
							M:UpdateDamage()
							M:UpdateDamageIcon()
							M:emote("scream")
							M << "\red Your face has become disfigured!"
							M.face_dmg = 1
					else
						M:adjustFireLoss(14)
			else
				M:adjustFireLoss(5 * max(1, volume / 10))

		reaction_obj(var/obj/O, var/volume)
			if(istype(O,/obj/item/weapon/ore/artifact))
				O:acid(volume)
				return
			if(istype(O,/obj/item) && prob(10) && !O.unacidable)
				var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(O.loc)
				I.desc = "Looks like this was \an [O] some time ago."
				for(var/mob/living/M in viewers(5, O))
					M << "\red \the [O] melts."
				del(O)

	pacid
		name = "Polytrinic acid"
		id = "pacid"
		description = "Polytrinic acid is a an extremely corrosive chemical substance."
		reagent_state = LIQUID
		reagent_color = "#8E18A9"

		on_mob_life(var/mob/living/M)
			if(!M) M = holder.my_atom

			if(prob(75)) M:toxloss++
			if(prob(75)) M.adjustFireLoss(1)
			..()
			return

		reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
			if(method == TOUCH)
				if(istype(M, /mob/living/carbon/human) && !M.face_dmg)
					if(M:wear_mask && !M:wear_mask.unacidable)
						del (M:wear_mask)
						M << "\red Your mask melts away!"
					if(M:head && !M:head.unacidable)
						del (M:head)
						M << "\red Your helmet melts into uselessness!"

					var/datum/organ/external/affecting = M:organs["head"]
					if (affecting)
						affecting.take_damage(20, 0)
						M:UpdateDamage()
						M:UpdateDamageIcon()
						M:emote("scream")
						M << "\red Your face has become disfigured!"
						M.face_dmg = 1
				else
					M:adjustFireLoss(22)
			else
				M:adjustFireLoss(5 * max(1, volume / 10))

		reaction_obj(var/obj/O, var/volume)
			if(istype(O,/obj/item/weapon/ore/artifact))
				O:acid(volume)
				return
			if(istype(O,/obj/item) && !O.unacidable)
				var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(O.loc)
				I.desc = "Looks like this was \an [O] some time ago."
				for(var/mob/living/M in viewers(5, O))
					M << "\red \the [O] melts."
				del(O)

	virusfood
		name = "Virus food"
		id = "virusfood"
		description = "A set of specially engineered food for the growth of viral cells"
		reagent_state = LIQUID
		nutriment_factor = 2 * REAGENTS_METABOLISM
		reagent_color = "#899613" // rgb: 137, 150, 19

		on_mob_life(var/mob/living/M as mob)
			if(!M) M = holder.my_atom
			M.nutrition += nutriment_factor
			..()
			return

	lipozine
		name = "Lipozine" // The anti-nutriment.
		id = "lipozine"
		description = "A chemical compound that causes a powerful fat-burning reaction."
		reagent_state = LIQUID
		nutriment_factor = 10 * REAGENTS_METABOLISM
		reagent_color = "#BBEDA4" // rgb: 187, 237, 164

		on_mob_life(var/mob/living/M as mob)
			if(!M) M = holder.my_atom
			M.nutrition -= nutriment_factor
			if(M.nutrition < 0)//Prevent from going into negatives.
				M.nutrition = 0
			..()
			return

	condensedcapsaicin
		name = "Condensed Capsaicin"
		id = "condensedcapsaicin"
		description = "A chemical agent used for self-defense and in police work."
		reagent_state = LIQUID
		reagent_color = "#B31008" // rgb: 179, 16, 8

		on_mob_life(var/mob/living/M as mob)
			if(!M) M = holder.my_atom
			if(!data) data = 1
			switch(data)
				if(1 to 15)
					M.bodytemperature += 5 * TEMPERATURE_DAMAGE_COEFFICIENT
					if(holder.has_reagent("frostoil"))
						holder.remove_reagent("frostoil", 5)
					if(istype(M, /mob/living/carbon/slime))
						M.bodytemperature += rand(5,20)
				if(15 to 25)
					M.bodytemperature += 10 * TEMPERATURE_DAMAGE_COEFFICIENT
					if(istype(M, /mob/living/carbon/slime))
						M.bodytemperature += rand(10,20)
				if(25 to INFINITY)
					M.bodytemperature += 15 * TEMPERATURE_DAMAGE_COEFFICIENT
					if(istype(M, /mob/living/carbon/slime))
						M.bodytemperature += rand(15,20)
			data++
			..()
			return

		reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
			if(!istype(M, /mob/living))
				return
			if(method == TOUCH)
				if(istype(M, /mob/living/carbon/human))
					var/mob/living/carbon/human/victim = M
					var/mouth_covered = 0
					var/eyes_covered = 0
					var/obj/item/safe_thing = null
					if( victim.wear_mask )
						if ( victim.wear_mask.flags & MASKCOVERSEYES )
							eyes_covered = 1
							safe_thing = victim.wear_mask
						if ( victim.wear_mask.flags & MASKCOVERSMOUTH )
							mouth_covered = 1
							safe_thing = victim.wear_mask
					if( victim.head )
						if ( victim.head.flags & MASKCOVERSEYES )
							eyes_covered = 1
							safe_thing = victim.head
						if ( victim.head.flags & MASKCOVERSMOUTH )
							mouth_covered = 1
							safe_thing = victim.head
					if(victim.glasses)
						eyes_covered = 1
						if ( !safe_thing )
							safe_thing = victim.glasses
					if ( eyes_covered && mouth_covered )
						return
					else if(mouth_covered)	// Reduced effects if partially protected
						if(prob(10)) victim.emote("scream")
						victim.eye_blurry = max(M.eye_blurry, 4)
						victim.eye_blind = max(M.eye_blind, 1)
						victim.confused = max(M.confused, 4)
						victim.Weaken(2)
						victim.drop_item()
						return
					else if(eyes_covered) // Eye cover is better than mouth cover
						victim.eye_blurry = max(M.eye_blurry, 3)
						return
					else // Oh dear :D
						if(prob(20)) victim.emote("scream")
						victim.eye_blurry = max(M.eye_blurry, 8)
						victim.eye_blind = max(M.eye_blind, 2)
						victim.confused = max(M.confused, 8)
						victim.Weaken(5)
						victim.drop_item()