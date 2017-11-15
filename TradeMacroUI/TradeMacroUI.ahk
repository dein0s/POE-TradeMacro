#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include, E:\PoE_tools\DEV\POE-TradeMacro\lib\Class_Console.ahk
#Include, E:\PoE_tools\DEV\POE-TradeMacro\lib\EasyIni.ahk
#Include, E:\PoE_tools\DEV\TradeMacroUI\UI_Elements.ahk

; TODO: move tooltips and display names to config_trade.ini

TradeOpts := class_EasyIni("d:\System\Documents\PoE-TradeMacro\dev_refactoring_tradeopts\config_trade.ini")

; _DEBUG := TradeOpts.Debug.Debug
_DEBUG := 1

if (_DEBUG) {
  Class_Console("debug", 70, 0, 1000, 1000, ,0)
  debug.show()
}

TradeMacroUI_Hotkeys()
TradeMacroUI_Cookies()
Gui, Show


; ##################### UI sections

TradeMacroUI_Hotkeys()
{
  Global
  GuiAddGroupBox("[TradeMacro] Hotkeys", "x7 yp+42 w270 h245")
  sectionHotkeys := "Hotkeys"
  sectionHotkeyStates := "HotkeyStates"
  for keyName, keyVal in TradeOpts[sectionHotkeys] {
    GuiAddText(keyName ":", "x17 yp+35 w100 h20 0x0100")
    GuiAddHotkey(keyVal, "x+1 yp-2 w120 h20", sectionHotkeys "_" keyName "_Var", sectionHotkeys "_" keyName "_Hwnd", "UpdateConfigFromUI")
    GuiAddCheckbox("", "x+5 yp-6 w30 h30", TradeOpts[sectionHotkeyStates, keyName], sectionHotkeyStates "_" keyName "_Var", sectionHotkeyStates "_" keyName "_Hwnd", "UpdateConfigFromUI")
  }
  Gui, Add, Link, x17 yp+32 w160 h20 cBlue BackgroundTrans, <a href="http://www.autohotkey.com/docs/Hotkeys.htm">Hotkey Options</a>
  return
}

TradeMacroUI_Cookies()
{
  Global
  GuiAddGroupBox("[TradeMacro] Manual cookie selection", "x7 yp+33 w270 h165")
  sectionCookies := "Cookies"
  for keyName, keyVal in TradeOpts[sectionCookies] {
    if (keyName == "UseManualCookies") {
      GuiAddCheckbox("OVERWRITE DISPLAY NAME", "x17 yp+20 w200 h30", keyVal, sectionCookies "_" keyName "_Var", sectionCookies "_" keyName "_Hwnd", "UpdateConfigFromUI")
    }
    else {
      GuiAddText(keyName, "x17 yp+32 w70 h20 0x0100", "Lbl" sectionCookies "_" keyName "_Var", "Lbl" sectionCookies "_" keyName "_Hwnd")
      GuiAddEdit(keyVal, "x+10 yp-2 w150 h20", sectionCookies "_" keyName "_Var", sectionCookies "_" keyName "_Hwnd", "UpdateConfigFromUI")
    }
  }
  Gui, Add, Link, x17 yp+28 w160 h20 cBlue BackgroundTrans, <a href="https://github.com/PoE-TradeMacro/POE-TradeMacro/wiki/Cookie-retrieval">How to</a>
  return
}

UpdateConfigFromUI:
  GuiControlGet, ControlContent, , %A_GuiControl%
  if (ControlContent) {
    RegExMatch(A_GuiControl, "(^.*?)_(.*?)_", match)
    if (match1 and match2) {
      if (match1 == "Hotkeys") {
        RegExMatch(ControlContent, "[^\#\!\^\+\&\<\>\*\~\$\s]+", validKey)
        if (validKey) {
          TradeOpts[match1, match2] := ControlContent
        }
      }
      else {
        if TradeOpts.HasKey(match1) {
          TradeOpts[match1, match2] := ControlContent
        }
      }
    }
  }
  return
