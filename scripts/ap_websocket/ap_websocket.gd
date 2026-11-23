## Handles the websocket connection to Archipelago.
## Use [ArchipelagoManager] to handle item send/receive instead of this class.
class_name ArchipelagoWS
extends Node

const UUID_CHARS: String = "0123456789abcdef"
const WS_TIMEOUT_MS: int = 10 * 1000 # 10s

var address: String
var port: String
var slot: String
var password: String

var _socket: WebSocketPeer = WebSocketPeer.new()
var _checked_insecure: bool = false

var _connect_start_time: int = -1
var _connecting: bool = false
var _connected: bool = false
var _player_id: int = 0
var _players: Array[APWSClasses.NetworkPlayer] = []
var _send_queue: Array[int] = []

signal connection_updated(success: bool)

signal packet_room_info(packet: APWSClasses.RoomInfo)
signal packet_connection_refused(packet: APWSClasses.ConnectionRefused)
signal packet_connected(packet: APWSClasses.Connected)
signal packet_location_info(packet: APWSClasses.LocationInfo)
signal packet_received_items(packet: APWSClasses.ReceivedItems)
signal packet_data_package(packet: APWSClasses.DataPackage)

func _init() -> void:
	packet_connection_refused.connect(_on_packet_connection_refused)
	packet_connected.connect(_on_packet_connected)
	
	process_mode = Node.PROCESS_MODE_ALWAYS

func _create_url() -> String:
	if not _checked_insecure:
		_checked_insecure = true
		return "ws://%s:%s" % [address, port]
	_checked_insecure = false
	return "wss://%s:%s"% [address, port]

func connect_to_ap() -> void:
	ModLoaderLog.debug("Begin connection to Archipelago", ArchipelagoMod.LOG_NAME)
	if address == "":
		ModLoaderLog.error("Address empty", ArchipelagoMod.LOG_NAME)
		ArchipelagoMod.instance.ap_ws_connection_failure.emit("Address must not be blank.")
		return
	if port == "" or not port.is_valid_int():
		ModLoaderLog.error("Port empty", ArchipelagoMod.LOG_NAME)
		ArchipelagoMod.instance.ap_ws_connection_failure.emit("Port must be a valid integer.")
		return
	if slot == "":
		ModLoaderLog.error("Slot empty", ArchipelagoMod.LOG_NAME)
		ArchipelagoMod.instance.ap_ws_connection_failure.emit("Slot must not be blank.")
		return
	ModLoaderLog.info("Connecting to Archipelago...", ArchipelagoMod.LOG_NAME)
	
	# loop twice; first is connecting to ws://, second is wss://
	for i: int in 2:
		var url: String = _create_url()
		ModLoaderLog.info("Connecting to %s" % url, ArchipelagoMod.LOG_NAME)
		_connect_start_time = Time.get_ticks_msec()
		var err: Error = _socket.connect_to_url(url)
		if err != OK:
			if i == 1:
				ArchipelagoMod.instance.ap_ws_connection_failure.emit("Errno %d" % err)
				_socket.close()
				return
			continue
		_connecting = true
		var success: bool = await connection_updated
		if success:
			break
	
	if not _connected:
		ArchipelagoMod.instance.ap_ws_connection_failure.emit("Timed out")
		_socket.close()
		return
	
	var roominfo: APWSClasses.RoomInfo = await packet_room_info
	
	if roominfo.password and password == "":
		_connected = false
		_socket.close()
		ArchipelagoMod.instance.ap_ws_connection_failure.emit("Password is required to join.")
		return
	
	# handle datapackage before or after?
	# will datapackage be necessary?
	
	_send_connect()

func disconnect_from_ap() -> void:
	ModLoaderLog.info("Disconnecting from Archipelago", ArchipelagoMod.LOG_NAME)
	_socket.close(1000)
	_connected = false
	_connecting = false
	# invalidate caches?

func request_location_scouts(locations: Array[int]) -> void:
	if not _connected:
		ModLoaderLog.warning("Attempted to communicate with socket before connected.", ArchipelagoMod.LOG_NAME)
	
	while not _connected:
		await get_tree().create_timer(5.0).timeout
	
	var c: APWSClasses.LocationScouts = APWSClasses.LocationScouts.new(locations, APWSClasses.LocationScoutsHint.Disabled)
	var err: Error = _socket.send_text(JSON.stringify([c.to_json()]))
	if err != OK:
		ModLoaderLog.error("Failed to send LocationScouts packet (errno %d)" % err, ArchipelagoMod.LOG_NAME)

func queue_send_location(location: int) -> void:
	if location not in _send_queue:
		_send_queue.append(location)

func _get_cached_uuid() -> String:
	if FileAccess.file_exists("user://ap_uuid.txt"):
		ModLoaderLog.info("Using cached uuid", ArchipelagoMod.LOG_NAME)
		return FileAccess.get_file_as_string("user://ap_uuid.txt")
	ModLoaderLog.info("Generating new uuid", ArchipelagoMod.LOG_NAME)
	var n: String = ""
	for i: int in 32:
		if i in [8, 12, 16, 20]:
			n += "-"
		if i == 12:
			n += "4"
		elif i == 16:
			var r: int = (randi() % 16 & 0x3) | 0x8
			n += UUID_CHARS[r]
		else:
			n += UUID_CHARS[randi() % 16]
	var f: FileAccess = FileAccess.open("user://ap_uuid.txt", FileAccess.WRITE)
	ModLoaderLog.info("Saved uuid to user://ap_uuid.txt", ArchipelagoMod.LOG_NAME)
	f.store_string(n)
	f.close()
	return n

func _send_connect() -> void:
	ModLoaderLog.info("Sending Connect packet", ArchipelagoMod.LOG_NAME)
	var c: APWSClasses.Connect = APWSClasses.Connect.new()
	c.name = slot
	c.uuid = _get_cached_uuid()
	c.password = password
	c.slot_data = true
	var err: Error = _socket.send_text(JSON.stringify([c.to_json()]))
	if err != OK:
		ModLoaderLog.error("Failed to send connect packet (errno %d)" % err, ArchipelagoMod.LOG_NAME)

func _send_get_datapackage(slot_info: Dictionary[int, APWSClasses.NetworkSlot]) -> void:
	ModLoaderLog.info("Sending GetDataPackage packet", ArchipelagoMod.LOG_NAME)
	var c: APWSClasses.GetDataPackage = APWSClasses.GetDataPackage.new()
	c.games = []
	
	for key:int in slot_info:
		var slot: APWSClasses.NetworkSlot = slot_info[key]
		if slot.game not in c.games:
			c.games.append(slot.game)
	
	var err: Error = _socket.send_text(JSON.stringify([c.to_json()]))
	if err != OK:
		ModLoaderLog.error("Failed to send GetDataPackage packet (errno %d)" % err, ArchipelagoMod.LOG_NAME)


func send_goal() -> void:
	ModLoaderLog.info("Sending Goal packet", ArchipelagoMod.LOG_NAME)
	var c: APWSClasses.StatusUpdate = APWSClasses.StatusUpdate.new(APWSClasses.ClientStatus.GOAL)
	var err: Error = _socket.send_text(JSON.stringify([c.to_json()]))
	if err != OK:
		ModLoaderLog.error("Failed to send goal packet (errno %d)" % err, ArchipelagoMod.LOG_NAME)

func _process(_delta: float) -> void:
	if not _connecting: return
	
	_socket.poll()
	
	var state: WebSocketPeer.State = _socket.get_ready_state()
	
	if state == WebSocketPeer.STATE_CONNECTING:
		if Time.get_ticks_msec() - _connect_start_time > WS_TIMEOUT_MS:
			ModLoaderLog.warning("Connection timed out.", ArchipelagoMod.LOG_NAME)
			_socket.close()
			_connecting = false
			connection_updated.emit(false)
	elif state == WebSocketPeer.STATE_OPEN:
		if not _connected:
			_connected = true
			connection_updated.emit(true)
		
		while _socket.get_available_packet_count() > 0:
			var packet: PackedByteArray = _socket.get_packet()
			if _socket.was_string_packet():
				var text: String = packet.get_string_from_utf8()
				ModLoaderLog.debug("Received data: %s" % text, ArchipelagoMod.LOG_NAME)
				_process_packet(text)
			else:
				ModLoaderLog.error("Received bytes data of size %d" % packet.size(), ArchipelagoMod.LOG_NAME)
		
		if not _send_queue.is_empty():
			var loc: APWSClasses.LocationChecks = APWSClasses.LocationChecks.new(_send_queue)
			var err: Error = _socket.send_text(JSON.stringify([loc.to_json()]))
			if err != OK:
				ModLoaderLog.error("Failed to send location checks (errno %d)" % err, ArchipelagoMod.LOG_NAME)
			else:
				_send_queue.clear()
		
	elif state == WebSocketPeer.STATE_CLOSING:
		#ModLoaderLog.debug("Socket state closing", ArchipelagoMod.LOG_NAME)
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		ModLoaderLog.warning("Socket closed with code: %d" % _socket.get_close_code(), ArchipelagoMod.LOG_NAME)
		_connected = false
		_connecting = false
		connection_updated.emit(false)

func _process_packet(packet: String) -> void:
	var data: Array = JSON.parse_string(packet)
	for pack: Dictionary in data:
		match pack['cmd']:
			"RoomInfo":
				var r: APWSClasses.RoomInfo = APWSClasses.RoomInfo.from_json(pack)
				packet_room_info.emit(r)
			"ConnectionRefused":
				var r: APWSClasses.ConnectionRefused = APWSClasses.ConnectionRefused.new(pack)
				packet_connection_refused.emit(r)
			"Connected":
				var r: APWSClasses.Connected = APWSClasses.Connected.new(pack)
				packet_connected.emit(r)
			"LocationInfo":
				var r: APWSClasses.LocationInfo = APWSClasses.LocationInfo.new(pack)
				packet_location_info.emit(r)
			"ReceivedItems":
				var r: APWSClasses.ReceivedItems = APWSClasses.ReceivedItems.new(pack)
				packet_received_items.emit(r)
			"DataPackage":
				var r: APWSClasses.DataPackage = APWSClasses.DataPackage.new(pack)
				packet_data_package.emit(r)

func _on_packet_connection_refused(packet: APWSClasses.ConnectionRefused) -> void:
	var reason: String = "\n".join(packet.errors)
	ModLoaderLog.info("Connection refused: %s" % reason, ArchipelagoMod.LOG_NAME)
	_socket.close()
	_connected = false
	ArchipelagoMod.instance.ap_ws_connection_failure.emit(reason)

func _on_packet_connected(packet: APWSClasses.Connected) -> void:
	_player_id = packet.slot
	_players.assign(packet.players)
	
	# NOTICE: 'packet.checked_locations' contains a list of location ids that we already collected
	# We can use this to skip over locations, or we can use a custom save file
	# Either one works
	
	#GetDataPackage
	_send_get_datapackage(packet.slot_info)
	
	ArchipelagoMod.instance.ap_ws_connected.emit()
