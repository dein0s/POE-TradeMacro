#NoEnv
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
#SingleInstance force
ListLines Off
Process, Priority, , A
SetBatchLines, -1
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1
SendMode Input
; https://autohotkey.com/boards/viewtopic.php?f=6&t=6413


#Include, %A_ScriptDir%\..\lib\Class_Console.ahk

#Include, %A_ScriptDir%\..\lib\EasyIni.ahk
#Include, %A_ScriptDir%\..\lib\JSON.ahk
#Include, %A_ScriptDir%\..\lib\PoEScripts_HandleUserSettings.ahk

;Class_Console(Name,x,y,w,h,GuiTitle:="",Timestamp:=1,HTML:="",Font:="Lucida Console",FontSize:=11)
; init console and show it
Class_Console("debug", 70, 0, 1000, 1000, ,0)
debug.show()

Func_TimeIt(FuncName, ConsoleName="", FuncInfo=true, args*)
{
  if (ConsoleName != "") {
    %ConsoleName%.log("===================START===================")
    if (FuncInfo) {
      ActualFunc := Func(FuncName)
      Func_Properties := "Name,IsBuiltIn,IsVariadic,MinParams,MaxParams"
      loop Parse, Func_Properties, csv
        FuncInfoData .= A_LoopField ":`t" (A_Index<4?"`t":"") ActualFunc[A_LoopField] "`n"
      %ConsoleName%.log("Function info `n" FuncInfoData)
    }
    else {
      %ConsoleName%.log(FuncName)
    }
  }
  FuncParams := IsFunc(FuncName)
  if (FuncParams > 0) {
    FuncParams -= 1
    if (FuncParams == 1) {
      FuncStart := A_TickCount
      %FuncName%(args[1])
      ParamsStr := args[1]
    }
    else {
      FuncStart := A_TickCount
      %FuncName%(args*)
      for argIndex, argVal in args {
        ParamsStr .= argVal "`n"
      }
    }
    FuncEnd := A_TickCount
    FuncTime := FuncEnd - FuncStart
    TimeUnit := (FuncTime < 1000) ? "milliseconds" : "seconds"
    FuncTimeOut := (FuncTime < 1000) ? FuncTime : FuncTime / 1000
    OutStr := Format("Execution of {} took: {} {}", FuncName, FuncTimeOut, TimeUnit)
    if (ConsoleName != "") {
      %ConsoleName%.log("Params `n" ParamsStr)
      %ConsoleName%.log(OutStr)
    }
  }
  if (ConsoleName != "") {
    %ConsoleName%.log("===================END===================")
  }
  return FuncTime
}

PrepareData(ConsoleName="")
{
  FileRemoveDir, %A_ScriptDir%\user_data_to_modify, 1
  FileCopyDir, %A_ScriptDir%\user_data_default, %A_ScriptDir%\user_data_to_modify, 1
  if (ConsoleName != "") {
    %ConsoleName%.log("Modified data reset to the original state")
  }
}


TestResults := {}
Executions := 10
ConsoleName := "debug"
Functions := {"PoEScripts_ConvertItemInfoConfig": [A_ScriptDir "\script_data_default", A_ScriptDir "\user_data_to_modify"]
, "PoEScripts_ConvertAdditionalMacrosSettings": [A_ScriptDir "\user_data_to_modify"]
, "PoEScripts_ConvertMapModsWarnings": [A_ScriptDir "\user_data_to_modify"]
, "PoEScripts_ConvertOldFiles": [A_ScriptDir "\script_data_default", A_ScriptDir "\user_data_to_modify", []]
, "PoEScripts_CopyFiles": [A_ScriptDir "\script_data_default", A_ScriptDir "\user_data_to_modify", ""]}


; execute and log results
loop % Executions {
  for functionName, functionParams in Functions {
    PrepareData()
    TimeItResult := Func_TimeIt(functionName, , , functionParams*)
    if (!TestResults.HasKey(functionName)) {
      TestResults.Insert(functionName, [])
    }
    TestResults[functionName].push(TimeItResult)
  }

  if (A_Index == Executions) {
    %ConsoleName%.clear()
    for functionName, functionResults in TestResults {
      resSum := 0
      resStr := ""
      %ConsoleName%.log("=======================")
      %ConsoleName%.log(functionName)
      for resIndex, resVal in functionResults {
        resSum += resVal
        resStr .= resval " "
      }
      %ConsoleName%.log("Results: " resStr)
      %ConsoleName%.log("Average: " resSum / Executions)
      %ConsoleName%.log("=======================")
    }
  }
}
