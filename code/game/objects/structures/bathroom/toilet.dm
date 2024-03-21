//
// Toilets
//

// Toilet
/obj/structure/toilet
	name = "toilet"
	desc = "A white, ceramic toilet."
	icon = 'icons/obj/bathroom.dmi'
	icon_state = "toilet00"
	anchored = TRUE
	density = FALSE
	var/is_lid_open = FALSE // If the lid is up.
	var/is_cistern_open = FALSE // If the cistern bit is open.
	var/w_items = 0 // The combined w_class of all the items in the cistern.
	var/mob/living/swirlied_mob = null	// The mob being given a swirlie, if any.

/obj/structure/toilet/Initialize()
	. = ..()
	is_lid_open = round(rand(FALSE, TRUE))
	update_icon()

/obj/structure/toilet/attack_hand(mob/living/user)
	if(swirlied_mob)
		usr.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		usr.visible_message(
			SPAN_DANGER("[user] slams the toilet seat onto [swirlied_mob.name]'s head!"),
			SPAN_NOTICE("You slam the toilet seat onto [swirlied_mob.name]'s head!"),
			"You hear reverberating porcelain."
		)
		swirlied_mob.apply_damage(5, def_zone = BP_HEAD, used_weapon = "blunt force")
		return

	if(is_cistern_open && !is_lid_open)
		if(!contents.len)
			to_chat(user, SPAN_NOTICE("The cistern is empty."))
			return
		else
			var/obj/item/I = pick(contents)
			if(ishuman(user))
				user.put_in_hands(I)
			else
				I.forceMove(get_turf(src))
			to_chat(user, SPAN_NOTICE("You find \an [I] in the cistern."))
			w_items -= I.w_class
			return

	is_lid_open = !is_lid_open
	update_icon()

/obj/structure/toilet/update_icon()
	icon_state = "toilet[is_lid_open][is_cistern_open]"

/obj/structure/toilet/attackby(obj/item/attacking_item, mob/user)
	if(attacking_item.iscrowbar())
		to_chat(user, SPAN_NOTICE("You start to [is_cistern_open ? "replace the lid on the cistern" : "lift the lid off the cistern"]."))
		playsound(loc, 'sound/effects/stonedoor_is_lid_openclose.ogg', 50, 1)
		if(attacking_item.use_tool(src, user, 30, volume = 0))
			user.visible_message(
				SPAN_NOTICE("[user] [is_cistern_open ? "replaces the lid on the cistern" : "lifts the lid off the cistern"]!"),
				SPAN_NOTICE("You [is_cistern_open ? "replace the lid on the cistern" : "lift the lid off the cistern"]!"),
				"You hear scraping porcelain."
			)
			is_cistern_open = !is_cistern_open
			update_icon()
			return

	if(istype(attacking_item, /obj/item/grab))
		usr.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		var/obj/item/grab/G = attacking_item

		if(isliving(G.affecting))
			var/mob/living/GM = G.affecting

			if(G.state > 1)
				if(!GM.loc == get_turf(src))
					to_chat(user, SPAN_NOTICE("[GM.name] needs to be on \the [src]."))
					return
				if(is_lid_open && !swirlied_mob)
					user.visible_message(
						SPAN_DANGER("[user] starts to give [GM.name] a swirlie!"),
						SPAN_NOTICE("You start to give [GM.name] a swirlie!")
					)
					swirlied_mob = GM
					if(do_after(user, 30, GM, do_flags = DO_UNIQUE))
						user.visible_message(
							SPAN_DANGER("[user] gives [GM.name] a swirlie!"),
							SPAN_NOTICE("You give [GM.name] a swirlie!"),
							"You hear a toilet flushing."
						)
						if(!GM.internal)
							GM.adjustOxyLoss(5)
						SSstatistics.IncrementSimpleStat("swirlies")
					swirlied_mob = null
				else
					user.visible_message(
						SPAN_DANGER("[user] slams [GM.name] into the [src]!"),
						SPAN_NOTICE("You slam [GM.name] into the [src]!")
					)
					GM.apply_damage(5, def_zone = BP_HEAD, used_weapon = "blunt force")
			else
				to_chat(user, SPAN_NOTICE("You need a tighter grip."))

	if(is_cistern_open && !istype(user, /mob/living/silicon/robot))
		if(attacking_item.w_class > 3)
			to_chat(user, SPAN_NOTICE("\The [attacking_item] does not fit."))
			return
		if(w_items + attacking_item.w_class > 5)
			to_chat(user, SPAN_NOTICE("The cistern is full."))
			return
		user.drop_from_inventory(attacking_item,src)
		w_items += attacking_item.w_class
		usr.visible_message(
			SPAN_DANGER("[user] places \the [attacking_item] into the toilet's cistern."),
			SPAN_NOTICE("You carefully place \the [attacking_item] into the toilet's cistern."),
			"You hear scraping porcelain."
		)
		return

// Noose Toilet
/obj/structure/toilet/noose
	desc = "A white, ceramic toilet. The cistern's lid seems to have been moved and sits slightly ajar."

/obj/structure/toilet/noose/Initialize()
	. = ..()
	new /obj/item/stack/cable_coil(src)

// Urinal
/obj/structure/urinal
	name = "urinal"
	desc = "A white, ceramic urinal."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "urinal"
	anchored = TRUE
	density = FALSE

/obj/structure/urinal/attackby(obj/item/attacking_item, mob/user)
	if(istype(attacking_item, /obj/item/grab))
		var/obj/item/grab/G = attacking_item
		if(isliving(G.affecting))
			var/mob/living/GM = G.affecting
			if(G.state>1)
				if(!GM.loc == get_turf(src))
					to_chat(user, SPAN_NOTICE("[GM.name] needs to be on the urinal."))
					return
				user.visible_message(
					SPAN_DANGER("[user] slams [GM.name] into \the [src]!"),
					SPAN_NOTICE("You slam [GM.name] into \the [src]!"))
				GM.apply_damage(5, def_zone = BP_HEAD, used_weapon = "blunt force")
				user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN * 1.5)
			else
				to_chat(user, SPAN_NOTICE("You need a tighter grip."))
