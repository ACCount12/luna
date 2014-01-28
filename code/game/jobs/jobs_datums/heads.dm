/datum/job/captain
	dept_flag = JOB_HEAD
	rank = "Captain"
	max_slots = 1
	pda_type = /obj/item/device/pda/heads/captain
	headset_type = /obj/item/device/radio/headset/heads/captain

	equip_mob(var/mob/living/carbon/human/H)
		H.equip_if_possible(new /obj/item/clothing/under/rank/captain(H), slot_w_uniform)
	//	H.equip_if_possible(new /obj/item/clothing/suit/armor/captain(H), slot_wear_suit)
		H.equip_if_possible(new /obj/item/clothing/shoes/brown(H), slot_shoes)
	//	H.equip_if_possible(new /obj/item/clothing/head/caphat(H), slot_head)
		H.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(H), slot_glasses)
		H.equip_if_possible(new /obj/item/clothing/gloves/green(H), slot_gloves)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack/captain(H), slot_back)

		H.equip_if_possible(new /obj/item/weapon/gun/energy/taser(H), slot_in_backpack)
		H.equip_if_possible(new /obj/item/weapon/storage/box/id(H), slot_in_backpack)
		..()

	get_access()
		return get_all_accesses()

	place_mob(var/mob/living/M)
		world << "<b>[M] is the captain!</b>"
		..()

/datum/job/civilian/head
	dept_flag = JOB_CIVILIAN | JOB_HEAD
	rank = "Head of Personnel"
	max_slots = 1
	access = list(access_security, access_brig, access_forensics_lockers, access_incinerator,
				access_tox, access_tox_storage, access_chemistry, access_medical, access_medlab, access_engine,
				access_emergency_storage, access_change_ids, access_ai_upload, access_eva, access_heads,
				access_all_personal_lockers, access_tech_storage, access_bar, access_janitor, access_hydroponics,
				access_crematorium, access_kitchen, access_robotics, access_cargo, access_cargo_bot,
				access_security_passthrough, access_laboratories_doors, access_maintenance_hall, access_shield_generator)
	pda_type = /obj/item/device/pda/heads/hop
	headset_type = /obj/item/device/radio/headset/heads/hop

	equip_mob(var/mob/living/carbon/human/H)
		H.equip_if_possible(new /obj/item/clothing/under/rank/head_of_personnel(H), slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/suit/armor/vest(H), slot_wear_suit)
		H.equip_if_possible(new /obj/item/clothing/shoes/brown(H), slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/head/helmet(H), slot_head)
	//	H.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(H), slot_glasses)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), slot_back)

	//	H.equip_if_possible(new /obj/item/device/flash(H), slot_l_store)
		H.equip_if_possible(new /obj/item/weapon/gun/energy/taser(H), slot_in_backpack)
		H.equip_if_possible(new /obj/item/weapon/storage/box/id(H), slot_in_backpack)
		..()

/datum/job/security/head
	dept_flag = JOB_SECURITY | JOB_HEAD
	rank = "Head of Security"
	max_slots = 1
	access = list(access_HoSoffice, access_incinerator, access_medical, access_morgue, access_tox, access_tox_storage, access_chemistry,
				access_teleporter, access_heads, access_tech_storage, access_security, access_brig, access_atmospherics, access_medlab,
				access_bar, access_janitor, access_kitchen, access_robotics, access_laboratories_doors, access_armory, access_engine,
				access_security_passthrough, access_maintenance_hall, access_shield_generator, access_forensics_lockers, access_hydroponics)
	pda_type = /obj/item/device/pda/heads/hos
	headset_type = /obj/item/device/radio/headset/heads/hos

	equip_mob(var/mob/living/carbon/human/H)
		H.equip_if_possible(new /obj/item/clothing/under/rank/head_of_security(H), slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/suit/storage/armor/hos(H), slot_wear_suit)
		H.equip_if_possible(new /obj/item/clothing/shoes/jackboots(H), slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/head/helmet/HoS(H), slot_head)
		H.equip_if_possible(new /obj/item/clothing/gloves/black(H), slot_gloves)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack/security(H), slot_back)

		H.equip_if_possible(new /obj/item/weapon/gun/energy/taser(H), slot_in_backpack)
		..()

/datum/job/engineering/head
	dept_flag = JOB_ENGINEERING | JOB_HEAD
	rank = "Chief Engineer"
	max_slots = 1
	access = list(access_engine, access_engine_equip, access_tech_storage,
				access_external_airlocks, access_atmospherics, access_emergency_storage, access_eva,
				access_heads, access_ai_upload, access_construction, access_security_passthrough,
				access_maintenance_hall, access_shield_generator, access_laboratories_doors)
	pda_type = /obj/item/device/pda/heads/ce
	headset_type = /obj/item/device/radio/headset/heads/ce

	equip_mob(var/mob/living/carbon/human/H)
		H.equip_if_possible(new /obj/item/clothing/gloves/yellow(H), slot_gloves)
		H.equip_if_possible(new /obj/item/clothing/shoes/brown(H), slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/head/helmet/hardhat/white(H), slot_head)
		H.equip_if_possible(new /obj/item/clothing/glasses/meson(H), slot_glasses)
		H.equip_if_possible(new /obj/item/clothing/under/rank/chief_engineer(H), slot_w_uniform)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack/industrial(H), slot_back)

		H.equip_if_possible(new /obj/item/weapon/gun/energy/taser(H), slot_in_backpack)
		H.mind.store_memory(get_airlock_wires_text())
		..()

/datum/job/medsci/head
	dept_flag = JOB_SCIENCE | JOB_MEDICAL | JOB_HEAD
	rank = "Research Director"
	max_slots = 1
	access = list(access_medical, access_morgue, access_medlab, access_robotics, access_hydroponics,
				access_tech_storage, access_heads, access_tox, access_tox_storage, access_chemistry,
				access_teleporter, access_security_passthrough, access_laboratories_doors)
	pda_type = /obj/item/device/pda/heads/rd
	headset_type = /obj/item/device/radio/headset/heads/rd

	equip_mob(var/mob/living/carbon/human/H)
		H.equip_if_possible(new /obj/item/clothing/shoes/brown(H), slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/under/rank/research_director(H), slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/suit/storage/labcoat(H), slot_wear_suit)
		H.equip_if_possible(new /obj/item/weapon/clipboard(H), slot_r_hand)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), slot_back)

		H.equip_if_possible(new /obj/item/weapon/gun/energy/taser(H), slot_in_backpack)
		..()