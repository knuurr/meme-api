# Reference
# Source: https://gist.github.com/warfighter8/2b39d65bfb2140a42e8225b6cc23a380
# Also: https://github.com/GitHub30/toast-notification-examples/blob/main/README.md

Add-Type -Assembly System.Windows.Forms
Add-Type -Assembly System.Drawing

# Push toast notofication
function pushToast($xml) {
    $XmlDocument = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]::New()
    $XmlDocument.loadXml($xml)
    $AppId = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]::CreateToastNotifier($AppId).Show($XmlDocument)

}

# Meme type as positional argument, as defined in INI
$endpoint = $args[0]
Write-Host "Type: $endpoint" 

# Define the INI file data as a hashtable
$iniData = @{
    "dogs" = @{
        "URL" = "https://api.domain.local/meme/cats"
    }
    "cats" = @{
        "URL" = "http://localhost:5000/meme/dogs"
    }
}

# Custom hearders for Invoke-WebRequest - like API key
$headers = @{
    'X-API-KEY' = 'your-api-key'
}

# Uncomment for self-signed cert (like in home lab)

# For PowerShell 6.0.0 > you can use "-SkipCertificateCheck"
# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-webrequest?view=powershell-7.3#-skipcertificatecheck
# taken from https://stackoverflow.com/questions/59924142/powershell-iwr-fails-when-attempting-skipcertificatecheck
# add-type @"
#     using System.Net;
#     using System.Security.Cryptography.X509Certificates;
#     public class TrustAllCertsPolicy : ICertificatePolicy {
#         public bool CheckValidationResult(
#             ServicePoint srvPoint, X509Certificate certificate,
#             WebRequest request, int certificateProblem) {
#             return true;
#         }
#     }
# "@
# [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy


$url = $iniData[$endpoint].URL
Write-Host "Accesed URL: $url"

# Send GET request

### With headers
$response = Invoke-WebRequest -Uri $url -UseBasicParsing -Headers $headers

### Without any headers
# $response = Invoke-WebRequest -Uri $url -UseBasicParsing

# For PowerShell 6.0.0 >= you can use "-SkipCertificateCheck" for self-signed certs
# $response = Invoke-WebRequest -SkipCertificateCheck -Uri $url -UseBasicParsing -Headers $headers

# Fetch the image from the response
$imageBytes = $response.Content


# Check if content size is 0 bytes
if ($response.Content.Length -eq 0) {
    Write-Host "Received content is 0 bytes. Exiting."
    $xml = @"
<toast>
    <visual>
        <binding template="ToastGeneric">
            <text>Failed downloading!</text>
            <text>Received content is 0 bytes. Check mount accessible from container and/or API key</text>
        </binding>
    </visual>
</toast>
"@
        
    pushToast $xml  
    exit
}

# Check if remote URL is inaccessible (status code other than 200)
if ($response.StatusCode -ne 200) {
    Write-Host "Remote URL is inaccessible. Exiting."
    $xml = @"
<toast>
    <visual>
        <binding template="ToastGeneric">
            <text>URL is down!</text>
            <text>Remote URL is inaccessible. Is server up?</text>
        </binding>
    </visual>
</toast>
"@
        
    pushToast $xml
    exit
}


# Generate a random file name
$randomFileName = [System.IO.Path]::GetRandomFileName()
$extension = ".png"
$randomFileName = $randomFileName + $extension

# Construct the full file path in the TEMP directory
$tempDirectory = [System.IO.Path]::GetTempPath()
$tempFilePath = Join-Path -Path $tempDirectory -ChildPath $randomFileName

# Save image to the TEMP directory
[System.IO.File]::WriteAllBytes($tempFilePath, $imageBytes)

# Output TEMP file path to CLI
Write-Output "Image saved to: $tempFilePath"


# Set clipboard content to the TEMP file path
[Windows.Forms.Clipboard]::SetImage($imageBytes)

# Convert image to base64 string
# $base64Image = [System.Convert]::ToBase64String($imageBytes)

# DEBUF
# Open image using Paint
# Start-Process -FilePath "mspaint.exe" -ArgumentList $tempFilePath


$headlineText = 'Meme copied to clipboard!'

$xml = @"
<toast>
    <visual>
        <binding template="ToastGeneric">
            <text>$($headlineText)</text>
            <text>$($tempFilePath)</text>
            <image src="$($tempFilePath)"/>
        </binding>
    </visual>
    <audio silent="true"/>
</toast>
"@
pushToast $xml
exit