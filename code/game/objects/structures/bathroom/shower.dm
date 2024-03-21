/obj/machinery/shower
	name = "shower"
	desc = "A stainless steel shower. The shower's temperature is set to [water_temperature]."
	icon = 'icons/obj/bathroom.dmi'
	icon_state = "shower"
	density = FALSE
	anchored = TRUE
	use_power = POWER_USE_OFF
	var/is_on = FALSE
    var/is_washing = FALSE // If the shower is washing a mob.
	var/mob_present = FALSE // `TRUE` if there is a mob on the shower's turf, this is to ease process().
    var/has_mist = FALSE
    var/spray_amount = 20
    var/water_temperature = "lukewarm" // Scalding, warm, lukewarm, cold, or freezing.
	var/list/temperature_settings = list("scalding" = T0C + 60, "warm" = T0C + 45, "lukewarm" = T0C + 37, "cold" = T0C + 20, "freezing" = T0C + 10) // 60 celsius, 45 celsius, 37 celsius, 20 celsius, and 10 celsius.
    var/obj/effect/mist/shower_mist = null
	var/datum/looping_sound/showering/soundloop

/obj/machinery/shower/Initialize()
	. = ..()
	create_reagents(2)
	soundloop = new(list(src), FALSE)

/obj/machinery/shower/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/shower/attack_hand(mob/M)
	on = !on
	update_icon()
	if(on)
		if(M.loc == loc)
			wash(M)
			process_heat(M)
		for(var/atom/movable/G in get_turf(src))
			G.clean_blood()

/obj/machinery/shower/attackby(obj/item/attacking_item, mob/user)
	if(attacking_item.type == /obj/item/device/analyzer)
		to_chat(user, SPAN_NOTICE("The shower's temperature is set to [water_temperature]."))
	if(attacking_item.iswrench())
		var/new_temperature = tgui_input_list(user, "What would you like to set the temperature to?", "[src]", temperature_settings)
		if(new_temperature)
			to_chat(user, SPAN_NOTICE("You begin to adjust the shower's temperature with \the [attacking_item]."))
			if(attacking_item.use_tool(src, user, 50, volume = 50))
				water_temperature = new_temperature
				desc = "A stainless steel shower. The shower's temperature is set to [water_temperature]."
				user.visible_message(
            	    SPAN_NOTICE("[user] adjusts the shower's temperature with \the [attacking_item]."),
        			SPAN_NOTICE("You adjust the shower's temperature with \the [attacking_item].")
            	)
				add_fingerprint(user)

/obj/machinery/shower/update_icon()
	cut_overlays()
	if(shower_mist)
		qdel(shower_mist)

	if(on)
		soundloop.start(src)
		add_overlay(image('icons/obj/bathroom.dmi', src, "water", MOB_LAYER + 1, dir))
		if(temperature_settings[water_temperature] < T20C)
			return // No mist for cold water.
		if(!has_mist)
			spawn(50)
				if(src && on)
					has_mist = TRUE
					shower_mist = new /obj/effect/mist(loc)
	else
		soundloop.stop(src)
		if(has_mist)
			has_mist = TRUE
			shower_mist = new /obj/effect/mist(loc)
			addtimer(CALLBACK(src, PROC_REF(clear_mist)), 250, TIMER_OVERRIDE | TIMER_UNIQUE)

/obj/machinery/shower/proc/clear_mist()
	if(!on)
		QDEL_NULL(shower_mist)
		has_mist = FALSE

/obj/machinery/shower/Crossed(atom/movable/O)
	..()
	wash(O)
	if(ismob(O))
		mob_present = TRUE
		process_heat(O)

/obj/machinery/shower/Uncrossed(atom/movable/O)
	if(ismob(O))
		mob_present = FALSE
	..()

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
	if(!mob_present)
		return
	for(var/mob/living/L in loc)
		wash(L)
		process_heat(L)

/obj/machinery/shower/proc/wash_floor()
	if(!has_mist && is_washing)
		return
	is_washing = TRUE
	var/turf/T = get_turf(src)
	reagents.add_reagent(/singleton/reagent/water, 2)
	T.clean(src)
	spawn(100)
		is_washing = FALSE

/obj/machinery/shower/proc/process_heat(mob/living/M)
	if(!on || !istype(M))
		return

	var/temperature = temperature_settings[water_temperature]
	var/temp_adj = between(BODYTEMP_COOLING_MAX, temperature - M.bodytemperature, BODYTEMP_HEATING_MAX)
	M.bodytemperature += temp_adj

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(temperature >= H.species.heat_level_1)
			to_chat(H, SPAN_DANGER("The water is scalding hot!"))
		else if(temperature <= H.species.cold_level_1)
			to_chat(H, SPAN_WARNING("The water is freezing cold!"))

// Water Mist
/obj/effect/mist
	name = "mist"
	icon = 'icons/obj/bathroom.dmi'
	icon_state = "mist"
    anchored = TRUE
	layer = MOB_LAYER + 1
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

// Rubber Duck
/obj/item/bikehorn/rubberducky
	name = "rubber duck"
	desc = "A yellow, rubber duck.
	icon = 'icons/obj/bathroom.dmi'
	icon_state = "rubber_duck"
	item_state = "rubber_duck"
