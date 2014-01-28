/datum/job/medsci
	dept_flag = JOB_SCIENCE | JOB_MEDICAL
	headset_type = /obj/item/device/radio/headset/headset_medsci

/datum/job/medsci/geneticist
	rank = "Geneticist"
	max_slots = 2
	access = list(access_medical, access_morgue, access_medlab, access_laboratories_doors)
	pda_type = /obj/item/device/pda/gene

	equip_mob(var/mob/living/carbon/human/H)
		H.equip_if_possible(new /obj/item/clothing/under/rank/geneticist(H), slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/white(H), slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/suit/storage/labcoat(H), slot_wear_suit)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), slot_back)
		..()

/datum/job/medsci/chemist
	rank = "Chemist"
	max_slots = 2
	access = list(access_medical, access_chemistry, access_laboratories_doors)
	pda_type = /obj/item/device/pda/chem

	equip_mob(var/mob/living/carbon/human/H)
		H.equip_if_possible(new /obj/item/clothing/under/rank/chemist(H), slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/white(H), slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/suit/storage/labcoat(H), slot_wear_suit)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), slot_back)
		..()

/datum/job/medsci/roboticist
	rank = "Roboticist"
	max_slots = 2
	access = list(access_robotics, access_tech_storage, access_medical, access_morgue)
	pda_type = /obj/item/device/pda/robot
	headset_type = /obj/item/device/radio/headset/headset_rob

	equip_mob(var/mob/living/carbon/human/H)
		H.equip_if_possible(new /obj/item/clothing/under/rank/roboticist(H), slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/suit/storage/labcoat(H), slot_wear_suit)
		H.equip_if_possible(new /obj/item/clothing/gloves/black(H), slot_gloves)
		H.equip_if_possible(new /obj/item/weapon/storage/toolbox/mechanical(H), slot_l_hand)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), slot_back)
		..()


/datum/job/medsci/doctor
	rank = "Medical Doctor"
	dept_flag = JOB_MEDICAL
	max_slots = 4
	access = list(access_medical, access_morgue, access_laboratories_doors)
	pda_type = /obj/item/device/pda/medical
	headset_type = /obj/item/device/radio/headset/headset_med

	equip_mob(var/mob/living/carbon/human/H)
		H.equip_if_possible(new /obj/item/clothing/under/rank/medical(H), slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/white(H), slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/suit/storage/labcoat(H), slot_wear_suit)
		H.equip_if_possible(new /obj/item/weapon/storage/firstaid/regular(H), slot_l_hand)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack/medic(H), slot_back)
		..()

/datum/job/medsci/scientist
	rank = "Scientist"
	dept_flag = JOB_SCIENCE
	max_slots = 5
	access = list(access_tox, access_tox_storage, access_medlab, access_laboratories_doors)
	pda_type = /obj/item/device/pda/toxins
	headset_type = /obj/item/device/radio/headset/headset_sci

	equip_mob(var/mob/living/carbon/human/H)
		H.equip_if_possible(new /obj/item/clothing/under/rank/scientist(H), slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/white(H), slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/suit/storage/labcoat(H), slot_wear_suit)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), slot_back)

		H.equip_if_possible(new /obj/item/clothing/mask/gas(H), slot_in_backpack)
		H.equip_if_possible(new /obj/item/weapon/tank/oxygen(H), slot_in_backpack)
		..()