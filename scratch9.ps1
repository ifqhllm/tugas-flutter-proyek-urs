$word = New-Object -ComObject Word.Application
$word.Visible = $false
$pdfPath = "c:\Users\ifqoh\OneDrive\Documents\al_heedh\lib\doa pertama haid.pdf"
$txtPath = "c:\Users\ifqoh\OneDrive\Documents\al_heedh\lib\doa_pertama_haid.txt"
$doc = $word.Documents.Open($pdfPath)
$doc.SaveAs([ref]$txtPath, [ref]2)
$doc.Close()
$word.Quit()
