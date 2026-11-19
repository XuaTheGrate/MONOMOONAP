class_name APWSClasses
extends Object

## An enumeration containing the possible command permission, for commands that may be restricted.
enum Permission {
	## Completely disables access
	Disabled    = 0b000,
	## allows manual use 
	Enabled     = 0b001,
	## allows manual use after goal completion
	Goal        = 0b010,
	## forces use after goal completion, only works for release and collect
	Auto        = 0b110,
	## forces use after goal completion, allows manual use any time
	AutoEnabled = 0b111, 
}

## An object representing software versioning. Used in the [Connect] packet to
## allow the client to inform the server of the Archipelago version it supports.
class NetworkVersion extends RefCounted:
	var major: int
	var minor: int
	var build: int
	
	func _init(mjr: int, mnr: int, bld: int) -> void:
		major = mjr
		minor = mnr
		build = bld
	
	static func from_json(json: Dictionary) -> NetworkVersion:
		var j: int = json['major']
		var n: int = json['minor']
		var b: int = json['build']
		return NetworkVersion.new(j, n, b)
	
	func to_json() -> Dictionary:
		return {"major":major,"minor":minor,"build":build,"class":"Version"}

class NetworkPlayer extends RefCounted:
	var team: int
	var slot: int
	var alias: String
	var name: String
	
	func _init(json: Dictionary) -> void:
		team = json['team']
		slot = json['slot']
		alias = json['alias']
		name = json['name']

enum SlotType {
	Spectator = 0b00,
	Player = 0b01,
	Group = 0b10
}

class NetworkSlot extends RefCounted:
	var name: String
	var game: String
	var type: SlotType
	var group_members: Array[int] = []
	
	func _init(json: Dictionary) -> void:
		name = json['name']
		game = json['game']
		type = json['type']
		group_members.assign(json['group_members'])

## Sent to clients when they connect to an Archipelago server.
class RoomInfo extends RefCounted:
	## Object denoting the version of Archipelago which the server is running.
	var version: NetworkVersion
	## Object denoting the version of Archipelago which generated the multiworld.
	var generator_version: NetworkVersion
	## Denotes special features or capabilities that the sender is capable of. Example: WebHost
	var tags: Array[String]
	## Denoted whether a password is required to join this room.
	var password: bool
	## Mapping of permission name to Permission, keys are: "release", "collect" and "remaining".
	var permissions: Dictionary[String, Permission]
	## The percentage of total locations that need to be checked to receive a hint from the server.
	var hint_cost: int
	## The amount of hint points you receive per item/location check completed.
	var location_check_points: int
	## List of games present in this multiworld.
	var games: Array[String]
	## Checksum hash of the individual games' data packages the server will send.
	## Used by newer clients to decide which games' caches are outdated.
	var datapackage_checksums: Dictionary[String, String]
	## Uniquely identifying name of this generation.
	var seed_name: String
	## Unix time stamp of "now". Send for time synchronization if wanted for things like the DeathLink Bounce.
	var time: float
	
	static func from_json(json: Dictionary) -> RoomInfo:
		var r: RoomInfo = RoomInfo.new()
		r.password = json['password']
		r.games.assign(json['games'])
		r.tags.assign(json['tags'])
		r.version = NetworkVersion.from_json(json['version'])
		r.generator_version = NetworkVersion.from_json(json['generator_version'])
		r.permissions.assign(json['permissions'])
		r.hint_cost = json['hint_cost']
		r.location_check_points = json['location_check_points']
		r.datapackage_checksums.assign(json['datapackage_checksums'])
		r.seed_name = json['seed_name']
		r.time = json['time']
		return r

## Sent by the client to initiate a connection to an Archipelago game session.
class Connect extends RefCounted:
	## If the game session requires a password, it should be passed here.
	var password: String
	## The name of the game the client is playing. Example: A Link to the Past
	var game: String = "MONOMOON"
	## The player name for this client.
	var name: String
	## Unique identifier for player. Cached in the user cache \Archipelago\Cache\common.json
	var uuid: String
	## An object representing the Archipelago version this client supports.
	var version: NetworkVersion = NetworkVersion.new(0, 6, 8)
	## Flags configuring which items should be sent by the server.
	## https://github.com/ArchipelagoMW/Archipelago/blob/main/docs/network%20protocol.md#items_handling-flags
	var items_handling: int = 0b001
	## Denotes special features or capabilities that the sender is capable of.
	var tags: Array[String] = []
	## If true, the Connect answer will contain slot_data.
	var slot_data: bool
	
	func to_json() -> Dictionary:
		return {
			"cmd": "Connect",
			"password": password,
			"game": game,
			"name": name,
			"uuid": uuid,
			"version": version.to_json(),
			"items_handling": items_handling,
			"tags": tags,
			"slot_data": slot_data
		}

## Sent to clients when the server refuses connection.
## This is sent during the initial connection handshake.
class ConnectionRefused extends RefCounted:
	## Optional. When provided, should contain any one of:
	## InvalidSlot, InvalidGame, IncompatibleVersion, InvalidPassword, or InvalidItemsHandling.
	var errors: Array[String] = []
	
	func _init(json: Dictionary) -> void:
		errors.assign(json['errors'])

## Sent to clients when the connection handshake is successfully completed.
class Connected extends RefCounted:
	## Your team number.
	var team: int
	## Your slot number on your team.
	var slot: int
	## List denoting other players in the multiworld, whether connected or not.
	var players: Array[NetworkPlayer]
	## Contains ids of remaining locations that need to be checked. Useful for trackers, among other things.
	var missing_locations: Array[int]
	## Contains ids of all locations that have been checked. Useful for trackers, among other things. Location ids are in the range of ± 2**53-1.
	var checked_locations: Array[int]
	## Contains a json object for slot related data, differs per game. Empty if not required. Not present if slot_data in Connect is false.
	var slot_data: Dictionary = {}
	## maps each slot to a NetworkSlot information.
	var slot_info: Dictionary[int, NetworkSlot]
	## Number of hint points that the current player has.
	var hint_points: int
	
	func _init(json: Dictionary) -> void:
		team = json['team']
		slot = json['slot']
		
		for p: Dictionary in json['players']:
			players.append(NetworkPlayer.new(p))
		
		missing_locations.assign(json['missing_locations'])
		checked_locations.assign(json['checked_locations'])
		
		if 'slot_data' in json:
			slot_data.assign(json['slot_data'])
		
		for k: String in json['slot_info']:
			var i: int = int(k)
			var d: Dictionary = json['slot_info'][k]
			slot_info[i] = NetworkSlot.new(d)
		
		hint_points = json['hint_points']

enum LocationScoutsHint {
	## Do not hint locations.
	Disabled,
	## Hint all locations, including already hinted locations.
	Enabled,
	## Only hint locations that have not been already hinted.
	OnlyNew
}

## Sent to the server to retrieve the items that are on a specified list of locations.
## The server will respond with a LocationInfo packet containing the items located in the scouted locations. 
class LocationScouts extends RefCounted:
	## The ids of the locations seen by the client.
	## May contain any number of locations, even ones sent before;
	## duplicates do not cause issues with the Archipelago server.
	var locations: Array[int]
	var create_as_hint: LocationScoutsHint
	
	func _init(l: Array[int], c: LocationScoutsHint) -> void:
		locations.assign(l)
		create_as_hint = c
	
	func to_json() -> Dictionary:
		return {
			"cmd": "LocationScouts",
			"locations": locations,
			"create_as_hint": create_as_hint
		}

enum NetworkItemFlags {
	Progression = 0b001,
	Useful = 0b010,
	Trap = 0b100
}

## Items that are sent over the net.
class NetworkItem extends RefCounted:
	## The ID of the item.
	var item: int
	## The location ID of the item inside the world.
	var location: int
	## The player slot of the world the item is located in,
	## except when inside an LocationInfo Packet then it will be the slot of the player to receive the item
	var player: int
	var flags: int
	
	func _init(json: Dictionary) -> void:
		item = json['item']
		location = json['location']
		player = json['player']
		flags = json['flags']
	
	func _to_string() -> String:
		return "NetworkItem(item=%s, location=%s, player=%s, flags=%s)" % [item, location, player, flags]

## Sent to clients to acknowledge a received [LocationScouts] packet and responds with the item in the location(s) being scouted.
class LocationInfo extends RefCounted:
	var locations: Array[NetworkItem]
	
	func _init(json: Dictionary) -> void:
		for i: Dictionary in json['locations']:
			locations.append(NetworkItem.new(i))
