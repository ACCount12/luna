/* --- Traffic Control Scripting Language --- */
	// Nanotrasen TCS Language - Made by Doohl

/n_Interpreter/TCS_Interpreter
	HandleError(runtimeError/e)
		..()
		Compiler.Holder.add_entry(e.ToString(), "Execution Error")


/datum/NTSL_Compiler/TCS
	interpreter_type = /n_Interpreter/TCS_Interpreter

	/* -- Execute the compiled code -- */

	Run(var/datum/signal/signal)
		var/n_Interpreter/TCS_Interpreter/interpreter2 = interpreter
		var/obj/machinery/telecomms/server/Holder2 = Holder	// the server that is running the code
		..()
		// Channel macros
		interpreter2.SetVar("$common",	1459)
		interpreter2.SetVar("$science",	1351)
		interpreter2.SetVar("$command",	1353)
		interpreter2.SetVar("$medical",	1355)
		interpreter2.SetVar("$engineering",1357)
		interpreter2.SetVar("$security",	1359)
		interpreter2.SetVar("$supply",	1347)
		interpreter2.SetVar("$service",	1349)

		// Signal data
		interpreter2.SetVar("$content", 	signal.data["message"])
		interpreter2.SetVar("$freq"   , 	signal.frequency)
		interpreter2.SetVar("$source" , 	signal.data["name"])
		interpreter2.SetVar("$job"    , 	signal.data["job"])
		interpreter2.SetVar("$sign"   ,		signal)
		interpreter2.SetVar("$pass"	  ,		!(signal.data["reject"])) // if the signal isn't rejected, pass = 1; if the signal IS rejected, pass = 0

		// Set up the script procs

		/*	-> Send another signal to a server
					@format: broadcast(content, frequency, source, job)

					@param content:		Message to broadcast
					@param frequency:	Frequency to broadcast to
					@param source:		The name of the source you wish to imitate. Must be stored in stored_names list.
					@param job:			The name of the job.
		*/
		interpreter2.SetProc("broadcast", "tcombroadcast", signal, list("message", "freq", "source", "job"))

		/*	-> Send a code signal.
					@format: signal(frequency, code)

					@param frequency:		Frequency to send the signal to
					@param code:			Encryption code to send the signal with
		*/
		interpreter2.SetProc("signal", "signaler", signal, list("freq", "code"))

		/*	-> Store a value permanently to the server machine (not the actual game hosting machine, the ingame machine)
					@format: mem(address, value)

					@param address:		The memory address (string index) to store a value to
					@param value:		The value to store to the memory address
		*/
		interpreter2.SetProc("mem", "mem", signal, list("address", "value"))


		// Run the compiled code
		interpreter2.Run()

		// Backwards-apply variables onto signal data
		/* sanitize EVERYTHING. fucking players can't be trusted with SHIT */

		signal.data["message"] 	= interpreter2.GetCleanVar("$content", signal.data["message"])
		signal.frequency 		= interpreter2.GetCleanVar("$freq", signal.frequency)

		var/setname = interpreter.GetCleanVar("$source", signal.data["name"])

		if(signal.data["name"] != setname)
			signal.data["realname"] = setname
		signal.data["name"]		= setname
		signal.data["job"]		= interpreter2.GetCleanVar("$job", signal.data["job"])
		signal.data["reject"]	= !(interpreter2.GetCleanVar("$pass")) // set reject to the opposite of $pass

		// If the message is invalid, just don't broadcast it!
		if(signal.data["message"] == "" || !signal.data["message"])
			signal.data["reject"] = 1

/*  -- Actual language proc code --  */

var/const/SIGNAL_COOLDOWN = 20 // 2 seconds

datum/signal

	proc/mem(var/address, var/value)

		if(istext(address))
			var/obj/machinery/telecomms/server/S = data["server"]

			if(!value && value != 0)
				return S.memory[address]

			else
				S.memory[address] = value


	proc/signaler(var/freq = 1459, var/code = 30)

		if(isnum(freq) && isnum(code))

			var/obj/machinery/telecomms/server/S = data["server"]

			if(S.last_signal + SIGNAL_COOLDOWN > world.timeofday && S.last_signal < MIDNIGHT_ROLLOVER)
				return
			S.last_signal = world.timeofday

			var/datum/radio_frequency/connection = radio_controller.return_frequency(freq)

			if(findtext(num2text(freq), ".")) // if the frequency has been set as a decimal
				freq *= 10 // shift the decimal one place

			freq = sanitize_frequency(freq)

			code = round(code)
			code = Clamp(code, 0, 100)

			var/datum/signal/signal = new
			signal.source = S
			signal.encryption = code
			signal.data["message"] = "ACTIVATE"

			connection.post_signal(S, signal)

			var/time = time2text(world.realtime,"hh:mm:ss")
			lastsignalers.Add("[time] <B>:</B> [S.id] sent a signal command, which was triggered by NTSL.<B>:</B> [format_frequency(freq)]/[code]")


	proc/tcombroadcast(var/message, var/freq, var/source, var/job)

		var/datum/signal/newsign = new
		var/obj/machinery/telecomms/server/S = data["server"]
		var/obj/item/device/radio/hradio = S.server_radio

		if(!hradio)
			error("[src] has no radio.")
			return

		if((!message || message == "") && message != 0)
			message = "*beep*"
		if(!source)
			source = "[html_encode(uppertext(S.id))]"
			hradio = new // sets the hradio as a radio intercom
		if(!freq || (!isnum(freq) && text2num(freq) == null))
			freq = 1459
		if(findtext(num2text(freq), ".")) // if the frequency has been set as a decimal
			freq *= 10 // shift the decimal one place

		if(!job)
			job = "?"

		newsign.data["mob"] = null
		newsign.data["mobtype"] = /mob/living/carbon/human
		newsign.data["name"] = source
		newsign.data["realname"] = newsign.data["name"]
		newsign.data["job"] = "[job]"
		newsign.data["compression"] = 0
		newsign.data["message"] = message
		newsign.data["type"] = 2 // artificial broadcast
		if(!isnum(freq))
			freq = text2num(freq)
		newsign.frequency = freq

		var/datum/radio_frequency/connection = radio_controller.return_frequency(freq)
		newsign.data["connection"] = connection


		newsign.data["radio"] = hradio
		newsign.data["vmessage"] = message
		newsign.data["vname"] = source
		newsign.data["vmask"] = 0
		newsign.data["level"] = list()

		newsign.sanitize_data()

		var/pass = S.relay_information(newsign, "/obj/machinery/telecomms/hub")
		if(!pass)
			S.relay_information(newsign, "/obj/machinery/telecomms/broadcaster") // send this simple message to broadcasters

