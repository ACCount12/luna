/datum/job/engineering
	dept_flag = JOB_ENGINEERING
	headset_type = /obj/item/device/radio/headset/headset_eng

	equip_mob(var/mob/living/carbon/human/H)
		H.equip_if_possible(new /obj/item/clothing/suit/storage/hazard(H), slot_wear_suit)
		..()

/datum/job/engineering/engineer
	rank = "Engineer"
	max_slots = 5
	access = list(access_engine, access_incinerator, access_engine_equip, access_tech_storage,
				access_external_airlocks, access_laboratories_doors, access_maintenance_hall, access_shield_generator)
	pda_type = /obj/item/device/pda/engineering

	equip_mob(var/mob/living/carbon/human/H)
		H.equip_if_possible(new /obj/item/clothing/under/rank/engineer(H), slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/orange(H), slot_shoes)
		H.equip_if_possible(new /obj/item/weapon/storage/toolbox/mechanical(H), slot_l_hand)
		H.equip_if_possible(new /obj/item/clothing/gloves/yellow(H), slot_gloves)
		H.equip_if_possible(new /obj/item/device/t_scanner(H), slot_r_store)
		H.equip_if_possible(new /obj/item/clothing/head/helmet/hardhat(H), slot_head)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack/industrial(H), slot_back)
		..()

/datum/job/engineering/atmospheric_technician
	rank = "Atmospheric Technician"
	max_slots = 2
	access = list(access_atmospherics, access_emergency_storage, access_tech_storage,
				access_external_airlocks, access_maintenance_hall, access_incinerator)
	pda_type = /obj/item/device/pda/atmos

	equip_mob(var/mob/living/carbon/human/H)
		H.equip_if_possible(new /obj/item/clothing/under/rank/atmospheric_technician(H), slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_if_possible(new /obj/item/weapon/storage/toolbox/mechanical(H), slot_l_hand)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack/industrial(H), slot_back)
		H.equip_if_possible(new /obj/item/clothing/head/helmet/hardhat(H), slot_head)
		..()