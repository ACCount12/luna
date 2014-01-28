/mob/proc/equip_to_slot(obj/item/W as obj, slot, redraw_mob = 1)
	return

/mob/proc/has_organ_for_slot(var/slot)
	return 1

//This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible() or advanced_equip_to_slot_if_possible()
//set redraw_mob to 0 if you don't wish the hud to be updated - if you're doing it manually in your own proc.
/mob/living/carbon/monkey/equip_to_slot(obj/item/W as obj, slot, redraw_mob = 1)
	if(!slot) return
	if(!istype(W)) return

	if(W == get_active_hand())
		u_equip(W)

	switch(slot)
		if(slot_back)
			src.back = W
			W.equipped(src, slot)
			//update_inv_back(redraw_mob)
		if(slot_wear_mask)
			src.wear_mask = W
			W.equipped(src, slot)
			//update_inv_wear_mask(redraw_mob)
		if(slot_handcuffed)
			src.handcuffed = W
			//update_inv_handcuffed(redraw_mob)
		if(slot_l_hand)
			src.l_hand = W
			W.equipped(src, slot)
			//update_inv_l_hand(redraw_mob)
		if(slot_r_hand)
			src.r_hand = W
			W.equipped(src, slot)
			//update_inv_r_hand(redraw_mob)
		if(slot_in_backpack)
			W.loc = src.back
		else
			return

	W.layer = 20
	update_clothing()
	return


//This is a SAFE proc. Use this instead of equip_to_splot()!
//set del_on_fail to have it delete W if it fails to equip
//set disable_warning to disable the 'you are unable to equip that' warning.
//unset redraw_mob to prevent the mob from being redrawn at the end.
/mob/proc/equip_to_slot_if_possible(var/obj/item/W, slot, del_on_fail = 0, disable_warning = 0, redraw_mob = 1)
	if(!istype(W)) return 0

	if(!W.mob_can_equip(src, slot, disable_warning))
		if(del_on_fail)
			del(W)
		else if(!disable_warning)
			src << "\red You are unable to equip that." //Only print if del_on_fail is false
		return 0

	equip_to_slot(W, slot, redraw_mob) //This proc should not ever fail.
	return 1

//This is just a commonly used configuration for the equip_to_slot_if_possible() proc, used to equip people when the rounds tarts and when events happen and such.
/mob/proc/equip_to_slot_or_del(obj/item/W as obj, slot)
	return equip_to_slot_if_possible(W, slot, 1, 1, 0)

//The list of slots by priority. equip_to_appropriate_slot() uses this list. Doesn't matter if a mob type doesn't have a slot.
var/list/slot_equipment_priority = list(slot_back, slot_wear_id,\
										slot_w_uniform, slot_wear_suit,\
										slot_wear_mask,	slot_head,\
										slot_shoes,	slot_gloves,\
										slot_ears, slot_glasses,\
										slot_belt, slot_s_store,\
										slot_l_store, slot_r_store)

//puts the item "W" into an appropriate slot in a human's inventory
//returns 0 if it cannot, 1 if successful
/mob/proc/equip_to_appropriate_slot(obj/item/W)
	if(!istype(W)) return 0

	for(var/slot in slot_equipment_priority)
		if(equip_to_slot_if_possible(W, slot, 0, 1, 1)) //del_on_fail = 0; disable_warning = 0; redraw_mob = 1
			return 1

	return 0