#define TIME_LEFT (SSshuttle.emergency.timeLeft())
#define ENGINES_START_TIME 100
#define ENGINES_STARTED (SSshuttle.emergency.mode == SHUTTLE_IGNITING)
#define IS_DOCKED (SSshuttle.emergency.mode == SHUTTLE_DOCKED || (ENGINES_STARTED))

/obj/machinery/computer/emergency_shuttle
	name = "emergency shuttle console"
	desc = ""
	ui_x = 400
	ui_y = 400

	var/auth_need = 3
	var/list/authorized = list()

/obj/machinery/computer/emergency_shuttle/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.human_adjacent_state)

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "emergency_shuttle_console", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/computer/emergency_shuttle/ui_data()
	var/list/data = list()

	data["timer_str"] = SSshuttle.emergency.getTimerStr()
	data["engines_started"] = ENGINES_STARTED
	data["authorizations_remaining"] = max((auth_need - authorized.len), 0)
	var/list/A = list()
	data["authorizations"] = A

	data["enabled"] = (IS_DOCKED && !ENGINES_STARTED)
	data["emagged"] = obj_flags & EMAGGED ? 1 : 0
	return data

/obj/machinery/computer/emergency_shuttle/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	if(ENGINES_STARTED) // past the point of no return
		return
	if(!IS_DOCKED) // shuttle computer only has uses when onstation
		return
	return FALSE

/obj/machinery/computer/emergency_shuttle/process()
	// Launch check is in process in case auth_need changes for some reason
	// probably external.
	. = FALSE
	if(!SSshuttle.emergency)
		return

	if(SSshuttle.emergency.mode == SHUTTLE_STRANDED)
		authorized.Cut()
		DISABLE_BITFIELD(obj_flags, EMAGGED)

	if(ENGINES_STARTED || (!IS_DOCKED))
		return .

	// Check to see if we've reached criteria for early launch
	if((authorized.len >= auth_need) || (obj_flags & EMAGGED))
		// shuttle timers use 1/10th seconds internally
		SSshuttle.emergency.setTimer(ENGINES_START_TIME)
		var/system_error = obj_flags & EMAGGED ? "SYSTEM ERROR:" : null
		minor_announce("The emergency shuttle will launch in \
			[TIME_LEFT] seconds", system_error, alert=TRUE)
		. = TRUE

/obj/machinery/computer/emergency_shuttle/emag_act(mob/user)
	// How did you even get on the shuttle before it go to the station?
	if(!IS_DOCKED)
		return

	if(CHECK_BITFIELD(obj_flags, EMAGGED) || ENGINES_STARTED)	//SYSTEM ERROR: THE SHUTTLE WILL LA-SYSTEM ERROR: THE SHUTTLE WILL LA-SYSTEM ERROR: THE SHUTTLE WILL LAUNCH IN 10 SECONDS
		to_chat(user, "<span class='warning'>The shuttle is already about to launch!</span>")
		return

	var/time = TIME_LEFT
	message_admins("[ADMIN_LOOKUPFLW(user.client)] has emagged the emergency shuttle [time] seconds before launch.")
	log_game("[key_name(user)] has emagged the emergency shuttle in [COORD(src)] [time] seconds before launch.")

	ENABLE_BITFIELD(obj_flags, EMAGGED)
	SSshuttle.emergency.movement_force = list("KNOCKDOWN" = 60, "THROW" = 20)//YOUR PUNY SEATBELTS can SAVE YOU NOW, MORTAL
	process()

/obj/docking_port/mobile/emergency
	name = "emergency shuttle"
	id = "emergency"

	dwidth = 9
	width = 22
	height = 11
	dir = EAST
	port_direction = WEST
	var/sound_played = 0 //If the launch sound has been sent to all players on the shuttle itself
	var/startTime = 0 // this + ROUNDTIMERBOAT is real launch time
	var/earlyLaunch = FALSE

/obj/docking_port/mobile/emergency/canDock(obj/docking_port/stationary/S)
	return SHUTTLE_CAN_DOCK //If the emergency shuttle can't move, the whole game breaks, so it will force itself to land even if it has to crush a few departments in the process

/obj/docking_port/mobile/emergency/register()
	. = ..()
	SSshuttle.emergency = src
//#ifdef MATURESERVER
//	SSshuttle.moveShuttle("emergency", "emergency_home", TRUE)
//#endif
/obj/docking_port/mobile/emergency/Destroy(force)
	if(force)
		// This'll make the shuttle subsystem use the backup shuttle.
		if(src == SSshuttle.emergency)
			// If we're the selected emergency shuttle
			SSshuttle.emergencyDeregister()

	. = ..()

/obj/docking_port/mobile/emergency/request(obj/docking_port/stationary/S, area/signalOrigin, reason, redAlert, set_coefficient=null)
//	if(!isnum(set_coefficient))
//		var/security_num = seclevel2num(get_security_level())
//		switch(security_num)
//			if(SEC_LEVEL_GREEN)
//				set_coefficient = 2
//			if(SEC_LEVEL_BLUE)
//				set_coefficient = 1
//			else
//				set_coefficient = 0.5
//	var/call_time = SSshuttle.emergencyCallTime * set_coefficient * engine_coeff
	switch(mode)
		// The shuttle can not normally be called while "recalling", so
		// if this proc is called, it's via admin fiat
		if(SHUTTLE_RECALL, SHUTTLE_IDLE, SHUTTLE_CALL)
			mode = SHUTTLE_CALL
			setTimer(0) //call_time went here
		else
			return

	SSshuttle.emergencyCallAmount++

	if(prob(70))
		SSshuttle.emergencyLastCallLoc = signalOrigin
	else
		SSshuttle.emergencyLastCallLoc = null

//	priority_announce("The emergency shuttle has been called. [redAlert ? "Red Alert state confirmed: Dispatching priority shuttle. " : "" ]It will arrive in [timeLeft(600)] minutes.[reason][SSshuttle.emergencyLastCallLoc ? "\n\nCall signal traced. Results can be viewed on any communications console." : "" ]", null, 'sound/blank.ogg', "Priority")

/obj/docking_port/mobile/emergency/cancel(area/signalOrigin)
	if(mode != SHUTTLE_CALL)
		return
	if(SSshuttle.emergencyNoRecall)
		return

	invertTimer()
	mode = SHUTTLE_RECALL

	if(prob(70))
		SSshuttle.emergencyLastCallLoc = signalOrigin
	else
		SSshuttle.emergencyLastCallLoc = null
	priority_announce("The emergency shuttle has been recalled.[SSshuttle.emergencyLastCallLoc ? " Recall signal traced. Results can be viewed on any communications console." : "" ]", null, 'sound/blank.ogg', "Priority")

/obj/docking_port/mobile/emergency/proc/is_hijacked()
	var/has_people = FALSE
	var/hijacker_present = FALSE
	for(var/mob/living/player in GLOB.player_list)
		if(player.mind)
			if(player.stat != DEAD)
				if(isanimal(player)) //animals don't count
					continue
				if(isbrain(player)) //also technically dead
					continue
				if(shuttle_areas[get_area(player)])
					has_people = TRUE
					var/location = get_turf(player.mind.current)
					//Non-antag present. Can't hijack.
					if(!(player.mind.has_antag_datum(/datum/antagonist)) && !istype(location, /turf/open/floor/plasteel/shuttle/red) && !istype(location, /turf/open/floor/mineral/plastitanium/red/brig))
						return FALSE
					//Antag present, doesn't stop but let's see if we actually want to hijack
					var/prevent = FALSE
					for(var/datum/antagonist/A in player.mind.antag_datums)
						if(A.can_hijack == HIJACK_HIJACKER)
							hijacker_present = TRUE
							prevent = FALSE
							break //If we have both prevent and hijacker antags assume we want to hijack.
						else if(A.can_hijack == HIJACK_PREVENT)
							prevent = TRUE
					if(prevent)
						return FALSE

	return has_people && hijacker_present

/obj/docking_port/mobile/emergency/proc/vampire_werewolf()
	var/list/vampires = list()
	var/list/werewolves = list()
	for(var/mob/living/player in GLOB.player_list)
		if(player.mind)
			if(player.stat != DEAD)
				if(isbrain(player)) //also technically dead
					continue
				if(shuttle_areas[get_area(player)])
					if(player.mind.has_antag_datum(/datum/antagonist/werewolf))
						werewolves += player
						continue
					if(player.mind.has_antag_datum(/datum/antagonist/vampire))
						vampires += player
						continue
	if(vampires.len)
		if(!werewolves.len)
			return "vampire"
	if(werewolves.len)
		if(!vampires.len)
			return "werewolf"


/obj/docking_port/mobile/emergency/proc/ShuttleDBStuff()
	set waitfor = FALSE
	if(!SSdbcore.Connect())
		return
	var/datum/DBQuery/query_round_shuttle_name = SSdbcore.NewQuery({"
		UPDATE [format_table_name("round")] SET shuttle_name = :name WHERE id = :round_id
	"}, list("name" = name, "round_id" = GLOB.round_id))
	query_round_shuttle_name.Execute()
	qdel(query_round_shuttle_name)

/obj/docking_port/mobile/emergency/check()
	if(!timer)
		return
	var/time_left = timeLeft(1)

	// The emergency shuttle doesn't work like others so this
	// ripple check is slightly different
	if(!ripples.len && (time_left <= SHUTTLE_RIPPLE_TIME) && ((mode == SHUTTLE_CALL) || (mode == SHUTTLE_ESCAPE)))
		var/destination
		if(mode == SHUTTLE_CALL)
			destination = SSshuttle.getDock("emergency_home")
		else if(mode == SHUTTLE_ESCAPE)
			destination = SSshuttle.getDock("emergency_away")
		create_ripples(destination)

	switch(mode)
		if(SHUTTLE_RECALL)
			if(time_left <= 0)
				mode = SHUTTLE_IDLE
				timer = 0
		if(SHUTTLE_CALL)
			if(time_left <= 0)
				//move emergency shuttle to station
				if(initiate_docking(SSshuttle.getDock("emergency_home")) != DOCKING_SUCCESS)
					setTimer(20)
					return
				mode = SHUTTLE_DOCKED
//				setTimer(ROUNDTIMERBOAT) //important
//				startTime = world.time //important

//				send2irc("Server", "The Emergency Shuttle has docked with the station.")
//				priority_announce("The Emergency Shuttle has docked with the station. You have [timeLeft(600)] minutes to board the Emergency Shuttle.", null, 'sound/blank.ogg', "Priority")
				ShuttleDBStuff()


		if(SHUTTLE_DOCKED)
			if(time_left <= ENGINES_START_TIME)
				mode = SHUTTLE_IGNITING
				SSshuttle.checkHostileEnvironment()
				if(mode == SHUTTLE_STRANDED)
					return
				for(var/A in SSshuttle.mobile)
					var/obj/docking_port/mobile/M = A
					if(M.launch_status == UNLAUNCHED) //Pods will not launch from the mine/planet, and other ships won't launch unless we tell them to.
						M.check_transit_zone()

		if(SHUTTLE_IGNITING)
			var/success = TRUE
			SSshuttle.checkHostileEnvironment()
			if(mode == SHUTTLE_STRANDED)
				return

			success &= (check_transit_zone() == TRANSIT_READY)
			for(var/A in SSshuttle.mobile)
				var/obj/docking_port/mobile/M = A
				if(M.launch_status == UNLAUNCHED)
					success &= (M.check_transit_zone() == TRANSIT_READY)
			if(!success)
				setTimer(ENGINES_START_TIME)

			if(time_left <= 50 && !sound_played) //4 seconds left:REV UP THOSE ENGINES BOYS. - should sync up with the launch
				sound_played = 1 //Only rev them up once.
				var/list/areas = list()
				for(var/area/shuttle/escape/E in GLOB.sortedAreas)
					areas += E
				hyperspace_sound(HYPERSPACE_WARMUP, areas)

			if(time_left <= 0 && !SSshuttle.emergencyNoEscape)
				//move each escape pod (or applicable spaceship) to its corresponding transit dock
				for(var/A in SSshuttle.mobile)
					var/obj/docking_port/mobile/M = A
					M.on_emergency_launch()

				//now move the actual emergency shuttle to its transit dock
				var/list/areas = list()
				for(var/area/shuttle/escape/E in GLOB.sortedAreas)
					areas += E
				hyperspace_sound(HYPERSPACE_LAUNCH, areas)
				enterTransit()
				mode = SHUTTLE_ESCAPE
				launch_status = ENDGAME_LAUNCHED
				setTimer(SSshuttle.emergencyEscapeTime * engine_coeff)
				priority_announce("The last boat has left. Roguetown is doomed.", null, 'sound/misc/boatleave.ogg')

		if(SHUTTLE_STRANDED)
			SSshuttle.checkHostileEnvironment()

		if(SHUTTLE_ESCAPE)
			if(sound_played && time_left <= HYPERSPACE_END_TIME)
				var/list/areas = list()
				for(var/area/shuttle/escape/E in GLOB.sortedAreas)
					areas += E
				hyperspace_sound(HYPERSPACE_END, areas)
			if(time_left <= PARALLAX_LOOP_TIME)
				var/area_parallax = FALSE
				for(var/place in shuttle_areas)
					var/area/shuttle/shuttle_area = place
					if(shuttle_area.parallax_movedir)
						area_parallax = TRUE
						break
				if(area_parallax)
					parallax_slowdown()
					for(var/A in SSshuttle.mobile)
						var/obj/docking_port/mobile/M = A
						if(M.launch_status == ENDGAME_LAUNCHED)
							if(istype(M, /obj/docking_port/mobile/pod))
								M.parallax_slowdown()

			if(time_left <= 0)
				//move each escape pod to its corresponding escape dock
				for(var/A in SSshuttle.mobile)
					var/obj/docking_port/mobile/M = A
					M.on_emergency_dock()

				// now move the actual emergency shuttle to centcom
				// unless the shuttle is "hijacked"
				var/destination_dock = "emergency_away"
				if(is_hijacked())
					destination_dock = "emergency_syndicate"
					minor_announce("Corruption detected in \
						shuttle navigation protocols. Please contact your \
						supervisor.", "SYSTEM ERROR:", alert=TRUE)

				dock_id(destination_dock)
				mode = SHUTTLE_ENDGAME
				timer = 0

/obj/docking_port/mobile/emergency/transit_failure()
	..()
	message_admins("Moving emergency shuttle directly to centcom dock to prevent deadlock.")

	mode = SHUTTLE_ESCAPE
	launch_status = ENDGAME_LAUNCHED
	setTimer(SSshuttle.emergencyEscapeTime)
	priority_announce("The Emergency Shuttle preparing for direct jump. Estimate [timeLeft(600)] minutes until the shuttle docks at Central Command.", null, null, "Priority")


/obj/docking_port/mobile/pod
	name = "escape pod"
	id = "pod"
	dwidth = 1
	width = 3
	height = 4
	launch_status = UNLAUNCHED

/obj/docking_port/mobile/pod/request(obj/docking_port/stationary/S)
	var/obj/machinery/computer/shuttle/C = getControlConsole()
	if(!istype(C, /obj/machinery/computer/shuttle/pod))
		return ..()
	to_chat(usr, "<span class='warning'>Escape pods will only launch during \"Code Red\" security alert.</span>")
	return TRUE

/obj/docking_port/mobile/pod/cancel()
	return

/obj/machinery/computer/shuttle/pod
	name = "pod control computer"
	admin_controlled = 1
	possible_destinations = "pod_asteroid"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "dorm_available"
	light_color = LIGHT_COLOR_BLUE
	density = FALSE

/obj/machinery/computer/shuttle/pod/update_icon()
	return

/obj/machinery/computer/shuttle/pod/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	ENABLE_BITFIELD(obj_flags, EMAGGED)
	to_chat(user, "<span class='warning'>I fry the pod's alert level checking system.</span>")

/obj/machinery/computer/shuttle/pod/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	. = ..()
	if(possible_destinations == initial(possible_destinations) || override)
		possible_destinations = "pod_lavaland[idnum]"

/obj/docking_port/stationary/random
	name = "escape pod"
	id = "pod"
	dwidth = 1
	width = 3
	height = 4
	var/target_area = /area/lavaland/surface/outdoors
	var/edge_distance = 16
	// Minimal distance from the map edge, setting this too low can result in shuttle landing on the edge and getting "sliced"

/obj/docking_port/stationary/random/Initialize(mapload)
	. = ..()
	if(!mapload)
		return

	var/list/turfs = get_area_turfs(target_area)
	var/original_len = turfs.len
	while(turfs.len)
		var/turf/T = pick(turfs)
		if(T.x<edge_distance || T.y<edge_distance || (world.maxx+1-T.x)<edge_distance || (world.maxy+1-T.y)<edge_distance)
			turfs -= T
		else
			forceMove(T)
			return

	// Fallback: couldn't find anything
	WARNING("docking port '[id]' could not be randomly placed in [target_area]: of [original_len] turfs, none were suitable")
	return INITIALIZE_HINT_QDEL

//Pod suits/pickaxes


/obj/item/clothing/head/helmet/space/orange
	name = "emergency space helmet"
	icon_state = "syndicate-helm-orange"
	item_state = "syndicate-helm-orange"

/obj/item/clothing/suit/space/orange
	name = "emergency space suit"
	icon_state = "syndicate-orange"
	item_state = "syndicate-orange"
	slowdown = 3

/obj/item/pickaxe/emergency
	name = "emergency disembarkation tool"
	desc = ""

/obj/item/storage/pod
	name = "emergency space suits"
	desc = ""
	anchored = TRUE
	density = FALSE
	icon = 'icons/obj/storage.dmi'
	icon_state = "safe"
	var/unlocked = FALSE

/obj/item/storage/pod/PopulateContents()
	new /obj/item/clothing/head/helmet/space/orange(src)
	new /obj/item/clothing/head/helmet/space/orange(src)
	new /obj/item/clothing/suit/space/orange(src)
	new /obj/item/clothing/suit/space/orange(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/tank/internals/oxygen/red(src)
	new /obj/item/tank/internals/oxygen/red(src)
	new /obj/item/pickaxe/emergency(src)
	new /obj/item/pickaxe/emergency(src)
	new /obj/item/storage/toolbox/emergency(src)

/obj/item/storage/pod/attackby(obj/item/W, mob/user, params)
	if (can_interact(user))
		return ..()

/obj/item/storage/pod/attack_hand(mob/user)
	if (can_interact(user))
		SEND_SIGNAL(src, COMSIG_TRY_STORAGE_SHOW, user)
	return TRUE

/obj/item/storage/pod/MouseDrop(over_object, src_location, over_location)
	if(can_interact(usr))
		return ..()

/obj/item/storage/pod/AltClick(mob/user)
	if(!can_interact(user))
		return
	..()

/obj/item/storage/pod/can_interact(mob/user)
	if(!..())
		return FALSE
	to_chat(user, "The storage unit will only unlock during a Red or Delta security alert.")

/obj/docking_port/mobile/emergency/backup
	name = "backup shuttle"
	id = "backup"
	dwidth = 2
	width = 8
	height = 8
	dir = EAST

/obj/docking_port/mobile/emergency/backup/Initialize()
	// We want to be a valid emergency shuttle
	// but not be the main one, keep whatever's set
	// valid.
	// backup shuttle ignores `timid` because THERE SHOULD BE NO TOUCHING IT
	var/current_emergency = SSshuttle.emergency
	. = ..()
	SSshuttle.emergency = current_emergency
	SSshuttle.backup_shuttle = src

/obj/docking_port/mobile/emergency/shuttle_build/register()
	. = ..()
	initiate_docking(SSshuttle.getDock("emergency_home"))

#undef TIME_LEFT
#undef ENGINES_START_TIME
#undef ENGINES_STARTED
#undef IS_DOCKED
