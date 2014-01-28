/proc/SetupOccupationsList()
	var/list/new_occupations = list()

	for(var/occupation in occupations)
		if (!(new_occupations.Find(occupation)))
			new_occupations[occupation] = 1
		else
			new_occupations[occupation] += 1

	occupations = new_occupations
	return


/proc/FindOccupationCandidates(list/unassigned, job, level)
	var/list/candidates = list()

	for (var/mob/new_player/player in unassigned)
		if (level == 1 && player.preferences.occupation1 == job && !jobban_isbanned(player, job))
			candidates += player

		if (level == 2 && player.preferences.occupation2 == job && !jobban_isbanned(player, job))
			candidates += player

		if (level == 3 && player.preferences.occupation3 == job && !jobban_isbanned(player, job))
			candidates += player

	return candidates


/proc/PickOccupationCandidate(list/candidates)
	if (candidates.len > 0)
		var/list/randomcandidates = shuffle(candidates)
		candidates -= randomcandidates[1]
		return randomcandidates[1]

	return null


/proc/SetTitles()
	for (var/mob/new_player/player in world)
		if(!player.preferences) continue
		if(player.preferences.occupation1 == player.mind.assigned_role && player.preferences.title1)
			player.mind.title = player.preferences.title1
		else if(player.preferences.occupation2 == player.mind.assigned_role && player.preferences.title2)
			player.mind.title = player.preferences.title2
		else if(player.preferences.occupation3 == player.mind.assigned_role && player.preferences.title3)
			player.mind.title = player.preferences.title3
	return 0


/proc/DivideOccupations()
	var/list/unassigned = list()
	var/list/occupation_choices = occupations.Copy()
	var/list/occupation_eligible = occupations.Copy()
	occupation_choices = shuffle(occupation_choices)

	for (var/mob/new_player/player in world)
		if (player.client && player.ready && !player.mind.assigned_role)
			unassigned += player

			// If someone picked AI before it was disabled, or has a saved profile with it
			// on a game that now lacks it, this will make sure they don't become the AI,
			// by changing that choice to Captain.
			if (!config.allow_ai)
				if (player.preferences.occupation1 == "AI")
					player.preferences.occupation1 = "Captain"
				if (player.preferences.occupation2 == "AI")
					player.preferences.occupation2 = "Captain"
				if (player.preferences.occupation3 == "AI")
					player.preferences.occupation3 = "Captain"
			if (jobban_isbanned(player, player.preferences.occupation1))
				player.preferences.occupation1 = "Unassigned"
			if (jobban_isbanned(player, player.preferences.occupation2))
				player.preferences.occupation2 = "Unassigned"
			if (jobban_isbanned(player, player.preferences.occupation3))
				player.preferences.occupation3 = "Unassigned"

	if (unassigned.len == 0)
		return 0

	var/mob/new_player/captain_choice = null

	for (var/level = 1 to 3)
		var/list/captains = FindOccupationCandidates(unassigned, "Captain", level)
		for(var/mob/new_player/traitorcheck in captains)	//Do not allow Traitors to choose to be Captain.  Remove them from the list of potential Captains.
			if(traitorcheck.mind.special_role)
				captains -= traitorcheck
		var/mob/new_player/candidate = PickOccupationCandidate(captains)

		if (candidate != null)
			captain_choice = candidate
			unassigned -= captain_choice
			break

	if (captain_choice == null && unassigned.len > 0)
		unassigned = shuffle(unassigned)
		var/mob/new_player/traitorcheck = unassigned[1]
		if (traitorcheck.mind.special_role)		//If a Traitor is first in the list of people checked to be Captain, reshuffle the list.  This will decrease the chance of a Traitor Captains without eliminating it entirely.
			unassigned = shuffle(unassigned)

		for(var/mob/new_player/player in unassigned)
			if(jobban_isbanned(player, "Captain"))
				continue
			else
				captain_choice = player
				break
		unassigned -= captain_choice

	if (captain_choice == null)
		world << "Captainship not forced on anyone."
	else
		captain_choice.mind.assigned_role = "Captain"

	//so that an AI is chosen during this game mode
	if(ticker.mode.name == "AI malfunction" && unassigned.len > 0)
		var/mob/new_player/ai_choice = null

		for (var/level = 1 to 3)
			var/list/ais = FindOccupationCandidates(unassigned, "AI", level)
			var/mob/new_player/candidate = PickOccupationCandidate(ais)

			if (candidate != null)
				ai_choice = candidate
				unassigned -= ai_choice
				break

		if (ai_choice == null && unassigned.len > 0)
			unassigned = shuffle(unassigned)
			for(var/mob/new_player/player in unassigned)
				if(jobban_isbanned(player, "AI"))
					continue
				else
					ai_choice = player
					break
			unassigned -= ai_choice

		if (ai_choice != null)
			ai_choice.mind.assigned_role = "AI"
		else
			world << "It is [ticker.mode.name] and there is no AI, someone should fix this"

	for (var/level = 1 to 3)
		if (unassigned.len == 0)	//everyone is assigned
			break

		for (var/occupation in assistant_occupations)
			if (unassigned.len == 0)
				break
			var/list/candidates = FindOccupationCandidates(unassigned, occupation, level)
			for (var/mob/new_player/candidate in candidates)
				candidate.mind.assigned_role = occupation
				unassigned -= candidate

		for (var/occupation in occupation_choices)
			if (unassigned.len == 0)
				break
			if(ticker.mode.name == "AI malfunction" && occupation == "AI")
				continue
			var/eligible = occupation_eligible[occupation]
			if (eligible == 0)
				continue
			var/list/candidates = FindOccupationCandidates(unassigned, occupation, level)
			var/eligiblechange = 0
			while (eligible--)
				var/mob/new_player/candidate = PickOccupationCandidate(candidates)
				if (candidate == null)
					break
				candidate.mind.assigned_role = occupation
				unassigned -= candidate
				eligiblechange++
			occupation_eligible[occupation] -= eligiblechange

	if (unassigned.len)
		unassigned = shuffle(unassigned)
		for (var/occupation in occupation_choices)
			if (unassigned.len == 0)
				break
			if(ticker.mode.name == "AI malfunction" && occupation == "AI")
				continue
			var/eligible = occupation_eligible[occupation]
			while (eligible-- && unassigned.len > 0)
				var/mob/new_player/candidate = unassigned[1]
				if (candidate == null)
					break
				candidate.mind.assigned_role = occupation
				unassigned -= candidate

	for (var/mob/new_player/player in unassigned)
		player.mind.assigned_role = pick(assistant_occupations)

	// Assign vacant head of department roles at random from the departments under them.
	for (var/department in get_job_types())
		var/list/candidate_list = list()
		var/list/job_list = get_type_jobs(department)
		var/head = get_department_head(department)

		// Skip departments that don't have assigned heads.
		if (!head) continue

		// Build candidate list from already-assigned players.
		for (var/mob/new_player/player in world)
			if(!player.mind) continue
			// Clear the list if an existing head is found. We don't want two HoDs.
			if (player.mind.assigned_role == head)
				candidate_list = list()
				break
			// Don't give the job to anyone banned or in the wrong department either.
			if (job_list.Find(player.mind.assigned_role) && !jobban_isbanned(player, head))
				candidate_list += player

		// Assign a candidate at random. Leave it vacant if there's no one suitable.
		if (candidate_list.len > 0)
			candidate_list = shuffle(candidate_list)
			var/mob/new_player/candidate = candidate_list[1]
			candidate.mind.assigned_role = head

	return 1

/mob/living/carbon/human/proc/Equip_Rank(rank, joined_late)
	var/datum/job/J = get_job_datum(rank)
	if(J)
		J.equip_mob(src)
	else
		src << "RUH ROH! Your job is [rank] and the game just can't handle it! Please report this bug to an administrator."

	src << "<B>You are the [rank].</B>"
	src.job = rank
	src.mind.assigned_role = rank

	J.place_mob(src, joined_late)
	src.update_clothing()
	return