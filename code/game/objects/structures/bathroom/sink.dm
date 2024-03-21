/obj/structure/sink
	name = "sink"
	desc = "A white, ceramic sink."
	desc_info = "You can right click this and change the amount transferred per use."
	icon = 'icons/obj/bathroom.dmi'
	icon_state = "sink"
	anchored = TRUE
	var/is_washing = FALSE // If the sink is washing something.
	var/amount_per_transfer_from_this = 300
	var/possible_transfer_amounts = list(5, 10, 15, 25, 30, 50, 60, 100, 120, 250, 300)

/obj/structure/sink/attack_hand(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/temp = H.organs_by_name[BP_R_HAND]
		if(user.hand)
			temp = H.organs_by_name[BP_L_HAND]
		if(temp && !temp.is_usable())
			to_chat(user, SPAN_NOTICE("You try to move your [temp.name], but cannot!"))
			return

	if(isrobot(user) || isAI(user))
		return

	if(!Adjacent(user))
		return

	if(is_washing)
		to_chat(user, SPAN_WARNING("Someone's already washing here."))
		return

	to_chat(usr, SPAN_NOTICE("You start washing your hands."))
	playsound(get_turf(src), 'sound/effects/sink_long.ogg', 75, 1)

	is_washing = TRUE
	if(!do_after(user, 40, src))
		is_washing = FALSE
		return TRUE
	is_washing = FALSE

	if(!Adjacent(user))
		return // Mob has moved away from the sink.

	user.clean_blood()
	user.visible_message(
		SPAN_NOTICE("[user] washes their hands using \the [src]."),
		SPAN_NOTICE("You wash your hands using \the [src].")
    )

/obj/structure/sink/attackby(obj/item/attacking_item, mob/user)
	if(is_washing)
		to_chat(user, SPAN_WARNING("Someone's already washing here."))
		return

	// Filling/emptying open reagent containers
	var/obj/item/reagent_containers/RG = attacking_item

	if (istype(RG) && RG.is_open_container())
		var/atype = alert(usr, "Do you want to fill or empty \the [RG] at \the [src]?", "Fill or Empty", "Fill", "Empty", "Cancel")

		if(!usr.Adjacent(src)) return
		if(RG.loc != usr && !isrobot(user)) return
		if(is_washing)
			to_chat(usr, SPAN_WARNING("Someone's already using \the [src]."))
			return

		switch(atype)
			if ("Fill")
				if(RG.reagents.total_volume >= RG.volume)
					to_chat(usr, SPAN_WARNING("\The [RG] is already full."))
					return

				RG.reagents.add_reagent(/singleton/reagent/water, min(RG.volume - RG.reagents.total_volume, amount_per_transfer_from_this))
				user.visible_message(
                    "<b>[user]</b> fills \a [RG] using \the [src].",
					SPAN_NOTICE("You fill \a [RG] using \the [src].")
                )
				playsound(get_turf(src), 'sound/effects/sink.ogg', 75, 1)
			if ("Empty")
				if(!RG.reagents.total_volume)
					to_chat(usr, SPAN_WARNING("\The [RG] is already empty."))
					return

				var/empty_amount = RG.reagents.trans_to(src, RG.amount_per_transfer_from_this)
				var/max_reagents = RG.reagents.maximum_volume
				user.visible_message("<b>[user]</b> empties [empty_amount == max_reagents ? "all of \the [RG]" : "some of \the [RG]"] into \a [src].")
				playsound(src.loc, /singleton/sound_category/generic_pour_sound, 10, 1)
		return

	else if(istype(attacking_item, /obj/item/reagent_containers/syringe)) // Filling and emptying syringes.
		var/obj/item/reagent_containers/syringe/S = attacking_item
		switch(S.mode)
			if(0) // Draw.
				if(S.reagents.total_volume >= S.volume)
					to_chat(usr, SPAN_WARNING("\The [S] is already full."))
					return

				var/trans = min(S.volume - S.reagents.total_volume, S.amount_per_transfer_from_this)
				S.reagents.add_reagent(/singleton/reagent/water, trans)
				user.visible_message(SPAN_NOTICE("[usr] uses \the [S] to draw water from \the [src]."),
										SPAN_NOTICE("You draw [trans] units of water from \the [src]. \The [S] now contains [S.reagents.total_volume] units."))
			if(1) // Inject.
				if(!S.reagents.total_volume)
					to_chat(usr, SPAN_WARNING("\The [S] is already empty."))
					return

				var/trans = min(S.amount_per_transfer_from_this, S.reagents.total_volume)
				S.reagents.remove_any(trans)
				user.visible_message(
                    SPAN_NOTICE("[usr] empties \the [S] into \the [src]."),
					SPAN_NOTICE("You empty [trans] units of water into \the [src]. \The [S] now contains [S.reagents.total_volume] units.")
                )
		return

	else if(istype(attacking_item, /obj/item/melee/baton))
		var/obj/item/melee/baton/B = attacking_item
		if(B.bcell)
			if(B.bcell.charge > 0 && B.status == 1)
				flick("baton_active", src)
				user.Stun(10)
				user.stuttering = 10
				user.Weaken(10)
				if(isrobot(user))
					var/mob/living/silicon/robot/R = user
					R.cell.charge -= 20
				else
					B.deductcharge(B.hitcost)
				user.visible_message(SPAN_DANGER("[user] was stunned by \the [attacking_item]!"))
				return 1
	else if(istype(attacking_item, /obj/item/reagent_containers/food/snacks/monkeycube)) // This is necessary to stop monkeycubes being washed.
		return
	else if(istype(attacking_item, /obj/item/mop))
		attacking_item.reagents.add_reagent(/singleton/reagent/water, 5)
		to_chat(user, SPAN_NOTICE("You wet \the [attacking_item] in \the [src]."))
		playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
		return

	else if(istype(attacking_item, /obj/item/reagent_containers/bowl))
		var/obj/item/reagent_containers/bowl/B = attacking_item
		if(B.grease)
			B.grease = FALSE
			B.update_icon()

	var/turf/location = user.loc
	if(!isturf(location)) return

	var/obj/item/I = attacking_item
	if(!I || !istype(I,/obj/item)) return

	to_chat(usr, SPAN_NOTICE("You start washing \the [I]."))
	playsound(loc, 'sound/effects/sink_long.ogg', 75, 1)

	is_washing = TRUE
	if(!do_after(user, 40, src))
		is_washing = FALSE
		return TRUE
	is_washing = FALSE

	if(user.loc != location)
		return // User has moved.
	if(!I)
		return // Item's been destroyed while washing.
	if(user.get_active_hand() != I)
		return // Person has switched hands or the item in their hands.

	I.clean_blood()
	user.visible_message( \
		SPAN_NOTICE("[user] washes \a [I] using \the [src]."), \
		SPAN_NOTICE("You wash \a [I] using \the [src].")
    )

/obj/structure/sink/verb/set_APTFT() // Set `amount_per_transfer_from_this`.
	set name = "Set Transfer Amount"
	set category = "Object"
	set src in view(1)
	var/N = tgui_input_list(usr, "Set the amount to transfer from this.", "[src]", possible_transfer_amounts)
	if(N)
		amount_per_transfer_from_this = N

// Kitchen Sink
/obj/structure/sink/kitchen
	name = "kitchen sink"
	icon_state = "sink_alt"
