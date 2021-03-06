/obj/item/weapon/disk
	name = "disk"
	icon = 'items.dmi'
	w_class = 1.0

/obj/item/weapon/disk/data
	name = "data disk"
	var/title = "Data Disk"
	icon_state = "datadisk0"
	item_state = "card-id"
	var/data
	var/read_only = 0
	var/portable = 1

/obj/item/weapon/disk/data/attack_self(mob/user as mob)
	src.read_only = !src.read_only
	user << "You flip the write-protect tab to [src.read_only ? "protected" : "unprotected"]."

/obj/item/weapon/disk/data/examine()
	set src in oview(5)
	..()
	usr << text("The write-protect tab is set to [src.read_only ? "protected" : "unprotected"].")
	return


//TO DO: Look over this code. Something is fishy in it, possibly the way it stores the UI and the UE.
/obj/item/weapon/disk/data/genetics
	name = "genetics data disk"
	icon_state = "datadiskgen0" //Gosh I hope syndies don't mistake them for the nuke disk.
	var/datum/dna_buffer/dna

/obj/item/weapon/disk/data/genetics/New()
	..()
	var/diskcolor = pick(0,1,2)
	src.icon_state = "datadiskgen[diskcolor]"



/obj/item/weapon/disk/nuclear
	name = "nuclear authentication disk"
	icon_state = "nucleardisk"
	item_state = "card-id"

/obj/item/weapon/disk/nuclear/Del()
	if (ticker.mode && ticker.mode.name == "nuclear emergency")
		if(blobstart.len > 0)
			var/obj/D = new /obj/item/weapon/disk/nuclear(pick(blobstart))
			message_admins("[src] has been destroyed. Spawning [D] at ([D.x], [D.y], [D.z]).")
	..()