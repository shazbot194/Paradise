/obj/item/device/spacepod_equipment/weaponry/proc/action(target, user, params)
	if(my_atom.next_firetime > world.time)
		to_chat(usr, "<span class='warning'>Your weapons are recharging.</span>")
		return

	if(!my_atom.equipment_system || !my_atom.equipment_system.weapon_system)
		to_chat(usr, "<span class='warning'>Missing equipment or weapons.</span>")
		my_atom.verbs -= text2path("[type]/proc/fire_weapons")
		return

	if(!my_atom.battery.use(shot_cost))
		to_chat(usr, "<span class='warning'>Insufficient charge to fire the weapons</span>")
		return

	var/turf/targloc = get_turf(target)
	if(!targloc || !istype(targloc))
		return 0

	var/olddir
	var/turf/firstloc
	var/turf/secondloc
	var/offset_x = 0
	var/offset_y = 0
	var/center
	for(var/i = 0; i < shots_per; i++)
		if(olddir != my_atom.dir)
			switch(my_atom.dir)
				if(NORTH)
					firstloc = get_step(my_atom, NORTH)
					secondloc = get_step(firstloc,EAST)
					offset_x = 16
					center = 90
				if(SOUTH)
					firstloc = get_turf(my_atom)
					secondloc = get_step(firstloc,EAST)
					offset_x = 16
					center = 270
				if(EAST)
					firstloc = get_step(my_atom, EAST)
					secondloc = get_step(firstloc,NORTH)
					offset_y = 16
					center = 0
				if(WEST)
					firstloc = get_turf(my_atom)
					secondloc = get_step(firstloc,NORTH)
					offset_y = 16
					center = 180

			olddir = dir
			var/spread_a = round((rand() - 0.5) * variance)
			var/spread_b = round((rand() - 0.5) * variance)
			var/obj/item/projectile/A = new projectile_type(firstloc)
			var/obj/item/projectile/B = new projectile_type(secondloc)
			A.preparePixelProjectile_offset(target, targloc, firstloc, user, params, spread_a, offset_y, offset_x)
			B.preparePixelProjectile_offset(target, targloc, secondloc, user, params, spread_b, -offset_y, -offset_x)

//			projectiles--
			to_chat(usr, "<span class='warning'>pew pew</span>")

			if(can_fire(A, 1, center))
				A.fire()
				to_chat(usr, "<span class='warning'>Should work</span>")
			else
				to_chat(usr, "<span class='warning'>didn't work</span>")
			if(can_fire(B, 0, center))
				B.fire()
			playsound(src, fire_sound, 50, 1)
			sleep(cooldown)
	my_atom.next_firetime = world.time + fire_delay		// To keep it in line with the other fire proc
	sleep(2)		// For some reason it can fire twice without this
	return

/obj/item/device/spacepod_equipment/weaponry/proc/can_fire(var/obj/item/projectile/bullet, var/gun, var/center)
	var/temp_ang = bullet.Angle
	if(center == 0 & temp_ang > 180)
		temp_ang = -(360 - temp_ang)
	if(gun)
		if(temp_ang > (center - arc_center) & temp_ang < (center + arc_side))
			to_chat(usr, "<span class='warning'>In angle</span>")
			return TRUE
	else
		if(temp_ang < (center + arc_center) & temp_ang > (center - arc_side))
			return TRUE
	to_chat(usr, "<span class='warning'>not in angle</span>")
	return FALSE

/obj/item/device/spacepod_equipment/weaponry/proc/fire_weapons()
	if(my_atom.next_firetime > world.time)
		to_chat(usr, "<span class='warning'>Your weapons are recharging.</span>")
		return
	var/turf/firstloc
	var/turf/secondloc
	if(!my_atom.equipment_system || !my_atom.equipment_system.weapon_system)
		to_chat(usr, "<span class='warning'>Missing equipment or weapons.</span>")
		my_atom.verbs -= text2path("[type]/proc/fire_weapons")
		return
	if(!my_atom.battery.use(shot_cost))
		to_chat(usr, "<span class='warning'>Insufficient charge to fire the weapons</span>")
		return
	var/olddir
	for(var/i = 0; i < shots_per; i++)
		if(olddir != my_atom.dir)
			switch(my_atom.dir)
				if(NORTH)
					firstloc = get_step(my_atom, NORTH)
					secondloc = get_step(firstloc,EAST)
				if(SOUTH)
					firstloc = get_turf(my_atom)
					secondloc = get_step(firstloc,EAST)
				if(EAST)
					firstloc = get_step(my_atom, EAST)
					secondloc = get_step(firstloc,NORTH)
				if(WEST)
					firstloc = get_turf(my_atom)
					secondloc = get_step(firstloc,NORTH)
		olddir = dir
		var/obj/item/projectile/projone = new projectile_type(firstloc)
		var/obj/item/projectile/projtwo = new projectile_type(secondloc)
		projone.starting = get_turf(my_atom)
		projone.firer = usr
		projone.def_zone = "chest"
		projtwo.starting = get_turf(my_atom)
		projtwo.firer = usr
		projtwo.def_zone = "chest"
		spawn()
			playsound(src, fire_sound, 50, 1)
			projone.dumbfire(my_atom.dir)
			projtwo.dumbfire(my_atom.dir)
		sleep(2)
	my_atom.next_firetime = world.time + fire_delay

/datum/spacepod/equipment
	var/obj/spacepod/my_atom
	var/list/obj/item/device/spacepod_equipment/installed_modules = list() // holds an easy to access list of installed modules

	var/obj/item/device/spacepod_equipment/weaponry/weapon_system // weapons system
	var/obj/item/device/spacepod_equipment/misc/misc_system // misc system
	var/obj/item/device/spacepod_equipment/cargo/cargo_system // cargo system
	var/obj/item/device/spacepod_equipment/cargo/sec_cargo_system // secondary cargo system
	var/obj/item/device/spacepod_equipment/lock/lock_system // lock system

/datum/spacepod/equipment/New(var/obj/spacepod/SP)
	..()
	if(istype(SP))
		my_atom = SP

/obj/item/device/spacepod_equipment
	name = "equipment"
	var/obj/spacepod/my_atom
	var/occupant_mod = 0	// so any module can modify occupancy
	var/list/storage_mod = list("slots" = 0, "w_class" = 0)		// so any module can modify storage slots

/obj/item/device/spacepod_equipment/proc/removed(var/mob/user) // So that you can unload cargo when you remove the module
	return

/*
///////////////////////////////////////
/////////Weapon System///////////////////
///////////////////////////////////////
*/

/obj/item/device/spacepod_equipment/weaponry
	name = "pod weapon"
	desc = "You shouldn't be seeing this"
	icon = 'icons/vehicles/spacepod.dmi'
	icon_state = "blank"
	var/obj/item/projectile/projectile_type
	var/shot_cost = 0
	var/shots_per = 1
	var/fire_sound
	var/fire_delay = 15		// smallest that is possible is 2 due to a sleep(2) being needed to prevent accidental spam
	var/cooldown = 2
	var/variance = 0		// spread, put in twice what you want, as it will be multiplided by -0.5 to 0.5
	var/arc_center = 30		// angle limit to cockpit
	var/arc_side = 60		// angle limit to the side


/obj/item/device/spacepod_equipment/weaponry/taser
	name = "disabler system"
	desc = "A weak taser system for space pods, fires disabler beams."
	icon_state = "weapon_taser"
	projectile_type = /obj/item/projectile/beam/disabler
	shot_cost = 400
	fire_sound = 'sound/weapons/Taser.ogg'

/obj/item/device/spacepod_equipment/weaponry/burst_taser
	name = "burst taser system"
	desc = "A weak taser system for space pods, this one fires 3 at a time."
	icon_state = "weapon_burst_taser"
	projectile_type = /obj/item/projectile/beam/disabler
	shot_cost = 1200
	shots_per = 3
	fire_sound = 'sound/weapons/Taser.ogg'
	fire_delay = 30

/obj/item/device/spacepod_equipment/weaponry/laser
	name = "laser system"
	desc = "A weak laser system for space pods, fires concentrated bursts of energy."
	icon_state = "weapon_laser"
	projectile_type = /obj/item/projectile/beam
	shot_cost = 600
	fire_sound = 'sound/weapons/Laser.ogg'

// MINING LASERS
/obj/item/device/spacepod_equipment/weaponry/mining_laser_basic
	name = "weak mining laser system"
	desc = "A weak mining laser system for space pods, fires bursts of energy that cut through rock."
	icon = 'icons/goonstation/pods/ship.dmi'
	icon_state = "pod_taser"
	projectile_type = /obj/item/projectile/kinetic/pod
	shot_cost = 300
	fire_delay = 14
	fire_sound = 'sound/weapons/Kenetic_accel.ogg'

/obj/item/device/spacepod_equipment/weaponry/mining_laser
	name = "mining laser system"
	desc = "A mining laser system for space pods, fires bursts of energy that cut through rock."
	icon = 'icons/goonstation/pods/ship.dmi'
	icon_state = "pod_m_laser"
	projectile_type = /obj/item/projectile/kinetic/pod/regular
	shot_cost = 250
	fire_delay = 10
	fire_sound = 'sound/weapons/Kenetic_accel.ogg'

/obj/item/device/spacepod_equipment/weaponry/mining_laser_hyper
	name = "enhanced mining laser system"
	desc = "An enhanced mining laser system for space pods, fires bursts of energy that cut through rock."
	icon = 'icons/goonstation/pods/ship.dmi'
	icon_state = "pod_w_laser"
	projectile_type = /obj/item/projectile/kinetic/pod/enhanced
	shot_cost = 200
	fire_delay = 8
	fire_sound = 'sound/weapons/Kenetic_accel.ogg'

/*
///////////////////////////////////////
/////////Misc. System///////////////////
///////////////////////////////////////
*/

/obj/item/device/spacepod_equipment/misc
	name = "pod misc"
	desc = "You shouldn't be seeing this"
	icon = 'icons/goonstation/pods/ship.dmi'
	icon_state = "blank"
	var/enabled

/obj/item/device/spacepod_equipment/misc/tracker
	name = "\improper spacepod tracking system"
	desc = "A tracking device for spacepods."
	icon_state = "pod_locator"
	enabled = 0

/obj/item/device/spacepod_equipment/misc/tracker/attackby(obj/item/I as obj, mob/user as mob, params)
	if(isscrewdriver(I))
		if(enabled)
			enabled = 0
			user.show_message("<span class='notice'>You disable \the [src]'s power.")
			return
		enabled = 1
		user.show_message("<span class='notice'>You enable \the [src]'s power.</span>")
	else
		..()

/*
///////////////////////////////////////
/////////Cargo System//////////////////
///////////////////////////////////////
*/

/obj/item/device/spacepod_equipment/cargo
	name = "pod cargo"
	desc = "You shouldn't be seeing this"
	icon = 'icons/vehicles/spacepod.dmi'
	icon_state = "cargo_blank"
	var/obj/storage = null

/obj/item/device/spacepod_equipment/cargo/proc/passover(var/obj/item/I)
	return

/obj/item/device/spacepod_equipment/cargo/proc/unload() // called by unload verb
	if(storage)
		storage.forceMove(get_turf(my_atom))
		storage = null

/obj/item/device/spacepod_equipment/cargo/removed(var/mob/user) // called when system removed
	. = ..()
	unload()

// Ore System
/obj/item/device/spacepod_equipment/cargo/ore
	name = "spacepod ore storage system"
	desc = "An ore storage system for spacepods. Scoops up any ore you drive over."
	icon_state = "cargo_ore"

/obj/item/device/spacepod_equipment/cargo/ore/passover(var/obj/item/I)
	if(storage && istype(I,/obj/item/weapon/ore))
		I.forceMove(storage)

// Crate System
/obj/item/device/spacepod_equipment/cargo/crate
	name = "spacepod crate storage system"
	desc = "A heavy duty storage system for spacepods. Holds one crate."
	icon_state = "cargo_crate"

/*
///////////////////////////////////////
/////////Secondary Cargo System////////
///////////////////////////////////////
*/

/obj/item/device/spacepod_equipment/sec_cargo
	name = "secondary cargo"
	desc = "you shouldn't be seeing this"
	icon = 'icons/vehicles/spacepod.dmi'
	icon_state = "blank"

// Passenger Seat
/obj/item/device/spacepod_equipment/sec_cargo/chair
	name = "passenger seat"
	desc = "A passenger seat for a spacepod."
	icon_state = "sec_cargo_chair"
	occupant_mod = 1

// Loot Box
/obj/item/device/spacepod_equipment/sec_cargo/loot_box
	name = "loot box"
	desc = "A small compartment to store valuables."
	icon_state = "sec_cargo_loot"
	storage_mod = list("slots" = 7, "w_class" = 14)

/*
///////////////////////////////////////
/////////Lock System///////////////////
///////////////////////////////////////
*/

/obj/item/device/spacepod_equipment/lock
	name = "pod lock"
	desc = "You shouldn't be seeing this"
	icon = 'icons/vehicles/spacepod.dmi'
	icon_state = "blank"
	var/mode = 0
	var/id = null

// Key and Tumbler System
/obj/item/device/spacepod_equipment/lock/keyed
	name = "spacepod tumbler lock"
	desc = "A locking system to stop podjacking. This version uses a standalone key."
	icon_state = "lock_tumbler"
	var/static/id_source = 0

/obj/item/device/spacepod_equipment/lock/keyed/New()
	..()
	id = ++id_source

// The key
/obj/item/device/spacepod_key
	name = "spacepod key"
	desc = "A key for a spacepod lock."
	icon = 'icons/vehicles/spacepod.dmi'
	icon_state = "podkey"
	w_class = WEIGHT_CLASS_TINY
	var/id = 0

// Key - Lock Interactions
/obj/item/device/spacepod_equipment/lock/keyed/attackby(obj/item/I as obj, mob/user as mob, params)
	if(istype(I, /obj/item/device/spacepod_key))
		var/obj/item/device/spacepod_key/key = I
		if(!key.id)
			key.id = id
			to_chat(user, "<span class='notice'>You grind the blank key to fit the lock.</span>")
		else
			to_chat(user, "<span class='warning'>This key is already ground!</span>")
	else
		..()
