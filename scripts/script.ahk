; Define the key bind (Ctrl+Alt+P)
^!p::
    ; Specify the path to the PowerShell script
    scriptPath := ".\fetch_image.ps1"
    
    ; Run the PowerShell script
    ; RunWait, powershell.exe -ExecutionPolicy Bypass -WindowStyle Minimized -File "%scriptPath% cats
    RunWait, powershell.exe -ExecutionPolicy Bypass -Command "%scriptPath% cats"
    
    ; Return to the AHK script
    return

; Define the key bind (Ctrl+Alt+[)
^![::
    ; Specify the path to the PowerShell script
    scriptPath := ".\fetch_image.ps1"
    
    ; Run the PowerShell script
    RunWait, powershell.exe -ExecutionPolicy Bypass -WindowStyle Minimized -Command "%scriptPath% dogs"
    
    ; Return to the AHK script
    return
