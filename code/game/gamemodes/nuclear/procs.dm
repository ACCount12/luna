/datum/game_mode/proc/equip_syndicate(mob/living/carbon/human/synd_mob)
	synd_mob.equip_if_possible(new /obj/item/device/radio/headset/syndicate(synd_mob), synd_mob.slot_ears)

	synd_mob.equip_if_possible(new /obj/item/clothing/under/syndicate(synd_mob), synd_mob.slot_w_uniform)
	synd_mob.equip_if_possible(new /obj/item/clothing/shoes/black(synd_mob), synd_mob.slot_shoes)
	synd_mob.equip_if_possible(new /obj/item/clothing/gloves/swat(synd_mob), synd_mob.slot_gloves)

	synd_mob.equip_if_possible(new /obj/item/weapon/storage/backpack(synd_mob), synd_mob.slot_back)
	synd_mob.equip_if_possible(new /obj/item/weapon/reagent_containers/pill/cyanide(synd_mob), synd_mob.slot_in_backpack)

	synd_mob.update_clothing()


/datum/game_mode/proc/get_possible_syndicates()
	var/list/candidates = list()

	for(var/mob/new_player/player in world)
		if(player.client && player.ready)
			if(player.be_nuke_agent)
				candidates += player.mind

	if(candidates.len < 1)
		for(var/mob/new_player/player in world)
			if(player.client && player.ready)
				candidates += player.mind

	if(candidates.len < 1)
		return null
	else
		return candidates


/datum/game_mode/proc/get_player_count()
	var/count = 0
	for(var/mob/new_player/P in world)
		if(P.ready)
			count++
	return count