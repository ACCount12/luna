var/const/JOB_ENGINEERING	= 1
var/const/JOB_SECURITY		= 2
var/const/JOB_MEDICAL		= 4
var/const/JOB_SCIENCE		= 8
var/const/JOB_CIVILIAN		= 16
var/const/JOB_HEAD			= 32

var/const/JOB_HIDDEN		= 512 // Badminous jobs
var/const/JOB_ANTAG			= 1024 // Jobs for event antags as latejoin
// for dept_flag

/datum/job
	var/rank
	var/faction = "Station"
	var/dept_flag
	var/list/access = list()
	var/max_slots = 0

	var/id_type = /obj/item/weapon/card/id
	var/headset_type = /obj/item/device/radio/headset
	var/pda_type = /obj/item/device/pda
	var/pda_slot = slot_belt

	proc/equip_mob(var/mob/living/carbon/human/H, var/id_in_pda = 0)
		var/obj/item/weapon/card/id/id
		var/obj/item/device/pda/pda

		if(id_type)	id = new id_type(H)
		if(pda_type) pda = new pda_type(H)

		if(pda)
			if(id_in_pda && id)
				pda.id = id
				id.loc = pda
				H.equip_if_possible(pda, slot_wear_id)
			else
				H.equip_if_possible(pda, pda_slot)
				if(id) H.equip_if_possible(id, slot_wear_id)

		if(headset_type)
			H.equip_if_possible(new headset_type(H), slot_ears)

		forge_pda_id(H, id, pda)

	proc/get_access()
		return (access + access_maint_tunnels) // maintence for erryone!

	proc/forge_pda_id(var/mob/living/carbon/human/H, var/obj/item/weapon/card/id/id, var/obj/item/device/pda/pda)
		if(istype(id))
			id.registered = H.real_name
			id.assignment = rank
			id.name = "[H.real_name]'s ID Card ([rank])"
			id.access = get_access()

		if(istype(pda))
			pda.owner = H.real_name
			pda.name = "PDA-[H.real_name] ([rank])"

	proc/place_mob(var/mob/living/M, var/join_late = 0)
		var/obj/S = null
		if(!join_late)
			for(var/obj/effect/landmark/start/sloc in world)
				if (sloc.name != rank)
					continue
				if (locate(/mob) in sloc.loc)
					continue
				S = sloc
				break
			if (!S)
				S = locate("start*[rank]") // use old stype
			if (!S) // No start point for rank.
				world << "Map bug: no (unoccupied) start locations available for [rank]. Attempting to use shuttle..."
				var/start = pick(latejoin)
				if(!start)//If it can't even find space  here, something must be *very* wrong. Probably a lazy mapper or early WIP map.
					world << "Map bug: There aren't any start locations for the shuttle, either!."
				else
					M.loc = start

			if (istype(S, /obj/effect/landmark/start) && istype(S.loc, /turf))
				M.loc = S.loc
		else
			M.loc = pick(latejoin)

var/list/all_jobs = list()

/proc/setup_jobs()
	all_jobs = list()
	for(var/type in typesof(/datum/job))
		var/datum/job/J = new type()
		if(J.rank && J.max_slots)
			all_jobs.Add(J)

/proc/get_jobs_datums(var/get_empty = 1, var/get_antags = 0, var/get_special = 0)
	if(get_empty && get_antags && get_special)
		return all_jobs

	var/list/jobs = list()
	for(var/datum/job/J in all_jobs)
		if(!J.max_slots && !get_empty)
			continue

		if((J.dept_flag) && !get_special)
			continue

		if((J.dept_flag) && !get_antags)
			continue

		jobs.Add(J)
	return jobs

/proc/get_job_datum(var/job)
	if(!all_jobs.len)
		setup_jobs()

	for(var/datum/job/J in all_jobs)
		if(J.rank == job)
			return J

	return null

/proc/get_access(var/job)
	var/datum/job/J = get_job_datum(job)
	if(istype(J))
		return J.get_access()
	return list()