infrared-remote-ahk
===================

Autohotkey infrared remote control script, allows you to use the HP OVU400103/00 with the Verizon Cable Box Remote Control or add support for any infrared remote control you like, to control your computer while watching youtube, netflix VLC player or standard media center


 Autohotkey Driver to interface the OVU400103/00 infrared detector to your remote control

 Tested okay on win7, win xp (you might need to run as administrator)
 Tested okay with Verizon Cable Box Remote using DVD selector
 
 Note that the unique verizon codes are coming in on byte Keys5 .. (see line 155 of remoteControlDriver.ahk)
 this may not be the case for all controllers, some will require you to look closely
 at the error codes to see which bytes are being affected by your particular controller.
 This will require you to modify the label creator accordingly (see line 168)
 
 Set debugOn:=true if you want to detect new codes of a remote 
  
 Just point the remote at the OVU sensor and hit the key, then if an unserviced code is detected
 an error msgbox will pop up.  The error message will tell you what function to create, it will
 dump the byte sequence being detected so you can work out which ones to service... 
 
 for example if you see 
 
 "default_120"
 
 then Keys5 is returning the value '120' and you need to create a default_120: subroutine to capture and service this key.
 
 The OVU400103 can detect a wide variety of remotes, but it doesnt always detect all of the keys on that remote. You
 can use this code as the basis for a wide variety or infrared applications.
 
 This particular app will use the [menu] key to change between keyboard mode and mouse mode.
 Keyboard mode. (hit menu key)
   The up/down/left/right and OK button function like the cursor keys and enter key.
 Mouse Mode   (hit menu key again)
   The up/down/left/right and OK button  control the mouse pointer and a left click, hold down for double click
   
Pause/play and fast forward/back should work in either mode.

 The script will try to detect if VLC or different apps are running by scanning the window titles and can run a different set of commands for that application.
 
