extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


#just show the online ui if u press the online button
func _on_button_pressed():
	$connectionpanel.visible = true


func _on_serverbutton_pressed():
	NetcodeGlobal.port = $connectionpanel/GridContainer/portline.text
	NetcodeGlobal._initserver()


func _on_clientbutton_pressed():
	NetcodeGlobal.host = $connectionpanel/GridContainer/hostline.text
	NetcodeGlobal.port = $connectionpanel/GridContainer/portline.text
	NetcodeGlobal._initclient()
