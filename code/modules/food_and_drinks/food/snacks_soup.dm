/obj/item/reagent_containers/food/snacks/soup
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'icons/obj/food/soupsalad.dmi'
	trash = /obj/item/reagent_containers/glass/bowl
	bitesize = 5
	volume = 80
	list_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/water = 5, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("tasteless soup" = 1)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/soup/Initialize()
	. = ..()
	eatverb = pick("slurp","sip","inhale","drink")

/obj/item/reagent_containers/food/snacks/soup/wish
	name = "wish soup"
	desc = ""
	icon_state = "wishsoup"
	list_reagents = list(/datum/reagent/water = 10)
	tastes = list("wishes" = 1)

/obj/item/reagent_containers/food/snacks/soup/wish/Initialize()
	. = ..()
	var/wish_true = prob(25)
	if(wish_true)
		desc = ""
		bonus_reagents = list(/datum/reagent/consumable/nutriment = 9, /datum/reagent/consumable/nutriment/vitamin = 1)
	if(wish_true)
		reagents.add_reagent(/datum/reagent/consumable/nutriment, 9)
		reagents.add_reagent(/datum/reagent/consumable/nutriment/vitamin, 1)
		foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/soup/meatball
	name = "meatball soup"
	desc = ""
	icon_state = "meatballsoup"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("meat" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/soup/slime
	name = "slime soup"
	desc = ""
	icon_state = "slimesoup"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/toxin/slimejelly = 5, /datum/reagent/consumable/nutriment/vitamin = 5)
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/toxin/slimejelly = 5, /datum/reagent/water = 5, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("slime" = 1)
	foodtype = TOXIC | SUGAR

/obj/item/reagent_containers/food/snacks/soup/blood
	name = "tomato soup"
	desc = ""
	icon_state = "tomatosoup"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 6)
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/blood = 10, /datum/reagent/water = 5, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("iron" = 1)
	foodtype = GROSS


/obj/item/reagent_containers/food/snacks/soup/clownstears
	name = "clown's tears"
	desc = ""
	icon_state = "clownstears"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/banana = 5, /datum/reagent/consumable/nutriment/vitamin = 8, /datum/reagent/consumable/clownstears = 10)
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/banana = 5, /datum/reagent/water = 5, /datum/reagent/consumable/nutriment/vitamin = 8, /datum/reagent/consumable/clownstears = 10)
	tastes = list("a bad joke" = 1)
	foodtype = FRUIT | SUGAR

/obj/item/reagent_containers/food/snacks/soup/nettle
	name = "nettle soup"
	desc = ""
	icon_state = "nettlesoup"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/medicine/omnizine = 5, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("nettles" = 1)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/soup/mystery
	name = "mystery soup"
	desc = ""
	icon_state = "mysterysoup"
	var/extra_reagent = null
	list_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("chaos" = 1)

/obj/item/reagent_containers/food/snacks/soup/mystery/Initialize()
	. = ..()
	extra_reagent = pick(/datum/reagent/consumable/capsaicin, /datum/reagent/consumable/frostoil, /datum/reagent/medicine/omnizine, /datum/reagent/consumable/banana, /datum/reagent/blood, /datum/reagent/toxin/slimejelly, /datum/reagent/toxin, /datum/reagent/consumable/banana, /datum/reagent/carbon, /datum/reagent/medicine/oculine)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents[extra_reagent] = 5
	reagents.add_reagent(extra_reagent, 5)

/obj/item/reagent_containers/food/snacks/soup/hotchili
	name = "hot chili"
	desc = ""
	icon_state = "hotchili"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/tomatojuice = 2, /datum/reagent/consumable/nutriment/vitamin = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/capsaicin = 1, /datum/reagent/consumable/tomatojuice = 2, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("hot peppers" = 1)
	foodtype = VEGETABLES | MEAT

/obj/item/reagent_containers/food/snacks/soup/monkeysdelight
	name = "monkey's delight"
	desc = ""
	icon_state = "monkeysdelight"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 5)
	list_reagents = list(/datum/reagent/consumable/nutriment = 10, /datum/reagent/consumable/banana = 5, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("the jungle" = 1, "banana" = 1)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/soup/tomato
	name = "tomato soup"
	desc = ""
	icon_state = "tomatosoup"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/tomatojuice = 10, /datum/reagent/consumable/nutriment/vitamin = 3)
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/tomatojuice = 10, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("tomato" = 1)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/soup/tomato/eyeball
	name = "eyeball soup"
	desc = ""
	icon_state = "eyeballsoup"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/liquidgibs = 3)
	tastes = list("tomato" = 1, "squirming" = 1)
	foodtype = MEAT | GROSS

/obj/item/reagent_containers/food/snacks/soup/beet
	name = "beet soup"
	desc = ""
	icon_state = "beetsoup"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 5)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/soup/beet/Initialize()
	. = ..()
	name = pick("borsch","bortsch","borstch","borsh","borshch","borscht")
	tastes = list(name = 1)


/obj/item/reagent_containers/food/snacks/soup/spacylibertyduff
	name = "spacy liberty duff"
	desc = ""
	icon_state = "spacylibertyduff"
	bitesize = 3
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 5)
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/drug/mushroomhallucinogen = 6)
	tastes = list("jelly" = 1, "mushroom" = 1)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/soup/amanitajelly
	name = "amanita jelly"
	desc = ""
	icon_state = "amanitajelly"
	bitesize = 3
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 5)
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/drug/mushroomhallucinogen = 3, /datum/reagent/toxin/amatoxin = 6)
	tastes = list("jelly" = 1, "mushroom" = 1)
	foodtype = VEGETABLES | TOXIC

/obj/item/reagent_containers/food/snacks/soup/stew
	name = "stew"
	desc = ""
	icon_state = "stew"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/tomatojuice = 5, /datum/reagent/consumable/nutriment/vitamin = 5)
	list_reagents = list(/datum/reagent/consumable/nutriment = 10, /datum/reagent/medicine/oculine = 5, /datum/reagent/consumable/tomatojuice = 5, /datum/reagent/consumable/nutriment/vitamin = 5)
	bitesize = 7
	volume = 100
	tastes = list("tomato" = 1, "carrot" = 1)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/soup/sweetpotato
	name = "sweet potato soup"
	desc = ""
	icon_state = "sweetpotatosoup"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("sweet potato" = 1)
	foodtype = VEGETABLES | SUGAR

/obj/item/reagent_containers/food/snacks/soup/bungocurry
	name = "bungo curry"
	desc = ""
	icon_state = "bungocurry"
	bonus_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 5, /datum/reagent/consumable/bungojuice = 6)
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/capsaicin = 5)
	tastes = list("bungo" = 2, "hot curry" = 4, "tropical sweetness" = 1)
	filling_color = "#E6A625"
	foodtype = VEGETABLES | FRUIT | DAIRY
