//todo: toothbrushes, and some sort of "toilet-filthinator" for the hos

/obj/structure/toilet
	name = "toilet"
	desc = "The HT-451, a torque rotation-based, waste disposal unit for small matter. This one seems remarkably clean."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "toilet00"
	density = 0
	anchored = 1
	var/open = 0			//if the lid is up
	var/cistern = 0			//if the cistern bit is open
	var/w_items = 0			//the combined w_class of all the items in the cistern
	var/mob/living/swirlie = null	//the mob being given a swirlie

/obj/structure/toilet/Initialize()
	. = ..()
	open = round(rand(0, 1))
	update_icon()

/obj/structure/toilet/attack_hand(mob/living/user as mob)
	if(swirlie)
		usr.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		usr.visible_message(SPAN_DANGER("[user] slams the toilet seat onto [swirlie.name]'s head!"), SPAN_NOTICE("You slam the toilet seat onto [swirlie.name]'s head!"), "You hear reverberating porcelain.")
		swirlie.adjustBruteLoss(8)
		return

	if(cistern && !open)
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

	open = !open
	update_icon()

/obj/structure/toilet/update_icon()
	icon_state = "toilet[open][cistern]"

/obj/structure/toilet/attackby(obj/item/attacking_item, mob/user)
	if(attacking_item.iscrowbar())
		to_chat(user, SPAN_NOTICE("You start to [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"]."))
		playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 50, 1)
		if(attacking_item.use_tool(src, user, 30, volume = 0))
			user.visible_message(SPAN_NOTICE("[user] [cistern ? "replaces the lid on the cistern" : "lifts the lid off the cistern"]!"), SPAN_NOTICE("You [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"]!"), "You hear grinding porcelain.")
			cistern = !cistern
			update_icon()
			return

	if(istype(attacking_item, /obj/item/grab))
		usr.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		var/obj/item/grab/G = attacking_item

		if(isliving(G.affecting))
			var/mob/living/GM = G.affecting

			if(G.state>1)
				if(!GM.loc == get_turf(src))
					to_chat(user, SPAN_NOTICE("[GM.name] needs to be on the toilet."))
					return
				if(open && !swirlie)
					user.visible_message(SPAN_DANGER("[user] starts to give [GM.name] a swirlie!"), SPAN_NOTICE("You start to give [GM.name] a swirlie!"))
					swirlie = GM
					if(do_after(user, 30, GM, do_flags = DO_UNIQUE))
						user.visible_message(SPAN_DANGER("[user] gives [GM.name] a swirlie!"), SPAN_NOTICE("You give [GM.name] a swirlie!"), "You hear a toilet flushing.")
						if(!GM.internal)
							GM.adjustOxyLoss(5)
						SSstatistics.IncrementSimpleStat("swirlies")
					swirlie = null
				else
					user.visible_message(SPAN_DANGER("[user] slams [GM.name] into the [src]!"), SPAN_NOTICE("You slam [GM.name] into the [src]!"))
					GM.adjustBruteLoss(8)
			else
				to_chat(user, SPAN_NOTICE("You need a tighter grip."))

	if(cistern && !istype(user,/mob/living/silicon/robot)) //STOP PUTTING YOUR MODULES IN THE TOILET.
		if(attacking_item.w_class > 3)
			to_chat(user, SPAN_NOTICE("\The [attacking_item] does not fit."))
			return
		if(w_items + attacking_item.w_class > 5)
			to_chat(user, SPAN_NOTICE("The cistern is full."))
			return
		user.drop_from_inventory(attacking_item,src)
		w_items += attacking_item.w_class
		to_chat(user, "You carefully place \the [attacking_item] into the cistern.")
		return

/obj/structure/toilet/noose
	desc = "The HT-451, a torque rotation-based, waste disposal unit for small matter. This one's cistern seems remarkably scratched."

/obj/structure/toilet/noose/Initialize()
	. = ..()
	new /obj/item/stack/cable_coil(src)
	if(prob(5))
		cistern = 1

/obj/structure/urinal
	name = "urinal"
	desc = "The HU-452, an experimental urinal."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "urinal"
	density = 0
	anchored = 1

/obj/structure/urinal/attackby(obj/item/attacking_item, mob/user)
	if(istype(attacking_item, /obj/item/grab))
		var/obj/item/grab/G = attacking_item
		if(isliving(G.affecting))
			var/mob/living/GM = G.affecting
			if(G.state>1)
				if(!GM.loc == get_turf(src))
					to_chat(user, SPAN_NOTICE("[GM.name] needs to be on the urinal."))
					return
				user.visible_message(SPAN_DANGER("[user] slams [GM.name] into the [src]!"), SPAN_NOTICE("You slam [GM.name] into the [src]!"))
				GM.apply_damage(8, def_zone = BP_HEAD, used_weapon = "blunt force")
				user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN * 1.5)
			else
				to_chat(user, SPAN_NOTICE("You need a tighter grip."))

/obj/item/bikehorn/rubberducky
	name = "rubber ducky"
	desc = "Rubber ducky you're so fine, you make bathtime lots of fuuun. Rubber ducky I'm awfully fooooond of yooooouuuu~"	//thanks doohl
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rubberducky"
	item_state = "rubberducky"
