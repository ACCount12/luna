/obj/item/weapon/reagent_containers/glass/beaker/vial
	name = "vial"
	desc = "A small glass vial. Can hold up to 25 units."
	icon_state = "vial"
	g_amt = 250
	volume = 25
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(5,10,15,25)

/obj/item/weapon/reagent_containers/glass/beaker/vial/virus/flu_virion
	name = "vial (flu virion culture)"
	desc = "A small glass vial. Can hold up to 25 units. Contains H13N1 flu virion culture in synthblood medium."
	New()
		..()
		var/datum/disease/F = new /datum/disease/advance/flu(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)

/obj/item/weapon/reagent_containers/glass/beaker/vial/virus/epiglottis_virion
	name = "vial (Epiglottis virion culture)"
	desc = "A small glass vial. Can hold up to 25 units. Contains Epiglottis virion culture in synthblood medium."
	New()
		..()
		var/datum/disease/F = new /datum/disease/advance/voice_change(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)

/obj/item/weapon/reagent_containers/glass/beaker/vial/virus/liver_enhance_virion
	name = "vial (liver enhancement virion culture)"
	desc = "A small glass vial. Can hold up to 25 units. Contains liver enhancement virion culture in synthblood medium."
	New()
		..()
		var/datum/disease/F = new /datum/disease/advance/heal(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)

/obj/item/weapon/reagent_containers/glass/beaker/vial/virus/hullucigen_virion
	name = "vial (hullucigen virion)"
	desc = "A small glass vial. Can hold up to 25 units. Contains hullucigen virion culture in synthblood medium."
	New()
		..()
		var/datum/disease/F = new /datum/disease/advance/hullucigen(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)

/obj/item/weapon/reagent_containers/glass/beaker/vial/virus/pierrot_throat
	name = "vial (Pierrot's Throat culture)"
	desc = "A small glass vial. Can hold up to 25 units. Contains H0NI<42 virion culture in synthblood medium."
	New()
		..()
		var/datum/disease/F = new /datum/disease/pierrot_throat(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)

/obj/item/weapon/reagent_containers/glass/beaker/vial/virus/cold
	name = "vial (Rhinovirus culture)"
	desc = "A small glass vial. Can hold up to 25 units. Contains XY-rhinovirus culture in synthblood medium."
	New()
		..()
		var/datum/disease/advance/F = new /datum/disease/advance/cold(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)

/obj/item/weapon/reagent_containers/glass/beaker/vial/virus/random
	name = "vial (random culture)"
	desc = "A small glass vial. Can hold up to 25 units. Contains a random disease."
	New()
		..()
		var/datum/disease/advance/F = new(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)

/*obj/item/weapon/reagent_containers/glass/vial/virus/retrovirus
	name = "vial (retrovirus culture)"
	desc = "A small glass vial. Can hold up to 25 units. Contains a retrovirus culture in a synthblood medium."
	New()
		..()
		var/datum/disease/F = new /datum/disease/dna_retrovirus(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)*/

/obj/item/weapon/reagent_containers/glass/beaker/vial/virus/dna_spread
	name = "vial (retrovirus culture)"
	desc = "A small glass vial. Can hold up to 25 units. Contains a retrovirus culture in a synthblood medium."
	New()
		..()
		var/datum/disease/F = new /datum/disease/dnaspread(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)


/obj/item/weapon/reagent_containers/glass/beaker/vial/virus/gbs
	name = "vial (GBS culture)"
	desc = "A small glass vial. Can hold up to 25 units. Contains Gravitokinetic Bipotential SADS+ culture in synthblood medium."//Or simply - General BullShit
	New()
		var/datum/reagents/R = new/datum/reagents(20)
		reagents = R
		R.my_atom = src
		var/datum/disease/F = new /datum/disease/gbs
		var/list/data = list("virus"= F)
		R.add_reagent("blood", 20, data)

/obj/item/weapon/reagent_containers/glass/beaker/vial/virus/fake_gbs
	name = "vial (GBS culture)"
	desc = "A small glass vial. Can hold up to 25 units. Contains Gravitokinetic Bipotential SADS- culture in synthblood medium."
	New()
		..()
		var/datum/disease/F = new /datum/disease/fake_gbs(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)

/obj/item/weapon/reagent_containers/glass/beaker/vial/virus/rhumba_beat
	name = "vial (Rhumba Beat culture)"
	desc = "A small glass vial. Can hold up to 25 units. Contains The Rhumba Beat culture in synthblood medium."
	New()
		var/datum/reagents/R = new/datum/reagents(20)
		reagents = R
		R.my_atom = src
		var/datum/disease/F = new /datum/disease/rhumba_beat
		var/list/data = list("virus"= F)
		R.add_reagent("blood", 20, data)


/obj/item/weapon/reagent_containers/glass/beaker/vial/virus/brainrot
	name = "vial (Brainrot culture)"
	desc = "A small glass vial. Can hold up to 25 units. Contains Cryptococcus Cosmosis culture in synthblood medium."
	New()
		..()
		var/datum/disease/F = new /datum/disease/brainrot(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)

/obj/item/weapon/reagent_containers/glass/beaker/vial/virus/magnitis
	name = "vial (Magnitis culture)"
	desc = "A small glass vial. Can hold up to 25 units. Contains a small dosage of Fukkos Miracos."
	New()
		..()
		var/datum/disease/F = new /datum/disease/magnitis(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)

/*obj/item/weapon/reagent_containers/glass/beaker/vial/virus/fakedeath
	name = "vial (Fake Death culture)"
	desc = "A small glass vial. Can hold up to 25 units. Contains a small dosage of MetG"
	New()
		..()
		var/datum/disease/F = new /datum/disease/advance/fakedeath(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)*/

/obj/item/weapon/reagent_containers/glass/beaker/vial/virus/wizarditis
	name = "vial (Wizarditis culture)"
	desc = "A small glass vial. Can hold up to 25 units. Contains a sample of Rincewindus Vulgaris."
	New()
		..()
		var/datum/disease/F = new /datum/disease/wizarditis(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)