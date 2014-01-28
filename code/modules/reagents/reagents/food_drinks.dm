//////////////
/// DRINKS ///
//////////////

/datum/reagent
	orangejuice
		name = "Orange juice"
		id = "orangejuice"
		description = "Both delicious AND rich in Vitamin C, what more do you need?"
		reagent_state = LIQUID
		nutriment_factor = 1 * REAGENTS_METABOLISM
		reagent_color = "#E78108" // rgb: 231, 129, 8

		on_mob_life(var/mob/living/M as mob)
			M.nutrition += nutriment_factor
			if(!M) M = holder.my_atom
			if(M.getOxyLoss() && prob(30)) M.adjustOxyLoss(-1)
			M.nutrition++
			..()
			return

	tomatojuice
		name = "Tomato Juice"
		id = "tomatojuice"
		description = "Tomatoes made into juice. What a waste of big, juicy tomatoes, huh?"
		reagent_state = LIQUID
		nutriment_factor = 1 * REAGENTS_METABOLISM
		reagent_color = "#731008" // rgb: 115, 16, 8

		on_mob_life(var/mob/living/M as mob)
			M.nutrition += nutriment_factor
			if(!M) M = holder.my_atom
			if(M.getFireLoss() && prob(20)) M.heal_organ_damage(0,1)
			M.nutrition++
			..()
			return

	limejuice
		name = "Lime Juice"
		id = "limejuice"
		description = "The sweet-sour juice of limes."
		reagent_state = LIQUID
		nutriment_factor = 1 * REAGENTS_METABOLISM
		reagent_color = "#365E30" // rgb: 54, 94, 48

		on_mob_life(var/mob/living/M as mob)
			M.nutrition += nutriment_factor
			if(!M) M = holder.my_atom
			if(M.getToxLoss() && prob(20)) M.adjustToxLoss(-1)
			M.nutrition++
			..()
			return

	carrotjuice
		name = "Carrot juice"
		id = "carrotjuice"
		description = "It is just like a carrot but without crunching."
		reagent_state = LIQUID
		nutriment_factor = 1 * REAGENTS_METABOLISM
		reagent_color = "#973800" // rgb: 151, 56, 0

		on_mob_life(var/mob/living/M as mob)
			if(!M) M = holder.my_atom
			M.nutrition += nutriment_factor
			M.eye_blurry = max(M.eye_blurry-1 , 0)
			M.eye_blind = max(M.eye_blind-1 , 0)
			if(!data) data = 1
			switch(data)
				if(1 to 20)
					M.eye_stat--
				if(21 to INFINITY)
					if (prob(data-15))
						M.disabilities &= ~BLIND
			data++
			..()
			return

	berryjuice
		name = "Berry Juice"
		id = "berryjuice"
		description = "A delicious blend of several different kinds of berries."
		reagent_state = LIQUID
		nutriment_factor = 1 * REAGENTS_METABOLISM
		reagent_color = "#863333" // rgb: 134, 51, 51

		on_mob_life(var/mob/living/M as mob)
			if(!M) M = holder.my_atom
			M.nutrition += nutriment_factor
			..()
			return

	poisonberryjuice
		name = "Poison Berry Juice"
		id = "poisonberryjuice"
		description = "A tasty juice blended from various kinds of very deadly and toxic berries."
		reagent_state = LIQUID
		nutriment_factor = 1 * REAGENTS_METABOLISM
		reagent_color = "#863353" // rgb: 134, 51, 83

		on_mob_life(var/mob/living/M as mob)
			if(!M) M = holder.my_atom
			M.nutrition += nutriment_factor
			M.adjustToxLoss(1)
			..()
			return

	watermelonjuice
		name = "Watermelon Juice"
		id = "watermelonjuice"
		description = "Delicious juice made from watermelon."
		reagent_state = LIQUID
		nutriment_factor = 1 * REAGENTS_METABOLISM
		reagent_color = "#863333" // rgb: 134, 51, 51

		on_mob_life(var/mob/living/M as mob)
			if(!M) M = holder.my_atom
			M.nutrition += nutriment_factor
			..()
			return

	lemonjuice
		name = "Lemon Juice"
		id = "lemonjuice"
		description = "This juice is VERY sour."
		reagent_state = LIQUID
		nutriment_factor = 1 * REAGENTS_METABOLISM
		reagent_color = "#863333" // rgb: 175, 175, 0

		on_mob_life(var/mob/living/M as mob)
			if(!M) M = holder.my_atom
			M.nutrition += nutriment_factor
			..()
			return

	banana
		name = "Banana Juice"
		id = "banana"
		description = "The raw essence of a banana. HONK"
		nutriment_factor = 1 * REAGENTS_METABOLISM
		reagent_color = "#863333" // rgb: 175, 175, 0

		on_mob_life(var/mob/living/M as mob)
			M.nutrition += nutriment_factor
			if(istype(M, /mob/living/carbon/human) && M.job in list("Clown"))
				if(!M) M = holder.my_atom
				M.heal_organ_damage(1,1)
				..()
				return
			if(istype(M, /mob/living/carbon/monkey))
				if(!M) M = holder.my_atom
				M.heal_organ_damage(1,1)
				..()
				return
			..()

	nothing
		name = "Nothing"
		id = "nothing"
		description = "Absolutely nothing."
		nutriment_factor = 1 * REAGENTS_METABOLISM
		on_mob_life(var/mob/living/M as mob)
			M.nutrition += nutriment_factor
			M.silent += 2

			if(istype(M, /mob/living/carbon/human) && M.job in list("Mime"))
				if(!M) M = holder.my_atom
				M.heal_organ_damage(1,1)
				..()
				return
			..()

	potato_juice
		name = "Potato Juice"
		id = "potato"
		description = "Juice of the potato. Bleh."
		reagent_state = LIQUID
		nutriment_factor = 2 * REAGENTS_METABOLISM
		reagent_color = "#302000" // rgb: 48, 32, 0

		on_mob_life(var/mob/living/M as mob)
			M.nutrition += nutriment_factor
			..()
			return

	milk
		name = "Milk"
		id = "milk"
		description = "An opaque white liquid produced by the mammary glands of mammals."
		reagent_state = LIQUID
		reagent_color = "#DFDFDF" // rgb: 223, 223, 223

		on_mob_life(var/mob/living/M as mob)
			if(!M) M = holder.my_atom
			if(M.getBruteLoss() && prob(20)) M.heal_organ_damage(1,0)
			if(holder.has_reagent("capsaicin"))
				holder.remove_reagent("capsaicin", 2)
			M.nutrition++
			..()
			return

	soymilk
		name = "Soy Milk"
		id = "soymilk"
		description = "An opaque white liquid made from soybeans."
		reagent_state = LIQUID
		reagent_color = "#DFDFC7" // rgb: 223, 223, 199

		on_mob_life(var/mob/living/M as mob)
			if(!M) M = holder.my_atom
			if(M.getBruteLoss() && prob(20)) M.heal_organ_damage(1,0)
			M.nutrition++
			..()
			return

	cream
		name = "Cream"
		id = "cream"
		description = "The fatty, still liquid part of milk. Why don't you mix this with sum scotch, eh?"
		reagent_state = LIQUID
		nutriment_factor = 1 * REAGENTS_METABOLISM
		reagent_color = "#DFD7AF" // rgb: 223, 215, 175

		on_mob_life(var/mob/living/M as mob)
			M.nutrition += nutriment_factor
			if(M.getBruteLoss() && prob(20)) M.heal_organ_damage(1,0)
			..()
			return

	coffee
		name = "Coffee"
		id = "coffee"
		description = "Coffee is a brewed drink prepared from roasted seeds, commonly called coffee beans, of the coffee plant."
		reagent_state = LIQUID
		reagent_color = "#482000" // rgb: 72, 32, 0

		on_mob_life(var/mob/living/M as mob)
			..()
			M.dizziness = max(0,M.dizziness-5)
			M.drowsyness = max(0,M.drowsyness-3)
			M.sleeping = max(0,M.sleeping - 2)
			if (M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
				M.bodytemperature = min(310, M.bodytemperature + (35 * TEMPERATURE_DAMAGE_COEFFICIENT))

			if(prob(20)) M.make_jittery(1)

			if(holder.has_reagent("frostoil"))
				holder.remove_reagent("frostoil", 5)
			..()
			return

	tea
		name = "Tea"
		id = "tea"
		description = "Tasty black tea, it has antioxidants, it's good for you!"
		reagent_state = LIQUID
		reagent_color = "#101000" // rgb: 16, 16, 0

		on_mob_life(var/mob/living/M as mob)
			..()
			M.dizziness = max(0,M.dizziness-2)
			M.drowsyness = max(0,M.drowsyness-1)
			M.jitteriness = max(0,M.jitteriness-3)
			M.sleeping = max(0,M.sleeping-1)
			if(M.getToxLoss() && prob(20))
				M.adjustToxLoss(-1)
			if (M.bodytemperature < 310)  //310 is the normal bodytemp. 310.055
				M.bodytemperature = min(310, M.bodytemperature + (30 * TEMPERATURE_DAMAGE_COEFFICIENT))
			..()
			return

	icecoffee
		name = "Iced Coffee"
		id = "icecoffee"
		description = "Coffee and ice, refreshing and cool."
		reagent_state = LIQUID
		reagent_color = "#102838" // rgb: 16, 40, 56

		on_mob_life(var/mob/living/M as mob)
			..()
			M.dizziness = max(0,M.dizziness-5)
			M.drowsyness = max(0,M.drowsyness-3)
			M.sleeping = max(0,M.sleeping-2)
			if (M.bodytemperature > 310)//310 is the normal bodytemp. 310.055
				M.bodytemperature = max(310, M.bodytemperature - (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
			M.make_jittery(5)
			..()
			return

	icetea
		name = "Iced Tea"
		id = "icetea"
		description = "No relation to a certain rap artist/ actor."
		reagent_state = LIQUID
		reagent_color = "#104038" // rgb: 16, 64, 56

		on_mob_life(var/mob/living/M as mob)
			..()
			M.dizziness = max(0,M.dizziness-2)
			M.drowsyness = max(0,M.drowsyness-1)
			M.sleeping = max(0,M.sleeping-2)
			if(M.getToxLoss() && prob(20))
				M.adjustToxLoss(-1)
			if (M.bodytemperature > 310)//310 is the normal bodytemp. 310.055
				M.bodytemperature = max(310, M.bodytemperature - (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
			return

	space_cola
		name = "Cola"
		id = "cola"
		description = "A refreshing beverage."
		reagent_state = LIQUID
		reagent_color = "#100800" // rgb: 16, 8, 0

		on_mob_life(var/mob/living/M as mob)
			M.drowsyness = max(0,M.drowsyness-5)
			if (M.bodytemperature > 310)//310 is the normal bodytemp. 310.055
				M.bodytemperature = max(310, M.bodytemperature - (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
			M.nutrition += 1
			..()
			return

	nuka_cola
		name = "Nuka Cola"
		id = "nuka_cola"
		description = "Cola, cola never changes."
		reagent_state = LIQUID
		reagent_color = "#100800" // rgb: 16, 8, 0

		on_mob_life(var/mob/living/M as mob)
			M.make_jittery(20)
			M.druggy = max(M.druggy, 30)
			M.dizziness +=5
			M.drowsyness = 0
			M.sleeping = max(0,M.sleeping-2)
			if (M.bodytemperature > 310)//310 is the normal bodytemp. 310.055
				M.bodytemperature = max(310, M.bodytemperature - (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
			M.nutrition += 1
			..()
			return

	spacemountainwind
		name = "Space Mountain Wind"
		id = "spacemountainwind"
		description = "Blows right through you like a space wind."
		reagent_state = LIQUID
		reagent_color = "#102000" // rgb: 16, 32, 0

		on_mob_life(var/mob/living/M as mob)
			M.drowsyness = max(0,M.drowsyness-7)
			M.sleeping = max(0,M.sleeping-1)
			if (M.bodytemperature > 310)
				M.bodytemperature = max(310, M.bodytemperature - (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
			M.make_jittery(5)
			M.nutrition += 1
			..()
			return

	dr_gibb
		name = "Dr. Gibb"
		id = "dr_gibb"
		description = "A delicious blend of 42 different flavours"
		reagent_state = LIQUID
		reagent_color = "#102000" // rgb: 16, 32, 0

		on_mob_life(var/mob/living/M as mob)
			M.drowsyness = max(0,M.drowsyness-6)
			if (M.bodytemperature > 310)
				M.bodytemperature = max(310, M.bodytemperature - (5 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
			M.nutrition += 1
			..()
			return

	space_up
		name = "Space-Up"
		id = "space_up"
		description = "Tastes like a hull breach in your mouth."
		reagent_state = LIQUID
		reagent_color = "#00FF00" // rgb: 0, 255, 0

		on_mob_life(var/mob/living/M as mob)
			if (M.bodytemperature > 310)
				M.bodytemperature = max(310, M.bodytemperature - (8 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
			M.nutrition += 1
			..()
			return

	lemon_lime
		name = "Lemon Lime"
		description = "A tangy substance made of 0.5% natural citrus!"
		id = "lemon_lime"
		reagent_state = LIQUID
		reagent_color = "#8CFF00" // rgb: 135, 255, 0

		on_mob_life(var/mob/living/M as mob)
			if (M.bodytemperature > 310)
				M.bodytemperature = max(310, M.bodytemperature - (8 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
			M.nutrition += 1
			..()
			return

	sodawater
		name = "Soda Water"
		id = "sodawater"
		description = "A can of club soda. Why not make a scotch and soda?"
		reagent_state = LIQUID
		reagent_color = "#619494" // rgb: 97, 148, 148

		on_mob_life(var/mob/living/M as mob)
			M.dizziness = max(0,M.dizziness-5)
			M.drowsyness = max(0,M.drowsyness-3)
			if (M.bodytemperature > 310)
				M.bodytemperature = max(310, M.bodytemperature - (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
			..()
			return

	tonic
		name = "Tonic Water"
		id = "tonic"
		description = "It tastes strange but at least the quinine keeps the Space Malaria at bay."
		reagent_state = LIQUID
		reagent_color = "#0064C8" // rgb: 0, 100, 200

		on_mob_life(var/mob/living/M as mob)
			M.dizziness = max(0,M.dizziness-5)
			M.drowsyness = max(0,M.drowsyness-3)
			M.sleeping = max(0,M.sleeping-2)
			if (M.bodytemperature > 310)
				M.bodytemperature = max(310, M.bodytemperature - (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
			..()
			return

	ice
		name = "Ice"
		id = "ice"
		description = "Frozen water, your dentist wouldn't like you chewing this."
		reagent_state = SOLID
		reagent_color = "#619494" // rgb: 97, 148, 148

		on_mob_life(var/mob/living/M as mob)
			if(!M) M = holder.my_atom
			M.bodytemperature -= 5 * TEMPERATURE_DAMAGE_COEFFICIENT
			..()
			return

	soy_latte
		name = "Soy Latte"
		id = "soy_latte"
		description = "A nice and tasty beverage while you are reading your hippie books."
		reagent_state = LIQUID
		reagent_color = "#664300" // rgb: 102, 67, 0

		on_mob_life(var/mob/living/M as mob)
			..()
			M.dizziness = max(0,M.dizziness-5)
			M.drowsyness = max(0,M.drowsyness-3)
			M.sleeping = 0
			if (M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
				M.bodytemperature = min(310, M.bodytemperature + (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
			M.make_jittery(5)
			if(M.getBruteLoss() && prob(20)) M.heal_organ_damage(1,0)
			M.nutrition++
			..()
			return

	cafe_latte
		name = "Cafe Latte"
		id = "cafe_latte"
		description = "A nice, strong and tasty beverage while you are reading."
		reagent_state = LIQUID
		reagent_color = "#664300" // rgb: 102, 67, 0

		on_mob_life(var/mob/living/M as mob)
			..()
			M.dizziness = max(0,M.dizziness-5)
			M.drowsyness = max(0,M.drowsyness-3)
			M.sleeping = 0
			if (M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
				M.bodytemperature = min(310, M.bodytemperature + (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
			M.make_jittery(5)
			if(M.getBruteLoss() && prob(20)) M.heal_organ_damage(1,0)
			M.nutrition++
			..()
			return

	doctor_delight
		name = "The Doctor's Delight"
		id = "doctorsdelight"
		description = "A gulp a day keeps the MediBot away. That's probably for the best."
		reagent_state = LIQUID
		reagent_color = "#FF8CFF" // rgb: 255, 140, 255

		on_mob_life(var/mob/living/M as mob)
			if(!M) M = holder.my_atom
			if(M.getOxyLoss() && prob(90)) M.adjustOxyLoss(-2)
			if(M.getBruteLoss() && prob(90)) M.heal_organ_damage(2,0)
			if(M.getFireLoss() && prob(90)) M.heal_organ_damage(0,2)
			if(M.getToxLoss() && prob(90)) M.adjustToxLoss(-2)
			if(M.dizziness !=0) M.dizziness = max(0,M.dizziness-15)
			if(M.confused !=0) M.confused = max(0,M.confused - 5)
			..()
			return

////////////
/// FOOD ///
////////////

	nutriment
		name = "Nutriment"
		id = "nutriment"
		description = "All the vitamins, minerals, and carbohydrates the body needs in pure form."
		reagent_state = SOLID
		nutriment_factor = 15 * REAGENTS_METABOLISM
		reagent_color = "#664330" // rgb: 102, 67, 48

		on_mob_life(var/mob/living/M as mob)
			if(!M) M = holder.my_atom
			if(prob(50)) M.heal_organ_damage(1,0)
			M.nutrition += nutriment_factor	// For hunger and fatness
			..()
			return

	soysauce
		name = "Soysauce"
		id = "soysauce"
		description = "A salty sauce made from the soy plant."
		reagent_state = LIQUID
		nutriment_factor = 2 * REAGENTS_METABOLISM
		reagent_color = "#792300" // rgb: 121, 35, 0

	ketchup
		name = "Ketchup"
		id = "ketchup"
		description = "Ketchup, catsup, whatever. It's tomato paste."
		reagent_state = LIQUID
		nutriment_factor = 5 * REAGENTS_METABOLISM
		reagent_color = "#731008" // rgb: 115, 16, 8


	capsaicin
		name = "Capsaicin Oil"
		id = "capsaicin"
		description = "This is what makes chilis hot."
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

	frostoil
		name = "Frost Oil"
		id = "frostoil"
		description = "A special oil that noticably chills the body. Extraced from Icepeppers."
		reagent_state = LIQUID
		reagent_color = "#B31008" // rgb: 139, 166, 233

		on_mob_life(var/mob/living/M as mob)
			if(!M) M = holder.my_atom
			if(!data) data = 1
			switch(data)
				if(1 to 15)
					M.bodytemperature -= 5 * TEMPERATURE_DAMAGE_COEFFICIENT
					if(holder.has_reagent("capsaicin"))
						holder.remove_reagent("capsaicin", 5)
					if(istype(M, /mob/living/carbon/slime))
						M.bodytemperature -= rand(5,20)
				if(15 to 25)
					M.bodytemperature -= 10 * TEMPERATURE_DAMAGE_COEFFICIENT
					if(istype(M, /mob/living/carbon/slime))
						M.bodytemperature -= rand(10,20)
				if(25 to INFINITY)
					M.bodytemperature -= 15 * TEMPERATURE_DAMAGE_COEFFICIENT
					if(prob(1)) M.emote("shiver")
					if(istype(M, /mob/living/carbon/slime))
						M.bodytemperature -= rand(15,20)
			data++
			..()
			return

		reaction_turf(var/turf/simulated/T, var/volume)
			for(var/mob/living/carbon/slime/M in T)
				M.adjustToxLoss(rand(15,30))

	sodiumchloride
		name = "Table Salt"
		id = "sodiumchloride"
		description = "A salt made of sodium chloride. Commonly used to season food."
		reagent_state = SOLID
		reagent_color = "#FFFFFF" // rgb: 255,255,255

	blackpepper
		name = "Black Pepper"
		id = "blackpepper"
		description = "A powder ground from peppercorns. *AAAACHOOO*"
		reagent_state = SOLID
		// no reagent_color (ie, black)

	coco
		name = "Coco Powder"
		id = "coco"
		description = "A fatty, bitter paste made from coco beans."
		reagent_state = SOLID
		nutriment_factor = 5 * REAGENTS_METABOLISM
		reagent_color = "#302000" // rgb: 48, 32, 0

		on_mob_life(var/mob/living/M as mob)
			M.nutrition += nutriment_factor
			..()
			return

	hot_coco
		name = "Hot Chocolate"
		id = "hot_coco"
		description = "Made with love! And coco beans."
		reagent_state = LIQUID
		nutriment_factor = 2 * REAGENTS_METABOLISM
		reagent_color = "#403010" // rgb: 64, 48, 16

		on_mob_life(var/mob/living/M as mob)
			if (M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
				M.bodytemperature = min(310, M.bodytemperature + (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
			M.nutrition += nutriment_factor
			..()
			return

	psilocybin
		name = "Psilocybin"
		id = "psilocybin"
		description = "A strong psycotropic derived from certain species of mushroom."
		reagent_color = "#E700E7" // rgb: 231, 0, 231

		on_mob_life(var/mob/living/M as mob)
			if(!M) M = holder.my_atom
			M.druggy = max(M.druggy, 30)
			if(!data) data = 1
			switch(data)
				if(1 to 5)
					if (!M.stuttering) M.stuttering = 1
					M.make_dizzy(5)
					if(prob(10)) M.emote(pick("twitch","giggle"))
				if(5 to 10)
					if (!M.stuttering) M.stuttering = 1
					M.make_jittery(10)
					M.make_dizzy(10)
					M.druggy = max(M.druggy, 35)
					if(prob(20)) M.emote(pick("twitch","giggle"))
				if (10 to INFINITY)
					if (!M.stuttering) M.stuttering = 1
					M.make_jittery(20)
					M.make_dizzy(20)
					M.druggy = max(M.druggy, 40)
					if(prob(30)) M.emote(pick("twitch","giggle"))
			holder.remove_reagent(src.id, 0.2)
			data++
			..()
			return

	sprinkles
		name = "Sprinkles"
		id = "sprinkles"
		description = "Multi-reagent_colored little bits of sugar, commonly found on donuts. Loved by cops."
		nutriment_factor = 1 * REAGENTS_METABOLISM
		reagent_color = "#FF00FF" // rgb: 255, 0, 255

		on_mob_life(var/mob/living/M as mob)
			M.nutrition += nutriment_factor
			if(istype(M, /mob/living/carbon/human) && M.job in list("Security Officer", "Head of Security", "Detective", "Warden"))
				if(!M) M = holder.my_atom
				M.heal_organ_damage(1,1)
				M.nutrition += nutriment_factor
				..()
				return
			..()

	syndicream
		name = "Cream filling"
		id = "syndicream"
		description = "Delicious cream filling of a mysterious origin. Tastes criminally good."
		nutriment_factor = 1 * REAGENTS_METABOLISM
		reagent_color = "#AB7878" // rgb: 171, 120, 120

		on_mob_life(var/mob/living/M as mob)
			M.nutrition += nutriment_factor
			if(istype(M, /mob/living/carbon/human) && M.mind)
				if(M.mind.special_role)
					if(!M) M = holder.my_atom
					M.heal_organ_damage(2,2)
					M.nutrition += nutriment_factor
					..()
					return
			..()

	cornoil
		name = "Corn Oil"
		id = "cornoil"
		description = "An oil derived from various types of corn."
		reagent_state = LIQUID
		nutriment_factor = 20 * REAGENTS_METABOLISM
		reagent_color = "#302000" // rgb: 48, 32, 0

		on_mob_life(var/mob/living/M as mob)
			M.nutrition += nutriment_factor
			..()
			return
		reaction_turf(var/turf/simulated/T, var/volume)
			if (!istype(T)) return
			src = null
			if(volume >= 3)
				if(T.wet >= 1) return
				T.wet = 1
				if(T.wet_overlay)
					T.overlays -= T.wet_overlay
					T.wet_overlay = null
				T.wet_overlay = image('icons/effects/water.dmi',T,"wet_floor")
				T.overlays += T.wet_overlay

				spawn(800)
					if (!istype(T)) return
					if(T.wet >= 2) return
					T.wet = 0
					if(T.wet_overlay)
						T.overlays -= T.wet_overlay
						T.wet_overlay = null
			var/hotspot = (locate(/obj/effect/hotspot) in T)
			if(hotspot)
				var/datum/gas_mixture/lowertemp = T.remove_air( T:air:total_moles() )
				lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
				lowertemp.react()
				T.assume_air(lowertemp)
				del(hotspot)

	enzyme
		name = "Universal Enzyme"
		id = "enzyme"
		description = "A universal enzyme used in the preperation of certain chemicals and foods."
		reagent_state = LIQUID
		reagent_color = "#365E30" // rgb: 54, 94, 48

	dry_ramen
		name = "Dry Ramen"
		id = "dry_ramen"
		description = "Space age food, since August 25, 1958. Contains dried noodles, vegetables, and chemicals that boil in contact with water."
		reagent_state = SOLID
		nutriment_factor = 1 * REAGENTS_METABOLISM
		reagent_color = "#302000" // rgb: 48, 32, 0

		on_mob_life(var/mob/living/M as mob)
			M.nutrition += nutriment_factor
			..()
			return

	hot_ramen
		name = "Hot Ramen"
		id = "hot_ramen"
		description = "The noodles are boiled, the flavors are artificial, just like being back in school."
		reagent_state = LIQUID
		nutriment_factor = 5 * REAGENTS_METABOLISM
		reagent_color = "#302000" // rgb: 48, 32, 0

		on_mob_life(var/mob/living/M as mob)
			M.nutrition += nutriment_factor
			if (M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
				M.bodytemperature = min(310, M.bodytemperature + (10 * TEMPERATURE_DAMAGE_COEFFICIENT))
			..()
			return

	hell_ramen
		name = "Hell Ramen"
		id = "hell_ramen"
		description = "The noodles are boiled, the flavors are artificial, just like being back in school."
		reagent_state = LIQUID
		nutriment_factor = 5 * REAGENTS_METABOLISM
		reagent_color = "#302000" // rgb: 48, 32, 0

		on_mob_life(var/mob/living/M as mob)
			M.nutrition += nutriment_factor
			M.bodytemperature += 10 * TEMPERATURE_DAMAGE_COEFFICIENT
			..()
			return

	flour
		name = "flour"
		id = "flour"
		description = "This is what you rub all over yourself to pretend to be a ghost."
		reagent_state = SOLID
		nutriment_factor = 1 * REAGENTS_METABOLISM
		reagent_color = "#FFFFFF" // rgb: 0, 0, 0

		on_mob_life(var/mob/living/M as mob)
			M.nutrition += nutriment_factor
			..()
			return

		reaction_turf(var/turf/T, var/volume)
			src = null
			if(!istype(T, /turf/space))
				new /obj/effect/decal/cleanable/flour(T)

	cherryjelly
		name = "Cherry Jelly"
		id = "cherryjelly"
		description = "Totally the best. Only to be spread on foods with excellent lateral symmetry."
		reagent_state = LIQUID
		nutriment_factor = 1 * REAGENTS_METABOLISM
		reagent_color = "#801E28" // rgb: 128, 30, 40

		on_mob_life(var/mob/living/M as mob)
			M.nutrition += nutriment_factor
			..()
			return