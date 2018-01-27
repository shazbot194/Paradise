/obj/item/projectile/bullet/reusable
	name = "reusable bullet"
	desc = "How do you even reuse a bullet?"
	var/ammo_type = /obj/item/ammo_casing/caseless/
	var/dropped = 0

/obj/item/projectile/bullet/reusable/on_hit(atom/target, blocked = 0)
	. = ..()
	handle_drop()

/obj/item/projectile/bullet/reusable/on_range()
	handle_drop()
	..()

/obj/item/projectile/bullet/reusable/proc/handle_drop()
	if(!dropped)
		new ammo_type(loc)
		dropped = 1

/obj/item/projectile/bullet/reusable/magspear
	name = "magnetic spear"
	desc = "WHITE WHALE, HOLY GRAIL"
	damage = 30 //takes 3 spears to kill a mega carp, one to kill a normal carp
	icon_state = "magspear"
	ammo_type = /obj/item/ammo_casing/caseless/magspear

/obj/item/projectile/bullet/reusable/foam_dart
	name = "foam dart"
	desc = "I hope you're wearing eye protection."
	damage = 0 // It's a damn toy.
	damage_type = OXY
	nodamage = 1
	icon = 'icons/obj/guns/toy.dmi'
	icon_state = "foamdart"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart
	range = 10
	var/obj/item/weapon/pen/pen = null
	log_override = TRUE//it won't log even when there's a pen inside, but since the damage will be so low, I don't think there's any point in making it any more complex

/obj/item/projectile/bullet/reusable/foam_dart/handle_drop()
	if(dropped)
		return
	dropped = 1
	var/obj/item/ammo_casing/caseless/foam_dart/newdart = new ammo_type(loc)
	var/obj/item/ammo_casing/caseless/foam_dart/old_dart = ammo_casing
	newdart.modified = old_dart.modified
	if(pen)
		var/obj/item/projectile/bullet/reusable/foam_dart/newdart_FD = newdart.BB
		newdart_FD.pen = pen
		pen.loc = newdart_FD
		pen = null
	newdart.BB.damage = damage
	newdart.BB.nodamage = nodamage
	newdart.BB.damage_type = damage_type
	newdart.update_icon()

/obj/item/projectile/bullet/reusable/foam_dart/Destroy()
	QDEL_NULL(pen)
	return ..()

/obj/item/projectile/bullet/reusable/foam_dart/riot
	name = "riot foam dart"
	icon_state = "foamdart_riot"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot
	stamina = 25
	log_override = FALSE

//Flare's aren't really reusable, but the code works almost too well to not use it here

/obj/item/projectile/bullet/reusable/flare
	name = "flare"
	desc = "Hot stuff."
	damage = 10					//It's a low velocity flare, its mostly going to thud and burn you some
	damage_type = BURN
	icon_state = "flare"
	ammo_type = /obj/item/device/flashlight/flare/shot
	range = 10


/obj/item/projectile/bullet/reusable/flare/Move()
	..()
	light_color = "#ff0000"
	set_light(7)

/obj/item/device/flashlight/flare/shot	//The drop for the flare shot above
	name = "flare"
	desc = "A red flare."
	w_class = 2
	icon_state = "flareshot"

/obj/item/device/flashlight/flare/shot/New()
	fuel = rand(200, 500)
	on = TRUE
	src.force = on_damage
	src.damtype = "fire"
	processing_objects += src
	..()

/obj/item/device/flashlight/flare/shot/turn_off()
	on = 0
	src.force = initial(src.force)
	src.damtype = initial(src.damtype)
	if(ismob(loc))
		var/mob/U = loc
		update_brightness(U)
	else
		update_brightness(null)

/obj/item/device/flashlight/flare/shot/update_brightness(var/mob/user = null)
	..()
	if(on)
		item_state = "[initial(item_state)]-on"
	else
		item_state = "[initial(item_state)]-emptie"