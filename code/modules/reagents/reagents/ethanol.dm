///////////////////////////////////////////////ALHO///////////////////////////////////////////////////////////
/////////////////////////////The ten friggen million reagents that get you drunk//////////////////////////////


/datum/reagent/ethanol
	name = "Ethanol"
	id = "ethanol"
	description = "A well-known alcohol with a variety of applications."
	reagent_state = LIQUID
	reagent_color = "#404030" // rgb: 64, 64, 48
	var/boozepwr = 35 //lower numbers mean the booze will have an effect faster.

	on_mob_life(var/mob/living/M as mob)
		if(!data) data = 1
		data++
		M.jitteriness = max(M.jitteriness-5,0)
		if(data >= boozepwr)
			if (!M.intoxicated) M.intoxicated = 1
			M.intoxicated += 4
			M.make_dizzy(5)
		if(data >= boozepwr*2.5 && prob(33))
			if (!M.confused) M.confused = 1
			M.confused += 3
		..()
		return

	beer
		name = "Beer"
		id = "beer"
		description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
		reagent_color = "#664300" // rgb: 102, 67, 0
		boozepwr = 55

		on_mob_life(var/mob/living/M as mob)
			M.nutrition += 1
			..()
			return

	kahlua
		name = "Kahlua"
		id = "kahlua"
		description = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936!"
		reagent_color = "#664300" // rgb: 102, 67, 0

		on_mob_life(var/mob/living/M as mob)
			M.dizziness = max(0,M.dizziness-5)
			M.drowsyness = max(0,M.drowsyness-3)
			M.sleeping = max(0,M.sleeping-2)
			M.make_jittery(5)
			..()
			return

	whiskey
		name = "Whiskey"
		id = "whiskey"
		description = "A superb and well-aged single-malt whiskey. Damn."
		reagent_color = "#664300" // rgb: 102, 67, 0

	thirteenloko
		name = "Thirteen Loko"
		id = "thirteenloko"
		description = "A potent mixture of caffeine and alcohol."
		reagent_color = "#102000" // rgb: 16, 32, 0

		on_mob_life(var/mob/living/M as mob)
			M.drowsyness = max(0,M.drowsyness-7)
			M.sleeping = max(0,M.sleeping-2)
			if (M.bodytemperature > 310)
				M.bodytemperature = max(310, M.bodytemperature - (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
			M.make_jittery(5)
			M.nutrition += 1
			..()
			return

	vodka
		name = "Vodka"
		id = "vodka"
		description = "Number one drink AND fueling choice for Russians worldwide."
		reagent_color = "#0064C8" // rgb: 0, 100, 200

		on_mob_life(var/mob/living/M as mob)
			M.radiation = max(M.radiation-2,0)
			..()
			return

	holywater
		name = "Holy Water"
		id = "holywater"
		description = "Water blessed by some deity."
		reagent_color = "#E0E8EF" // rgb: 224, 232, 239
		boozepwr = 15

	bilk
		name = "Bilk"
		id = "bilk"
		description = "This appears to be beer mixed with milk. Disgusting."
		reagent_color = "#895C4C" // rgb: 137, 92, 76

		on_mob_life(var/mob/living/M as mob)
			if(M.getBruteLoss() && prob(10)) M.heal_organ_damage(1,0)
			M.nutrition += 2
			..()
			return

	threemileisland
		name = "Three Mile Island Iced Tea"
		id = "threemileisland"
		description = "Made for a woman, strong enough for a man."
		reagent_color = "#666340" // rgb: 102, 99, 64

		on_mob_life(var/mob/living/M as mob)
			M.druggy = max(M.druggy, 50)
			..()
			return

	gin
		name = "Gin"
		id = "gin"
		description = "It's gin. In space. I say, good sir."
		reagent_color = "#664300" // rgb: 102, 67, 0

	rum
		name = "Rum"
		id = "rum"
		description = "Yohoho and all that."
		reagent_color = "#664300" // rgb: 102, 67, 0

	tequilla
		name = "Tequila"
		id = "tequilla"
		description = "A strong and mildly flavoured, mexican produced spirit. Feeling thirsty hombre?"
		reagent_color = "#FFFF91" // rgb: 255, 255, 145

	vermouth
		name = "Vermouth"
		id = "vermouth"
		description = "You suddenly feel a craving for a martini..."
		reagent_color = "#91FF91" // rgb: 145, 255, 145

	wine
		name = "Wine"
		id = "wine"
		description = "An premium alchoholic beverage made from distilled grape juice."
		reagent_color = "#7E4043" // rgb: 126, 64, 67

	cognac
		name = "Cognac"
		id = "cognac"
		description = "A sweet and strongly alchoholic drink, made after numerous distillations and years of maturing. Classy as fornication."
		reagent_color = "#AB3C05" // rgb: 171, 60, 5

	hooch
		name = "Hooch"
		id = "hooch"
		description = "Either someone's failure at cocktail making or attempt in alchohol production. In any case, do you really want to drink that?"
		reagent_color = "#664300" // rgb: 102, 67, 0
		boozepwr = 35

	ale
		name = "Ale"
		id = "ale"
		description = "A dark alchoholic beverage made by malted barley and yeast."
		reagent_color = "#664300" // rgb: 102, 67, 0

	goldschlager
		name = "Goldschlager"
		id = "goldschlager"
		description = "100 proof cinnamon schnapps, made for alcoholic teen girls on spring break."
		reagent_color = "#FFFF91" // rgb: 255, 255, 145

	patron
		name = "Patron"
		id = "patron"
		description = "Tequila with silver in it, a favorite of alcoholic women in the club scene."
		reagent_color = "#585840" // rgb: 88, 88, 64

	gintonic
		name = "Gin and Tonic"
		id = "gintonic"
		description = "An all time classic, mild cocktail."
		reagent_color = "#664300" // rgb: 102, 67, 0
		boozepwr = 65

	cuba_libre
		name = "Cuba Libre"
		id = "cubalibre"
		description = "Rum, mixed with cola. Viva la revolution."
		reagent_color = "#3E1B00" // rgb: 62, 27, 0

	whiskey_cola
		name = "Whiskey Cola"
		id = "whiskeycola"
		description = "Whiskey, mixed with cola. Surprisingly refreshing."
		reagent_color = "#3E1B00" // rgb: 62, 27, 0
		boozepwr = 65

	martini
		name = "Classic Martini"
		id = "martini"
		description = "Vermouth with Gin. Not quite how 007 enjoyed it, but still delicious."
		reagent_color = "#664300" // rgb: 102, 67, 0

	vodkamartini
		name = "Vodka Martini"
		id = "vodkamartini"
		description = "Vodka with Gin. Not quite how 007 enjoyed it, but still delicious."
		reagent_color = "#664300" // rgb: 102, 67, 0

	white_russian
		name = "White Russian"
		id = "whiterussian"
		description = "That's just, like, your opinion, man..."
		reagent_color = "#A68340" // rgb: 166, 131, 64
		boozepwr = 55

	screwdrivercocktail
		name = "Screwdriver"
		id = "screwdrivercocktail"
		description = "Vodka, mixed with plain ol' orange juice. The result is surprisingly delicious."
		reagent_color = "#A68310" // rgb: 166, 131, 16
		boozepwr = 55

	booger
		name = "Booger"
		id = "booger"
		description = "Ewww..."
		reagent_color = "#8CFF8C" // rgb: 140, 255, 140
		boozepwr = 55

	bloody_mary
		name = "Bloody Mary"
		id = "bloodymary"
		description = "A strange yet pleasurable mixture made of vodka, tomato and lime juice. Or at least you THINK the red stuff is tomato juice."
		reagent_color = "#664300" // rgb: 102, 67, 0
		boozepwr = 55

	brave_bull
		name = "Brave Bull"
		id = "bravebull"
		description = "It's just as effective as Dutch-Courage!."
		reagent_color = "#664300" // rgb: 102, 67, 0

	tequilla_sunrise
		name = "Tequila Sunrise"
		id = "tequillasunrise"
		description = "Tequila and orange juice. Much like a Screwdriver, only Mexican~"
		reagent_color = "#FFE48C" // rgb: 255, 228, 140
		boozepwr = 55

	toxins_special
		name = "Toxins Special"
		id = "toxinsspecial"
		description = "This thing is ON FIRE!. CALL THE DAMN SHUTTLE!"
		reagent_state = LIQUID
		reagent_color = "#664300" // rgb: 102, 67, 0

		on_mob_life(var/mob/living/M as mob)
			if (M.bodytemperature < 330)
				M.bodytemperature = min(330, M.bodytemperature + (15 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
			..()
			return

	beepsky_smash
		name = "Beepsky Smash"
		id = "beepskysmash"
		description = "Deny drinking this and prepare for THE LAW."
		reagent_state = LIQUID
		reagent_color = "#664300" // rgb: 102, 67, 0

		on_mob_life(var/mob/living/M as mob)
			M.Stun(2)
			..()
			return

	irish_cream
		name = "Irish Cream"
		id = "irishcream"
		description = "Whiskey-imbued cream, what else would you expect from the Irish."
		reagent_color = "#664300" // rgb: 102, 67, 0

	manly_dorf
		name = "The Manly Dorf"
		id = "manlydorf"
		description = "Beer and Ale, brought together in a delicious mix. Intended for true men only."
		reagent_color = "#664300" // rgb: 102, 67, 0
		boozepwr = 10

	longislandicedtea
		name = "Long Island Iced Tea"
		id = "longislandicedtea"
		description = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."
		reagent_color = "#664300" // rgb: 102, 67, 0
		boozepwr = 55

	moonshine
		name = "Moonshine"
		id = "moonshine"
		description = "You've really hit rock bottom now... your liver packed its bags and left last night."
		reagent_color = "#664300" // rgb: 102, 67, 0
		boozepwr = 25

	b52
		name = "B-52"
		id = "b52"
		description = "Coffee, Irish Cream, and cognac. You will get bombed."
		reagent_color = "#664300" // rgb: 102, 67, 0
		boozepwr = 25

	irishcoffee
		name = "Irish Coffee"
		id = "irishcoffee"
		description = "Coffee, and alcohol. More fun than a Mimosa to drink in the morning."
		reagent_color = "#664300" // rgb: 102, 67, 0
		boozepwr = 55

	margarita
		name = "Margarita"
		id = "margarita"
		description = "On the rocks with salt on the rim. Arriba~!"
		reagent_color = "#8CFF8C" // rgb: 140, 255, 140
		boozepwr = 55

	black_russian
		name = "Black Russian"
		id = "blackrussian"
		description = "For the lactose-intolerant. Still as classy as a White Russian."
		reagent_color = "#360000" // rgb: 54, 0, 0
		boozepwr = 55

	manhattan
		name = "Manhattan"
		id = "manhattan"
		description = "The Detective's undercover drink of choice. He never could stomach gin..."
		reagent_color = "#664300" // rgb: 102, 67, 0
		boozepwr = 55

	manhattan_proj
		name = "Manhattan Project"
		id = "manhattan_proj"
		description = "A scientist's drink of choice, for pondering ways to blow up the station."
		reagent_color = "#664300" // rgb: 102, 67, 0

		on_mob_life(var/mob/living/M as mob)
			M.druggy = max(M.druggy, 30)
			..()
			return

	whiskeysoda
		name = "Whiskey Soda"
		id = "whiskeysoda"
		description = "For the more refined griffon."
		reagent_color = "#664300" // rgb: 102, 67, 0

	antifreeze
		name = "Anti-freeze"
		id = "antifreeze"
		description = "Ultimate refreshment."
		reagent_color = "#664300" // rgb: 102, 67, 0

		on_mob_life(var/mob/living/M as mob)
			if (M.bodytemperature < 330)
				M.bodytemperature = min(330, M.bodytemperature + (20 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
			..()
			return

	barefoot
		name = "Barefoot"
		id = "barefoot"
		description = "Barefoot and pregnant"
		reagent_color = "#664300" // rgb: 102, 67, 0

	snowwhite
		name = "Snow White"
		id = "snowwhite"
		description = "A cold refreshment"
		reagent_color = "#FFFFFF" // rgb: 255, 255, 255

	demonsblood
		name = "Demons Blood"
		id = "demonsblood"
		description = "AHHHH!!!!"
		reagent_color = "#820000" // rgb: 130, 0, 0

	vodkatonic
		name = "Vodka and Tonic"
		id = "vodkatonic"
		description = "For when a gin and tonic isn't russian enough."
		reagent_color = "#0064C8" // rgb: 0, 100, 200

	ginfizz
		name = "Gin Fizz"
		id = "ginfizz"
		description = "Refreshingly lemony, deliciously dry."
		reagent_color = "#664300" // rgb: 102, 67, 0

	bahama_mama
		name = "Bahama mama"
		id = "bahama_mama"
		description = "Tropical cocktail."
		reagent_color = "#FF7F3B" // rgb: 255, 127, 59

	singulo
		name = "Singulo"
		id = "singulo"
		description = "A blue-space beverage!"
		reagent_color = "#2E6671" // rgb: 46, 102, 113

	sbiten
		name = "Sbiten"
		id = "sbiten"
		description = "A spicy Vodka! Might be a little hot for the little guys!"
		reagent_color = "#664300" // rgb: 102, 67, 0

		on_mob_life(var/mob/living/M as mob)
			if (M.bodytemperature < 360)
				M.bodytemperature = min(360, M.bodytemperature + (50 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
			..()
			return

	devilskiss
		name = "Devils Kiss"
		id = "devilskiss"
		description = "Creepy time!"
		reagent_color = "#A68310" // rgb: 166, 131, 16

	red_mead
		name = "Red Mead"
		id = "red_mead"
		description = "The true Viking drink! Even though it has a strange red reagent_color."
		reagent_color = "#C73C00" // rgb: 199, 60, 0

	mead
		name = "Mead"
		id = "mead"
		description = "A Vikings drink, though a cheap one."
		reagent_state = LIQUID
		reagent_color = "#664300" // rgb: 102, 67, 0

		on_mob_life(var/mob/living/M as mob)
			M.nutrition += 1
			..()
			return

	iced_beer
		name = "Iced Beer"
		id = "iced_beer"
		description = "A beer which is so cold the air around it freezes."
		reagent_color = "#664300" // rgb: 102, 67, 0

		on_mob_life(var/mob/living/M as mob)
			if(M.bodytemperature > 270)
				M.bodytemperature = max(270, M.bodytemperature - (20 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
			..()
			return

	grog
		name = "Grog"
		id = "grog"
		description = "Watered down rum, Nanotrasen approves!"
		reagent_color = "#664300" // rgb: 102, 67, 0
		boozepwr = 90

	aloe
		name = "Aloe"
		id = "aloe"
		description = "So very, very, very good."
		reagent_color = "#664300" // rgb: 102, 67, 0

	andalusia
		name = "Andalusia"
		id = "andalusia"
		description = "A nice, strange named drink."
		reagent_color = "#664300" // rgb: 102, 67, 0

	alliescocktail
		name = "Allies Cocktail"
		id = "alliescocktail"
		description = "A drink made from your allies, not as sweet as when made from your enemies."
		reagent_color = "#664300" // rgb: 102, 67, 0

	acid_spit
		name = "Acid Spit"
		id = "acidspit"
		description = "A drink for the daring, can be deadly if incorrectly prepared!"
		reagent_state = LIQUID
		reagent_color = "#365000" // rgb: 54, 80, 0

	amasec
		name = "Amasec"
		id = "amasec"
		description = "Official drink of the Nanotrasen Gun-Club!"
		reagent_state = LIQUID
		reagent_color = "#664300" // rgb: 102, 67, 0

	changelingsting
		name = "Changeling Sting"
		id = "changelingsting"
		description = "You take a tiny sip and feel a burning sensation..."
		reagent_color = "#2E6671" // rgb: 46, 102, 113

		on_mob_life(var/mob/living/M as mob)
			if(!M.weakened)
				M << "<span class='danger'>Your muscles begin to painfully tighten.</span>"
			M.weakened = max(M.weakened, 4)

	irishcarbomb
		name = "Irish Car Bomb"
		id = "irishcarbomb"
		description = "Mmm, tastes like chocolate cake..."
		reagent_color = "#2E6671" // rgb: 46, 102, 113

	syndicatebomb
		name = "Syndicate Bomb"
		id = "syndicatebomb"
		description = "Tastes like terrorism!"
		reagent_color = "#2E6671" // rgb: 46, 102, 113

	erikasurprise
		name = "Erika Surprise"
		id = "erikasurprise"
		description = "The surprise is, it's green!"
		reagent_color = "#2E6671" // rgb: 46, 102, 113

	driestmartini
		name = "Driest Martini"
		id = "driestmartini"
		description = "Only for the experienced. You think you see sand floating in the glass."
		nutriment_factor = 1 * REAGENTS_METABOLISM
		reagent_color = "#2E6671" // rgb: 46, 102, 113
		boozepwr = 25

	bananahonk
		name = "Banana Mama"
		id = "bananahonk"
		description = "A drink from Clown Heaven."
		nutriment_factor = 1 * REAGENTS_METABOLISM
		reagent_color = "#FFFF91" // rgb: 255, 255, 140

		on_mob_life(var/mob/living/M as mob)
			M.nutrition += nutriment_factor
			if(istype(M, /mob/living/carbon/human) && M.job in list("Clown") || istype(M, /mob/living/carbon/monkey))
				if(!M) M = holder.my_atom
				M.heal_organ_damage(1,1)
			..()
			return

	silencer
		name = "Silencer"
		id = "silencer"
		description = "A drink from Mime Heaven."
		nutriment_factor = 1 * REAGENTS_METABOLISM
		reagent_color = "#664300" // rgb: 102, 67, 0

		on_mob_life(var/mob/living/M as mob)
			M.nutrition += nutriment_factor

			M.silent += 2

			if(istype(M, /mob/living/carbon/human) && M.job in list("Mime"))
				if(!M) M = holder.my_atom
				M.heal_organ_damage(1,1)
				..()
				return

/datum/reagent
	atomicbomb
		name = "Atomic Bomb"
		id = "atomicbomb"
		description = "Nuclear proliferation never tasted so good."
		reagent_state = LIQUID
		reagent_color = "#666300" // rgb: 102, 99, 0

		on_mob_life(var/mob/living/M as mob)
			M.druggy = max(M.druggy, 50)
			M.confused = max(M.confused+2,0)
			M.make_dizzy(10)
			if (!M.stuttering) M.stuttering = 1
			M.stuttering += 3
			if(!data) data = 1
			data++
			switch(data)
				if(51 to INFINITY)
					M.sleeping += 1
			..()
			return

	gargle_blaster
		name = "Pan-Galactic Gargle Blaster"
		id = "gargleblaster"
		description = "Whoah, this stuff looks volatile!"
		reagent_state = LIQUID
		reagent_color = "#664300" // rgb: 102, 67, 0

		on_mob_life(var/mob/living/M as mob)
			if(!data) data = 1
			data++
			M.dizziness +=6
			if(data >= 15 && data <45)
				if (!M.stuttering) M.stuttering = 1
				M.stuttering += 3
			else if(data >= 45 && prob(50) && data <55)
				M.confused = max(M.confused+3,0)
			else if(data >=55)
				M.druggy = max(M.druggy, 55)
			..()
			return

	neurotoxin
		name = "Neurotoxin"
		id = "neurotoxin"
		description = "A strong neurotoxin that puts the subject into a death-like state."
		reagent_state = LIQUID
		reagent_color = "#2E2E61" // rgb: 46, 46, 97

		on_mob_life(var/mob/living/carbon/M as mob)
			if(!M) M = holder.my_atom
			if(!M.weakened)
				M << "<span class='danger'>Your muscles begin to painfully tighten.</span>"
			M.weakened = max(M.weakened, 6)
			if(!data) data = 1
			data++
			M.dizziness +=6
			if(data >= 15 && data <45)
				if (!M.stuttering) M.stuttering = 1
				M.stuttering += 3
			else if(data >= 45 && prob(50) && data <55)
				M.confused = max(M.confused+3,0)
			else if(data >=55)
				M.druggy = max(M.druggy, 55)
			..()
			return

	hippies_delight
		name = "Hippie's Delight"
		id = "hippiesdelight"
		description = "You just don't get it maaaan."
		reagent_state = LIQUID
		reagent_color = "#664300" // rgb: 102, 67, 0

		on_mob_life(var/mob/living/M as mob)
			if(!M) M = holder.my_atom
			M.druggy = max(M.druggy, 50)
			if(!data) data = 1
			data++
			switch(data)
				if(1 to 5)
					if (!M.stuttering) M.stuttering = 1
					M.make_dizzy(10)
					if(prob(10)) M.emote(pick("twitch","giggle"))
				if(5 to 10)
					if (!M.stuttering) M.stuttering = 1
					M.make_jittery(20)
					M.make_dizzy(20)
					M.druggy = max(M.druggy, 45)
					if(prob(20)) M.emote(pick("twitch","giggle"))
				if (10 to INFINITY)
					if (!M.stuttering) M.stuttering = 1
					M.make_jittery(40)
					M.make_dizzy(40)
					M.druggy = max(M.druggy, 60)
					if(prob(30)) M.emote(pick("twitch","giggle"))
			holder.remove_reagent(src.id, 0.2)
			..()
			return