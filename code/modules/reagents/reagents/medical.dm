///////////////
/// MEDICAL ///
///////////////

/datum/reagent
	inaprovaline
		name = "Inaprovaline"
		id = "inaprovaline"
		description = "Inaprovaline is a synaptic stimulant and cardiostimulant. Commonly used to stabilize patients."
		reagent_state = LIQUID
		reagent_color = "#C8A5DC"

		on_mob_life(var/mob/living/M)
			if(!M) M = holder.my_atom
			if(M.losebreath >= 10)
				M.losebreath = max(5, M.losebreath-5)
			holder.remove_reagent(src.id, 0.2)
			return