/////////////////////////// DNA DATUM
#define STRUCDNASIZE 25

/datum/dna
	var/unique_enzymes = null
	var/struc_enzymes = null
	var/uni_identity = null
	var/mutantrace = null
	var/real_name //Stores the real name of the person who originally got this dna datum. Used primarely for changelings,
	var/blood_type

/datum/dna/proc/check_integrity()
	//Lazy.
//	if(length(uni_identity) != 39) uni_identity = "00600200A00E0110148FC01300B0095BD7FD3F4"
//	if(length(struc_enzymes)!= STRUCDNASIZE*3) struc_enzymes = "2013E85C944C19A4B00185144725785DC6406A4508186248487555169453220780579106750610"
	return

/datum/dna/proc/ready_dna(mob/living/carbon/human/character)

	var/temp
	var/hair
	var/beard

	// determine DNA fragment from hairstyle
	// :wtc:

	var/list/styles = list("bald", "hair_a", "hair_b", "hair_longfringe", "hair_vlongfringe", "hair_longest", "hair_test", "hair_c", "hair_d", "hair_e", "hair_f", "hair_bedhead", "hair_bedheadv2", "hair_spikey", "hair_dreads", "hair_afro", "hair_bigafro", "hair_braid", "hair_kigami", "hair_ponytail" )
	var/hrange = round(4095 / styles.len)

	var/style = styles.Find(character.hair_icon_state)
	if(style)
		hair = style * hrange + hrange - rand(1,hrange-1)
	else
		hair = 0

	switch(character.face_icon_state)
		if("bald") beard = rand(1,350)
		if("facial_elvis") beard = rand(351,650)
		if("facial_vandyke") beard = rand(651,950)
		if("facial_neckbeard") beard = rand(951,1250)
		if("facial_chaplin") beard = rand(1251,1550)
		if("facial_watson") beard = rand(1551,1850)
		if("facial_abe") beard = rand(1851,2150)
		if("facial_chin") beard = rand(2151,2450)
		if("facial_hip") beard = rand(2451,2750)
		if("facial_gt") beard = rand(2751,3050)
		if("facial_hogan") beard = rand(3051,3350)
		if("facial_selleck") beard = rand(3351,3650)
		if("facial_fullbeard") beard = rand(3651,3950)
		if("facial_longbeard") beard = rand(3951,4095)

	temp = add_zero2(num2hex((character.r_hair),1), 3)
	temp += add_zero2(num2hex((character.b_hair),1), 3)
	temp += add_zero2(num2hex((character.g_hair),1), 3)
	temp += add_zero2(num2hex((character.r_facial),1), 3)
	temp += add_zero2(num2hex((character.b_facial),1), 3)
	temp += add_zero2(num2hex((character.g_facial),1), 3)
	temp += add_zero2(num2hex(((character.s_tone + 220) * 16),1), 3)
	temp += add_zero2(num2hex((character.r_eyes),1), 3)
	temp += add_zero2(num2hex((character.g_eyes),1), 3)
	temp += add_zero2(num2hex((character.b_eyes),1), 3)

	var/gender

	if (character.gender == MALE)
		gender = add_zero2(num2hex((rand(1,(2050+BLOCKADD))),1), 3)
	else
		gender = add_zero2(num2hex((rand((2051+BLOCKADD),4094)),1), 3)

	temp += gender
	temp += add_zero2(num2hex((beard),1), 3)
	temp += add_zero2(num2hex((hair),1), 3)

	uni_identity = temp

	var/mutstring = ""
	for(var/i = 1, i <= 26, i++)
		mutstring += add_zero2(num2hex(rand(1,1024)),3)
	struc_enzymes = mutstring

	unique_enzymes = md5(character.real_name)
	reg_dna[unique_enzymes] = character.real_name

/////////////////////////// DNA DATUM

/////////////////////////// DNA HELPER-PROCS
/proc/getleftblocks(input,blocknumber,blocksize)
	var/string
	string = copytext(input,1,((blocksize*blocknumber)-(blocksize-1)))
	if (blocknumber > 1)
		return string
	else
		return null

/proc/getrightblocks(input,blocknumber,blocksize)
	var/string
	string = copytext(input,blocksize*blocknumber+1,length(input)+1)
	if (blocknumber < (length(input)/blocksize))
		return string
	else
		return null

/proc/getblock(input,blocknumber,blocksize)
	var/result
	result = copytext(input ,(blocksize*blocknumber)-(blocksize-1),(blocksize*blocknumber)+1)
	return result

/proc/setblock(istring, blocknumber, replacement, blocksize)
	var/result
	result = getleftblocks(istring, blocknumber, blocksize) + replacement + getrightblocks(istring, blocknumber, blocksize)
	return result

/proc/add_zero2(t, u)
	var/temp1
	while (length(t) < u)
		t = "0[t]"
	temp1 = t
	if (length(t) > u)
		temp1 = copytext(t,2,u+1)
	return temp1

/proc/miniscramble(input,rs,rd)
	var/output
	output = null
	if (input == "C" || input == "D" || input == "E" || input == "F")
		output = pick(prob((rs*10));"4",prob((rs*10));"5",prob((rs*10));"6",prob((rs*10));"7",prob((rs*5)+(rd));"0",prob((rs*5)+(rd));"1",prob((rs*10)-(rd));"2",prob((rs*10)-(rd));"3")
	if (input == "8" || input == "9" || input == "A" || input == "B")
		output = pick(prob((rs*10));"4",prob((rs*10));"5",prob((rs*10));"A",prob((rs*10));"B",prob((rs*5)+(rd));"C",prob((rs*5)+(rd));"D",prob((rs*5)+(rd));"2",prob((rs*5)+(rd));"3")
	if (input == "4" || input == "5" || input == "6" || input == "7")
		output = pick(prob((rs*10));"4",prob((rs*10));"5",prob((rs*10));"A",prob((rs*10));"B",prob((rs*5)+(rd));"C",prob((rs*5)+(rd));"D",prob((rs*5)+(rd));"2",prob((rs*5)+(rd));"3")
	if (input == "0" || input == "1" || input == "2" || input == "3")
		output = pick(prob((rs*10));"8",prob((rs*10));"9",prob((rs*10));"A",prob((rs*10));"B",prob((rs*10)-(rd));"C",prob((rs*10)-(rd));"D",prob((rs*5)+(rd));"E",prob((rs*5)+(rd));"F")
	if (!output) output = "5"
	return output

/proc/isblockon(hnumber, bnumber)
	var/temp2
	temp2 = hex2num(hnumber)
	if (bnumber == HULKBLOCK || bnumber == TELEBLOCK)
		if (temp2 >= 3500 + BLOCKADD)
			return 1
		else
			return 0
	if (bnumber == XRAYBLOCK || bnumber == FIREBLOCK)
		if (temp2 >= 3050 + BLOCKADD)
			return 1
		else
			return 0
	if (temp2 >= 2050 + BLOCKADD)
		return 1
	else
		return 0

/proc/randmutb(mob/M as mob)
	var/num
	var/newdna
	num = pick(1,3,FAKEBLOCK,5,CLUMSYBLOCK,7,9,BLINDBLOCK,DEAFBLOCK)
	newdna = setblock(M.dna.struc_enzymes,num,toggledblock(getblock(M.dna.struc_enzymes,num,3)),3)
	M.dna.struc_enzymes = newdna
	return

/proc/randmutg(mob/M as mob)
	var/num
	var/newdna
	num = pick(HULKBLOCK,XRAYBLOCK,FIREBLOCK,TELEBLOCK)
	newdna = setblock(M.dna.struc_enzymes,num,toggledblock(getblock(M.dna.struc_enzymes,num,3)),3)
	M.dna.struc_enzymes = newdna
	return

/proc/randmuti(mob/M as mob)
	var/num
	var/newdna
	num = pick(1,2,3,4,5,6,7,8,9,10,11,12,13)
	newdna = setblock(M.dna.uni_identity,num,add_zero2(num2hex(rand(1,4095),1),3),3)
	M.dna.uni_identity = newdna
	return

/proc/scramble(var/type, mob/M as mob, var/p)
	if(!M)	return
	M.dna.check_integrity()
	if(type)
		for(var/i = 1, i <= 13, i++)
			if(prob(p))
				M.dna.uni_identity = setblock(M.dna.uni_identity, i, add_zero2(num2hex(rand(1,4095), 1), 3), 3)
		updateappearance(M, M.dna.uni_identity)

	else
		for(var/i = 1, i <= 13, i++)
			if(prob(p))
				M.dna.struc_enzymes = setblock(M.dna.struc_enzymes, i, add_zero2(num2hex(rand(1,4095), 1), 3), 3)
		domutcheck(M, null)
	return

/proc/toggledblock(hnumber) //unused
	var/temp3
	var/chtemp
	temp3 = hex2num(hnumber)
	if (temp3 < 2050)
		chtemp = rand(2050,4095)
		return add_zero2(num2hex(chtemp,1),3)
	else
		chtemp = rand(1,2049)
		return add_zero2(num2hex(chtemp,1),3)
/////////////////////////// DNA HELPER-PROCS

/////////////////////////// DNA MISC-PROCS
/proc/updateappearance(mob/M as mob,structure)
	if(istype(M, /mob/living/carbon/human))
		M.dna.check_integrity()
		var/mob/living/carbon/human/H = M
		H.r_hair = hex2num(getblock(structure,1,3))
		H.b_hair = hex2num(getblock(structure,2,3))
		H.g_hair = hex2num(getblock(structure,3,3))
		H.r_facial = hex2num(getblock(structure,4,3))
		H.b_facial = hex2num(getblock(structure,5,3))
		H.g_facial = hex2num(getblock(structure,6,3))
		H.s_tone = round(((hex2num(getblock(structure,7,3)) / 16) - 220))
		H.r_eyes = hex2num(getblock(structure,8,3))
		H.g_eyes = hex2num(getblock(structure,9,3))
		H.b_eyes = hex2num(getblock(structure,10,3))

		if (isblockon(getblock(structure, 11,3),11))
			H.gender = FEMALE
		else
			H.gender = MALE
		///
		var/beardnum = hex2num(getblock(structure,12,3))
		if (beardnum >= 1 && beardnum <= 350)
			H.face_icon_state = "bald"
			H.f_style = "bald"
		else if (beardnum >= 351 && beardnum <= 650)
			H.face_icon_state = "facial_elvis"
			H.f_style = "facial_elvis"
		else if (beardnum >= 651 && beardnum <= 950)
			H.face_icon_state = "facial_vandyke"
			H.f_style = "facial_vandyke"
		else if (beardnum >= 951 && beardnum <= 1250)
			H.face_icon_state = "facial_neckbeard"
			H.f_style = "facial_neckbeard"
		else if (beardnum >= 1251 && beardnum <= 1550)
			H.face_icon_state = "facial_chaplin"
			H.f_style = "facial_chaplin"
		else if (beardnum >= 1551 && beardnum <= 1850)
			H.face_icon_state = "facial_watson"
			H.f_style = "facial_watson"
		else if (beardnum >= 1851 && beardnum <= 2150)
			H.face_icon_state = "facial_abe"
			H.f_style = "facial_abe"
		else if (beardnum >= 2151 && beardnum <= 2450)
			H.face_icon_state = "facial_chin"
			H.f_style = "facial_chin"
		else if (beardnum >= 2451 && beardnum <= 2750)
			H.face_icon_state = "facial_hip"
			H.f_style = "facial_hip"
		else if (beardnum >= 2751 && beardnum <= 3050)
			H.face_icon_state = "facial_gt"
			H.f_style = "facial_gt"
		else if (beardnum >= 3051 && beardnum <= 3350)
			H.face_icon_state = "facial_hogan"
			H.f_style = "facial_hogan"
		else if (beardnum >= 3351 && beardnum <= 3650)
			H.face_icon_state = "facial_selleck"
			H.f_style = "facial_selleck"
		else if (beardnum >= 3651 && beardnum <= 3950)
			H.face_icon_state = "facial_fullbeard"
			H.f_style = "facial_fullbeard"
		else if (beardnum >= 3951 && beardnum <= 4095)
			H.face_icon_state = "facial_longbeard"
			H.f_style = "facial_longbeard"


		var/hairnum = hex2num(getblock(structure,13,3))


		var/list/styles = list("bald", "hair_a", "hair_b", "hair_longfringe", "hair_vlongfringe", "hair_longest", "hair_test", "hair_c", "hair_d", "hair_e", "hair_f", "hair_bedhead", "hair_bedheadv2", "hair_spikey", "hair_dreads", "hair_afro", "hair_bigafro", "hair_braid", "hair_kigami", "hair_ponytail" )
		var/hrange = round(4095 / styles.len)

		var/style = round(hairnum / hrange)

		if (style > styles.len)
			style = styles.len
		if (style < 1)
			style = 1

		H.hair_icon_state = styles[style]
		H.h_style = H.hair_icon_state


		H.update_face()
		H.update_body()

		return 1
	else
		return 0

/proc/ismuton(var/block,var/mob/M)
	return isblockon(getblock(M.dna.struc_enzymes, block,3),block)

/proc/domutcheck(mob/M as mob, connected, inj)
	if (!M) return
	//telekinesis = 1
	//firemut = 2
	//xray = 4
	//hulk = 8
	//clumsy = 16
	//nobreath = 32
	//remoteviewing = 64
	//regenerate = 128
	//Increaserun = 256
	//remotetalk = 512
	//morphskincolour = 1024
	//blend = 2048
	//hallucinationimmunity = 4096
	//fingerprints = 8192
	//shockimmunity = 16384
	//smallsize = 32768


	M.dna.check_integrity()

	M.disabilities = 0
	M.sdisabilities = 0
	var/list/oldmut = M.mutations
	M.mutations = list()

	M.see_in_dark = 2
	M.see_invisible = 0

	if(ismuton(NOBREATHBLOCK,M))
		if(inj || prob(30) || (mNobreath in oldmut))
			M << "\blue You stop breathing"
			M.mutations += mNobreath
	if(ismuton(REMOTEVIEWBLOCK,M))
		if(inj || prob(30) || (mRemote in oldmut))
			M << "\blue Your mind expands"
			M.mutations += mRemote
	if(ismuton(REGENERATEBLOCK,M))
		if(inj || prob(30) || (mRegen in oldmut))
			M << "\blue You feel strange"
			M.mutations += mRegen
	if(ismuton(INCREASERUNBLOCK,M))
		if(inj || prob(30) || (mRun in oldmut))
			M << "\blue You feel quick"
			M.mutations += mRun
	if(ismuton(REMOTETALKBLOCK,M))
		if(inj || prob(30) || (mRemotetalk in oldmut))
			M << "\blue You expand your mind outwards"
			M.mutations += mRemotetalk
	if(ismuton(MORPHBLOCK,M))
		if(inj || prob(30) || (mMorph in oldmut))
			M.mutations += mMorph
			M << "\blue Your skin feels strange"
	if(ismuton(BLENDBLOCK,M))
		if(inj || prob(30) || (mBlend in oldmut))
			M.mutations += mBlend
			M << "\blue You feel alone"
	if(ismuton(HALLUCINATIONBLOCK,M))
		if(inj || prob(30) || (mHallucination in oldmut))
			M.mutations += mHallucination
			M << "\blue Your mind says 'Hello'"
	if(ismuton(NOPRINTSBLOCK,M))
		if(inj || prob(30) || (mFingerprints in oldmut))
			M.mutations += mFingerprints
			M << "\blue Your fingers feel numb"
	if(ismuton(SHOCKIMMUNITYBLOCK,M))
		if(inj || prob(30) || (mShock in oldmut))
			M.mutations += mShock
			M << "\blue You feel strange"
	if(ismuton(SMALLSIZEBLOCK,M))
		if(inj || prob(30) || (mSmallsize in oldmut))
			M << "\blue Your skin feels rubbery"
			M.mutations += mSmallsize



	if (isblockon(getblock(M.dna.struc_enzymes, HULKBLOCK,3),HULKBLOCK))
		if(inj || prob(15) || (HULK in oldmut))
			M << "\blue Your muscles hurt."
			M.mutations += HULK
	if (isblockon(getblock(M.dna.struc_enzymes, HEADACHEBLOCK,3),HEADACHEBLOCK))
		M.disabilities |= 2
		M << "\red You get a headache."
	if (isblockon(getblock(M.dna.struc_enzymes, FAKEBLOCK,3),FAKEBLOCK))
		M << "\red You feel strange."
		if (prob(95))
			if(prob(50))
				randmutb(M)
			else
				randmuti(M)
		else
			randmutg(M)
	if (isblockon(getblock(M.dna.struc_enzymes, COUGHBLOCK,3),COUGHBLOCK))
		M.disabilities |= 4
		M << "\red You start coughing."
	if (isblockon(getblock(M.dna.struc_enzymes, CLUMSYBLOCK,3),CLUMSYBLOCK))
		M << "\red You feel lightheaded."
		M.mutations += CLUMSY
	if (isblockon(getblock(M.dna.struc_enzymes, TWITCHBLOCK,3),TWITCHBLOCK))
		M.disabilities |= 8
		M << "\red You twitch."
	if (isblockon(getblock(M.dna.struc_enzymes, XRAYBLOCK,3),XRAYBLOCK))
		if(inj || prob(30) || (XRAY in oldmut))
			M << "\blue The walls suddenly disappear."
			M.sight |= (SEE_MOBS|SEE_OBJS|SEE_TURFS)
			M.see_in_dark = 8
			M.see_invisible = 2
			M.mutations += XRAY
	if (isblockon(getblock(M.dna.struc_enzymes, NERVOUSBLOCK,3),NERVOUSBLOCK))
		M.disabilities |= 16
		M << "\red You feel nervous."
	if (isblockon(getblock(M.dna.struc_enzymes, FIREBLOCK,3),FIREBLOCK))
		if(inj || prob(30) || (COLD_RESISTANCE in oldmut))
			M << "\blue Your body feels warm."
			M.mutations += COLD_RESISTANCE
	if (isblockon(getblock(M.dna.struc_enzymes, BLINDBLOCK,3),BLINDBLOCK))
		M.sdisabilities |= 1
		M << "\red You can't seem to see anything."
	if (isblockon(getblock(M.dna.struc_enzymes, TELEBLOCK,3),TELEBLOCK))
		if(inj || prob(20) || (TK in oldmut))
			M << "\blue You feel smarter."
			M.mutations += TK
	if (isblockon(getblock(M.dna.struc_enzymes, DEAFBLOCK,3),DEAFBLOCK))
		M.sdisabilities |= 4
		M.ear_deaf = 1
		M << "\red Its kinda quiet..."

	if(HUSK in oldmut)
		M.mutations += HUSK

	if(NOCLONE in oldmut)
		M.mutations += NOCLONE
//////////////////////////////////////////////////////////// Monkey Block
	if (isblockon(getblock(M.dna.struc_enzymes, 14,3),14) && istype(M, /mob/living/carbon/human))
	// human > monkey
		var/list/implants = list() //Try to preserve implants.
		for(var/obj/item/weapon/implant/W in M)
			if (istype(W, /obj/item/weapon/implant))
				implants += W
		for(var/obj/item/weapon/W in M)
			M.u_equip(W)
			if (M.client)
				M.client.screen -= W
			if (W)
				W.loc = M.loc
				W.dropped(M)
				W.layer = initial(W.layer)
		for(var/obj/item/clothing/C)
			C.dropped(M)
			if (M.client)
				M.client.screen -= C
		if(!connected)
			M.update_clothing()
			M.monkeyizing = 1
			M.canmove = 0
			M.icon = null
			M.invisibility = 101
			var/atom/movable/overlay/animation = new /atom/movable/overlay( M.loc )
			animation.icon_state = "blank"
			animation.icon = 'mob.dmi'
			animation.master = src
			flick("h2monkey", animation)
			sleep(48 * tick_multiplier)
			del(animation)

		var/mob/living/carbon/monkey/O = new /mob/living/carbon/monkey(src)
		O.dna = M.dna
		M.dna = null

		for(var/obj/T in M)
			del(T)
		for(var/R in M.organs)
			del(M.organs["[R]"])

		O.loc = M.loc

		if(M.mind)
			M.mind.transfer_to(O)

		if (connected) //inside dna thing
			var/obj/machinery/dna_scannernew/C = connected
			O.loc = C
			C.occupant = O
			connected = null
		O.name = "monkey ([copytext(md5(M.real_name), 2, 6)])"
		O.toxloss += (M.toxloss + 20)
		O.bruteloss += (M.bruteloss + 40)
		O.oxyloss += M.oxyloss
		O.fireloss += M.fireloss
		O.stat = M.stat
		O.a_intent = "harm"
		for (var/obj/item/weapon/implant/I in implants)
			I.loc = O
			I.implanted = O
			continue
		del(M)
		return

	if (!isblockon(getblock(M.dna.struc_enzymes, 14,3),14) && !istype(M, /mob/living/carbon/human))
	// monkey > human
		var/list/implants = list()
		for (var/obj/item/weapon/implant/I in M) //Still preserving implants
			implants += I

		if(!connected)
			for(var/obj/item/weapon/W in M)
				M.u_equip(W)
				if (M.client)
					M.client.screen -= W
				if (W)
					W.loc = M.loc
					W.dropped(M)
					W.layer = initial(W.layer)
			M.update_clothing()
			M.monkeyizing = 1
			M.canmove = 0
			M.icon = null
			M.invisibility = 101
			var/atom/movable/overlay/animation = new /atom/movable/overlay( M.loc )
			animation.icon_state = "blank"
			animation.icon = 'mob.dmi'
			animation.master = src
			flick("monkey2h", animation)
			sleep(48 * tick_multiplier)
			del(animation)

		var/mob/living/carbon/human/O = new /mob/living/carbon/human( src )
		if (isblockon(getblock(M.dna.uni_identity, 11,3),11))
			O.gender = FEMALE
		else
			O.gender = MALE
		O.dna = M.dna
		M.dna = null

		for(var/obj/T in M)
			del(T)

		O.loc = M.loc

		if(M.mind)
			M.mind.transfer_to(O)

		if (connected) //inside dna thing
			var/obj/machinery/dna_scannernew/C = connected
			O.loc = C
			C.occupant = O
			connected = null

		var/i
		while (!i)
			var/randomname
			if (O.gender == MALE)
				randomname = capitalize(pick(first_names_male) + " " + capitalize(pick(last_names)))
			else
				randomname = capitalize(pick(first_names_female) + " " + capitalize(pick(last_names)))
			if (findname(randomname))
				continue
			else
				O.real_name = randomname
				i++
		updateappearance(O,O.dna.uni_identity)
	//	O.toxloss += M.toxloss
	//	O.bruteloss += M.bruteloss
	//	O.oxyloss += M.oxyloss
	//	O.fireloss += M.fireloss
	//	O.stat = M.stat
		for (var/obj/item/weapon/implant/I in implants)
			I.loc = O
			I.implanted = O
			continue

		O.update_clothing()
		O.toxloss += (M.toxloss + 20)
		O.bruteloss += (M.bruteloss + 40)
		O.oxyloss += M.oxyloss
		del(M)
		return
//////////////////////////////////////////////////////////// Monkey Block
	if (M) M.update_clothing()
	return null
/////////////////////////// DNA MISC-PROCS