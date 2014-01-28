// Datum used for storing DNA in dna modifiers and data/cloning disks

/datum/dna_buffer
	var/unique_enzymes
	var/struc_enzymes
	var/uni_identity
	var/mutantrace

	var/ckey
	var/mind
	var/owner_name
	var/label

/datum/dna_buffer/proc/copy_from(var/D)
	if(istype(D, /datum/dna_buffer))
		var/datum/dna_buffer/buffer = D
		unique_enzymes = buffer.unique_enzymes
		struc_enzymes = buffer.struc_enzymes
		uni_identity = buffer.uni_identity
		mutantrace = buffer.mutantrace

		ckey = buffer.ckey
		mind = buffer.mind
		owner_name = buffer.owner_name
		label = buffer.label
		return 1

	if(istype(D, /mob/living/carbon))
		var/mob/living/carbon/M = D
		M.dna.check_integrity()
		owner_name = M.real_name
		D = M.dna
		ckey = M.ckey
		mind = M.mind

	if(istype(D, /datum/dna))
		var/datum/dna/buffer = D
		unique_enzymes = buffer.unique_enzymes
		struc_enzymes = buffer.struc_enzymes
		uni_identity = buffer.uni_identity
		mutantrace = buffer.mutantrace
		return 1

	return 0

/datum/dna_buffer/proc/copy_selective(var/mob/living/carbon/M, var/copy = "se")
	if(!iscarbon(M))
		return 0
	M.dna.check_integrity()
	var/datum/dna/buffer = M.dna
	owner_name = M.real_name
	mutantrace = buffer.mutantrace


	switch(copy)
		if("ue") unique_enzymes = buffer.unique_enzymes
		if("se") struc_enzymes = buffer.struc_enzymes
		if("ui") uni_identity = buffer.uni_identity
	return 1