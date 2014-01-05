/datum/event/electricalstorm
	var/datum/signal_scrambler/scrambler
	var/list/Lights = list()
	var/list/APCs = list()
	var/list/Doors = list()

	Announce()
		command_alert("The ship is flying through an electrical storm.  Radio communications may be disrupted", "Anomaly Alert")

		scrambler = new /datum/signal_scrambler()
		scrambler.power = rand(30, 100)

		for(var/obj/machinery/light/Light in world)
			src.Lights += Light

		for(var/obj/machinery/power/apc/APC in world)
			src.APCs += APC

		for(var/obj/machinery/door/airlock/Door in world)
			src.Doors += Door

	Tick()
		for(var/x = 0; x < 2; x++)
			if (prob(50))
				BlowLight()
		if (prob(20))
			DisruptAPC()
		if (prob(20))
			DisableDoor()

	Die()
		command_alert("The ship has cleared the electrical storm.  Radio communications restored", "Anomaly Alert")
		del(scrambler)
		/*for (var/datum/radio_frequency/Freq in ScrambledFrequencies)
			radio_controller.UnregisterScrambler(Freq)*/

	proc/BlowLight() //Blow out a light fixture
		var/obj/machinery/light/Light = pick(Lights)
		if(Light.status != LIGHT_OK)
			return

		spawn(0) //Overload the light, spectacularly.
			Light.ul_SetLuminosity(10)
			sleep(5)
			if(Light) // Just in case
				Light.on = 1
				Light.broken()

	proc/DisruptAPC()
		var/obj/machinery/power/apc/APC = pick(APCs)
		if(APC.crit)
			return

		if (prob(40))
			APC.operating = 0 //Blow its breaker
		if (prob(8))
			APC.set_broken()

	proc/DisableDoor()
		var/obj/machinery/door/airlock/Airlock = pick(Doors)

		if(prob(70))
			Airlock.wires.PulseColour(GetWireColorByFlag(AIRLOCK_WIRE_DOOR_BOLTS, /obj/machinery/door/airlock))
		else if(prob(50))
			Airlock.wires.PulseColour(GetWireColorByFlag(AIRLOCK_WIRE_MAIN_POWER1, /obj/machinery/door/airlock))
		else
			Airlock.wires.RandomPulse()