/datum/job/civilian
	dept_flag = JOB_CIVILIAN

/datum/job/civilian/unassigned
	rank = "Unassigned"
	max_slots = -1

	equip_mob(var/mob/living/carbon/human/H)
		H.equip_if_possible(new /obj/item/clothing/under/color/grey(H), slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), slot_back)
		..()

/datum/job/civilian/clown
	rank = "Clown"
	max_slots = 1
	access = list(access_theater)
	pda_type = /obj/item/device/pda/clown

	equip_mob(var/mob/living/carbon/human/H)
		H.equip_if_possible(new /obj/item/clothing/under/rank/clown(H), slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/clown_shoes(H), slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/mask/gas/clown_hat(H), slot_wear_mask)
		H.equip_if_possible(new /obj/item/weapon/reagent_containers/food/snacks/grown/banana(H), slot_in_backpack)
		H.equip_if_possible(new /obj/item/weapon/bikehorn(H), slot_in_backpack)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack/clown(H), slot_back)
		H.mutations += CLUMSY
		..()

/datum/job/civilian/mime
	rank = "Mime"
	max_slots = 1
	access = list(access_theater)
	pda_type = /obj/item/device/pda/mime

	equip_mob(var/mob/living/carbon/human/H)
		H.equip_if_possible(new /obj/item/clothing/under/rank/mime(H), slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/mask/gas/mime(H), slot_wear_mask)
		H.equip_if_possible(new /obj/item/clothing/gloves/latex(H), slot_gloves)
		H.equip_if_possible(new /obj/item/clothing/head/beret(H), slot_head)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), slot_back)
		H.silent += 1000000
		H.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/conjure/mimewall()
		..()

/datum/job/civilian/janitor
	rank = "Janitor"
	max_slots = 2
	access = list(access_janitor, access_laboratories_doors, access_incinerator, access_maintenance_hall)
	pda_type = /obj/item/device/pda/janitor

	equip_mob(var/mob/living/carbon/human/H)
		H.equip_if_possible(new /obj/item/clothing/under/rank/janitor(H), slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/galoshes(H), slot_shoes)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), slot_back)
		..()

/datum/job/civilian/barman
	rank = "Barman"
	max_slots = 1
	access = list(access_bar, access_kitchen)
	pda_type = /obj/item/device/pda/bar

	equip_mob(var/mob/living/carbon/human/H)
		H.equip_if_possible(new /obj/item/clothing/under/rank/bartender(H), slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/suit/armor/vest(H), slot_wear_suit)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), slot_back)
		..()

/datum/job/civilian/chef
	rank = "Chef"
	max_slots = 1
	access = list(access_kitchen)
	pda_type = /obj/item/device/pda/chef

	equip_mob(var/mob/living/carbon/human/H)
		H.equip_if_possible(new /obj/item/clothing/under/rank/chef(H), slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/head/chefhat(H), slot_head)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), slot_back)
		H.equip_if_possible(new /obj/item/weapon/kitchen/rollingpin(H), slot_in_backpack)
		..()

/datum/job/civilian/hydroponicist
	rank = "Hydroponicist"
	max_slots = 2
	access = list(access_medical, access_hydroponics, access_kitchen)
	pda_type = /obj/item/device/pda/hydro

	equip_mob(var/mob/living/carbon/human/H)
		H.equip_if_possible(new /obj/item/clothing/under/rank/hydroponics(H), slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/gloves/black(H), slot_gloves)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), slot_back)
		H.equip_if_possible(new /obj/item/clothing/head/greenbandana(H), slot_head)
		H.equip_if_possible(new /obj/item/clothing/suit/storage/apron(H), slot_wear_suit)
		..()

/datum/job/civilian/quartermaster
	rank = "Quartermaster"
	max_slots = 1
	access = list(access_cargo, access_cargo_bot, access_mining, access_teleporter)
	pda_type = /obj/item/device/pda/quartermaster
	headset_type = /obj/item/device/radio/headset/headset_cargo

	equip_mob(var/mob/living/carbon/human/H)
		H.equip_if_possible(new /obj/item/clothing/gloves/black(H), slot_gloves)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/under/rank/cargo(H), slot_w_uniform)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), slot_back)
		..()

/datum/job/civilian/cargotechnician
	rank = "Cargo Technician"
	max_slots = 2
	access = list(access_cargo, access_cargo_bot)
	pda_type = /obj/item/device/pda/cargo
	headset_type = /obj/item/device/radio/headset/headset_cargo

	equip_mob(var/mob/living/carbon/human/H)
		H.equip_if_possible(new /obj/item/clothing/gloves/black(H), slot_gloves)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/under/rank/cargotech(H), slot_w_uniform)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), slot_back)
		..()

/datum/job/civilian/shaftminer
	rank = "Shaft Miner"
	max_slots = 3
	access = list(access_mining, access_cargo, access_teleporter)
	pda_type = /obj/item/device/pda/miner
	headset_type = /obj/item/device/radio/headset/headset_mine

	equip_mob(var/mob/living/carbon/human/H)
		H.equip_if_possible(new /obj/item/clothing/gloves/black(H), slot_gloves)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/under/rank/miner(H), slot_w_uniform)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack/industrial(H), slot_back)
		H.equip_if_possible(new /obj/item/clothing/glasses/meson(H), slot_glasses)
		..()