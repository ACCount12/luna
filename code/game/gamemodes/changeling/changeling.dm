/datum/game_mode/changeling
	name = "changeling"
	config_tag = "changeling"


/datum/game_mode/changeling/post_setup()
	var/list/possible_changelings = get_possible_changelings()

	if(possible_changelings.len>0)
		changeling = pick(possible_changelings)

	changeling.current.make_changeling()
	changeling.special_role = "Changeling"
	changelings += changeling

	changeling.current << "<B>\red You are a changeling!</B>"
	changeling.current << "<B>You must complete the following tasks:</B>"

	var/obj_count = 1
	for(var/datum/objective/objective in SelectChangelingObjectives(changeling.assigned_role, changeling))
		changeling.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		obj_count++

	spawn (rand(waittime_l, waittime_h))
		send_intercept()

/datum/game_mode/changeling/proc/get_possible_changelings()
	var/list/candidates = list()
	for(var/mob/living/carbon/player in mob_list)
		if (player.client)
			if(BE_CHANGELING in player.client.prefs)
				candidates += player.mind

	if(candidates.len < 1)
		for(var/mob/living/carbon/player in mob_list)
			if (player.client)
				candidates += player.mind

	return candidates

//Centcom Update - in testing, copied mostly from Wizard.
/datum/game_mode/changeling/send_intercept()
	var/intercepttext = "<FONT size = 3><B>Cent. Com. Update</B> Requested staus information:</FONT><HR>"
	intercepttext += "<B> Cent. Com has recently been contacted by the following syndicate affiliated organisations in your area, please investigate any information you may have:</B>"

	var/list/possible_modes = list()
	possible_modes.Add("revolution", "wizard", "nuke", "traitor", "malf", "changeling", "cult")
	possible_modes -= "[ticker.mode]"
	var/number = pick(2, 3)
	var/i = 0
	for(i = 0, i < number, i++)
		possible_modes.Remove(pick(possible_modes))
	possible_modes.Insert(rand(possible_modes.len), "[ticker.mode]")

	var/datum/intercept_text/i_text = new /datum/intercept_text
	for(var/A in possible_modes)
		intercepttext += i_text.build(A, changeling)

	for (var/obj/machinery/computer/communications/comm in world)
		if (!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "paper- 'Cent. Com. Status Summary'"
			intercept.info = intercepttext

			comm.messagetitle.Add("Cent. Com. Status Summary")
			comm.messagetext.Add(intercepttext)

	command_alert("Summary downloaded and printed out at all communications consoles.", "Enemy communication intercept. Security Level Elevated.")
	world << sound('intercept.ogg')

/datum/game_mode/changeling/declare_completion()
	for(var/datum/mind/mind in changelings)
		var/changelingwin = 1
		var/changeling_name
		var/totalabsorbed = mind.changeling.absorbed_dna.len - 1

		if(mind.current)
			changeling_name = "[mind.current.real_name] (played by [mind.key])"
		else
			changeling_name = "[mind.key] (character destroyed)"

		world << "<B>The changeling was [changeling_name]</B>"
		world << "<B>Genomes absorbed: [totalabsorbed]</B>"

		var/count = 1
		for(var/datum/objective/objective in mind.objectives)
			if(objective.check_completion())
				world << "<B>Objective #[count]</B>: [objective.explanation_text] \green <B>Success</B>"
			else
				world << "<B>Objective #[count]</B>: [objective.explanation_text] \red Failed"
				changelingwin = 0
			count++

		if(changelingwin)
			world << "<B>The changeling was successful!<B>"
		else
			world << "<B>The changeling has failed!<B>"
	return 1
	//	. = ..()

/datum/game_mode/changeling/proc/get_mob_list()
	var/list/mobs = list()
	for(var/mob/living/player in world)
		if (player.client)
			mobs += player
	return mobs

/datum/game_mode/changeling/proc/pick_human_name_except(excluded_name)
	var/list/names = list()
	for(var/mob/living/player in world)
		if (player.client && (player.real_name != excluded_name))
			names += player.real_name
	if(!names.len)
		return null
	return pick(names)

/datum/game_mode/proc/grant_changeling_powers(mob/living/carbon/human/changeling_mob)
	if (!istype(changeling_mob))
		return
	changeling_mob.make_changeling()