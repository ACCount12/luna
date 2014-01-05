/obj/cabling/power
	icon = 'power_cond.dmi'
	name = "power cable"

	ConnectableTypes = list(/obj/machinery/power, /obj/structure/grille)
	NetworkControllerType = /datum/UnifiedNetworkController/PowernetController
	DropCablePieceType = /obj/item/weapon/cable_coil
	EquivalentCableType = /obj/cabling/power

/obj/item/weapon/cable_coil/power
	icon_state = "redcoil3"
	CoilColour = "red"
	BaseName  = "Electrical"
	CableType = /obj/cabling/power

/obj/cabling/power/heavy
	icon = 'power_heavy.dmi'
	DropCablePieceType = /obj/item/weapon/cable_coil/heavy

/obj/item/weapon/cable_coil/heavy
	icon_state = "heavycoil3"

	CoilColour = "heavy"
	CanLayDiagonally = 0