param(
    [string]$docxPath = "lib\doa sesudah adzan.docx",
    [string]$txtPath = "lib\doa_sesudah_adzan.txt"
)

Add-Type -AssemblyName System.IO.Compression.FileSystem

$tempFolder = Join-Path $env:TEMP (New-Guid).ToString()
[System.IO.Compression.ZipFile]::ExtractToDirectory($docxPath, $tempFolder)

$documentXmlPath = Join-Path $tempFolder "word\document.xml"

if (Test-Path $documentXmlPath) {
    [xml]$xml = Get-Content $documentXmlPath
    $paragraphs = $xml.document.body.p
    $text = ""
    foreach ($p in $paragraphs) {
        $runs = $p.r
        $pText = ""
        if ($runs) {
            foreach ($r in $runs) {
                if ($r.t) {
                    if ($r.t -is [string]) {
                        $pText += $r.t
                    } elseif ($r.t.'#text') {
                        $pText += $r.t.'#text'
                    }
                }
            }
        }
        $text += $pText + "`n"
    }
    Set-Content -Path $txtPath -Value $text -Encoding UTF8
    Write-Host "Extracted text saved to $txtPath"
} else {
    Write-Host "document.xml not found inside docx"
}

Remove-Item -Path $tempFolder -Recurse -Force
