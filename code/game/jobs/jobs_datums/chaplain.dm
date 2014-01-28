/datum/job/civilian/chaplain
	rank = "Counselor"
	max_slots = 1
	access = list(access_morgue, access_chapel_office, access_crematorium)
	pda_type = /obj/item/device/pda/chaplain

	equip_mob(var/mob/living/carbon/human/H)
		H.equip_if_possible(new /obj/item/clothing/under/rank/chaplain(H), slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/suit/storage/chaplain_hoodie(H), slot_wear_suit)
		H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), slot_back)
		..()