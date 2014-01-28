/mob/living/carbon/human/u_equip(obj/item/W as obj)
	if (W == wear_suit)
		wear_suit = null
		W = s_store
		if(W) u_equip(W)

	else if (W == w_uniform)
		W = r_store
		if(W) u_equip(W)
		W = l_store
		if(W) u_equip(W)
		W = wear_id
		if(W) u_equip(W)
		W = belt
		if(W) u_equip(W)
		w_uniform = null

	else if (W == wear_mask)
		if(internal)
			if (internals)
				internals.icon_state = "internal0"
			internal = null
		wear_mask = null

	else if (W == gloves)
		gloves = null
	else if (W == glasses)
		glasses = null
	else if (W == head)
		head = null
	else if (W == ears)
		ears = null
	else if (W == shoes)
		shoes = null
	else if (W == belt)
		belt = null
	else if (W == wear_id)
		wear_id = null
	else if (W == r_store)
		r_store = null
	else if (W == l_store)
		l_store = null
	else if (W == s_store)
		s_store = null
	else if (W == back)
		back = null
	else if (W == handcuffed)
		handcuffed = null
	else if (W == r_hand)
		r_hand = null
	else if (W == l_hand)
		l_hand = null

	if (client)
		client.screen -= W
	if (W)
		W.loc = loc
		W.dropped(src)
		W.layer = initial(W.layer)

	update_clothing()

/mob/living/carbon/human/db_click(text, t1)
	var/obj/item/W = equipped()
	var/emptyHand = (W == null)
	if (!emptyHand && !istype(W, /obj/item))
		return
	if (emptyHand)
		usr.next_move = usr.prev_move
		usr:lastDblClick -= 3	//permit the double-click redirection to proceed.

	switch(text)
		if("mask")
			if(wear_mask)
				if(emptyHand) wear_mask.DblClick()
				return
			equip_to_slot_if_possible(W, slot_wear_mask)
		if("back")
			if(back)
				if(emptyHand) back.DblClick()
				return
			equip_to_slot_if_possible(W, slot_back)
		if("o_clothing")
			if(wear_suit)
				if(emptyHand) wear_suit.DblClick()
				return
			equip_to_slot_if_possible(W, slot_wear_suit)
		if("gloves")
			if(gloves)
				if(emptyHand) gloves.DblClick()
				return
			equip_to_slot_if_possible(W, slot_gloves)
		if("shoes")
			if(shoes)
				if(emptyHand) shoes.DblClick()
				return
			equip_to_slot_if_possible(W, slot_shoes)
		if("belt")
			if(belt)
				if(emptyHand) belt.DblClick()
				return
			equip_to_slot_if_possible(W, slot_belt)
		if("eyes")
			if(glasses)
				if(emptyHand) glasses.DblClick()
				return
			equip_to_slot_if_possible(W, slot_glasses)
		if("head")
			if(head)
				if(emptyHand) head.DblClick()
				return
			equip_to_slot_if_possible(W, slot_head)
		if("ears")
			if(ears)
				if(emptyHand) ears.DblClick()
				return
			equip_to_slot_if_possible(W, slot_ears)
		if("i_clothing")
			if(w_uniform)
				if(emptyHand) w_uniform.DblClick()
				return
			equip_to_slot_if_possible(W, slot_w_uniform)
		if("id")
			if(wear_id)
				if(emptyHand) wear_id.DblClick()
				return
			equip_to_slot_if_possible(W, slot_wear_id)
		if("storage1")
			if(l_store)
				if(emptyHand) l_store.DblClick()
				return
			equip_to_slot_if_possible(W, slot_l_store)
		if("storage2")
			if(r_store)
				if(emptyHand) r_store.DblClick()
				return
			equip_to_slot_if_possible(W, slot_r_store)
		if("suit storage")
			if(s_store)
				if(emptyHand) s_store.DblClick()
				return
			equip_to_slot_if_possible(W, slot_s_store)
	return


//This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible() or advanced_equip_to_slot_if_possible()
//set redraw_mob to 0 if you don't wish the hud to be updated - if you're doing it manually in your own proc.
/mob/living/carbon/human/equip_to_slot(obj/item/W as obj, slot, redraw_mob = 1)
	if(!slot) return
	if(!istype(W)) return
	if(!has_organ_for_slot(slot)) return

	if(W == src.l_hand)
		src.l_hand = null
		//update_inv_l_hand() //So items actually disappear from hands.
	else if(W == src.r_hand)
		src.r_hand = null
		//update_inv_r_hand()

	W.loc = src
	switch(slot)
		if(slot_back)
			src.back = W
			W.equipped(src, slot)
			//update_inv_back(redraw_mob)
		if(slot_wear_mask)
			src.wear_mask = W
			//update_hair(redraw_mob)
			W.equipped(src, slot)
			//update_inv_wear_mask(redraw_mob)
		if(slot_handcuffed)
			src.handcuffed = W
			lasthandcuff = world.timeofday
			drop_from_slot(r_hand)
			drop_from_slot(l_hand)
			//update_inv_handcuffed(redraw_mob)
		if(slot_l_hand)
			src.l_hand = W
			W.equipped(src, slot)
			//update_inv_l_hand(redraw_mob)
		if(slot_r_hand)
			src.r_hand = W
			W.equipped(src, slot)
			//update_inv_r_hand(redraw_mob)
		if(slot_belt)
			src.belt = W
			W.equipped(src, slot)
			//update_inv_belt(redraw_mob)
		if(slot_wear_id)
			src.wear_id = W
			W.equipped(src, slot)
			//update_inv_wear_id(redraw_mob)
		if(slot_ears)
			src.ears = W
			W.equipped(src, slot)
			//update_inv_ears(redraw_mob)
		if(slot_glasses)
			src.glasses = W
			W.equipped(src, slot)
			//update_inv_glasses(redraw_mob)
		if(slot_gloves)
			src.gloves = W
			W.equipped(src, slot)
			//update_inv_gloves(redraw_mob)
		if(slot_head)
			src.head = W
			//update_hair(redraw_mob)	//rebuild hair
			if(istype(W,/obj/item/clothing/head/kitty))
				W.update_icon(src)
			W.equipped(src, slot)
			//update_inv_head(redraw_mob)
		if(slot_shoes)
			src.shoes = W
			W.equipped(src, slot)
			//update_inv_shoes(redraw_mob)
		if(slot_wear_suit)
			src.wear_suit = W
			W.equipped(src, slot)
			//update_inv_wear_suit(redraw_mob)
		if(slot_w_uniform)
			src.w_uniform = W
			W.equipped(src, slot)
			//update_inv_w_uniform(redraw_mob)
		if(slot_l_store)
			src.l_store = W
			W.equipped(src, slot)
			//update_inv_pockets(redraw_mob)
		if(slot_r_store)
			src.r_store = W
			W.equipped(src, slot)
			//update_inv_pockets(redraw_mob)
		if(slot_s_store)
			src.s_store = W
			W.equipped(src, slot)
			//update_inv_s_store(redraw_mob)
		if(slot_in_backpack)
			if(src.get_active_hand() == W)
				src.u_equip(W)
			W.loc = src.back
		else
			return
	update_clothing()
	W.layer = 20
	return


/obj/equip_e/human/process()
	if (item)
		item.add_fingerprint(source)
	if (!item)
		switch(place)
			if("mask")
				if (!target.wear_mask)
					del(src)
					return
			if("l_hand")
				if (!target.l_hand)
					del(src)
					return
			if("r_hand")
				if (!target.r_hand)
					del(src)
					return
			if("suit")
				if (!target.wear_suit)
					del(src)
					return
			if("uniform")
				if (!target.w_uniform)
					del(src)
					return
			if("back")
				if (!target.back)
					del(src)
					return
			if("handcuff")
				if (!target.handcuffed)
					del(src)
					return
			if("id")
				if (!target.wear_id || !target.w_uniform)
					del(src)
					return
			if("internal")
				if (!istype(target.wear_mask, /obj/item/clothing/mask) || !istype(target.back, /obj/item/weapon/tank) && !istype(target.belt, /obj/item/weapon/tank))
					del(src)
					return
			if("syringe")		return
			if("pill")			return
			if("fuel")			return
			if("drink")			return
			if("dnainjector")	return

	var/list/L = list( "syringe", "pill", "drink", "dnainjector", "fuel")
	if ((item && !( L.Find(place) )))
		for(var/mob/O in viewers(target, null))
			O.show_message(text("\red <B>[] is trying to put \a [] on []</B>", source, item, target), 1)
	else if (place == "syringe")
		for(var/mob/O in viewers(target, null))
			O.show_message(text("\red <B>[] is trying to inject []!</B>", source, target), 1)
	else if (place == "pill")
		for(var/mob/O in viewers(target, null))
			O.show_message(text("\red <B>[] is trying to force [] to swallow []!</B>", source, target, item), 1)
	else if (place == "drink")
		for(var/mob/O in viewers(target, null))
			O.show_message(text("\red <B>[] is trying to force [] to swallow a gulp from the []!</B>", source, target, item), 1)
	else if (place == "dnainjector")
		for(var/mob/O in viewers(target, null))
			O.show_message(text("\red <B>[] is trying to inject [] with the []!</B>", source, target, item), 1)
	else
		var/message = null
		switch(place)
			if("mask")
				message = text("\red <B>[] is trying to take off \a [] from []'s head!</B>", source, target.wear_mask, target)
			if("l_hand")
				message = text("\red <B>[] is trying to take off \a [] from []'s left hand!</B>", source, target.l_hand, target)
			if("r_hand")
				message = text("\red <B>[] is trying to take off \a [] from []'s right hand!</B>", source, target.r_hand, target)
			if("gloves")
				message = text("\red <B>[] is trying to take off the [] from []'s hands!</B>", source, target.gloves, target)
			if("eyes")
				message = text("\red <B>[] is trying to take off the [] from []'s eyes!</B>", source, target.glasses, target)
			if("ears")
				message = text("\red <B>[] is trying to take off the [] from []'s ears!</B>", source, target.ears, target)
			if("head")
				message = text("\red <B>[] is trying to take off the [] from []'s head!</B>", source, target.head, target)
			if("shoes")
				message = text("\red <B>[] is trying to take off the [] from []'s feet!</B>", source, target.shoes, target)
			if("belt")
				message = text("\red <B>[] is trying to take off the [] from []'s belt!</B>", source, target.belt, target)
			if("suit")
				message = text("\red <B>[] is trying to take off \a [] from []'s body!</B>", source, target.wear_suit, target)
			if("back")
				message = text("\red <B>[] is trying to take off \a [] from []'s back!</B>", source, target.back, target)
			if("handcuff")
				message = text("\red <B>[] is trying to unhandcuff []!</B>", source, target)
			if("uniform")
				message = text("\red <B>[] is trying to take off \a [] from []'s body!</B>", source, target.w_uniform, target)
			if("pockets")
				for(var/obj/item/I in list(target.l_store, target.r_store))
					if(I.on_found(source))
						message = text("\red <B>[] reaches into []'s pockets!</B>", source, target)
						break
				if(!message)
					message = text("\red <B>[] is trying to empty []'s pockets!</B>", source, target)
			if("CPR")
				if (target.cpr_time >= world.time + 3)
					del(src)
					return
				message = text("\red <B>[] is trying to perform CPR on []!</B>", source, target)
			if("id")
				message = text("\red <B>[] is trying to take off [] from []'s uniform!</B>", source, target.wear_id, target)
			if("internal")
				if (target.internal)
					message = text("\red <B>[] is trying to remove []'s internals</B>", source, target)
				else
					message = text("\red <B>[] is trying to set on []'s internals.</B>", source, target)
			else
		for(var/mob/M in viewers(target, null))
			M.show_message(message, 1)
	spawn( 40 )
		done()
		return
	return

/obj/equip_e/human/done()
	var/mut = 0
	if(TK in source.mutations)
		mut = 1
	if(!source || !target)						return
	if(source.loc != s_loc && mut == 0)			return
	if(target.loc != t_loc && mut == 0)			return
	if(LinkBlocked(s_loc,t_loc) && mut == 0)	return
	if(item && source.equipped() != item)		return
	if(source.restrained() && mut == 0) 		return
	if(source.stat)								return

	switch(place)
		if("mask")
			if (target.wear_mask)
				var/obj/item/W = target.wear_mask
				if(!W.canremove) return

				target.u_equip(W)
				W.add_fingerprint(source)
			else
				source.drop_item()
				target.equip_to_slot_if_possible(item, slot_wear_mask, 0, 1)
		if("gloves")
			if (target.gloves)
				var/obj/item/W = target.gloves
				if(!W.canremove) return

				target.u_equip(W)
				W.add_fingerprint(source)
			else
				source.drop_item()
				target.equip_to_slot_if_possible(item, slot_gloves, 0, 1)
		if("eyes")
			if (target.glasses)
				var/obj/item/W = target.glasses
				if(!W.canremove) return

				target.u_equip(W)
				W.add_fingerprint(source)
			else
				source.drop_item()
				target.equip_to_slot_if_possible(item, slot_glasses, 0, 1)
		if("belt")
			if (target.belt)
				var/obj/item/W = target.belt
				if(!W.canremove) return

				target.u_equip(W)
				W.add_fingerprint(source)
			else
				source.drop_item()
				target.equip_to_slot_if_possible(item, slot_belt, 0, 1)
		if("suitstorage")
			if (target.s_store)
				var/obj/item/W = target.s_store
				if(!W.canremove) return

				target.u_equip(W)
				W.add_fingerprint(source)
			else
				source.drop_item()
				target.equip_to_slot_if_possible(item, slot_s_store, 0, 1)
		if("head")
			if (target.head)
				var/obj/item/W = target.head
				if(!W.canremove) return

				target.u_equip(W)
				W.add_fingerprint(source)
			else
				source.drop_item()
				target.equip_to_slot_if_possible(item, slot_head, 0, 1)
		if("ears")
			if (target.ears)
				var/obj/item/W = target.ears
				if(!W.canremove) return

				target.u_equip(W)
				W.add_fingerprint(source)
			else
				source.drop_item()
				target.equip_to_slot_if_possible(item, slot_ears, 0, 1)
		if("shoes")
			if (target.shoes)
				var/obj/item/W = target.shoes
				if(!W.canremove) return

				target.u_equip(W)
				W.add_fingerprint(source)
			else
				source.drop_item()
				target.equip_to_slot_if_possible(item, slot_shoes, 0, 1)
		if("l_hand")
			if (target.l_hand)
				var/obj/item/W = target.l_hand
				target.u_equip(W)
				W.add_fingerprint(source)
			else
				source.drop_item()
				target.equip_to_slot_if_possible(item, slot_l_hand, 0, 1)
		if("r_hand")
			if (target.r_hand)
				var/obj/item/W = target.r_hand
				target.u_equip(W)
				W.add_fingerprint(source)
			else
				source.drop_item()
				target.equip_to_slot_if_possible(item, slot_r_hand, 0, 1)
		if("uniform")
			if (target.w_uniform)
				var/obj/item/W = target.w_uniform
				if(!W.canremove) return

				target.u_equip(W)
				W.add_fingerprint(source)
				W = target.l_store
				if(W) target.u_equip(W)
				W = target.r_store
				if(W) target.u_equip(W)
				W = target.wear_id
				if(W) target.u_equip(W)
			else
				source.drop_item()
				target.equip_to_slot_if_possible(item, slot_w_uniform, 0, 1)
		if("suit")
			if (target.wear_suit)
				var/obj/item/W = target.wear_suit
				if(!W.canremove) return

				target.u_equip(W)
				W.add_fingerprint(source)
			else
				source.drop_item()
				target.equip_to_slot_if_possible(item, slot_wear_suit, 0, 1)
		if("id")
			if (target.wear_id)
				var/obj/item/W = target.wear_id
				if(!W.canremove) return

				target.u_equip(W)
				W.add_fingerprint(source)
			else
				source.drop_item()
				target.equip_to_slot_if_possible(item, slot_wear_id, 0, 1)
		if("back")
			if (target.back)
				var/obj/item/W = target.back
				if(!W.canremove) return

				target.u_equip(W)
				W.add_fingerprint(source)
			else
				source.drop_item()
				target.equip_to_slot_if_possible(item, slot_back, 0, 1)
		if("handcuff")
			if (target.handcuffed)
				var/obj/item/W = target.handcuffed
				target.u_equip(W)
				W.add_fingerprint(source)
				target.lasthandcuff = null
			else
				source.drop_item()
				target.equip_to_slot_if_possible(item, slot_handcuffed, 0, 1)

		if("pockets")
			if(item)
				source.drop_item()
				if(!target.equip_to_slot_if_possible(item, slot_l_store, 0, 1))
					target.equip_to_slot_if_possible(item, slot_r_store, 0, 1)
			else
				if (target.l_store)
					var/obj/item/W = target.l_store
					target.u_equip(W)
					W.add_fingerprint(source)
				if (target.r_store)
					var/obj/item/W = target.r_store
					target.u_equip(W)
					W.add_fingerprint(source)

		if("CPR")
			if (target.cpr_time >= world.time + 30)
				del(src)
				return
			if ((target.health > -100 && target.health < 0))
				target.cpr_time = world.time
				target.adjustOxyLoss(-8)
				for(var/mob/O in viewers(source, null))
					O.show_message(text("\red [source] performs CPR on [target]!"), 1)
				source << "\red Repeat every 7 seconds AT LEAST."
		if("dnainjector")
			if (item)
				var/obj/item/weapon/dnainjector/S = item
				item.add_fingerprint(source)
				item:inject(target, null)
				if (!istype(S, /obj/item/weapon/dnainjector))
					del(src)
					return
				if (S.s_time >= world.time + 30)
					del(src)
					return
				S.s_time = world.time
				for(var/mob/O in viewers(source, null))
					O.show_message(text("\red [] injects [] with the DNA Injector!", source, target), 1)
		if("internal")
			if (target.internal)
				target.internal.add_fingerprint(source)
				target.internal = null
			else
				target.internal = null
				if (!istype(target.wear_mask, /obj/item/clothing/mask))
					return

				if (istype(target.back, /obj/item/weapon/tank))
					target.internal = target.back

				else if(istype(target.belt, /obj/item/weapon/tank))
					target.internal = target.belt

				if (target.internal)
					target.internal.add_fingerprint(source)
					for(var/mob/M in viewers(target, 1))
						M.show_message(text("[] is now running on internals.", target), 1)

	if(source) source.update_clothing()
	if(target) target.update_clothing()
	del(src)
	return

/mob/living/carbon/human/has_organ_for_slot(var/slot)
	var/datum/organ/external/O1
	var/datum/organ/external/O2

	if(slot in list(slot_wear_mask, slot_head, slot_ears, slot_glasses))
		O1 = organs["head"]
		if(!O1.status) return 0

	if(slot == slot_l_hand)
		O1 = organs["l_hand"]
		if(!O1.status) return 0

	if(slot == slot_r_hand)
		O1 = organs["r_hand"]
		if(!O1.status) return 0

	if(slot in list(slot_handcuffed, slot_gloves))
		O1 = organs["l_hand"]
		O2 = organs["r_hand"]
		if(!O1.status && !O2.status)
			return 0

	if(slot == slot_shoes)
		O1 = organs["l_foot"]
		O2 = organs["r_foot"]
		if(!O1.status && !O2.status)
			return 0

	return 1