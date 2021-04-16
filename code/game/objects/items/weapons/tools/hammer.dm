/obj/item/weapon/tool/hammer
	name = "hammer"
	desc = "Used for applying blunt force to a surface."
	icon_state = "hammer"
	item_state = "hammer"
	flags = CONDUCT
	force = WEAPON_FORCE_PAINFUL
	worksound = WORKSOUND_HAMMER
	w_class = ITEM_SIZE_SMALL
	origin_tech = list(TECH_ENGINEERING = 1)
	matter = list(MATERIAL_STEEL = 4, MATERIAL_WOOD = 2)
	attack_verb = list("attacked", "bashed", "battered", "bludgeoned", "whacked","flattened","pulped")
	tool_qualities = list(QUALITY_HAMMERING = 30)

/obj/item/weapon/tool/hammer/powered_hammer
	name = "powered sledgehammer"
	desc = "Used for applying excessive blunt force to a surface."
	icon_state = "powered_hammer"
	item_state = "powered_hammer"
	wielded_icon = "powered_hammer_on"
	switched_on_force = WEAPON_FORCE_BRUTAL
	structure_damage_factor = STRUCTURE_DAMAGE_BREACHING
	w_class = ITEM_SIZE_BULKY
	slot_flags = SLOT_BELT | SLOT_BACK
	matter = list(MATERIAL_STEEL = 4, MATERIAL_PLASTEEL = 6, MATERIAL_PLASTIC = 1)
	switched_on_qualities = list(QUALITY_HAMMERING = 45)
	switched_off_qualities = list(QUALITY_HAMMERING = 30)
	toggleable = TRUE
	armor_penetration = ARMOR_PEN_EXTREME
	degradation = 0.7
	use_power_cost = 2
	suitable_cell = /obj/item/weapon/cell/medium
	max_upgrades = 3

/obj/item/weapon/tool/hammer/powered_hammer/turn_on(mob/user)

	if (cell && cell.charge > 0)
		item_state = "[initial(item_state)]_on"
		to_chat(user, SPAN_NOTICE("You switch [src] on."))
		playsound(loc, 'sound/effects/sparks4.ogg', 50, 1)
		..()
	else
		item_state = initial(item_state)
		to_chat(user, SPAN_WARNING("[src] has no power!"))

/obj/item/weapon/tool/hammer/powered_hammer/turn_off(mob/user)
	item_state = initial(item_state)
	playsound(loc, 'sound/effects/sparks4.ogg', 50, 1)
	to_chat(user, SPAN_NOTICE("You switch [src] off."))
	..()

/obj/item/weapon/tool/hammer/powered_hammer/onestar_hammer
	name = "greyson sledgehammer"
	desc = "Used for applying immeasurable blunt force to anything in your way."
	icon_state = "onehammer"
	item_state = "onehammer"
	wielded_icon = "onehammer_on"
	switched_on_force = WEAPON_FORCE_LETHAL
	structure_damage_factor = STRUCTURE_DAMAGE_DESTRUCTIVE
	matter = list(MATERIAL_STEEL = 4, MATERIAL_PLATINUM = 3, MATERIAL_DIAMOND = 3)
	switched_on_qualities = list(QUALITY_HAMMERING = 60)
	switched_off_qualities = list(QUALITY_HAMMERING = 35)
	toggleable = TRUE
	degradation = 0.6
	use_power_cost = 1.5
	workspeed = 1.5
	max_upgrades = 2
