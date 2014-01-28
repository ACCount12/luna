/datum/job/security
	dept_flag = JOB_SECURITY
	pda_type = /obj/item/device/pda/security
	headset_type = /obj/item/device/radio/headset/headset_sec

/datum/job/security/officer
	rank = "Security Officer"
	max_slots = 5
	access = list(access_security, access_laboratories_doors, access_incinerator, access_brig, access_medical,
				access_security_passthrough, access_maintenance_hall, access_shield_generator)

	equip_mob(var/mob/living/carbon/human/H)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack/security(H), slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/color/red(H), slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/jackboots(H), slot_shoes)
	//	H.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(H), slot_glasses)
		H.equip_if_possible(new /obj/item/clothing/head/helmet/secsoft(H), slot_head)
	//	H.equip_if_possible(new /obj/item/weapon/melee/baton(H), slot_belt)
	//	H.equip_if_possible(new /obj/item/device/flash(H), slot_l_store)
		H.equip_if_possible(new /obj/item/clothing/gloves/red(H), slot_gloves)

	//	H.equip_if_possible(new /obj/item/weapon/gun/taser_gun(H), slot_in_backpack)
		H.equip_if_possible(new /obj/item/weapon/handcuffs(H), slot_in_backpack)
		H.equip_if_possible(new /obj/item/weapon/handcuffs(H), slot_in_backpack)
	//	H.equip_if_possible(new /obj/item/weapon/storage/box/grenades/flashbang(H), slot_in_backpack)
		..()

/datum/job/security/warden
	rank = "Warden"
	max_slots = 1
	access = list(access_security, access_laboratories_doors, access_incinerator, access_brig,
				access_medical, access_security_passthrough, access_maintenance_hall,
				access_shield_generator, access_armory)
	pda_type = /obj/item/device/pda/warden

	equip_mob(var/mob/living/carbon/human/H)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack/security(H), slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/rank/warden(H), slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/suit/warden_jacket(H), slot_wear_suit)
		H.equip_if_possible(new /obj/item/clothing/shoes/jackboots(H), slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/gloves/black(H), slot_gloves)
		..()

/datum/job/security/detective
	rank = "Forensic Technician"
	max_slots = 1
	access = list(access_security, access_forensics_lockers, access_morgue, access_security_passthrough, access_laboratories_doors, access_medical)
	pda_type = /obj/item/device/pda/det

	equip_mob(var/mob/living/carbon/human/H)
		H.equip_if_possible(new /obj/item/clothing/under/rank/forensic_technician(H), slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/brown(H), slot_shoes)
		//H.equip_if_possible(new /obj/item/clothing/head/det_hat(H), slot_head)
		H.equip_if_possible(new /obj/item/clothing/gloves/black(H), slot_gloves)
		H.equip_if_possible(new /obj/item/clothing/suit/storage/gearharness(H), slot_wear_suit)
		H.equip_if_possible(new /obj/item/weapon/lighter/zippo(H), slot_l_store)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack/security(H), slot_back)

		H.equip_if_possible(new /obj/item/weapon/storage/box/fcard(H), slot_in_backpack)
		H.equip_if_possible(new /obj/item/weapon/fcardholder(H), slot_in_backpack)
		H.equip_if_possible(new /obj/item/device/detective_scanner(H), slot_in_backpack)
		..()