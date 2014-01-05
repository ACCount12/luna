/datum/NTSL_Compiler/bot
	Run()
		..()
		var/obj/machinery/bot/code/Holder2 = Holder	// the bot that is running the code
		// bot telemetry data
		interpreter.SetVar("$health", 	Holder2.health)

		// Set up the script procs

		/*
			-> Move our shiny metal ass
					@format: move(dir)

					@param dir:		Direction of movement
		*/
		interpreter.SetProc("move", "mv", Holder2, list("dir"))

		/*
			-> Display an emote.
					@format: signal(signal)

					@param signal:		Signal, see bot's emote proc
		*/
		interpreter.SetProc("signal", "emote", Holder2, list("signal"))



/*		/*
			-> Send a code signal.
					@format: signal(frequency, code)

					@param frequency:		Frequency to send the signal to
					@param code:			Encryption code to send the signal with
		*/
		interpreter.SetProc("signal", "signaler", Holder, list("freq", "code"))

		/*
			-> Store a value permanently to the server machine (not the actual game hosting machine, the ingame machine)
					@format: mem(address, value)

					@param address:		The memory address (string index) to store a value to
					@param value:		The value to store to the memory address
		*/
		interpreter.SetProc("mem", "mem", Holder, list("address", "value"))*/


		// Run the compiled code
		interpreter.Run()