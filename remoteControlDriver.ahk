/*
 Autohotkey Driver to interface the OVU400103/00 infrared detector to the Verizon Remote Control
(c) Copyright Hugh Fuve 2010

MIT Licence, use it any way you like.

AHKHID.ahk  belongs to their respective creators, and is unmodified from were found.
http://www.autohotkey.com/board/topic/38015-ahkhid-an-ahk-implementation-of-the-hid-functions/
Credit goes to 
 TheGood
 Lazslo
 Titan

COM.ahk
Credit goes to Sean
http://www.autohotkey.com/board/topic/21142-com-standard-library/


 Tested okay on win7, win xp (you might need to run as administrator)
 Tested okay with Verizon Cable Box Remote using DVD selector
 
 Note that the unique verizon codes are coming in on byte Keys5 .. (see line 155)
 this may not be the case for all controllers, some will require you to look closely
 at the error codes to see which bytes are being affected by your particular controller.
 This will require you to modify the label creator accordingly (see line 168)
 
 Set debugOn:=true if you want to detect new codes of a remote 
  
 Just poin the remote at the sensor and hit the key, then if an unserviced code is detected an
 an error msgbox will pop up.  The error message will tell you what function to create... 
 
 for example if you see 
 
 "default_120"
 
 then you need to create a default_120: function to capture and service this key.
 
 */
 
debugOn:=false

/*!
Remote Control Driver to sense verizon remote controller
(C) BooYah Hugh Fuve 2011

DVD Menu                36
Power                   12
TV                      70
Radio                   80
Music                   71
Pictures                73
Videos                  74
Record                  23
Rewind                  21
Replay/Previous Track   27
Play                    22
Pause                   24
Stop                    25
Forward                 20
Skip/Next Track         26
Back                    35
More/Information        15
Up Arrow                30
Left Arrow              32
Right Arrow             33
Down Arrow              31
OK                      34
Volume Up               16
Volume Down             17
Windows Media Center    13
Mute                    14
Channel/Page Up         18
Channel/Page Down       19
Live TV                 37
Guide                   38
Recorded TV             72
1                       1
2/ABC                   2
3/DEF                   3
4/GHI                   4
5/JKL                   5
6/MNO                   6
7/PQRS                  7
8/TUV                   8
9/WXYZ                  9
*                       29
0                       0
#                       28
Clear                   10
Print                   78
Enter                   11

*/

setTimer activateService,3000
mouseRez:=1

;Must be in auto-execute section if I want to use the constants

#include AHKHID.ahk
#include COM.ahk
return

activateService:
 setTimer activateService,  off
  msgBox ,,, Remote Control Activated, 2  
  goto activate
  
  
+f9::
activate:
;Create GUI to receive messages
Gui, +LastFound
hGui := WinExist()

;Intercept WM_INPUT messages
WM_INPUT := 0xFF
OnMessage(WM_INPUT, "InputMsg")

;Register Remote Control with RIDEV_INPUTSINK (so that data is received even in the background)
r := AHKHID_Register(65468, 137, hGui, RIDEV_INPUTSINK)

;Prefix loop
Loop {
    Sleep 1000
    If WinActive("ahk_class QWidget") Or WinActive("ahk_class VLC DirectX")
       sPrefix := "VLC"
;    Else If WinActive("ahk_class Winamp v1.x") Or WinActive("ahk_class Winamp Video")
;        sPrefix := "Winamp"
    Else If WinActive("ahk_class MediaPlayerClassicW")
        sPrefix := "MPC"
    Else 
		sPrefix := "Default"
}


return

GuiClose: 
   Gui, Destroy    
   ExitApp

InputMsg(wParam, lParam) {
    Local devh, iKey, sLabel
   
    Critical
   
    ;Get handle of device
    devh := AHKHID_GetInputInfo(lParam, II_DEVHANDLE)
   
    ;Check for error
    If (devh <> -1) ;Check that it is my HP remote
        ;And (AHKHID_GetDevInfo(devh, DI_DEVTYPE, True) = RIM_TYPEHID)
        And (AHKHID_GetDevInfo(devh, DI_HID_VENDORID, True) = 1118)
        And (AHKHID_GetDevInfo(devh, DI_HID_PRODUCTID, True) = 109)
        And (AHKHID_GetDevInfo(devh, DI_HID_VERSIONNUMBER, True) = 272) {
       
        ;Get data
        iKey := AHKHID_GetInputData(lParam, uData)
       
        ;Check for error
        If (iKey <> -1) {

            ;Get keycode (located at the 6th byte)
			Keys0:= NumGet(uData, 0, "UChar")         
			Keys1:= NumGet(uData, 1, "UChar")         
			Keys2:= NumGet(uData, 2, "UChar")         
			Keys3:= NumGet(uData, 3, "UChar")         
			Keys4:= NumGet(uData, 4, "UChar")         
            Keys5:= NumGet(uData, 5, "UChar")         
            Keys6:= NumGet(uData, 6, "UChar")
			Keys7:= NumGet(uData, 7, "UChar")
			Keys8:= NumGet(uData, 8, "UChar")
			Keys9:= NumGet(uData, 9, "UChar")         
            Keys10:= NumGet(uData, 10, "UChar")
			Keys11:= NumGet(uData, 11, "UChar")
			Keys12:= NumGet(uData, 12, "UChar")
			Keys13:= NumGet(uData, 13, "UChar")
			Keys14:= NumGet(uData, 14, "UChar")
			Keys15:= NumGet(uData, 15, "UChar")
			
            ;Call the appropriate sub if it exists
            sLabel := sPrefix "_" Keys5
            If IsLabel(sLabel){
                Gosub, %sLabel%
				sleep, 100
			}else{
				if(debugOn){
					msgBox Error [%sLabel%]	%Keys0%.%Keys1%.%Keys2%.%Keys3% : %Keys4%.%Keys5%.%Keys6%.%Keys7% : %Keys8%.%Keys9%.%Keys10%.%Keys11% : %Keys12%.%Keys13%.%Keys14%.%Keys15%
				}
			}
			
			
			     
        }else{
			msgBox iKey error
		}
    }
}

default_11:   ;enter
	if(inputMode=="Keyboard"){
		SendInput {enter}		
	}else{
		SendInput {click}		
	}	
	
	return
default_14:   ;exit
	SendInput {esc}
	return
default_27:   ;menu
	if(inputMode=="Mouse"){
		inputMode:="Keyboard"
		
		msgbox ,,,"Keyboard Mode",2
	}else{
		inputMode:="Mouse"		
		msgbox ,,,"Mouse Mode",2
	}
	return
default_48:   ;back
	SendInput {alt down}{left}
	sleep, 20
	SendInput {alt up}
	sleep,200
	return
default_49:   ;next	
	SendInput {alt down}{right}
	sleep, 20
	SendInput {alt up}
	sleep,200
	return
	
default_50:   ;play
	SendInput {space}
	sleep,200
	return
default_57:   ;pause
	SendInput {space}
	sleep,200
	return

default_51:   ;rewind
	SendInput {ctrl down}{down}{ctrl up}
	sleep,200
	return
default_52:   ;ff
	SendInput {ctrl down}{up}{ctrl up}
	sleep,200
	return
default_56:   ;stop
	SendInput {alt down}{enter}{alt up}
sleep,200
    return
default_83:   ;options
	;SendInput {alt down}{enter}{alt up}
	;sleep, 200
	
	mouseRez:=mouseRez+1
	
	if(mouseRez>3){
		mouseRez:=1
	}	
	msgBox ,,,Mouse Res %mouseRez% ,1
	return   
default_84:   ;info
	;gosub activateService
	SendInput {alt down}q{alt up}
	SendInput {alt down}x{alt up}
	return
default_121:  ;up
	if(inputMode=="Keyboard"){
		SendInput {up}
	}else{
		gosub setMouseDelay
		MouseMove, 0, -mouseStep*mouseRez ,0, R
	}
	return
default_122:  ;down
	if(inputMode=="Keyboard"){
		SendInput {down}
	}else{
		gosub setMouseDelay
		MouseMove, 0, mouseStep*mouseRez ,0, R
	}
	
	return
default_123:  ;left
	if(inputMode=="Keyboard"){
		SendInput {left}
		sleep, 70
	}else{
		gosub setMouseDelay
		MouseMove, -mouseStep*mouseRez, 0 ,0, R
	}
	return
default_124:  ;right
	if(inputMode=="Keyboard"){
		SendInput {right}
		sleep, 70
	}else{
		gosub setMouseDelay
		MouseMove, mouseStep*mouseRez, 0 ,0, R
	}	
	return

setMouseDelay:
		if(mouseMoving==1){			
			setTimer mouseDelayOff,  250			
			mouseStep:=mouseStep+3
		} else if(mouseMoving==2) {			
			setTimer mouseDelayOff,  250			
			mouseStep:=mouseStep+3
		} else{
			setTimer mouseDelay1, 175			
			setTimer mouseDelayOff,  250								
			mouseStep:=3
			mouseMoving:=1
		}
		return
		
mouseDelay1:			
		setTimer mouseDelay1, off
		
		mouseStep:=10
		mouseMoving:=2
	return
	
mouseDelayOff:
		setTimer mouseDelayOff,  off
		mouseStep:=3
		mouseMoving:=0
	return

VLC_15: ;More
    SendInput f ;Toggle fullscreen
Return

VLC_18: ;Channel Up
    SendInput ^{Up}
Return

VLC_19: ;Channel Down
    SendInput ^{Down}
Return

VLC_21: ;Rewind
    SendInput !{Left}
Return

VLC_27: ;Previous Track
    SendInput p
Return

VLC_22: ;Play
    SendInput q
Return

VLC_24: ;Pause
    SendInput {Space}
Return

VLC_25: ;Stop
    SendInput s
Return

VLC_20: ;Forward
    SendInput !{Right}
Return

VLC_26: ;Next Track
    SendInput n
Return



;--------------------------------------------

xMPC_15: ;More
    SendInput !{Enter} ;Toggle fullscreen
Return

xMPC_18: ;Channel Up
    SendInput {Up}
Return

xMPC_19: ;Channel Down
    SendInput {Down}
Return
xMPC_21: ;Rewind
    SendInput !{Left}
Return
xMPC_20: ;Forward
    SendInput !{Right}
Return
xMPC_27: ;Previous Track
    SendInput !{End}
Return
xMPC_26: ;Next Track
    SendInput !{Home}
Return
xMPC_22: ;Play
    SendInput !p
Return
xMPC_24: ;Pause
    SendInput {Space}
Return
xMPC_25: ;Stop
    SendInput !s
Return


MPC_11:   ;enter
	SendInput {enter}
	return
MPC_14:   ;exit
	SendInput {esc}
	return
MPC_27:   ;menu
	SendInput {alt down}q{alt up}
	SendInput {alt down}x{alt up}
	return
MPC_48:   ;back
	SendInput {alt down}{left}
	sleep, 20
	SendInput {alt up}
	sleep,200
	return
MPC_49:   ;next	
	SendInput {alt down}{right}
	sleep, 20
	SendInput {alt up}
	sleep,200
	return
	
MPC_50:   ;play
	SendInput {space}
	sleep,200
	return
MPC_57:   ;pause
	SendInput {space}
	sleep,200
	return

MPC_51:   ;rewind
	SendInput {ctrl down}{down}{ctrl up}
	sleep,200
	return
MPC_52:   ;ff
	SendInput {ctrl down}{up}{ctrl up}
	sleep,200
	return
MPC_56:   ;stop
	SendInput {alt down}{enter}{alt up}
sleep,200
    return
MPC_83:   ;options
	SendInput {alt down}{enter}{alt up}
	sleep, 200
	return   
MPC_84:   ;info
	;gosub  activateService	
	return
MPC_121:  ;up
	SendInput {up}
	return
MPC_122:  ;down
	SendInput {down}
	return
MPC_123:  ;left
	SendInput {left}
	sleep, 70
	return
MPC_124:  ;right
	SendInput {right}
	sleep, 70
	return


;------------------------------------------
~+f11::
KeyHistory 
Return
;------------------------------------------
+f12::
    Reload
    msgBox reloading
Return




