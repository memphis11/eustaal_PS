#
#  Erstellung aller neuen Vorraussetzungen für die RDP Verbindung
#
#
#
#              geschrieben von Lars Richter
#


#-----------------------------------------
#-----------------------------------------

#
#
# Kopieren aller Dateien
#
#

# Zielordner lokal
$zielOrdner = "C:\Temp"


# Ordner anlegen, falls er nicht existiert
if (-not (Test-Path $zielOrdner)) {
    New-Item -ItemType Directory -Path $zielOrdner | Out-Null
}


# Datei herunterladen
$zielPfad = "C:\Temp\rds-GW-cert.pfx"
$url = "https://maxicomputergmbh-my.sharepoint.com/:u:/g/personal/richter_maxicomputer_de/EZi-hmXQOhNKpRqp-hNxZGQBSnNybxS1mXO3oN4zhnLyQg?download=1"

$zielPfad1 = "C:\Temp\NEW_RDP.rdp"
$url1 = "https://maxicomputergmbh-my.sharepoint.com/:u:/g/personal/richter_maxicomputer_de/EXIp32hsB0hAs7CwXT7TfvYBZrB4cLFV2a0nJLx24QLYIA?download=1"


Invoke-WebRequest -Uri $url -OutFile $zielPfad -UseBasicParsing
Invoke-WebRequest -Uri $url1 -OutFile $zielPfad1 -UseBasicParsing

# Zertifikat importieren
Import-PfxCertificate -FilePath $zielPfad -CertStoreLocation "Cert:\LocalMachine\Root" -Password (ConvertTo-SecureString -String "Start1234-#" -AsPlainText -Force)


#-----------------------------------------
#-----------------------------------------

#
#
# RDP Datei auf den Desktop kopieren
#
#

# Pfad zum Desktop des aktuellen Benutzers
$desktopPath = [Environment]::GetFolderPath("Desktop")

# Quelldatei
$quelle = "C:\Temp\NEW_RDP.rdp"

# Zieldatei
$ziel = Join-Path -Path $desktopPath -ChildPath "NEW_RDP.rdp"

# Datei kopieren
Copy-Item -Path $quelle -Destination $ziel -Force



#-----------------------------------------
#-----------------------------------------

#
#
# DNS Einträge in die Host Datei setzen
#
#

# Pfad zur Hosts-Datei
$hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"

# Neue DNS-Einträge
$eintraege = @(
    "83.65.244.135    rds-gw.eustaal.local",
    "83.65.244.135    gw.eustaal.com"
)


# Prüfen, ob PowerShell als Admin läuft
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be run as administrator..."
    exit
}

# Einträge hinzufügen, wenn sie noch nicht vorhanden sind
foreach ($eintrag in $eintraege) {
    if (-not (Select-String -Path $hostsPath -Pattern $eintrag -Quiet)) {
        Add-Content -Path $hostsPath -Value $eintrag
        Write-Host "Added: $eintrag"
    } else {
        Write-Host "Already available: $eintrag"
    }
}


#-----------------------------------------
#-----------------------------------------

#
#
# RDP Datei starten
#
#

# Info for User
Write-Host "-------------------------------------------------------"
Write-Host "-------------------------------------------------------"
Write-Host "-------------------------------------------------------"
Write-Host "-------------------------------------------------------"

Write-Host "Please change the username and the IP of the server...:"
Write-Host "`nDatei: $ziel"
Write-Host "`nPress [Enter] to start the Connection..."
Read-Host

# RDP-Datei starten
Start-Process -FilePath $ziel
