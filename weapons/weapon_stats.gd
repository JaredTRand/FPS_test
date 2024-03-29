extends Resource
class_name WeaponStats

var player

@export_group("Main Settings")
enum wepclass {MELEE, RANGED, MAGIC}
@export var weapon_class: wepclass

enum weptype {SWORD, HAMMER, SPEAR, 
			  STAFF, GRIMOIRE, WAND,
			  BOW, CROSSBOW, GUN
			 }
@export var weapon_type:weptype

@export var weight:float

@export_subgroup("Damage")
@export var damage:float
@export var knocback: float
