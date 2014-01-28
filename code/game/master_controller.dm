var/global/datum/controller/game_controller/master_controller //Set in world.New()
var/ticker_debug
var/updatetime
var/global/gametime = 0
var/global/gametime_last_updated

#define PROCESS_KILL 26	//Used to trigger removal from a processing lists

/datum/controller/game_controller
	var/processing = 1
	var/breather_ticks = 2
	//a somewhat crude attempt to iron over the 'bumps' caused by high-cpu use
	//by letting the MC have a breather for this many ticks after every loop

	var/air_cost 		= 0 //
	var/sun_cost		= 0 //
	var/mobs_cost		= 0 //
	var/turfs_cost		= 0 //
	var/diseases_cost	= 0 //
	var/objects_cost	= 0 //
	var/items_cost		= 0 //
	var/pipes_cost		= 0 //
	var/powernets_cost	= 0 //
	var/fire_cost		= 0 //
	var/others_cost		= 0 //
	var/ticker_cost		= 0 //
	var/total_cost		= 0

	var/last_thing_processed


	//var/lastannounce = 0
	var/tick = 0

	proc/setup()
		set background = 1
		if(master_controller && (master_controller != src))
			del(src) // There can be only one master.
		world << "Initializing world.."
		diary << "World initialization started at [time2text(world.timeofday, "hh:mm.ss")]"
		var/start_worldinit = world.timeofday

		spawn(0)
			world.startmysql()
			world.load_mode()
			world.load_motd()
			world.load_rules()
			world.load_admins()
			world.update_status()

		world << "\red \b Setting up shields.."
		var/start_shieldnetwork = world.timeofday
		ShieldNetwork = new /datum/shieldnetwork()
		vsc = new()

		ShieldNetwork.makenetwork()

		world << "\red \b Shield network set up in [(world.timeofday - start_shieldnetwork)/10] seconds"

		setupnetwork()
		sun = new /datum/sun()

		vote = new /datum/vote()

		world << "\red \b Creating radio controller.."
		var/start_radio_controller = world.timeofday
		radio_controller = new /datum/controller/radio()
		world << "\red \b Radio controller created in [(world.timeofday - start_radio_controller)/10] seconds"
		//main_hud1 = new /obj/hud()
		data_core = new /obj/effect/datacore()
		CreateShuttles()

		if(!air_master)
			world << "\red \b Initializing air controller"
			diary << "Air controller initialization started at [time2text(world.timeofday, "hh:mm.ss")]"
			var/start_airmaster = world.timeofday
			air_master = new /datum/controller/air_system()
			air_master.setup()
			world << "\red \b Air controller initialized in [(world.timeofday - start_airmaster)/10] seconds!"
			diary << "Air controller initialized at [time2text(world.timeofday, "hh:mm.ss")]. It took [(world.timeofday - start_airmaster)/10] seconds."

		plmaster = new /obj/overlay(  )
		plmaster.icon = 'tile_effects.dmi'
		plmaster.icon_state = "plasma"
		plmaster.layer = FLY_LAYER
		plmaster.mouse_opacity = 0

		slmaster = new /obj/overlay(  )
		slmaster.icon = 'tile_effects.dmi'
		slmaster.icon_state = "sleeping_agent"
		slmaster.layer = FLY_LAYER
		slmaster.mouse_opacity = 0

		world.update_status()

		ClearTempbans()

		setup_objects()

		setupgenetics()

		setupmining() //mining setup

		setuptitles()
		SetupAnomalies()
	//	tgrid.Setup()
		setupdooralarms() // Added by Strumpetplaya - Alarm Change
		BOOKHAND = new()
		world << "\red \b Setting up the book system..."

	// main_shuttle = new /datum/shuttle_controller/main_shuttle()
	// Handled by datum declerations now in the shuttle controller file

		if(!ticker)
			ticker = new /datum/controller/gameticker()

		// setup the in-game time
		gametime = rand(0,2200)
		gametime_last_updated = world.timeofday

		spawn
			ticker.pregame()

		world << "\red \b World initialized in [(world.timeofday - start_worldinit)/10] seconds"
		diary << "World initialized in [time2text(world.timeofday, "hh:mm.ss")]. It took [(world.timeofday - start_worldinit)/10] seconds."

	proc/setup_objects()
		world << "\red \b Initializing objects..."
		diary << "Object initialization started at [time2text(world.timeofday, "hh:mm.ss")]"
		sleep(-1)

		var/count_obj = 0
		var/start_objects_init = world.timeofday

		for(var/obj/object in world)
			object.initialize()
			count_obj++

		world << "\red \b [count_obj] objects initialized in [(world.timeofday - start_objects_init)/10] seconds!"
		diary << "Object initialization finished at [time2text(world.timeofday, "hh:mm.ss")]. It took [(world.timeofday - start_objects_init)/10] seconds to start [count_obj] objects."

		world << "\red \b Initializing pipe networks..."

		for(var/obj/machinery/atmospherics/machine in world)
			machine.build_network()


		world << "\red \b Building Unified Networks..."
		diary << "Unified Network creation started at [time2text(world.timeofday, "hh:mm.ss")]"
		var/start_network_creation = world.timeofday

		MakeUnifiedNetworks()

		world << "\red \b Unified Networks created in [(world.timeofday - start_network_creation)/10] seconds!"
		diary << "Unified Networks created in [time2text(world.timeofday, "hh:mm.ss")]. It took [(world.timeofday-start_network_creation)/10] seconds."

		sleep(-1)

		//Surgeries
		for(var/path in typesof(/datum/surgery))
			if(path == /datum/surgery)
				continue
			var/datum/surgery/S = new path()
			surgeries_list[S.name] = S

		world << "\red \b Initializations complete."

		/*var/list/l = new /list
		var/savefile/f = new("closet.sav")
		var/turf/t = locate(38,56,7)
		f["list"]>>l
		for(var/obj/o in l)
			var/obj/b = new o.type
			//var/obj/b.vars = o.vars.Copy()
			b.loc = t*/


	proc/process()
		if(!processing)
			return 0

		while(1)
			//var/start_time = world.timeofday
			tick++ // keep track of the ticks

			// update the clock
			// one real-life minute is 100 time-units
			gametime += (100 / 60) * (world.timeofday - gametime_last_updated) / 10
			gametime_last_updated = world.timeofday
			if(gametime > 2200) gametime -= 2200

			if(tick % 60 == 0)
				world.keepalive()

			// reduce frequency of the air process
			if(tick % 5 == 0)
				air_cost = process_air()
			sleep(breather_ticks)

			sun_cost = process_sun()
			sleep(breather_ticks)

			mobs_cost = process_life()
			sleep(breather_ticks)

			fire_cost = process_fire()
			sleep(breather_ticks)

			items_cost = process_items()
			sleep(breather_ticks)

			objects_cost = process_objects()
			sleep(breather_ticks)

			pipes_cost = process_pipes()
			sleep(breather_ticks)

			powernets_cost = process_powernets()
			sleep(breather_ticks)

			turfs_cost = process_turfs()
			sleep(breather_ticks)

			others_cost = process_others()
			sleep(breather_ticks)

			diseases_cost = process_diseases()
			sleep(breather_ticks)

			ticker_cost = process_ticker()
			sleep(breather_ticks)

			if(world.timeofday >= updatetime)
				updatetime = world.timeofday + 3000

			total_cost = 0

			total_cost += air_cost + sun_cost
			total_cost += mobs_cost + turfs_cost
			total_cost += diseases_cost + objects_cost
			total_cost += items_cost + pipes_cost
			total_cost += powernets_cost + fire_cost
			total_cost += others_cost + ticker_cost

			//tgrid.Tick(0) // Part of Alfie's travel code
			sleep(10 * tick_multiplier)


// Processing...
/datum/controller/game_controller/proc/process_fire()
	var/timer = world.timeofday
	ticker_debug = "fire processing"
	last_thing_processed = /obj/effect/fire

	for(var/obj/effect/fire/F in processing_fires)
		F.process()

	return (world.timeofday - timer) / 10


/datum/controller/game_controller/proc/process_life()
	var/timer = world.timeofday
	ticker_debug = "life processing"

	for(var/mob/M in mob_list)
		last_thing_processed = M.type
		M.Life()

	return (world.timeofday - timer) / 10


/datum/controller/game_controller/proc/process_sun()
	var/timer = world.timeofday
	ticker_debug = "sun processing"
	sun.calc_position()
	return (world.timeofday - timer) / 10


/datum/controller/game_controller/proc/process_air()
	var/timer = world.timeofday
	ticker_debug = "air processing"
	air_master.process()
	return (world.timeofday - timer) / 10


/datum/controller/game_controller/proc/process_items()
	var/timer = world.timeofday
	ticker_debug = "items processing"

	for(var/obj/item/item in processing_items)
		last_thing_processed = item.type
		if(item.process() == PROCESS_KILL)
			processing_items.Remove(item)

	return (world.timeofday - timer) / 10


/datum/controller/game_controller/proc/process_objects()
	var/timer = world.timeofday
	ticker_debug = "objects processing"

	var/i = 1
	while(i<=processing_objects.len)
		var/obj/Object = processing_objects[i]
		if(Object)
			if(Object.use_power)
				Object.auto_use_power()
			last_thing_processed = Object.type

			Object.process()
			i++
			continue

			/*if(Object.process() != PROCESS_KILL)
				i++
				continue*/
		processing_objects.Cut(i,i+1)

	return (world.timeofday - timer) / 10


/datum/controller/game_controller/proc/process_pipes()
	var/timer = world.timeofday
	ticker_debug = "pipes processing"

	for(var/datum/pipe_network/network in pipe_networks)
		network.process()

	return (world.timeofday - timer) / 10


/datum/controller/game_controller/proc/process_powernets()
	var/timer = world.timeofday
	ticker_debug = "uninets processing"

	for(var/OuterKey in AllNetworks)
		var/list/NetworkSet = AllNetworks[OuterKey]
		for(var/datum/UnifiedNetwork/Network in NetworkSet)
			if(Network)	Network.Controller.Process()

	return (world.timeofday - timer) / 10


/datum/controller/game_controller/proc/process_turfs()
	var/timer = world.timeofday
	ticker_debug = "turfs processing"

	for(var/turf/t in processing_turfs)
		last_thing_processed = t.type
		t.process()

	return (world.timeofday - timer) / 10


/datum/controller/game_controller/proc/process_diseases()
	var/timer = world.timeofday
	ticker_debug = "diseases processing"

	for(var/datum/disease/Disease in active_diseases)
		last_thing_processed = Disease.type
		Disease.process()

	return (world.timeofday - timer) / 10


/datum/controller/game_controller/proc/process_others()
	var/timer = world.timeofday
	ticker_debug = "other stuff processing"

	for(var/atom/A in processing_others) // The few exceptions which don't fit in the above lists
		last_thing_processed = A.type
		A:process()

	return (world.timeofday - timer) / 10


/datum/controller/game_controller/proc/process_ticker()
	var/timer = world.timeofday
	ticker_debug = "ticker processing"

	ticker.process()

	return (world.timeofday - timer) / 10