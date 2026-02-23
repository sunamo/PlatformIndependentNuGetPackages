$file = 'E:\vs\Projects\PlatformIndependentNuGetPackages\PlatformIndependentNuGetPackages.Runners.slnx'
$content = Get-Content $file -Raw
# Fix folders that have leading slash but no trailing slash: /Name" -> /Name/"
$fixed = [regex]::Replace($content, '<Folder Name="(/[^/"]+)">', { param($m) '<Folder Name="' + $m.Groups[1].Value + '/">' })
Set-Content $file $fixed -NoNewline
