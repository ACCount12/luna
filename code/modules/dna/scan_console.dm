/obj/machinery/computer/scan_consolenew
	name = "DNA Modifier Access Console"
	desc = "Scand DNA."
	icon = 'icons/obj/computer.dmi'
	icon_state = "scanner"
	density = 1
	var/uniblock = 1.0
	var/strucblock = 1.0
	var/subblock = 1.0
	var/unitarget = 1
	var/unitargethex = 1
	var/status = null
	var/radacc = 1.0

	var/buffers_amt = 3
	var/list/buffers = list(3)

	var/injmode = 0 // 0 for standart, 1 for blocky
	var/delete = 0
	var/injectorready = 0	//Quick fix for issue 286 (screwdriver the screen twice to restore injector)	-Pete
	var/temphtml = null
	var/obj/machinery/dna_scannernew/connected = null
	var/obj/item/weapon/disk/data/genetics/diskette = null

	var/allow_rad = 0
	var/allow_antitox = 0

	anchored = 1.0
//	use_power = 1
//	idle_power_usage = 10
//	active_power_usage = 400

	brightnessred = 0
	brightnessgreen = 2
	brightnessblue = 0

/obj/item/weapon/circuitboard/computer/scan_consolenew
	name = "Circuit board (DNA Machine)"
	computertype = /obj/machinery/computer/scan_consolenew
	origin_tech = "programming=2;biotech=2"

/obj/machinery/computer/scan_consolenew/attackby(obj/item/I as obj, mob/user as mob)
	..()
	if (istype(I, /obj/item/weapon/disk/data)) //INSERT SOME DISKETTES
		if (!src.diskette)
			user.drop_item()
			I.loc = src
			src.diskette = I
			user << "You insert [I]."
			src.updateUsrDialog()
			return
	else
		src.attack_hand(user)
	return

/obj/machinery/computer/scan_consolenew/ex_act(severity)
	switch(severity)
		if(1.0)
			//SN src = null
			del(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				del(src)
				return
		else
	return

/obj/machinery/computer/scan_consolenew/blob_act()
	if(prob(75))
		del(src)

/obj/machinery/computer/scan_consolenew/power_change()
	if(stat & BROKEN)
		icon_state = "broken"
	else if(powered())
		icon_state = initial(icon_state)
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			src.icon_state = "c_unpowered"
			stat |= NOPOWER

/obj/machinery/computer/scan_consolenew/New()
	..()
	spawn(5)
		try_connect()
	spawn(100)
		injectorready = 1

/obj/machinery/computer/scan_consolenew/proc/try_connect()
	for(dir in cardinal)
		connected = locate(/obj/machinery/dna_scannernew, get_step(src, dir))
		if(!isnull(connected))
			break


/obj/machinery/computer/scan_consolenew/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/disk/data) && !diskette)
		user.drop_item()
		W.loc = src
		src.diskette = W
		user << "You insert [W]."
		src.updateUsrDialog()

/obj/machinery/computer/scan_consolenew/attack_hand(user as mob)
	if(..())
		return
	var/dat

	if (!delete && temphtml) //Window in buffer - its a menu, dont add clear message
		dat = text("[temphtml]<BR><BR><A href='?src=\ref[src];clear=1'>Main Menu</A><BR><A href='?src=\ref[src];buffermenu=1'>Buffers Menu</A><BR><BR>")
	else if(connected) //Is something connected?
		var/mob/living/occupant = connected.get_occupant()
		dat = "<font color='blue'><B>Occupant Statistics:</B></FONT><BR>" //Blah obvious
		if(occupant && occupant.dna) //is there REALLY someone in there?
			if(NOCLONE in occupant.mutations)
				dat += "The occupant's DNA structure is ruined beyond recognition, please insert a subject with an intact DNA structure.<BR><BR>" //NOPE. -Pete
				dat += text("<A href='?src=\ref[];buffermenu=1'>View/Edit/Transfer Buffer</A><BR><BR>", src)
				dat += text("<A href='?src=\ref[];radset=1'>Radiation Emitter Settings</A><BR><BR>", src)
			else
				if (!istype(occupant,/mob/living/carbon/human))
					sleep(1)
				var/t1
				switch(occupant.stat) // obvious, see what their status is
					if(0)	t1 = "Conscious"
					if(1)	t1 = "Unconscious"
					else	t1 = "*dead*"
				dat += text("[]\tHealth %: [] ([])</FONT><BR>", (occupant.health > 50 ? "<font color='blue'>" : "<font color='red'>"), occupant.health, t1)
				dat += text("<font color='green'>Radiation Level: []%</FONT><BR><BR>", occupant.radiation)
				dat += text("Unique Enzymes : <font color='blue'>[]</FONT><BR>", uppertext(occupant.dna.unique_enzymes))
				dat += text("Unique Identifier: <font color='blue'>[]</FONT><BR>", occupant.dna.uni_identity)
				dat += text("Structural Enzymes: <font color='blue'>[]</FONT><BR><BR>", occupant.dna.struc_enzymes)
				dat += "<A href='?src=\ref[src];unimenu=1'>Modify Unique Identifier</A><BR>"
				dat += "<A href='?src=\ref[src];strucmenu=1'>Modify Structural Enzymes</A><BR><BR>"
				dat += "<A href='?src=\ref[src];buffermenu=1'>View/Edit/Transfer Buffer</A><BR><BR>"
				dat += "<A href='?src=\ref[src];genpulse=1'>Pulse Radiation</A><BR>"
				dat += "<A href='?src=\ref[src];radset=1'>Radiation Emitter Settings</A><BR><BR>"
				dat += "<A href='?src=\ref[src];inject=inaprovaline'>Inject Inaprovaline</A><BR><BR>"
				if(allow_rad)
					dat += "<A href='?src=\ref[src];inject=hyronalin'>Inject Hyronalin</A><BR><BR>"
				if(allow_antitox)
					dat += "<A href='?src=\ref[src];inject=anti_toxin'>Inject Anti-Toxin</A><BR><BR>"
		else
			dat += "The scanner is empty.<BR><BR>"
			dat += "<A href='?src=\ref[src];buffermenu=1'>View/Edit/Transfer Buffer</A><BR><BR>"
			dat += "<A href='?src=\ref[src];radset=1'>Radiation Emitter Settings</A><BR><BR>"
		if (!connected.locked)
			dat += "<A href='?src=\ref[src];locked=1'>Lock (Unlocked)</A><BR>"
		else
			dat += "<A href='?src=\ref[src];locked=1'>Unlock (Locked)</A><BR>"
			//Other stuff goes here
		if (!isnull(diskette))
			dat += "<A href='?src=\ref[src];eject_disk=1'>Eject Disk</A><BR>"
		dat += "<BR><BR><A href='?src=\ref[user];mach_close=scannernew'>Close</A>"
	else
		dat = "<font color='red'> Error: No DNA Modifier connected. </FONT>"
		try_connect()
	user << browse(dat, "window=scannernew;size=550x625")
	onclose(user, "scannernew")
	return

/obj/machinery/computer/scan_consolenew/proc/all_dna_blocks(var/buffer)
	var/list/arr = list()
	for(var/i = 1, i <= length(buffer)/3, i++)
		arr += "[i]:[copytext(buffer,i*3-2,i*3+1)]"
	return arr

/obj/machinery/computer/scan_consolenew/proc/setInjectorBlock(var/obj/item/weapon/dnainjector/I, var/blk, var/buffer)
	var/pos = findtext(blk,":")
	if(!pos) return 0
	var/id = text2num(copytext(blk,1,pos))
	if(!id) return 0
	I.block = id
	I.dna = copytext(buffer,id*3-2,id*3+1)
	return 1

/obj/machinery/computer/scan_consolenew/Topic(href, href_list)
	if(..())
		return
	if(!istype(usr.loc, /turf))
		return
	if(!src || !connected)
		return

	if ((usr.contents.Find(src) || in_range(src, usr) && istype(src.loc, /turf)) || (istype(usr, /mob/living/silicon)))
		usr.set_machine(src)

		var/mob/living/carbon/occupant = connected.get_occupant()
		var/datum/dna_buffer/tempbuffer

		if(href_list["buffer"])
			tempbuffer = buffers[text2num(href_list["buffer"])]
			if(!istype(tempbuffer))
				tempbuffer = new
				buffers[text2num(href_list["buffer"])] = tempbuffer

		if (href_list["locked"])
			if (connected && occupant)
				connected.toggle_lock()
		////////////////////////////////////////////////////////
		if (href_list["genpulse"])
			if(!occupant || !occupant.dna)//Makes sure someone is in there (And valid) before trying anything
				temphtml = text("No viable occupant detected.")//More than anything, this just acts as a sanity check in case the option DOES appear for whatever reason
				usr << browse(temphtml, "window=scannernew;size=550x650")
				onclose(usr, "scannernew")
			src.delete = 1
			src.temphtml = "Working ... Please wait ([connected.radduration] Seconds)"
			usr << browse(temphtml, "window=scannernew;size=550x650")
			onclose(usr, "scannernew")
			connected.radpulse()
			sleep(10*connected.radduration)
			temphtml = null
			usr << browse(temphtml, "window=scannernew;size=550x650")
			delete = 0

		if (href_list["radset"] && connected)
			temphtml = "Radiation Duration: <B><font color='green'>[connected.radduration]</B></FONT><BR>"
			temphtml += "Radiation Intensity: <font color='green'><B>[connected.radstrength]</B></FONT><BR><BR>"
			temphtml += "<A href='?src=\ref[src];rad_le=-2'>-</A> Duration <A href='?src=\ref[src];rad_le=2'>+</A><BR>"
			temphtml += "<A href='?src=\ref[src];rad_in=-1'>-</A> Intesity <A href='?src=\ref[src];rad_in=1'>+</A><BR>"
			delete = 0
		if (href_list["rad_le"] && connected)
			if(!connected.wires.IsIndexCut(DNASCAN_WIRE_RADDUR))
				connected.radduration += text2num(href_list["rad_le"])
				connected.radduration = Clamp(connected.radduration, 1, 20)
			dopage(src,"radset")

		if (href_list["rad_in"] && connected)
			if(!connected.wires.IsIndexCut(DNASCAN_WIRE_RADSTR))
				connected.radstrength += text2num(href_list["rad_in"])
				connected.radstrength = Clamp(connected.radstrength, 1, 10)
			dopage(src,"radset")

		////////////////////////////////////////////////////////
		if (href_list["unimenu"])
			if(!occupant || !occupant.dna)
				temphtml = text("No viable occupant detected.")
				usr << browse(temphtml, "window=scannernew;size=550x650")
				onclose(usr, "scannernew")

			// New way of displaying DNA blocks
			temphtml = text("Unique Identifier: <font color='blue'>[getblockstring(src.connected.occupant.dna.uni_identity,uniblock,subblock,3, src,1)]</FONT><br><br>")

			temphtml += text("Selected Block: <font color='blue'><B>[]</B></FONT><BR>", uniblock)
			temphtml += text("<A href='?src=\ref[];unimenuminus=1'><-</A> Block <A href='?src=\ref[];unimenuplus=1'>-></A><BR><BR>", src, src)
			temphtml += text("Selected Sub-Block: <font color='blue'><B>[]</B></FONT><BR>", subblock)
			temphtml += text("<A href='?src=\ref[];unimenusubminus=1'><-</A> Sub-Block <A href='?src=\ref[];unimenusubplus=1'>-></A><BR><BR>", src, src)
			temphtml += text("Selected Target: <font color='blue'><B>[]</B></FONT><BR>", unitargethex)
			temphtml += text("<A href='?src=\ref[];unimenutargetminus=1'><-</A> Target <A href='?src=\ref[];unimenutargetplus=1'>-></A><BR><BR>", src, src)
			temphtml += "<B>Modify Block:</B><BR>"
			temphtml += text("<A href='?src=\ref[];unipulse=1'>Irradiate</A><BR>", src)
			delete = 0
		if (href_list["unimenuplus"])
			if (uniblock < 13)
				uniblock++
			else
				uniblock = 1
			dopage(src,"unimenu")
		if (href_list["unimenuminus"])
			if (uniblock > 1)
				uniblock--
			else
				uniblock = 13
			dopage(src,"unimenu")
		if (href_list["unimenusubplus"])
			if (subblock < 3)
				subblock++
			else
				subblock = 1
			dopage(src,"unimenu")
		if (href_list["unimenusubminus"])
			if (subblock > 1)
				subblock--
			else
				subblock = 3
			dopage(src,"unimenu")
		if (href_list["unimenutargetplus"])
			if (unitarget < 15)
				unitarget++
				unitargethex = unitarget
				switch(unitarget)
					if(10)
						unitargethex = "A"
					if(11)
						unitargethex = "B"
					if(12)
						unitargethex = "C"
					if(13)
						unitargethex = "D"
					if(14)
						unitargethex = "E"
					if(15)
						unitargethex = "F"
			else
				unitarget = 0
				unitargethex = 0
			dopage(src,"unimenu")
		if (href_list["unimenutargetminus"])
			if (unitarget > 0)
				unitarget--
				unitargethex = unitarget
				switch(unitarget)
					if(10) unitargethex = "A"
					if(11) unitargethex = "B"
					if(12) unitargethex = "C"
					if(13) unitargethex = "D"
					if(14) unitargethex = "E"
			else
				unitarget = 15
				unitargethex = "F"
			dopage(src,"unimenu")
		if (href_list["uimenuset"] && href_list["uimenusubset"]) // This chunk of code updates selected block / sub-block based on click
			var/menuset = text2num(href_list["uimenuset"])
			var/menusubset = text2num(href_list["uimenusubset"])
			if ((menuset <= 13) && (menuset >= 1))
				src.uniblock = menuset
			if ((menusubset <= 3) && (menusubset >= 1))
				src.subblock = menusubset
			dopage(src, "unimenu")
		if (href_list["unipulse"])
			if(!occupant)
				return

			delete = 1
			temphtml = "Working ... Please wait ([connected.radduration] Seconds)"
			usr << browse(temphtml, "window=scannernew;size=550x650")
			onclose(usr, "scannernew")
			connected.uni_pulse(uniblock, subblock, unitarget)
			sleep(10*connected.radduration)
			if (!occupant)
				temphtml = null
				delete = 0
				return null

			dopage(src,"unimenu")
			src.delete = 0
		////////////////////////////////////////////////////////
		if (href_list["inject"])
			if(!occupant || !occupant.dna)
				temphtml = text("No viable occupant detected.")
				usr << browse(temphtml, "window=scannernew;size=550x650")
				onclose(usr, "scannernew")

			if(istype(occupant))
				if (occupant.reagents.get_reagent_amount(href_list["inject"]) < 50)
					occupant.reagents.add_reagent(href_list["inject"], 10)
					usr << text("Occupant now has [round(occupant.reagents.get_reagent_amount(href_list["inject"]))] units of [href_list["inject"]] in his/her bloodstream.")
				else
					usr << text("Occupant has [round(occupant.reagents.get_reagent_amount(href_list["inject"]))] units of [href_list["inject"]] in his/her bloodstream.")
				src.delete = 0
		////////////////////////////////////////////////////////
		if (href_list["strucmenu"])
			if(occupant)
				// New shit, it doesn't suck (as much)
				temphtml = text("Structural Enzymes: <font color='blue'>[getblockstring(src.connected.occupant.dna.struc_enzymes,strucblock,subblock,3,src,0)]</FONT><br><br>")
				// SE of occupant,	selected block,	selected subblock,	block size (3 subblocks)
				temphtml += text("Selected Block: <font color='blue'><B>[]</B></FONT><BR>", src.strucblock)
				temphtml += text("<A href='?src=\ref[];strucmenuminus=1'><-</A> Block <A href='?src=\ref[];strucmenuplus=1'>-></A><BR><BR>", src, src)
				temphtml += text("Selected Sub-Block: <font color='blue'><B>[]</B></FONT><BR>", src.subblock)
				temphtml += text("<A href='?src=\ref[];strucmenusubminus=1'><-</A> Sub-Block <A href='?src=\ref[];strucmenusubplus=1'>-></A><BR><BR>", src, src)
				temphtml += "<B>Modify Block:</B><BR>"
				temphtml += text("<A href='?src=\ref[];strucpulse=1'>Irradiate</A><BR>", src)
				delete = 0
		if (href_list["strucmenuplus"])
			if (strucblock < STRUCDNASIZE)
				strucblock++
			else
				strucblock = 1
			dopage(src,"strucmenu")
		if (href_list["strucmenuminus"])
			if (strucblock > 1)
				strucblock--
			else
				strucblock = STRUCDNASIZE
			dopage(src,"strucmenu")
		if (href_list["strucmenusubplus"])
			if (subblock < 3)
				subblock++
			else
				subblock = 1
			dopage(src,"strucmenu")
		if (href_list["strucmenusubminus"])
			if (subblock > 1)
				subblock--
			else
				subblock = 3
			dopage(src,"strucmenu")
		if (href_list["semenuset"] && href_list["semenusubset"]) // This chunk of code updates selected block / sub-block based on click (se stands for strutural enzymes)
			var/menuset = text2num(href_list["semenuset"])
			var/menusubset = text2num(href_list["semenusubset"])
			if ((menuset <= STRUCDNASIZE) && (menuset >= 1))
				src.strucblock = menuset
			if ((menusubset <= 3) && (menusubset >= 1))
				src.subblock = menusubset
			dopage(src, "strucmenu")
		if (href_list["strucpulse"])
			if(occupant)
				delete = 1
				temphtml = "Working ... Please wait ([connected.radduration] Seconds)"
				usr << browse(temphtml, "window=scannernew;size=550x650")
				onclose(usr, "scannernew")
				connected.struct_pulse(strucblock, subblock)
				sleep(10*connected.radduration)
			else
				temphtml = null
				delete = 0
				return null

			dopage(src,"strucmenu")
			src.delete = 0
		////////////////////////////////////////////////////////
		if (href_list["buffermenu"])
			if(occupant == usr)
				usr << browse(null, "window=scannernew;size=550x625")
				return
			temphtml = ""
			for(var/i=1, i < buffers_amt, i++)
				if (!istype(buffers[i], /datum/dna_buffer))
					temphtml += "Buffer [i] empty<BR>"
					if(occupant)
						temphtml += "Save: "
						temphtml += "<A href='?src=\ref[src];blockadd=ui;buffer=[i]'>UI</A> - "
						temphtml += "<A href='?src=\ref[src];blockadd=ue;buffer=[i]'>UE</A> - "
						temphtml += "<A href='?src=\ref[src];blockadd=se;buffer=[i]'>SE</A> "
					temphtml += "<BR>"
				else
					var/datum/dna_buffer/curbuffer = buffers[i]
					temphtml = "<B>Buffer [i]:</B><BR>"
					temphtml += "SE: <font color='blue'>[curbuffer.struc_enzymes]</FONT><BR>"
					temphtml += "UE: <font color='blue'>[curbuffer.unique_enzymes]</FONT><BR>"
					temphtml += "UI: <font color='blue'>[curbuffer.uni_identity]</FONT><BR>"
					temphtml += "By: <font color='blue'>[curbuffer.owner_name]</FONT><BR>"
					temphtml += "Label: <font color='blue'>[curbuffer.label]</FONT><BR>"
					if(occupant)
						temphtml += "Save from occupant: "
						temphtml += "<A href='?src=\ref[src];blockadd=ui;buffer=[i]'>UI</A> - "
						temphtml += "<A href='?src=\ref[src];blockadd=ue;buffer=[i]'>UE</A> - "
						temphtml += "<A href='?src=\ref[src];blockadd=se;buffer=[i]'>SE</A><BR>"
						temphtml += "Transfer to occupant: "
						temphtml += "<A href='?src=\ref[src];buffer_transfer=ui;buffer=[i]'>UI</A> - "
						temphtml += "<A href='?src=\ref[src];buffer_transfer=ue;buffer=[i]'>UE</A> - "
						temphtml += "<A href='?src=\ref[src];buffer_transfer=se;buffer=[i]'>SE</A><BR>"

					temphtml += "Transfer to injector: "
					temphtml += "<A href='?src=\ref[src];injector=ui;buffer=[i]'>UI</A> - "
					temphtml += "<A href='?src=\ref[src];injector=ue;buffer=[i]'>UI+UE</A> - "
					temphtml += "<A href='?src=\ref[src];injector=se;buffer=[i]'>SE</A><BR>"
					temphtml += "Injector Mode: [injmode ? "Block" : "Full"] <A href='?src=\ref[src];injmode=1'>Toggle</A>"

					if(diskette)
						temphtml += "Disk: <A href='?src=\ref[src];save_disk=1;buffer=[i]'>Save To</a> | "
						temphtml += "<A href='?src=\ref[src];load_disk=1;buffer=[i]'>Load From</a><br>"
					temphtml += "<A href='?src=\ref[src];label=1;buffer=[i]'>Edit Label</A><BR>"
					temphtml += "<A href='?src=\ref[src];clear=1;buffer=[i]'>Clear Buffer</A><BR><BR>"


		if (href_list["blockadd"])
			tempbuffer.copy_selective(connected.occupant, href_list["blockadd"])
			dopage(src,"buffermenu")

		if (href_list["clear"])
			buffers.Remove(tempbuffer)
			del tempbuffer
			dopage(src,"buffermenu")

		if (href_list["label"])
			tempbuffer.label = input("New Label:","Edit Label","Infos here")
			dopage(src,"buffermenu")

		if (href_list["buffer_transfer"])
			if (!connected.occupant)
				return

			switch(href_list["buffer_transfer"])
				if("ui")
					if(tempbuffer.uni_identity)
						occupant.dna.uni_identity = tempbuffer.uni_identity
				if("ue")
					if(tempbuffer.unique_enzymes)
						occupant.dna.unique_enzymes = tempbuffer.unique_enzymes
						occupant.real_name = tempbuffer.owner_name
						occupant.name = tempbuffer.owner_name
				if("se")
					if(tempbuffer.struc_enzymes)
						occupant.dna.struc_enzymes = tempbuffer.struc_enzymes
						domutcheck(occupant,connected)

			updateappearance(occupant,occupant.dna.uni_identity)
			temphtml = "Transfered."
			occupant.radiation += rand(10,40)
			delete = 0

		if (href_list["injmode"])
			injmode = !injmode

		if (href_list["injector"])
			if(src.injectorready)
				var/obj/item/weapon/dnainjector/I = new /obj/item/weapon/dnainjector
				var/success = 1
				var/writedata

				I.dnatype = href_list["injector"]

				switch(href_list["injector"])
					if("se")
						writedata = tempbuffer.struc_enzymes
					if("ui")
						writedata = tempbuffer.uni_identity
					if("ue")
						writedata = tempbuffer.uni_identity
						if(tempbuffer.owner_name)
							I.ue = tempbuffer.owner_name
						I.dnatype = "ui"

				if(!writedata)
					success = 0
				else if(injmode)
					var/blk = input(usr,"Select Block","Block") in all_dna_blocks(writedata)
					success = setInjectorBlock(I, blk, writedata)
				else
					I.dna = writedata

				if(success)
					I.loc = src.loc
					if(tempbuffer.label)
						I.name += " ([tempbuffer.label])"
					src.temphtml = "Injector created."
					src.delete = 0
					src.injectorready = 0
					spawn(300)
						src.injectorready = 1
				else
					del(I)
					src.temphtml = "Error in injector creation."
					src.delete = 0
			else
				src.temphtml = "Replicator not ready yet."
				src.delete = 0

		////////////////////////////////////////////////////////
		if (href_list["load_disk"])
			if (!istype(diskette) || !diskette.dna)
				return
			tempbuffer.copy_from(diskette.dna)
			src.temphtml = "Data loaded."

		if (href_list["save_disk"])
			if (!istype(diskette) || diskette.read_only)
				return

			del(diskette.dna)
			diskette.dna = new
			diskette.name = initial(diskette.name)
			if(tempbuffer.label)
				diskette.name += " ([tempbuffer.label])"

			diskette.dna.copy_from(tempbuffer)
			src.temphtml = "Data saved."

		if (href_list["eject_disk"])
			if (!src.diskette)
				return
			diskette.loc = get_turf(src)
			diskette = null
		////////////////////////////////////////////////////////
		if (href_list["clear"])
			temphtml = null
			delete = 0
		src.add_fingerprint(usr)
		src.updateUsrDialog()
	return
/////////////////////////// DNA MACHINES

/proc/miniscrambletarget(input,rs,rd)
	var/output = null
	switch(input)
		if("0")
			output = pick(prob((rs*10)+(rd));"0",prob((rs*10)+(rd));"1",prob((rs*10));"2",prob((rs*10)-(rd));"3")
		if("1")
			output = pick(prob((rs*10)+(rd));"0",prob((rs*10)+(rd));"1",prob((rs*10)+(rd));"2",prob((rs*10));"3",prob((rs*10)-(rd));"4")
		if("2")
			output = pick(prob((rs*10));"0",prob((rs*10)+(rd));"1",prob((rs*10)+(rd));"2",prob((rs*10)+(rd));"3",prob((rs*10));"4",prob((rs*10)-(rd));"5")
		if("3")
			output = pick(prob((rs*10)-(rd));"0",prob((rs*10));"1",prob((rs*10)+(rd));"2",prob((rs*10)+(rd));"3",prob((rs*10)+(rd));"4",prob((rs*10));"5",prob((rs*10)-(rd));"6")
		if("4")
			output = pick(prob((rs*10)-(rd));"1",prob((rs*10));"2",prob((rs*10)+(rd));"3",prob((rs*10)+(rd));"4",prob((rs*10)+(rd));"5",prob((rs*10));"6",prob((rs*10)-(rd));"7")
		if("5")
			output = pick(prob((rs*10)-(rd));"2",prob((rs*10));"3",prob((rs*10)+(rd));"4",prob((rs*10)+(rd));"5",prob((rs*10)+(rd));"6",prob((rs*10));"7",prob((rs*10)-(rd));"8")
		if("6")
			output = pick(prob((rs*10)-(rd));"3",prob((rs*10));"4",prob((rs*10)+(rd));"5",prob((rs*10)+(rd));"6",prob((rs*10)+(rd));"7",prob((rs*10));"8",prob((rs*10)-(rd));"9")
		if("7")
			output = pick(prob((rs*10)-(rd));"4",prob((rs*10));"5",prob((rs*10)+(rd));"6",prob((rs*10)+(rd));"7",prob((rs*10)+(rd));"8",prob((rs*10));"9",prob((rs*10)-(rd));"A")
		if("8")
			output = pick(prob((rs*10)-(rd));"5",prob((rs*10));"6",prob((rs*10)+(rd));"7",prob((rs*10)+(rd));"8",prob((rs*10)+(rd));"9",prob((rs*10));"A",prob((rs*10)-(rd));"B")
		if("9")
			output = pick(prob((rs*10)-(rd));"6",prob((rs*10));"7",prob((rs*10)+(rd));"8",prob((rs*10)+(rd));"9",prob((rs*10)+(rd));"A",prob((rs*10));"B",prob((rs*10)-(rd));"C")
		if("10")//A
			output = pick(prob((rs*10)-(rd));"7",prob((rs*10));"8",prob((rs*10)+(rd));"9",prob((rs*10)+(rd));"A",prob((rs*10)+(rd));"B",prob((rs*10));"C",prob((rs*10)-(rd));"D")
		if("11")//B
			output = pick(prob((rs*10)-(rd));"8",prob((rs*10));"9",prob((rs*10)+(rd));"A",prob((rs*10)+(rd));"B",prob((rs*10)+(rd));"C",prob((rs*10));"D",prob((rs*10)-(rd));"E")
		if("12")//C
			output = pick(prob((rs*10)-(rd));"9",prob((rs*10));"A",prob((rs*10)+(rd));"B",prob((rs*10)+(rd));"C",prob((rs*10)+(rd));"D",prob((rs*10));"E",prob((rs*10)-(rd));"F")
		if("13")//D
			output = pick(prob((rs*10)-(rd));"A",prob((rs*10));"B",prob((rs*10)+(rd));"C",prob((rs*10)+(rd));"D",prob((rs*10)+(rd));"E",prob((rs*10));"F")
		if("14")//E
			output = pick(prob((rs*10)-(rd));"B",prob((rs*10));"C",prob((rs*10)+(rd));"D",prob((rs*10)+(rd));"E",prob((rs*10)+(rd));"F")
		if("15")//F
			output = pick(prob((rs*10)-(rd));"C",prob((rs*10));"D",prob((rs*10)+(rd));"E",prob((rs*10)+(rd));"F")

	if(!input || !output) //How did this happen?
		output = "8"

	return output

/proc/getblockstring(input, block, subblock, blocksize, src, ui)
	// src is probably used here just for urls;
	// ui is 1 when requesting for the unique identifier screen, 0 for structural enzymes screen
	var/string
	var/subpos = 1 // keeps track of the current sub block
	var/blockpos = 1 // keeps track of the current block

	for(var/i = 1, i <= length(input), i++) // loop through each letter
		var/pushstring

		if(subpos == subblock && blockpos == block) // if the current block/subblock is selected, mark it
			pushstring = "</font color><b>[copytext(input, i, i+1)]</b><font color='blue'>"
		else
			if(ui) //This is for allowing block clicks to be differentiated
				pushstring = "<a href='?src=\ref[src];uimenuset=[num2text(blockpos)];uimenusubset=[num2text(subpos)]'>[copytext(input, i, i+1)]</a>"
			else
				pushstring = "<a href='?src=\ref[src];semenuset=[num2text(blockpos)];semenusubset=[num2text(subpos)]'>[copytext(input, i, i+1)]</a>"

		string += pushstring // push the string to the return string

		if(subpos >= blocksize) // add a line break for every block
			string += " </font color><font color='#285B5B'>|</font color><font color='blue'> "
			subpos = 0
			blockpos++
		subpos++

	return string