var/global/list/autolathe_recipes = list( \
		new /obj/item/weapon/screwdriver(), \
		new /obj/item/weapon/reagent_containers/glass/bucket(), \
		new /obj/item/weapon/crowbar(), \
		new /obj/item/device/flashlight(), \
		new /obj/item/weapon/extinguisher(), \
		new /obj/item/device/multitool(), \
		new /obj/item/device/t_scanner(), \
		new /obj/item/weapon/weldingtool(), \
		new /obj/item/weapon/screwdriver(), \
		new /obj/item/weapon/wirecutters(), \
		new /obj/item/weapon/wrench(), \
		new /obj/item/clothing/head/helmet/welding(), \
		new /obj/item/weapon/stock_parts/console_screen(), \
		new /obj/item/weapon/circuitboard/circuitry(), \
		/* new /obj/item/weapon/airlock_electronics(), \
		new /obj/item/weapon/airalarm_electronics(), \
		new /obj/item/weapon/firealarm_electronics(), \*/
		new /obj/item/stack/sheet/metal(), \
		new /obj/item/stack/sheet/plasteel, \
		new /obj/item/stack/sheet/glass(), \
		new /obj/item/stack/sheet/rglass(), \
		new /obj/item/stack/rods(), \
		new /obj/item/weapon/rcd_ammo(), \
		/*new /obj/item/weapon/kitchenknife(), \
		new /obj/item/weapon/surgicaldrill(),\*/
		new /obj/item/weapon/surgical/retractor(),\
		new /obj/item/weapon/surgical/cautery(),\
		new /obj/item/weapon/surgical/hemostat(),\
		new /obj/item/weapon/reagent_containers/glass/beaker(), \
		new /obj/item/weapon/reagent_containers/glass/beaker/large(), \
		new /obj/item/ammo_casing/shotgun/blank(), \
		new /obj/item/ammo_casing/shotgun/beanbag(), \
		new /obj/item/ammo_magazine/box/c38(), \
		new /obj/item/device/taperecorder/empty(), \
		new /obj/item/device/tape(), \
		new /obj/item/device/radio/headset(), \
		new /obj/item/device/radio(), \
		new /obj/item/device/assembly/igniter(), \
		new /obj/item/device/assembly/signaler(), \
		new /obj/item/device/assembly/timer(), \
		new /obj/item/device/assembly/voice(), \
		new /obj/item/weapon/surgical/scalpel(), \
		new /obj/item/weapon/surgical/circular_saw(), \
		new /obj/item/weapon/light/tube(), \
		new /obj/item/weapon/light/bulb(), \
		new /obj/item/weapon/camera_assembly(), \
	)

var/global/list/autolathe_recipes_hidden = list( \
		new /obj/item/weapon/flamethrower(), \
		new /obj/item/weapon/rcd(), \
		new /obj/item/device/radio/electropack(), \
		new /obj/item/weapon/weldingtool/industrial(), \
		new /obj/item/device/assembly/infra(), \
		new /obj/item/device/assembly/voice/radio(), \
		new /obj/item/device/infra_sensor(), \
		new /obj/item/weapon/handcuffs(), \
		new /obj/item/ammo_magazine/box/a357(), \
		new /obj/item/ammo_magazine/external/m12mm(), \
		new /obj/item/ammo_magazine/external/m762(), \
		new /obj/item/ammo_magazine/external/m75(), \
		new /obj/item/ammo_casing/shotgun(), \
		new /obj/item/ammo_casing/shotgun/dart(),  \
		/* new /obj/item/weapon/shield/riot(),  \*/
	)

/obj/machinery/autolathe
	name = "\improper Autolathe"
	desc = "It produces items using metal and glass."
	icon_state = "autolathe"
	density = 1

	var/m_amount = 0.0
	var/max_m_amount = 150000.0

	var/g_amount = 0.0
	var/max_g_amount = 75000.0

	var/operating = 0.0
	var/opened = 0
	anchored = 1.0
	var/list/L = list()
	var/list/LL = list()
	var/hacked = 0
	var/disabled = 0
	var/shocked = 0
	var/datum/wires/rdm/autolathe/wires = null
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 100

	proc
		regular_win(mob/user as mob)
			var/dat as text
			dat = text("<B>Metal Amount:</B> [src.m_amount] cm<sup>3</sup> (MAX: [max_m_amount])<BR>\n<FONT color=blue><B>Glass Amount:</B></FONT> [src.g_amount] cm<sup>3</sup> (MAX: [max_g_amount])<HR>")
			var/list/objs = list()
			objs += src.L
			if (src.hacked)
				objs += src.LL
			for(var/obj/t in objs)
				var/title = "[t.name] ([t.m_amt] m /[t.g_amt] g)"
				if (m_amount<t.m_amt || g_amount<t.g_amt)
					dat += title + "<br>"
					continue
				dat += "<A href='?src=\ref[src];make=\ref[t]'>[title]</A>"
				if (istype(t, /obj/item/stack))
					var/obj/item/stack/S = t
					var/max_multiplier = min(S.max_amount, S.m_amt?round(m_amount/S.m_amt):INFINITY, S.g_amt?round(g_amount/S.g_amt):INFINITY)
					if (max_multiplier>1)
						dat += " |"
					if (max_multiplier>10)
						dat += " <A href='?src=\ref[src];make=\ref[t];multiplier=[10]'>x[10]</A>"
					if (max_multiplier>25)
						dat += " <A href='?src=\ref[src];make=\ref[t];multiplier=[25]'>x[25]</A>"
					if (max_multiplier>1)
						dat += " <A href='?src=\ref[src];make=\ref[t];multiplier=[max_multiplier]'>x[max_multiplier]</A>"
				dat += "<br>"
			user << browse("<HTML><HEAD><TITLE>Autolathe Control Panel</TITLE></HEAD><BODY><TT>[dat]</TT></BODY></HTML>", "window=autolathe_regular")
			onclose(user, "autolathe_regular")

	shock(mob/user, prb)
		if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
			return 0
		return ..()

	interact(mob/user as mob)
		if(..())
			return
		if (shocked)
			src.shock(user,50)
		if (opened)
			wires.Interact(user)
			return
		if (disabled)
			user << "\red You press the button, but nothing happens."
			return
		regular_win(user)
		return

	attackby(var/obj/item/O as obj, var/mob/user as mob)
		if (istype(O, /obj/item/weapon/screwdriver))
			if (!opened)
				src.opened = 1
				src.icon_state = "autolathe_t"
				user << "You open the maintenance hatch of [src]."
			else
				src.opened = 0
				src.icon_state = "autolathe"
				user << "You close the maintenance hatch of [src]."
			return 1
		if (opened)
			if(istype(O, /obj/item/weapon/crowbar))
				if(m_amount >= 3750)
					var/obj/item/stack/sheet/metal/G = new /obj/item/stack/sheet/metal(src.loc)
					G.amount = round(m_amount / 3750)
				if(g_amount >= 3750)
					var/obj/item/stack/sheet/glass/G = new /obj/item/stack/sheet/glass(src.loc)
					G.amount = round(g_amount / 3750)

				default_deconstruction_crowbar()
				return 1
			else
				user.set_machine(src)
				interact(user)
				return 1

		if (stat)
			return 1

		if (src.m_amount + O.m_amt > max_m_amount)
			user << "\red The autolathe is full. Please remove metal from the autolathe in order to insert more."
			return 1
		if (src.g_amount + O.g_amt > max_g_amount)
			user << "\red The autolathe is full. Please remove glass from the autolathe in order to insert more."
			return 1
		if (O.m_amt == 0 && O.g_amt == 0)
			user << "\red This object does not contain significant amounts of metal or glass, or cannot be accepted by the autolathe due to size or hazardous materials."
			return 1
	/*
		if (istype(O, /obj/item/weapon/grab) && hacked)
			var/obj/item/weapon/grab/G = O
			if (prob(25) && G.affecting)
				G.affecting.gib()
				m_amount += 50000
			return
	*/

		var/amount = 1
		var/obj/item/stack/stack
		var/m_amt = O.m_amt
		var/g_amt = O.g_amt
		if (istype(O, /obj/item/stack))
			stack = O
			amount = stack.amount
			if (m_amt)
				amount = min(amount, round((max_m_amount-src.m_amount)/m_amt))
				flick("autolathe_o",src)//plays metal insertion animation
			if (g_amt)
				amount = min(amount, round((max_g_amount-src.g_amount)/g_amt))
				flick("autolathe_r",src)//plays glass insertion animation
			user << "You insert [amount] sheet[amount>1 ? "s" : ""] to the autolathe."
			stack.use(amount)
		else
			user.before_take_item(O)
			O.loc = src
			user << "You insert [O.name] into the autolathe."
		icon_state = "autolathe"
		use_power(max(1000, (m_amt+g_amt)*amount/10))
		src.m_amount += m_amt * amount
		src.g_amount += g_amt * amount
		if (O && O.loc == src)
			del(O)
		src.updateUsrDialog()

	attack_paw(mob/user as mob)
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		user.set_machine(src)
		interact(user)


	Topic(href, href_list)
		if(..())
			return
		usr.set_machine(src)
		src.add_fingerprint(usr)
		if(href_list["make"])
			var/obj/template = locate(href_list["make"])
			var/multiplier = text2num(href_list["multiplier"])
			if (!multiplier) multiplier = 1
			var/power = max(2000, (template.m_amt+template.g_amt)*multiplier/5)
			if(src.m_amount >= template.m_amt*multiplier && src.g_amount >= template.g_amt*multiplier)
				use_power(power)
				icon_state = "autolathe"
				flick("autolathe_n",src)
				spawn(16)
					if(!(src.m_amount >= template.m_amt*multiplier && src.g_amount >= template.g_amt*multiplier)) return
					use_power(power)
					src.m_amount -= template.m_amt*multiplier
					src.g_amount -= template.g_amt*multiplier
					if(src.m_amount < 0)
						src.m_amount = 0
					if(src.g_amount < 0)
						src.g_amount = 0
					var/obj/new_item = new template.type(src.loc)
					if (multiplier>1)
						var/obj/item/stack/S = new_item
						S.amount = multiplier
					src.updateUsrDialog()
		src.updateUsrDialog()
		return


	RefreshParts()
		..()
		var/tot_rating = 0
		for(var/obj/item/weapon/stock_parts/matter_bin/MB in component_parts)
			tot_rating += MB.rating
		tot_rating *= 25000
		max_m_amount = tot_rating * 2
		max_g_amount = tot_rating

	New()
		..()
		component_parts = list()
		component_parts += new /obj/item/weapon/circuitboard/machine/autolathe(null)
		component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
		component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
		component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
		component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
		component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
		RefreshParts()

		src.L = autolathe_recipes
		src.LL = autolathe_recipes_hidden

		wires = new(src)