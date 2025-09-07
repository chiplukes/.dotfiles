#debloate/remove apps
Write-Output "Removing Unwanted Apps"
$apps = @(
      @{name = "Microsoft.Microsoft3DViewer"},
      @{name = "Microsoft.AppConnector"},
      @{name = "Microsoft.BingFinance"},
      @{name = "Microsoft.BingNews"},
      @{name = "Microsoft.BingSports"},
      @{name = "Microsoft.BingTranslator"},
      @{name = "Microsoft.BingWeather"},
      @{name = "Microsoft.BingFoodAndDrink"},
      @{name = "Microsoft.BingHealthAndFitness"},
      @{name = "Microsoft.BingTravel"},
      @{name = "Microsoft.GamingServices"},
      @{name = "Microsoft.GetHelp"},
      @{name = "Microsoft.Getstarted"},
      @{name = "Microsoft.Messaging"},
      @{name = "Microsoft.Microsoft3DViewer"},
      @{name = "Microsoft.MicrosoftSolitaireCollection"},
      @{name = "Microsoft.NetworkSpeedTest"},
      @{name = "Microsoft.News"},
      @{name = "Microsoft.Office.Lens"},
      @{name = "Microsoft.Office.Sway"},
      @{name = "Microsoft.Office.OneNote"},
      @{name = "Microsoft.OneConnect"},
      @{name = "Microsoft.People"},
      @{name = "Microsoft.Print3D"},
      @{name = "Microsoft.SkypeApp"},
      @{name = "Microsoft.Wallet"},
      @{name = "Microsoft.Whiteboard"},
      @{name = "Microsoft.WindowsAlarms"},
      @{name = "microsoft.windowscommunicationsapps"},
      @{name = "Microsoft.WindowsFeedbackHub"},
      @{name = "Microsoft.WindowsMaps"},
      @{name = "Microsoft.WindowsPhone"},
      @{name = "Microsoft.WindowsSoundRecorder"},
      @{name = "Microsoft.XboxApp"},
      @{name = "Microsoft.ConnectivityStore"},
      @{name = "Microsoft.CommsPhone"},
      @{name = "Microsoft.ScreenSketch"},
      @{name = "Microsoft.Xbox.TCUI"},
      @{name = "Microsoft.XboxGameOverlay"},
      @{name = "Microsoft.XboxGameCallableUI"},
      @{name = "Microsoft.XboxSpeechToTextOverlay"},
      @{name = "Microsoft.MixedReality.Portal"},
      @{name = "Microsoft.XboxIdentityProvider"},
      @{name = "Microsoft.ZuneMusic"},
      @{name = "Microsoft.ZuneVideo"},
      @{name = "Microsoft.Getstarted"},
      @{name = "Microsoft.MicrosoftOfficeHub"},
      @{name = "*EclipseManager*"},
      @{name = "*ActiproSoftwareLLC*"},
      @{name = "*AdobeSystemsIncorporated.AdobePhotoshopExpress*"},
      @{name = "*Duolingo-LearnLanguagesforFree*"},
      @{name = "*PandoraMediaInc*"},
      @{name = "*CandyCrush*"},
      @{name = "*BubbleWitch3Saga*"},
      @{name = "*Wunderlist*"},
      @{name = "*Flipboard*"},
      @{name = "*Twitter*"},
      @{name = "*Facebook*"},
      @{name = "*Royal Revolt*"},
      @{name = "*Sway*"},
      @{name = "*Speed Test*"},
      @{name = "*Dolby*"},
      @{name = "*ACGMediaPlayer*"},
      @{name = "*Netflix*"},
      @{name = "*OneCalendar*"},
      @{name = "*LinkedInforWindows*"},
      @{name = "*HiddenCityMysteryofShadows*"},
      @{name = "*Hulu*"},
      @{name = "*HiddenCity*"},
      @{name = "*AdobePhotoshopExpress*"},
      @{name = "*HotspotShieldFreeVPN*"},
      @{name = "*Microsoft.Advertising.Xaml*"}
);
Foreach ($app in $apps)
{
  #Write-host "Uninstalling:" $app
  #Get-AppxPackage -allusers $app | Remove-AppxPackage

    Try{
        Write-Host "Removing :" $app.name
        Get-AppxPackage "*$app.name*" | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like "*$app.name*" | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    }
    Catch [System.Exception] {
        if($psitem.Exception.Message -like "*The requested operation requires elevation*"){
            Write-Warning "Unable to uninstall $app.name due to a Security Exception"
        }
        Else{
            Write-Warning "Unable to uninstall $app.name due to unhandled exception"
            Write-Warning $psitem.Exception.StackTrace
        }
    }
    Catch{
        Write-Warning "Unable to uninstall $app.name due to unhandled exception"
        Write-Warning $psitem.Exception.StackTrace
    }
}




# Windows Registry Tweaks
Write-Output "Applying Windows registry tweaks..."

try {
    # Restore Windows 10 context menu (disable Windows 11 context menu)
    Write-Output "Restoring Windows 10 context menu..."
    $ContextMenuPath = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
    if (-not (Test-Path $ContextMenuPath)) {
        New-Item -Path $ContextMenuPath -Force | Out-Null
    }
    Set-ItemProperty -Path $ContextMenuPath -Name "(Default)" -Value "" -Force

    Write-Output "Windows 10 context menu restored"
}
catch {
    Write-Warning "Failed to restore Windows 10 context menu: $($_.Exception.Message)"
}

try {
    # Show file extensions
    Write-Output "Enabling file extensions in Explorer..."
    $RegistryPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    $Name = 'HideFileExt'
    $Value = 0

    # Create the key if it does not exist
    if (-not (Test-Path $RegistryPath)) {
        New-Item -Path $RegistryPath -Force | Out-Null
    }

    # Set the value
    Set-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -Type DWord -Force
    Write-Output "File extensions enabled in Explorer"
}
catch {
    Write-Warning "Failed to enable file extensions: $($_.Exception.Message)"
}

try {
    # Use UTC time (needed for dual booting with Linux)
    Write-Output "Setting hardware clock to use UTC time..."
    $RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation'
    $Name = 'RealTimeIsUniversal'
    $Value = 1

    # Create the key if it does not exist
    if (-not (Test-Path $RegistryPath)) {
        New-Item -Path $RegistryPath -Force | Out-Null
    }

    # Set the value
    Set-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -Type DWord -Force
    Write-Output "Hardware clock set to UTC time"
}
catch {
    Write-Warning "Failed to set UTC time: $($_.Exception.Message)"
}

Write-Output "Registry tweaks completed"
