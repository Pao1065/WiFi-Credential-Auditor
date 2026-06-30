' Script para ejecutar PowerShell sin mostrar ventana
Set objShell = CreateObject("WScript.Shell")
objShell.Run "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File """ & Replace(WScript.ScriptFullName, WScript.ScriptName, "") & "stealth.ps1""", 0, False