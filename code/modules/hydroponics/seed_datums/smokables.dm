///////////////
//  Tobacco  //
///////////////
/datum/seed/tobacco
	name = "tobacco"
	seed_name = "tobacco"
	display_name = "tobacco leaves"
	mutants = list("finetobacco", "puretobacco", "badtobacco")
	chems = list(/singleton/reagent/toxin/tobacco = list(1,10))

/datum/seed/tobacco/setup_traits()
	..()
	set_trait(TRAIT_MATURATION,6)
	set_trait(TRAIT_PRODUCTION,6)
	set_trait(TRAIT_YIELD,5)
	set_trait(TRAIT_PRODUCT_ICON,"tobacco")
	set_trait(TRAIT_PRODUCT_COLOUR,"#749733")
	set_trait(TRAIT_PLANT_COLOUR,"#749733")
	set_trait(TRAIT_PLANT_ICON,"vine2")
	set_trait(TRAIT_IDEAL_HEAT, 304)
	set_trait(TRAIT_IDEAL_LIGHT, 7)
	set_trait(TRAIT_WATER_CONSUMPTION, 6)
	set_trait(TRAIT_NUTRIENT_CONSUMPTION, 0.15)

/obj/item/seeds/tobaccoseed
	seed_type = "tobacco"

/datum/seed/tobacco/finetobacco
	name = "finetobacco"
	seed_name = "fine tobacco"
	display_name = "fine tobacco leaves"
	chems = list(/singleton/reagent/toxin/tobacco/rich = list(1,10))

/datum/seed/tobacco/finetobacco/setup_traits()
	..()
	set_trait(TRAIT_YIELD,4)
	set_trait(TRAIT_PRODUCT_COLOUR,"#33571b")
	set_trait(TRAIT_PLANT_COLOUR,"#33571b")
	set_trait(TRAIT_NUTRIENT_CONSUMPTION, 0.20)

/obj/item/seeds/finetobacco
	seed_type = "finetobacco"

/datum/seed/tobacco/puretobacco //provides the pure nicotine reagent
	name = "puretobacco"
	seed_name = "succulent tobacco"
	display_name = "succulent tobacco leaves"
	chems = list(/singleton/reagent/mental/nicotine = list(1,10))

/datum/seed/tobacco/puretobacco/setup_traits()
	..()
	set_trait(TRAIT_YIELD,3)
	set_trait(TRAIT_JUICY,1)
	set_trait(TRAIT_PRODUCT_COLOUR,"#b7c61a")
	set_trait(TRAIT_PLANT_COLOUR,"#b7c61a")
	set_trait(TRAIT_NUTRIENT_CONSUMPTION, 0.30)

/datum/seed/tobacco/bad
	name = "badtobacco"
	seed_name = "low-grade tobacco"
	display_name = "low-grade tobacco leaves"
	mutants = list("tobacco")
	chems = list(/singleton/reagent/toxin/tobacco/fake = list(1,10))

////////////////
//  Ambrosia  //
////////////////
/datum/seed/ambrosia
	name = "ambrosia"
	seed_name = "ambrosia vulgaris"
	display_name = "ambrosia vulgaris"
	mutants = list("ambrosiadeus")
	chems = list(/singleton/reagent/nutriment = list(1), /singleton/reagent/drugs/ambrosia_extract = list(4,8), /singleton/reagent/kelotane = list(1,8,1), /singleton/reagent/bicaridine = list(1,10,1), /singleton/reagent/toxin = list(1,10))
	kitchen_tag = "ambrosia"

/datum/seed/ambrosia/setup_traits()
	..()
	set_trait(TRAIT_HARVEST_REPEAT,1)
	set_trait(TRAIT_MATURATION,6)
	set_trait(TRAIT_PRODUCTION,6)
	set_trait(TRAIT_YIELD,6)
	set_trait(TRAIT_POTENCY,5)
	set_trait(TRAIT_PRODUCT_ICON,"ambrosia")
	set_trait(TRAIT_PRODUCT_COLOUR,"#9FAD55")
	set_trait(TRAIT_PLANT_ICON,"ambrosia")
	set_trait(TRAIT_IDEAL_LIGHT, 6)

/obj/item/seeds/ambrosiavulgarisseed
	seed_type = "ambrosia"

/datum/seed/ambrosia/deus
	name = "ambrosiadeus"
	seed_name = "ambrosia deus"
	display_name = "ambrosia deus"
	mutants = null
	chems = list(/singleton/reagent/nutriment = list(1), /singleton/reagent/bicaridine = list(1,8), /singleton/reagent/synaptizine = list(1,8,1), /singleton/reagent/drugs/ambrosia_extract = list(4,10))
	kitchen_tag = "ambrosiadeus"

/datum/seed/ambrosia/deus/setup_traits()
	..()
	set_trait(TRAIT_PRODUCT_COLOUR,"#A3F0AD")
	set_trait(TRAIT_PLANT_COLOUR,"#2A9C61")

/obj/item/seeds/ambrosiadeusseed
	seed_type = "ambrosiadeus"

////////////////
//   Oracle   //
////////////////
/datum/seed/oracle
	name = "oracle"
	seed_name = "oracle"
	display_name = "oracle"
	mutants = list("vedamororacle")
	chems = list(/singleton/reagent/nutriment = list(1,5), /singleton/reagent/toxin/oracle = list(4,8))

/datum/seed/oracle/setup_traits()
	..()
	set_trait(TRAIT_HARVEST_REPEAT, 1)
	set_trait(TRAIT_MATURATION, 6)
	set_trait(TRAIT_PRODUCTION, 6)
	set_trait(TRAIT_YIELD, 6)
	set_trait(TRAIT_POTENCY, 5)
	set_trait(TRAIT_PRODUCT_ICON, "tobacco")
	set_trait(TRAIT_PRODUCT_COLOUR, "#ad5555")
	set_trait(TRAIT_PLANT_COLOUR, "#ffa2a2")
	set_trait(TRAIT_PLANT_ICON, "flower")
	set_trait(TRAIT_IDEAL_LIGHT, 6)

/obj/item/seeds/oracleseed
	seed_type = "oracle"

/datum/seed/oracle/vedamor
	name = "vedamororacle"
	seed_name = "vedamor oracle"
	display_name = "vedamor oracle"
	mutants = null
	chems = list(/singleton/reagent/nutriment = list(1,5), /singleton/reagent/toxin/oracle/rich = list(4,8))

/datum/seed/oracle/vedamor/setup_traits()
	..()
	set_trait(TRAIT_PRODUCT_COLOUR,"#ed1c1c")
	set_trait(TRAIT_PLANT_COLOUR,"#ad5555")

/obj/item/seeds/vedamororacleseed
	seed_type = "vedamororacle"
