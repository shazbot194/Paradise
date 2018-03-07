/obj/item/weapon/gun/projectile/automatic/l6_saw
	name = "\improper L6 SAW"
	desc = "A heavily modified .308 Win. light machine gun, designated 'L6 SAW'. Has 'Aussec Armoury - 2531' engraved on the receiver below the designation."
	icon_state = "l6closed100"
	item_state = "l6closedmag"
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = 0
	origin_tech = "combat=6;engineering=3;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/win308
	weapon_weight = WEAPON_MEDIUM
	fire_sound = 'sound/weapons/Gunshot3.ogg'
	var/cover_open = 0
	can_suppress = 0
	burst_size = 3
	fire_delay = 1

/obj/item/weapon/gun/projectile/automatic/l6_saw/attack_self(mob/user)
	cover_open = !cover_open
	to_chat(user, "<span class='notice'>You [cover_open ? "open" : "close"] [src]'s cover.</span>")
	update_icon()

/obj/item/weapon/gun/projectile/automatic/l6_saw/update_icon()
	icon_state = "l6[cover_open ? "open" : "closed"][magazine ? Ceiling(get_ammo(0)/12.5)*25 : "-empty"][suppressed ? "-suppressed" : ""]"
	item_state = "l6[cover_open ? "openmag" : "closedmag"]"

/obj/item/weapon/gun/projectile/automatic/l6_saw/afterattack(atom/target as mob|obj|turf, mob/living/user as mob|obj, flag, params) //what I tried to do here is just add a check to see if the cover is open or not and add an icon_state change because I can't figure out how c-20rs do it with overlays
	if(cover_open)
		to_chat(user, "<span class='notice'>[src]'s cover is open! Close it before firing!</span>")
	else
		..()
		update_icon()

/obj/item/weapon/gun/projectile/automatic/l6_saw/attack_hand(mob/user)
	if(loc != user)
		..()
		return	//let them pick it up
	if(!cover_open || (cover_open && !magazine))
		..()
	else if(cover_open && magazine)
		//drop the mag
		magazine.update_icon()
		magazine.loc = get_turf(loc)
		user.put_in_hands(magazine)
		magazine = null
		update_icon()
		to_chat(user, "<span class='notice'>You remove the magazine from [src].</span>")


/obj/item/weapon/gun/projectile/automatic/l6_saw/attackby(obj/item/A, mob/user, params)
	. = ..()
	if(.)
		return
	if(!cover_open)
		to_chat(user, "<span class='warning'>[src]'s cover is closed! You can't insert a new mag.</span>")
		return
	..()

//ammo//

/obj/item/projectile/bullet/saw
	damage = 45
	armour_penetration = 5

/obj/item/projectile/bullet/saw/bleeding
	damage = 20
	armour_penetration = 0

/obj/item/projectile/bullet/saw/bleeding/on_hit(atom/target, blocked = 0, hit_zone)
	. = ..()
	if((blocked != 100) && iscarbon(target))
		var/mob/living/carbon/C = target
		C.bleed(35)

/obj/item/projectile/bullet/saw/hollow
	damage = 60
	armour_penetration = -10

/obj/item/projectile/bullet/saw/ap
	damage = 40
	armour_penetration = 75

/obj/item/projectile/bullet/saw/incen
	damage = 7
	armour_penetration = 0

obj/item/projectile/bullet/saw/incen/Move()
	..()
	var/turf/location = get_turf(src)
	if(location)
		new /obj/effect/hotspot(location)
		location.hotspot_expose(700, 50, 1)

/obj/item/projectile/bullet/saw/incen/on_hit(atom/target, blocked = 0)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(3)
		M.IgniteMob()

//magazines//

/obj/item/ammo_box/magazine/win308
	name = "box magazine (.308 Win.)"
	icon_state = "a762-50"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/win308
	caliber = "win308"
	max_ammo = 50

/obj/item/ammo_box/magazine/win308/bleeding
	name = "box magazine (Bleeding .308 Win.)"
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/win308/bleeding

/obj/item/ammo_box/magazine/win308/hollow
	name = "box magazine (Hollow-Point .308 Win.)"
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/win308/hollow

/obj/item/ammo_box/magazine/win308/ap
	name = "box magazine (Armor Penetrating .308 Win.)"
	origin_tech = "combat=4"
	ammo_type = /obj/item/ammo_casing/win308/ap

/obj/item/ammo_box/magazine/win308/incen
	name = "box magazine (Incendiary .308 Win.)"
	origin_tech = "combat=4"
	ammo_type = /obj/item/ammo_casing/win308/incen

/obj/item/ammo_box/magazine/win308/update_icon()
	..()
	icon_state = "a762-[round(ammo_count(),10)]"

//casings//

/obj/item/ammo_casing/win308
	desc = "A .308 Win. bullet casing."
	icon_state = "762-casing"
	caliber = "win308"
	projectile_type = /obj/item/projectile/bullet/saw

/obj/item/ammo_casing/win308/bleeding
	desc = "A .308 Win. bullet casing with specialized inner-casing, that when it makes contact with a target, release tiny shrapnel to induce internal bleeding."
	icon_state = "762-casing"
	projectile_type = /obj/item/projectile/bullet/saw/bleeding

/obj/item/ammo_casing/win308/hollow
	desc = "A .308 Win. bullet casing designed to cause more damage to unarmored targets."
	projectile_type = /obj/item/projectile/bullet/saw/hollow

/obj/item/ammo_casing/win308/ap
	desc = "A .308 Win. bullet casing designed with a hardened-tipped core to help penetrate armored targets."
	projectile_type = /obj/item/projectile/bullet/saw/ap

/obj/item/ammo_casing/win308/incen
	desc = "A .308 Win. bullet casing designed with a chemical-filled capsule on the tip that when bursted, reacts with the atmosphere to produce a fireball, engulfing the target in flames. "
	projectile_type = /obj/item/projectile/bullet/saw/incen
