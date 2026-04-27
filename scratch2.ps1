Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead("c:\Users\ifqoh\OneDrive\Documents\al_heedh\lib\Bacaan Dzikir Pagi.docx")
$entry = $zip.GetEntry("word/document.xml")
$stream = $entry.Open()
$reader = [System.IO.StreamReader]::new($stream)
$xmlStr = $reader.ReadToEnd()
$reader.Close()
$zip.Dispose()
$xml = [xml]$xmlStr
$ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
$ns.AddNamespace("w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main")
$nodes = $xml.SelectNodes("//w:p", $ns)
$output = @()
foreach ($node in $nodes) {
    $texts = $node.SelectNodes(".//w:t", $ns) | ForEach-Object { $_.InnerText }
    if ($texts) { $output += ($texts -join "") }
}
$output | Out-File "c:\Users\ifqoh\OneDrive\Documents\al_heedh\lib\dzikir.txt" -Encoding utf8
