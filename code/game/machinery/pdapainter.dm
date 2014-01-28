/obj/machinery/pdapainter
	name = "\improper PDA station"
	desc = "A PDA service machine. To use, simply insert a PDA and choose the desired preset paint scheme."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pdapainter"
	density = 1
	anchored = 1
	var/obj/item/device/pda/storedpda = null
	var/list/colorlist = list("Captain" = "pda-cap", "Chief Engineer" = "pda-ce",
							"Engineer" = "pda-engineering", "Atmospheric Technican" = "pda-atmo",
							"Head Of Security" = "pda-hos", "Warden" = "pda-warden",
							"Security Officer" = "pda-security", "Detective" = "pda-det",
							"Research Director" = "pda-rd", "Scientist" = "pda-tox",
							"Genticist" = "pda-gene", "Roboticist" = "pda-robot",
							"Chemist" = "pda-chem", "Virologist" = "pda-viro",
							"Quartermaster" = "pda-qm", "Cargo Technician" = "pda-cargo",
							"Shaft Miner" = "pda-miner", "Head of Personnel" = "pda-hop",
							"Counselor" = "pda-holy", "Clown" = "pda-clown",
							"Mime" = "pda-mime", "Janitor" = "pda-janitor",
							"Lawyer" = "pda-lawyer", "Hydroponicist" = "pda-hydro",
							"Barman" = "pda-bar", "Chief" = "pda-chef")


/obj/machinery/pdapainter/update_icon()
	overlays.Cut()

	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
		return
	if(storedpda)
		overlays += "[initial(icon_state)]-closed"
	if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

	return

/obj/machinery/pdapainter/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/device/pda))
		if(storedpda)
			user << "There is already a PDA inside."
			return
		else
			var/obj/item/device/pda/P = usr.get_active_hand()
			if(istype(P))
				user.drop_item()
				storedpda = P
				P.loc = src
				P.add_fingerprint(usr)
				update_icon()


/obj/machinery/pdapainter/attack_hand(mob/user as mob)
	..()
	src.add_fingerprint(user)

	if(storedpda)
		var/P = input(user, "Select your color!", "PDA Painting") as null|anything in colorlist
		if(!P)
			return
		if(!in_range(src, user))
			return

		storedpda.icon_state = colorlist[P]
	else
		user << "<span class='notice'>The [src] is empty.</span>"


/obj/machinery/pdapainter/verb/ejectpda()
	set name = "Eject PDA"
	set category = "Object"
	set src in oview(1)

	if(storedpda)
		storedpda.loc = get_turf(src.loc)
		storedpda = null
		update_icon()
	else
		usr << "<span class='notice'>The [src] is empty.</span>"

/obj/machinery/pdapainter/verb/wipepda()
	set name = "Wipe PDA"
	set category = "Object"
	set src in oview(1)

	if(storedpda && alert(src,"Are you sure you want to factory-reset [storedpda]?","PDA station","Yes","No") == "Yes")
		usr << "<span class='notice'>You factory-reset [storedpda], wiping out all it's data.</span>"

		storedpda.name = "PDA"
		storedpda.owner = null
		storedpda.ownjob = null //related to above
		storedpda.mode = 0
		//Secondary variables
		storedpda.fon = 0 //Is the flashlight function on?
		storedpda.silent = 0 //To beep or not to beep, that is the question
		storedpda.toff = 0 //If 1, messenger disabled
		storedpda.tnote = null //Current Texts
		storedpda.ttone = "beep" //The ringtone!
		storedpda.honkamt = 0 //How many honks left when infected with honk.exe
		storedpda.mimeamt = 0 //How many silence left when infected with mime.exe
		storedpda.note = "Congratulations, your ship has chosen the Thinktronic 5230 Personal Data Assistant!" //Current note in the notepad function.

		if(storedpda.id)
			storedpda.id.loc = get_turf(src)
			storedpda.id = null
		/*if(storedpda.pai)
			storedpda.pai.loc = get_turf(src)
			storedpda.pai = null*/

/obj/machinery/pdapainter/power_change()
	..()
	update_icon()