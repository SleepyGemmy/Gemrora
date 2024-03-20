/obj/machinery/shower
	name = "shower"
	desc = "The HS-451. Installed in the 2450s by the Hygiene Division."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "shower"
	density = 0
	anchored = 1
	use_power = POWER_USE_OFF
	var/spray_amount = 20
	var/on = 0
	var/obj/effect/mist/mymist = null
	var/ismist = 0				//needs a var so we can make it linger~
	var/watertemp = "normal"	//freezing, normal, or boiling
	var/mobpresent = 0		//true if there is a mob on the shower's loc, this is to ease process()
	var/is_washing = 0
	var/list/temperature_settings = list("normal" = 310, "boiling" = T0C+100, "freezing" = T0C)
	var/datum/looping_sound/showering/soundloop

/obj/machinery/shower/Initialize()
	. = ..()
	create_reagents(2)
	soundloop = new(list(src), FALSE)

/obj/machinery/shower/Destroy()
	QDEL_NULL(soundloop)
	return ..()

//add heat controls? when emagged, you can freeze to death in it?

/obj/effect/mist
	name = "mist"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mist"
	layer = MOB_LAYER + 1
	anchored = 1
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/machinery/shower/attack_hand(mob/M as mob)
	on = !on
	update_icon()
	if(on)
		if (M.loc == loc)
			wash(M)
			process_heat(M)
		for (var/atom/movable/G in src.loc)
			G.clean_blood()

/obj/machinery/shower/attackby(obj/item/attacking_item, mob/user)
	if(attacking_item.type == /obj/item/device/analyzer)
		to_chat(user, SPAN_NOTICE("The water temperature seems to be [watertemp]."))
	if(attacking_item.iswrench())
		var/newtemp = input(user, "What setting would you like to set the temperature valve to?", "Water Temperature Valve") in temperature_settings
		to_chat(user, SPAN_NOTICE("You begin to adjust the temperature valve with \the [attacking_item]."))
		if(attacking_item.use_tool(src, user, 50, volume = 50))
			watertemp = newtemp
			user.visible_message(SPAN_NOTICE("[user] adjusts the shower with \the [attacking_item]."), SPAN_NOTICE("You adjust the shower with \the [attacking_item]."))
			add_fingerprint(user)

/obj/machinery/shower/update_icon()	//this is terribly unreadable, but basically it makes the shower mist up
	cut_overlays()					//once it's been on for a while, in addition to handling the water overlay.
	if(mymist)
		qdel(mymist)

	if(on)
		soundloop.start(src)
		add_overlay(image('icons/obj/watercloset.dmi', src, "water", MOB_LAYER + 1, dir))
		if(temperature_settings[watertemp] < T20C)
			return //no mist for cold water
		if(!ismist)
			spawn(50)
				if(src && on)
					ismist = 1
					mymist = new /obj/effect/mist(loc)
		else //??? what the fuck is this
			ismist = 1
			mymist = new /obj/effect/mist(loc)
	else
		soundloop.stop(src)
		if(ismist)
			ismist = 1
			mymist = new /obj/effect/mist(loc)
			addtimer(CALLBACK(src, PROC_REF(clear_mist)), 250, TIMER_OVERRIDE|TIMER_UNIQUE)

/obj/machinery/shower/proc/clear_mist()
	if (!on)
		QDEL_NULL(mymist)
		ismist = FALSE

/obj/machinery/shower/Crossed(atom/movable/O)
	..()
	wash(O)
	if(ismob(O))
		mobpresent += 1
		process_heat(O)

/obj/machinery/shower/Uncrossed(atom/movable/O)
	if(ismob(O))
		mobpresent -= 1
	..()

//Yes, showers are super powerful as far as washing goes.
/obj/machinery/shower/proc/wash(atom/movable/O)
	if(!on)
		return

	var/obj/effect/effect/water/W = new(O)
	W.create_reagents(spray_amount)
	W.reagents.add_reagent(/singleton/reagent/water, spray_amount)
	W.set_up(O, spray_amount)

	if(ishuman(O))
		var/mob/living/carbon/human/H = O
		H.wash()

	if(isobj(O))
		var/obj/object = O
		object.clean()

	if(isturf(loc))
		var/turf/tile = loc
		tile.clean_blood()
		tile.remove_cleanables()

/obj/machinery/shower/process()
	if(!on)
		return
	wash_floor()
	if(!mobpresent)
		return
	for(var/mob/living/L in loc)
		wash(L) // Why was it not here before?
		process_heat(L)

/obj/machinery/shower/proc/wash_floor()
	if(!ismist && is_washing)
		return
	is_washing = 1
	var/turf/T = get_turf(src)
	reagents.add_reagent(/singleton/reagent/water, 2)
	T.clean(src)
	spawn(100)
		is_washing = 0

/obj/machinery/shower/proc/process_heat(mob/living/M)
	if(!on || !istype(M))
		return

	var/temperature = temperature_settings[watertemp]
	var/temp_adj = between(BODYTEMP_COOLING_MAX, temperature - M.bodytemperature, BODYTEMP_HEATING_MAX)
	M.bodytemperature += temp_adj

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(temperature >= H.species.heat_level_1)
			to_chat(H, SPAN_DANGER("The water is searing hot!"))
		else if(temperature <= H.species.cold_level_1)
			to_chat(H, SPAN_WARNING("The water is freezing cold!"))
