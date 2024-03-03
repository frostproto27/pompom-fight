extends Node

# netcode logic and such

#init netcode variables
var isserver = false
var host = "127.0.0.1"
var port = 9999
var peer = ENetMultiplayerPeer.new()

# these need to be set to the characters that the players are controlling
var serverplayer
var clientplayer

func assignplayers(serp, clip):
	serverplayer = serp
	clientplayer = clip

func netcodeinit():
	#assign peer
	peer = ENetMultiplayerPeer.new()
	#connect everything up
	peer.connect("peer_connected", _on_network_peer_connected)
	peer.connect("peer_disconnected", _on_network_peer_disconnected)
	peer.connect("server_disconnected", _on_server_disconnected)
	SyncManager.connect("sync_started", _on_syncmanager_sync_started)
	SyncManager.connect("sync_stopped", _on_syncmanager_sync_stopped)
	SyncManager.connect("sync_lost", _on_syncmanager_sync_lost)
	SyncManager.connect("sync_regained", _on_syncmanager_sync_regained)
	SyncManager.connect("sync_error", _on_syncmanager_sync_error)
	#load game
	var scene = preload("res://netcode/netcodetest.tscn")
	get_tree().change_scene_to_file("res://netcode/netcodetest.tscn")
	# serverplayer = scene.serverplayer
	# clientplayer = scene.clientplayer
	
	# when u press the server button we need to set up a server, we do that thru enet
func _initserver():
	netcodeinit()
	# get the port from the users input and let the game know we're expecting 1 player to connect
	# (things here will need to be adjusted if we try to get spectating or player rooms up
	# -but for now im just tryna get the core structure in)
	peer.create_server(int(port), 1)
	multiplayer.set_multiplayer_peer(peer)
	isserver = true
	print("listening..")

#pretty much the same thing but for a client
func _initclient():
	netcodeinit()
	peer.create_client(host, int(port))
	multiplayer.set_multiplayer_peer(peer)
	isserver = false
	print("connecting..")

func _on_network_peer_connected(peer_id: int):
	print("connected!")
	SyncManager.add_peer(peer_id)
	# the server player is always 1, as that is the id given to the server
	serverplayer.set_multiplayer_authority(1)
	
	if isserver:
		print("starting..")
		# assign the client player to the id
		clientplayer.set_multiplayer_authority(peer_id)
		# give a little time to gather ping data
		await get_tree().create_timer(2.0).timeout
		# start syncing
		SyncManager.start()
	else:
		print("waiting for host..")
		# we need to get the client id in a bit of a different way if we're controlling it
		clientplayer.set_multiplayer_authority(peer.get_unique_id())

func _on_network_peer_disconnected(peer_id: int):
	print("disconnected :(")

func _on_server_disconnected() -> void:
	_on_network_peer_disconnected(1)

# i had a reset button in my original test build, might need to be reimplemented so heres the code
func _on_resetbutton_pressed() -> void:
	SyncManager.stop()
	SyncManager.clear_peers()
	if peer.get_connection_status() == 2:
		peer.close()
	get_tree().reload_current_scene()

func _on_syncmanager_sync_started():
	print("started!!")
	print(SyncManager.peers)

func _on_syncmanager_sync_stopped():
	pass

func _on_syncmanager_sync_lost():
	print("sync lost!")

func _on_syncmanager_sync_regained():
	print("sync regained")

func _on_syncmanager_sync_error(msg: String):
	print("fatal sync error: " + msg)
	if peer.get_connection_status() == 2:
		peer.close()
	SyncManager.clear_peers()
