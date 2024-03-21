// Puddle
/obj/structure/sink/puddle
	name = "puddle"
	icon_state = "puddle"
	desc = "A small pool of some liquid, ostensibly water."

/obj/structure/sink/puddle/attack_hand(mob/M)
	icon_state = "puddle-splash"
	..()
	icon_state = "puddle"

/obj/structure/sink/puddle/attackby(obj/item/attacking_item, mob/user)
	icon_state = "puddle-splash"
	..()
	icon_state = "puddle"
