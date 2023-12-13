#Region
#AutoIt3Wrapper_Icon = img\icon.ico
#AutoIt3Wrapper_Res_Icon_Add= img\fav.ico
#AutoIt3Wrapper_OutFile = _Limit time.exe
#AutoIt3Wrapper_Res_Language=1049
#AutoIt3Wrapper_Res_FileVersion=1.1.1.0
#AutoIt3Wrapper_Res_Description= Work time limitation
#AutoIt3Wrapper_Res_ProductVersion=3.9
#AutoIt3Wrapper_Res_LegalCopyright=©2022 Sasha_RSD
#AutoIt3Wrapper_Res_Field=ProductName|Limit time
#AutoIt3Wrapper_Res_Field=OriginalFilename|Limit time.exe
#EndRegion


#include <GUIConstantsEx.au3>
#include <Constants.au3>
#include <DateTimeConstants.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <Date.au3>
#include <Misc.au3>
Opt("TrayMenuMode", 1+2)
TraySetIcon(@ScriptFullPath, -5)
if _Singleton("Limit time",1) = 0 Then Exit TrayTip("Внимание", "Приложение уже запущенно!", 0, 2)


$BoolInverseWork = False
$TextMsBox = "Приложение для ограничения времени!" & @CRLF & "Для этого введите время, в которое нужно завершить работу и нажмите Старт." & @CRLF & "Как только время закончится, то все окна будут свернуты."
;-----------------------------------------------------------------------------------------------------Windows
$mainwindow = GUICreate("Ограничитель", 250, 170)
GUISetFont(10, 700, 0, "Comic Sans MS")
GUICtrlCreateLabel("Время сейчас: ", 10, 10)
GUICtrlCreateLabel("Остановить: ", 10, 32)
GUICtrlCreateLabel("Осталось: ", 10, 55)
$iTimeLeftLabel = GUICtrlCreateLabel("00:00:00", 142, 55, 70, 20)
$iTimeNowLabel = GUICtrlCreateLabel(StringMid(_NowCalc(), 12), 142, 10, 70, 20)
$okbutton = GUICtrlCreateButton("Старт/Пауза", 10, 85, 230, 30)
$idDate = GUICtrlCreateDate("00:00:00", 140, 32, 100, 20, $DTS_TIMEFORMAT)
$sStyle = "HH:mm:ss"

;-----------------------------------------------------------------------------------------------------TRAY
$iShowTray = TrayCreateItem("Показать окно")
TrayCreateItem("")
$iMusicTray = TrayCreateMenu("Музыка")
$iMusicitem0Tray = TrayCreateItem("Standart Sound", $iMusicTray)
$iMusicitem1Tray = TrayCreateItem("Песня 1", $iMusicTray)
$iMusicitem2Tray = TrayCreateItem("Песня 2", $iMusicTray)
$iMusicitem3Tray = TrayCreateItem("Песня 3", $iMusicTray)
$iMusicitem4Tray = TrayCreateItem("Песня 4", $iMusicTray)
$iMusicitem5Tray = 0

TrayCreateItem("")
$iHelpMenuTray = TrayCreateItem("Помощь")
$iInfoItemTray = TrayCreateItem("О разработчике")
TrayCreateItem("")
$iExitTray = TrayCreateItem("Exit")

;-----------------------------------------------------------------------------------------------------Menu
$iFileMenu = GUICtrlCreateMenu("&Настройки")
$iMusic= GUICtrlCreateMenu("Музыка", $iFileMenu, 1)
GUICtrlCreateMenuItem("", $iFileMenu, 1)
$iExit = GUICtrlCreateMenuItem("Выход", $iFileMenu)

$iHelpMenu = GUICtrlCreateMenu("Информация")
$iHelpItem = GUICtrlCreateMenuItem("Помощь", $iHelpMenu)
$iInfoItem = GUICtrlCreateMenuItem("О разработчике", $iHelpMenu)

$iMusicitem0 = GUICtrlCreateMenuItem("Standart Sound", $iMusic, -1, 1)
$iMusicitem1 = GUICtrlCreateMenuItem("Песня 1", $iMusic, -1, 1)
$iMusicitem2 = GUICtrlCreateMenuItem("Песня 2", $iMusic, -1, 1)
$iMusicitem3 = GUICtrlCreateMenuItem("Песня 3", $iMusic, -1, 1)
$iMusicitem4 = GUICtrlCreateMenuItem("Песня 4", $iMusic, -1, 1)
$iMusicitem5 = 0

;-----------------------------------------------------------------------------------------------------StatusBar
$iStatusBar1 = GUICtrlCreateLabel('Активно', 0, 125, 250, 25, BitOR($SS_SIMPLE, $SS_SUNKEN))
$iStatusBar0 = GUICtrlCreateLabel('Ожидание запуска', 0, 125, 250, 25, BitOR($SS_SIMPLE, $SS_SUNKEN))
$RedWork = GUICtrlCreateGraphic(225, 130)
GUICtrlSetGraphic(-1, $GUI_GR_COLOR, 0x000000, 0xff0000)
GUICtrlSetGraphic(-1, $GUI_GR_ELLIPSE, 0, 0, 15, 15)

;-----------------------------------------------------------------------------------------------------Registry
Local $PathStart = RegRead("HKEY_CURRENT_USER\SOFTWARE\Limiter_Settings", "PathMusicReg")
Local $NumSoundStart = RegRead("HKEY_CURRENT_USER\SOFTWARE\Limiter_Settings", "MusicNum")
If Not $NumSoundStart or Not $PathStart Then
	RegWrite("HKEY_CURRENT_USER\Software\Limiter_Settings", "MusicNum", "REG_DWORD", 0)
	RegWrite("HKEY_CURRENT_USER\Software\Limiter_Settings", "PathMusicReg", "REG_MULTI_SZ", "")
EndIf


If $NumSoundStart = 5 And FileExists($PathStart) Then
	Local $name = StringRegExp($PathStart, '\\([^\\]+)$' ,1)[0]
	Global $iMusicitem5 = GUICtrlCreateMenuItem($name, $iMusic, 1, 1)
	Global $iMusicitem5Tray = TrayCreateItem($name, $iMusicTray, 1)
	TrayItemSetState($iMusicitem5Tray, $TRAY_DEFAULT)
Else
	If $NumSoundStart = 5 Then
		RegWrite("HKEY_CURRENT_USER\Software\Limiter_Settings", "MusicNum", "REG_DWORD", 0)
		RegWrite("HKEY_CURRENT_USER\Software\Limiter_Settings", "PathMusicReg", "REG_MULTI_SZ", "")
	EndIf
	Global $iMusicitem5 = GUICtrlCreateMenuItem("Добавить...", $iMusic, 1, 1)
	Global $iMusicitem5Tray = TrayCreateItem("Добавить...", $iMusicTray, 1)
	TrayItemSetState($iMusicitem5Tray, BitOR($TRAY_FOCUS, $TRAY_DEFAULT))
	GUICtrlSetState($iMusicitem5, $GUI_FOCUS)
EndIf

;-----------------------------------------------------------------------------------------------------Main
MunuItemBox()
GUISetState(@SW_SHOW, $mainwindow)
GUICtrlSendMsg($idDate, $DTM_SETFORMATW, 0, $sStyle)
$startTimer=TimerInit()
SoundSetWaveVolume(100)

While 1
	Local $messageGUI = GUIGetMsg()
	Local $messageTray = TrayGetMsg()
	Select
		Case $iMusicitem0 = $messageGUI or $iMusicitem0Tray = $messageTray
			RegWrite("HKEY_CURRENT_USER\Software\Limiter_Settings", "MusicNum", "REG_DWORD", 0)
			RegWrite("HKEY_CURRENT_USER\Software\Limiter_Settings", "PathMusicReg", "REG_MULTI_SZ", "")
			PlayMusicNum()
		Case $iMusicitem1 = $messageGUI or $iMusicitem1Tray = $messageTray
			RegWrite("HKEY_CURRENT_USER\Software\Limiter_Settings", "MusicNum", "REG_DWORD", 1)
			PlayMusicNum()
		Case $iMusicitem2 = $messageGUI or $iMusicitem2Tray = $messageTray
			RegWrite("HKEY_CURRENT_USER\Software\Limiter_Settings", "MusicNum", "REG_DWORD", 2)
			PlayMusicNum()
		Case $iMusicitem3 = $messageGUI or $iMusicitem3Tray = $messageTray
			RegWrite("HKEY_CURRENT_USER\Software\Limiter_Settings", "MusicNum", "REG_DWORD", 3)
			PlayMusicNum()
		Case  $iMusicitem4 = $messageGUI or $iMusicitem4Tray = $messageTray
			RegWrite("HKEY_CURRENT_USER\Software\Limiter_Settings", "MusicNum", "REG_DWORD", 4)
			PlayMusicNum()
		Case  $iMusicitem5 = $messageGUI or $iMusicitem5Tray = $messageTray
			SetMusic()

		Case $okbutton = $messageGUI
			InverseWork()
		Case $iHelpItem = $messageGUI or $iHelpMenuTray = $messageTray
			MsgBox(64, "Помощь", $TextMsBox, 0, $mainwindow)
		Case $iInfoItem = $messageGUI or $iInfoItemTray = $messageTray
            InfoAboutWindow()

		Case $iShowTray = $messageTray
            GUISetState(@SW_SHOWNORMAL  , $mainwindow)
			If Not WinActive($mainwindow) Then WinActivate($mainwindow)
		Case $GUI_EVENT_CLOSE = $messageGUI
			GUISetState(@SW_HIDE and @SW_DISABLE, $mainwindow)
		Case $iExit = $messageGUI or  $iExitTray = $messageTray
			ExitLoop
	EndSelect

	If Ceiling(TimerDiff($startTimer))>1000 And Not WinExists("[TITLE:About; CLASS:AutoIt v3 GUI]") Then
		$startTimer=TimerInit()
		Local $NeedT = TimeCalculation()
		Local $NowT = StringMid(_NowCalc(), 12)

		GUICtrlDelete($iTimeNowLabel)
		GUICtrlDelete($iTimeLeftLabel)
		Global $iTimeNowLabel = GUICtrlCreateLabel($NowT, 142, 10, 70, 20)
		Global $iTimeLeftLabel = GUICtrlCreateLabel($NeedT, 142, 55, 70, 20)

		If (GUICtrlRead($idDate) == $NowT And $BoolInverseWork) Then
			While TimeEnd() <> 1
			Sleep(10)
			WEnd
		EndIf
	EndIf
	Sleep(10)
WEnd
GUIDelete()


Func TimeCalculation()
	Local $aMyTimeNow,$aMyDate
	Local $aTimeNeed = GUICtrlRead($idDate)
	_DateTimeSplit(_NowCalc(), $aMyDate, $aMyTimeNow)
	If $aMyTimeNow[1] < 10 Then $aMyTimeNow[1] = '0' & $aMyTimeNow[1]
	If $aMyTimeNow[2] < 10 Then $aMyTimeNow[2] = '0' & $aMyTimeNow[2]
	If $aMyTimeNow[3] < 10 Then $aMyTimeNow[3] = '0' & $aMyTimeNow[3]

	Local $UnitHour = Int(StringMid($aTimeNeed, 1, 1) & StringMid($aTimeNeed, 2, 1)) - Int($aMyTimeNow[1])
	Local $UnitMin = Int(StringMid($aTimeNeed, 4, 1) & StringMid($aTimeNeed, 5, 1)) - Int($aMyTimeNow[2])
	Local $UnitSec = Int(StringMid($aTimeNeed, 7, 1) & StringMid($aTimeNeed, 8, 1)) - Int($aMyTimeNow[3])

	If ($UnitSec < 0) Then
		$UnitMin = $UnitMin - 1
		$UnitSec = 60 + $UnitSec
	EndIf

	If ($UnitMin < 0) Then
		$UnitHour = $UnitHour - 1
		$UnitMin = 60 + $UnitMin
	EndIf

	If ($UnitHour < 0) Then
		$UnitHour = 24 + $UnitHour
	EndIf

	If $UnitSec < 10 Then $UnitSec = '0' & $UnitSec
	If $UnitMin < 10 Then $UnitMin = '0' & $UnitMin
	If $UnitHour < 10 Then $UnitHour = '0' & $UnitHour
	Return $UnitHour& ':' &$UnitMin& ':' &$UnitSec
EndFunc


Func TimeEnd()
	Local $EndT = _NowCalc()
	PlayMusicNum()
	Sleep(4000)
	WinMinimizeAll()
	Sleep(1000)

	Local $EndData = EndWindow()
	GUISetState(@SW_ENABLE and @SW_SHOW , $mainwindow)
	WinSetState($mainwindow, "", @SW_RESTORE )
	If $EndData[1] = $GUI_EVENT_CLOSE Then
		InverseWork()
	Else
		GUICtrlDelete($idDate)
		Local $NewTime = _DateAdd( 'n ', $EndData[0], $EndT)
		Global $idDate = GUICtrlCreateDate(StringMid($NewTime,12), 140, 32, 100, 20, $DTS_TIMEFORMAT)
		GUICtrlSendMsg($idDate, $DTM_SETFORMATW, 0, $sStyle)
	EndIf

	Return 1
EndFunc


Func PlayMusicNum()
	Local $MusicNumPlay = RegRead("HKEY_CURRENT_USER\SOFTWARE\Limiter_Settings", "MusicNum")
	Switch $MusicNumPlay
		Case 0
			StandartSound()
		Case 1, 2, 3, 4
			Local $NumSong = $MusicNumPlay + 1
			Local $PathLocal = @WindowsDir & "\media\Alarm0"& $NumSong &".wav"

			If FileExists($PathLocal) Then
				RegWrite("HKEY_CURRENT_USER\Software\Limiter_Settings", "PathMusicReg", "REG_MULTI_SZ", $PathLocal)
				SoundPlay($PathLocal, 0)
			Else
				Switch $MusicNumPlay
					Case 1
						GUICtrlSetState($iMusicitem1, $GUI_DISABLE)
						TrayItemSetState($iMusicitem1Tray, $TRAY_DISABLE)
					Case 2
						GUICtrlSetState($iMusicitem2, $GUI_DISABLE)
						TrayItemSetState($iMusicitem2Tray, $TRAY_DISABLE)
					Case 3
						GUICtrlSetState($iMusicitem3, $GUI_DISABLE)
						TrayItemSetState($iMusicitem3Tray, $TRAY_DISABLE)
					Case 4
						GUICtrlSetState($iMusicitem4, $GUI_DISABLE)
						TrayItemSetState($iMusicitem4Tray, $TRAY_DISABLE)
				EndSwitch
				RegWrite("HKEY_CURRENT_USER\Software\Limiter_Settings", "MusicNum", "REG_DWORD", 0)
				RegWrite("HKEY_CURRENT_USER\Software\Limiter_Settings", "PathMusicReg", "REG_MULTI_SZ", "")
				StandartSound()
			EndIf
		Case 5
			Local $PathLocal = RegRead("HKEY_CURRENT_USER\SOFTWARE\Limiter_Settings", "PathMusicReg")
			If FileExists($PathLocal) Then
				SoundPlay($PathLocal, 0)
				Sleep(3000)
				SoundPlay("")
			Else
				RegWrite("HKEY_CURRENT_USER\Software\Limiter_Settings", "MusicNum", "REG_DWORD", 0)
				RegWrite("HKEY_CURRENT_USER\Software\Limiter_Settings", "PathMusicReg", "REG_MULTI_SZ", "")
				StandartSound()
			EndIf
	EndSwitch
	Local $MusicNumNot5 = RegRead("HKEY_CURRENT_USER\SOFTWARE\Limiter_Settings", "MusicNum")
	Switch $MusicNumNot5
		Case 0, 1, 2, 3, 4
			GUICtrlSetData($iMusicitem5, "Добавить...")
			TrayItemSetText($iMusicitem5Tray, "Добавить...")
			GUICtrlSetState($iMusicitem5, $GUI_FOCUS)
			TrayItemSetState($iMusicitem5Tray, $TRAY_FOCUS)
	EndSwitch
	MunuItemBox()
EndFunc


Func SetMusic()
	$PathMusicReg = FileOpenDialog("Открыть", @DesktopDir & "\", "Музыка (*.wav;*.mp3)", 1 + 2)
	If Not @error Then
		RegWrite("HKEY_CURRENT_USER\Software\Limiter_Settings", "PathMusicReg", "REG_MULTI_SZ", $PathMusicReg)
		RegWrite("HKEY_CURRENT_USER\Software\Limiter_Settings", "MusicNum", "REG_DWORD", 5)
		Local $NameMusic5 = StringRegExp( $PathMusicReg, '\\([^\\]+)$' ,1)[0]
		GUICtrlSetData($iMusicitem5, $NameMusic5)
		GUICtrlSetState($iMusicitem5, $GUI_NOFOCUS)
		TrayItemSetText($iMusicitem5Tray, $NameMusic5)
		TrayItemSetState($iMusicitem5Tray, $TRAY_DEFAULT)

		SoundPlay($PathMusicReg, 0)
		Sleep(3000)
		SoundPlay("")
	EndIf
	MunuItemBox()
EndFunc


Func InverseWork()
	If($BoolInverseWork = False) Then
		GUICtrlDelete($iStatusBar0)
		$iStatusBar1 = GUICtrlCreateLabel('Активно', 0, 125, 250, 25, BitOR($SS_SIMPLE, $SS_SUNKEN))
		$GreenWork = GUICtrlCreateGraphic(225, 130)
		GUICtrlSetGraphic(-1, $GUI_GR_COLOR, 0x000000, 0x00ff00)
		GUICtrlSetGraphic(-1, $GUI_GR_ELLIPSE, 0, 0, 15, 15)
	Else
		GUICtrlDelete($iStatusBar1)
		$iStatusBar0 = GUICtrlCreateLabel('Ожидание запуска', 0, 125, 250, 25, BitOR($SS_SIMPLE, $SS_SUNKEN))
		$RedWork = GUICtrlCreateGraphic(225, 130)
		GUICtrlSetGraphic(-1, $GUI_GR_COLOR, 0x000000, 0xff0000)
		GUICtrlSetGraphic(-1, $GUI_GR_ELLIPSE, 0, 0, 15, 15)
	EndIf

	$BoolInverseWork = Not $BoolInverseWork
EndFunc


Func InfoAboutWindow()
	Local $about = GuiCreate("About", 210 ,110 ,-1 ,-1, BitOR($WS_CAPTION,$WS_SYSMENU))
	GUICtrlCreateLabel ("Time limiter 1.0", 50 ,11 ,135 ,20 )
	GUICtrlSetFont (-1,10, 800, 0, "Arial")

	GUICtrlCreateLabel ("(c) SashaRSD 2022" ,50,30,135,40)
	Local $email = GUICtrlCreateLabel ("kaa.99@yandex.ru",50,50,135,15)
	GuiCtrlSetFont($email, 9, -1, 4)
	GuiCtrlSetColor($email,0x0000ff)

	Local $www = GUICtrlCreateLabel ("https://github.com/sashaRSD", 20, 75, 190, 15)
	GuiCtrlSetFont($www, 10, -1, 4)
	GuiCtrlSetColor($www,0x0000ff)
	GuiCtrlSetCursor($www,0)

	GUISetState(@SW_SHOW, $about)
	While 1
		Switch GUIGetMsg()
			Case $www
				Run(@ComSpec & " /c " & 'start '& GUICtrlRead($www), "", @SW_HIDE)
				ExitLoop
			Case $GUI_EVENT_CLOSE
				ExitLoop
		EndSwitch
	WEnd
	GUIDelete($about)
EndFunc


Func EndWindow()
	Local $endwin=GUICreate("AddTime", 220, 100)
	GUISetFont(10, 700, 0, "Comic Sans MS")

	GUICtrlCreateLabel("Добавить ", 10, 12, 60, 20)
	Local $HinpDES = GUICtrlCreateInput("1", 75, 10, 40, 20, 0x0800)
	GUICtrlCreateUpdown(-1)
	GUICtrlSetLimit(-1, 9, 0)

	Local $HinpED = GUICtrlCreateInput("5", 115, 10, 40, 20, 0x0800)
	GUICtrlCreateUpdown(-1)
	GUICtrlSetLimit(-1, 9, 0)
	GUICtrlCreateLabel(" минут?", 160, 12, 60, 20)

	Local $ButtonEnd = GUICtrlCreateButton("Да", 10, 60, 200)

	GUISetState(@SW_SHOW, $endwin)
	While 1
		$command = GUIGetMsg()
		If $command = $ButtonEnd Or $command = $GUI_EVENT_CLOSE Then
			ExitLoop
		EndIf
	WEnd
	Local $AddMin= (GUICtrlRead($HinpDES) *10) + GUICtrlRead($HinpED)
	GUIDelete($endwin)

	Local $EndData = [$AddMin, $command]
	Return $EndData
EndFunc


Func StandartSound()
	Beep(500, 500)
	Beep(500, 500)
	Beep(500, 1000)
EndFunc


Func MunuItemBox()
	Switch RegRead("HKEY_CURRENT_USER\SOFTWARE\Limiter_Settings", "MusicNum")
		Case 0
			;--------------------------------------------------------->
			GUICtrlSetState($iMusicitem0, $GUI_CHECKED)
			TrayItemSetState($iMusicitem0Tray, $TRAY_CHECKED )
			;--------------------------------------------------------->
			GUICtrlSetState($iMusicitem1, $GUI_UNCHECKED)
			GUICtrlSetState($iMusicitem2, $GUI_UNCHECKED)
			GUICtrlSetState($iMusicitem3, $GUI_UNCHECKED)
			GUICtrlSetState($iMusicitem4, $GUI_UNCHECKED)
			GUICtrlSetState($iMusicitem5, $GUI_UNCHECKED)
			TrayItemSetState($iMusicitem1Tray, $TRAY_UNCHECKED)
			TrayItemSetState($iMusicitem2Tray, $TRAY_UNCHECKED)
			TrayItemSetState($iMusicitem3Tray, $TRAY_UNCHECKED)
			TrayItemSetState($iMusicitem4Tray, $TRAY_UNCHECKED)
			TrayItemSetState($iMusicitem5Tray, $TRAY_UNCHECKED)
		Case 1
			;--------------------------------------------------------->
			TrayItemSetState($iMusicitem1Tray, $TRAY_CHECKED )
			GUICtrlSetState($iMusicitem1, $GUI_CHECKED)
			;--------------------------------------------------------->
			GUICtrlSetState($iMusicitem0, $GUI_UNCHECKED)
			GUICtrlSetState($iMusicitem2, $GUI_UNCHECKED)
			GUICtrlSetState($iMusicitem3, $GUI_UNCHECKED)
			GUICtrlSetState($iMusicitem4, $GUI_UNCHECKED)
			GUICtrlSetState($iMusicitem5, $GUI_UNCHECKED)
			TrayItemSetState($iMusicitem0Tray, $TRAY_UNCHECKED)
			TrayItemSetState($iMusicitem2Tray, $TRAY_UNCHECKED)
			TrayItemSetState($iMusicitem3Tray, $TRAY_UNCHECKED)
			TrayItemSetState($iMusicitem4Tray, $TRAY_UNCHECKED)
			TrayItemSetState($iMusicitem5Tray, $TRAY_UNCHECKED)
		Case 2
			;--------------------------------------------------------->
			TrayItemSetState($iMusicitem2Tray, $TRAY_CHECKED )
			GUICtrlSetState($iMusicitem2, $GUI_CHECKED)
			;--------------------------------------------------------->
			GUICtrlSetState($iMusicitem0, $GUI_UNCHECKED)
			GUICtrlSetState($iMusicitem1, $GUI_UNCHECKED)
			GUICtrlSetState($iMusicitem3, $GUI_UNCHECKED)
			GUICtrlSetState($iMusicitem4, $GUI_UNCHECKED)
			GUICtrlSetState($iMusicitem5, $GUI_UNCHECKED)
			TrayItemSetState($iMusicitem0Tray, $TRAY_UNCHECKED)
			TrayItemSetState($iMusicitem1Tray, $TRAY_UNCHECKED)
			TrayItemSetState($iMusicitem3Tray, $TRAY_UNCHECKED)
			TrayItemSetState($iMusicitem4Tray, $TRAY_UNCHECKED)
			TrayItemSetState($iMusicitem5Tray, $TRAY_UNCHECKED)
		Case 3
			;--------------------------------------------------------->
			TrayItemSetState($iMusicitem3Tray, $TRAY_CHECKED )
			GUICtrlSetState($iMusicitem3, $GUI_CHECKED)
			;--------------------------------------------------------->
			GUICtrlSetState($iMusicitem0, $GUI_UNCHECKED)
			GUICtrlSetState($iMusicitem1, $GUI_UNCHECKED)
			GUICtrlSetState($iMusicitem2, $GUI_UNCHECKED)
			GUICtrlSetState($iMusicitem4, $GUI_UNCHECKED)
			GUICtrlSetState($iMusicitem5, $GUI_UNCHECKED)
			TrayItemSetState($iMusicitem0Tray, $TRAY_UNCHECKED)
			TrayItemSetState($iMusicitem1Tray, $TRAY_UNCHECKED)
			TrayItemSetState($iMusicitem2Tray, $TRAY_UNCHECKED)
			TrayItemSetState($iMusicitem4Tray, $TRAY_UNCHECKED)
			TrayItemSetState($iMusicitem5Tray, $TRAY_UNCHECKED)
		Case 4
			;--------------------------------------------------------->
			TrayItemSetState($iMusicitem4Tray, $TRAY_CHECKED )
			GUICtrlSetState($iMusicitem4, $GUI_CHECKED)
			;--------------------------------------------------------->
			GUICtrlSetState($iMusicitem0, $GUI_UNCHECKED)
			GUICtrlSetState($iMusicitem1, $GUI_UNCHECKED)
			GUICtrlSetState($iMusicitem2, $GUI_UNCHECKED)
			GUICtrlSetState($iMusicitem3, $GUI_UNCHECKED)
			GUICtrlSetState($iMusicitem5, $GUI_UNCHECKED)
			TrayItemSetState($iMusicitem0Tray, $TRAY_UNCHECKED)
			TrayItemSetState($iMusicitem1Tray, $TRAY_UNCHECKED)
			TrayItemSetState($iMusicitem2Tray, $TRAY_UNCHECKED)
			TrayItemSetState($iMusicitem3Tray, $TRAY_UNCHECKED)
			TrayItemSetState($iMusicitem5Tray, $TRAY_UNCHECKED)
		Case 5
			;--------------------------------------------------------->
			TrayItemSetState($iMusicitem5Tray, $TRAY_CHECKED )
			GUICtrlSetState($iMusicitem5, $GUI_CHECKED)
			;--------------------------------------------------------->
			GUICtrlSetState($iMusicitem0, $GUI_UNCHECKED)
			GUICtrlSetState($iMusicitem1, $GUI_UNCHECKED)
			GUICtrlSetState($iMusicitem2, $GUI_UNCHECKED)
			GUICtrlSetState($iMusicitem3, $GUI_UNCHECKED)
			GUICtrlSetState($iMusicitem4, $GUI_UNCHECKED)
			TrayItemSetState($iMusicitem0Tray, $TRAY_UNCHECKED)
			TrayItemSetState($iMusicitem1Tray, $TRAY_UNCHECKED)
			TrayItemSetState($iMusicitem2Tray, $TRAY_UNCHECKED)
			TrayItemSetState($iMusicitem3Tray, $TRAY_UNCHECKED)
			TrayItemSetState($iMusicitem4Tray, $TRAY_UNCHECKED)
	EndSwitch
EndFunc