/obj/item/weapon/circuitboard
	w_class = 2.0
	name = "circuit board"
	icon = 'icons/obj/module.dmi'
	icon_state = "id_mod"
	item_state = "electronic"
	origin_tech = "programming=2"
	desc = "Looks like a circuit. Probably is."
	g_amt = 100
	m_amt = 25

/obj/item/weapon/circuitboard/circuitry
	name = "circuitry"

/obj/item/weapon/circuitboard/power_control
	name = "power control module"
	icon_state = "power_mod"
	desc = "Heavy-duty switching circuits for power control."

/obj/item/weapon/circuitboard/airalarm_electronics
	name = "air alarm electronics"
	icon_state = "airalarm_electronics"



/obj/item/weapon/circuitboard/computer
	var/id = null
	var/frequency = null
	var/computertype = null
	var/hacked = 0

/obj/item/weapon/circuitboard/computer/security
	name = "circuit board (Security)"
	computertype = /obj/machinery/computer/security

/obj/item/weapon/circuitboard/computer/aiupload
	name = "circuit board (AI Upload)"
	computertype = /obj/machinery/computer/aiupload
	origin_tech = "programming=4"

/obj/item/weapon/circuitboard/computer/med_data
	name = "circuit board (Medical)"
	computertype = /obj/machinery/computer/med_data

/obj/item/weapon/circuitboard/computer/scan_consolenew
	name = "circuit board (DNA Machine)"
	computertype = /obj/machinery/computer/scan_consolenew
	origin_tech = "programming=2;biotech=2"

/obj/item/weapon/circuitboard/computer/communications
	name = "circuit board (Communications)"
	computertype = /obj/machinery/computer/communications
	origin_tech = "programming=2;magnets=2"

/obj/item/weapon/circuitboard/computer/card
	name = "circuit board (ID Computer)"
	computertype = /obj/machinery/computer/card

/obj/item/weapon/circuitboard/computer/teleporter
	name = "circuit board (Teleporter)"
	computertype = /obj/machinery/computer/teleporter
	origin_tech = "programming=2;bluespace=2"

/obj/item/weapon/circuitboard/computer/secure_data
	name = "circuit board (Secure Data)"
	computertype = /obj/machinery/computer/secure_data

/obj/item/weapon/circuitboard/computer/atmospherealerts
	name = "circuit board (Atmosphere alerts)"
	computertype = /obj/machinery/computer/atmosphere/alerts

/obj/item/weapon/circuitboard/computer/atmospheresiphonswitch
	name = "circuit board (Atmosphere siphon control)"
	computertype = /obj/machinery/computer/atmosphere/siphonswitch

/obj/item/weapon/circuitboard/computer/air_management
	name = "circuit board (Atmospheric monitor)"
	computertype = /obj/machinery/computer/general_air_control

/obj/item/weapon/circuitboard/computer/injector_control
	name = "circuit board (Injector control)"
	computertype = /obj/machinery/computer/general_air_control/fuel_injection

/obj/item/weapon/circuitboard/computer/general_alert
	name = "circuit board (General Alert)"
	computertype = /obj/machinery/computer/general_alert

/obj/item/weapon/circuitboard/computer/pod
	name = "circuit board (Massdriver control)"
	computertype = /obj/machinery/computer/pod

/obj/item/weapon/circuitboard/computer/robotics
	name = "circuit board (Robotics Control)"
	computertype = /obj/machinery/computer/robotics
	origin_tech = "programming=3"

/obj/item/weapon/circuitboard/computer/cloning
	name = "circuit board (Cloning)"
	computertype = /obj/machinery/computer/cloning
	origin_tech = "programming=3;biotech=3"

/obj/item/weapon/circuitboard/computer/arcade
	name = "circuit board (Arcade)"
	computertype = /obj/machinery/computer/arcade
	origin_tech = "programming=1"

/obj/item/weapon/circuitboard/computer/turbine_control
	name = "circuit board (Turbine control)"
	computertype = /obj/machinery/computer/turbine_computer

/obj/item/weapon/circuitboard/computer/solar_control
	name = "circuit board (Solar control)"
	computertype = /obj/machinery/power/solar_control
	origin_tech = "programming=2;powerstorage=2"

/obj/item/weapon/circuitboard/computer/powermonitor
	name = "circuit board (Massdriver control)"
	computertype = /obj/machinery/power/monitor

/obj/item/weapon/circuitboard/computer/olddoor
	name = "circuit board (DoorMex)"
	computertype = /obj/machinery/computer/pod/old

/obj/item/weapon/circuitboard/computer/syndicatedoor
	name = "circuit board (ProComp Executive)"
	computertype = /obj/machinery/computer/pod/old/syndicate

/obj/item/weapon/circuitboard/computer/swfdoor
	name = "circuit board (Magix)"
	computertype = /obj/machinery/computer/pod/old/swf

/obj/item/weapon/circuitboard/computer/operating
	name = "circuit board (Operating Computer)"
	computertype = /obj/machinery/computer/operating
	origin_tech = "programming=2;biotech=2"

/obj/item/weapon/circuitboard/computer/rdservercontrol
	name = "circuit board (R&D Server Control)"
	computertype = /obj/machinery/computer/rdservercontrol
	origin_tech = "programming=3"

/obj/item/weapon/circuitboard/computer/rdconsole
	name = "circuit board (R&D Console)"
	computertype = /obj/machinery/computer/rdconsole/core

/obj/item/weapon/circuitboard/computer/pandemic
	name = "circuit board (PanD.E.M.I.C. 2200)"
	computertype = /obj/machinery/computer/pandemic
	origin_tech = "programming=2;biotech=2"

/obj/item/weapon/circuitboard/computer/mecha_control
	name = "circuit board (Exosuit Control Console)"
	computertype = /obj/machinery/computer/mecha

/obj/item/weapon/circuitboard/computer/prisoner
	name = "circuit board (Prisoner Management Console)"
	computertype = /obj/machinery/computer/prisoner

/obj/item/weapon/circuitboard/computer/ordercomp
	name = "circuit board (Supply Ordering Console)"
	computertype = /obj/machinery/computer/cargo/ordercomp

/obj/item/weapon/circuitboard/computer/supplycomp
	name = "circuit board (Supply shuttle console)"
	computertype = /obj/machinery/computer/cargo/supplycomp
	origin_tech = "programming=3"

/obj/item/weapon/circuitboard/computer/supplycomp/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I,/obj/item/device/multitool))
		switch(alert("Current receiver spectrum is set to: [hacked ? "BROAD" : "STANDARD"]","Multitool-Circuitboard interface","Switch to [!hacked ? "BROAD" : "STANDARD"]","Cancel") )
			if("Switch to STANDARD","Switch to BROAD")
				hacked = !hacked

			if("Cancel")
				return
	return


/obj/structure/frame
	density = 1
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "box_0"

/obj/structure/frame/computer
	anchored = 0
	name = "computer frame"
	icon_state = "0"
	var/state = 0
	var/obj/item/weapon/circuitboard/computer/circuit = null


/obj/structure/frame/computer/attackby(obj/item/weapon/P as obj, mob/user as mob)
	switch(state)
		if(0)
			if(istype(P, /obj/item/weapon/wrench))
				playsound(src.loc, 'Ratchet.ogg', 50, 1)
				user << "\blue You start wrenching the frame into place."
				if(do_after(user, 20))
					user << "\blue You wrench the frame into place."
					anchored = 1
					state = 1
			if(istype(P, /obj/item/weapon/weldingtool))
				playsound(src.loc, 'Welder.ogg', 50, 1)
				user << "\blue You deconstruct the frame."
				var/obj/item/stack/sheet/metal/A = new /obj/item/stack/sheet/metal( src.loc )
				if(src.circuit)
					circuit.loc = src.loc
				A.amount = 5
				del(src)
		if(1)
			if(istype(P, /obj/item/weapon/wrench))
				playsound(src.loc, 'Ratchet.ogg', 50, 1)
				user << "\blue You start unfastening the frame."
				if(do_after(user, 20))
					user << "\blue You unfasten the frame."
					anchored = 0
					state = 0
			if(istype(P, /obj/item/weapon/circuitboard/computer) && !circuit)
				playsound(src.loc, 'Deconstruct.ogg', 50, 1)
				user << "\blue You place the circuit board inside the frame."
				src.icon_state = "1"
				src.circuit = P
				user.drop_item()
				P.loc = src
			if(istype(P, /obj/item/weapon/screwdriver) && circuit)
				playsound(src.loc, 'Screwdriver.ogg', 50, 1)
				user << "\blue You screw the circuit board into place."
				state = 2
				icon_state = "2"
			if(istype(P, /obj/item/weapon/crowbar) && circuit)
				playsound(src.loc, 'Crowbar.ogg', 50, 1)
				user << "\blue You remove the circuit board."
				state = 1
				icon_state = "0"
				circuit.loc = src.loc
				circuit = null
		if(2)
			if(istype(P, /obj/item/weapon/screwdriver) && circuit)
				playsound(src.loc, 'Screwdriver.ogg', 50, 1)
				user << "\blue You unfasten the circuit board."
				src.state = 1
				src.icon_state = "1"
			if(istype(P, /obj/item/weapon/cable_coil))
				var/obj/item/weapon/cable_coil/Coil = P
				if(Coil.use(5))
					playsound(src.loc, 'Deconstruct.ogg', 50, 1)
					user << "\blue You add cables to the frame."
					state = 3
					icon_state = "3"
		if(3)
			if(istype(P, /obj/item/weapon/wirecutters))
				playsound(src.loc, 'wirecutter.ogg', 50, 1)
				user << "\blue You remove the cables."
				src.state = 2
				src.icon_state = "2"
				var/obj/item/weapon/cable_coil/power/A = new /obj/item/weapon/cable_coil/power( src.loc )
				A.amount = 5

			if(istype(P, /obj/item/stack/sheet/glass))
				if(P:amount >= 2)
					playsound(src.loc, 'Deconstruct.ogg', 50, 1)
					P:amount -= 2
					if(!P:amount) del(P)
					user << "\blue You put in the glass panel."
					src.state = 4
					src.icon_state = "4"
		if(4)
			if(istype(P, /obj/item/weapon/crowbar))
				playsound(src.loc, 'Crowbar.ogg', 50, 1)
				user << "\blue You remove the glass panel."
				src.state = 3
				src.icon_state = "3"
				var/obj/item/stack/sheet/glass/A = new /obj/item/stack/sheet/glass(src.loc)
				A.amount = 2
			if(istype(P, /obj/item/weapon/screwdriver))
				playsound(src.loc, 'Screwdriver.ogg', 50, 1)
				user << "\blue You connect the monitor."
				var/obj/machinery/computer/B = new circuit.computertype(src.loc)

				if(circuit.id) B:id = circuit.id
				if(circuit.frequency) B:frequency = circuit.frequency
				if(circuit.hacked) B:hacked = circuit.hacked

				del(src)