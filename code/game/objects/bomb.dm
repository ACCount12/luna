/obj/effect/spawner/bomb
	name = "bomb"
	icon = 'screen1.dmi'
	icon_state = "x"
	var/btype = 0  //0 = radio, 1= prox, 2=time
	var/explosive = 1	// 0= firebomb
	var/btemp = 500	// bomb temperature (degC)
	var/active = 0

/obj/effect/spawner/bomb/New()
	..()
	var/obj/item/device/onetankbomb/bomb = new /obj/item/device/onetankbomb(get_turf(src))

	bomb.bombtank = new /obj/item/weapon/tank/plasma(bomb)
	bomb.bombtank.air_contents.temperature = btemp + T0C

	bomb.bombassembly = new /obj/item/device/assembly_holder(bomb)

	var/obj/item/device/assembly/assembly

	switch (btype)
		if(0) // radio
			assembly = new /obj/item/device/assembly/signaler/open()

		if(1) // proximity
			assembly = new /obj/item/device/assembly/prox_sensor()

		if(2) // timer
			assembly = new /obj/item/device/assembly/timer()
			assembly:time = 30

		if(3) // bombvest
			assembly = new /obj/item/device/assembly/health/open()

	bomb.bombassembly.attach(new /obj/item/device/assembly/igniter(), assembly)

	bomb.status = 1

	del(src)

/obj/effect/spawner/bomb/radio
	btype = 0

/obj/effect/spawner/bomb/proximity
	btype = 1

/obj/effect/spawner/bomb/timer
	btype = 2

/obj/effect/spawner/bomb/timer/syndicate
	btemp = 450

/obj/effect/spawner/bomb/suicide
	btype = 3


/obj/effect/spawner/newbomb
	name = "bomb"
	icon = 'screen1.dmi'
	icon_state = "x"
	var/btype = 0 // 0=radio, 1=prox, 2=time
	var/btemp1 = 1000
	var/btemp2 = 800	// tank temperatures

/obj/effect/spawner/newbomb/New()
	..()
	var/obj/item/device/transfer_valve/V = new(src.loc)
	var/obj/item/weapon/tank/plasma/PT = new(V)
	var/obj/item/weapon/tank/oxygen/OT = new(V)
	PT.master = V
	OT.master = V
	V.tank_one = PT
	V.tank_two = OT

	PT.air_contents.temperature = btemp1 + T0C
	OT.air_contents.temperature = btemp2 + T0C

	var/obj/item/device/assembly/A

	switch (src.btype)
		if (0) // radio
			A = new /obj/item/device/assembly/signaler(V)

		if (1) // proximity
			A = new /obj/item/device/assembly/prox_sensor(V)

		if (2) // timer
			A = new /obj/item/device/assembly/timer(V)
			A:time = 30

	V.attached_device = A
	A.holder = V
	A.toggle_secure()	//this calls update_icon(), which calls update_icon() on the holder (i.e. the bomb).

	del(src)

/obj/effect/spawner/newbomb/timer
	btype = 2

/obj/effect/spawner/newbomb/timer/syndicate
	name = "Low-Yield Bomb"
	btemp1 = 1500
	btemp2 = 1000

/obj/effect/spawner/newbomb/proximity
	btype = 1

/obj/effect/spawner/newbomb/radio
	btype = 0