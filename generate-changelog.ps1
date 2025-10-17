# EN: Generate detailed changelog from git commits
# CZ: Generování detailního changelogu z git commitů

$commits = git -C "C:\Proj_Net\portal-ui" log --all --after="2025-08-22" --before="2025-09-12" --reverse --format="%ai|%h|%s"

$currentDate = ""
$output = ""

foreach ($commit in $commits) {
    $parts = $commit -split '\|', 3
    $datetime = $parts[0]
    $hash = $parts[1]
    $message = $parts[2]

    $date = $datetime.Substring(0, 10)
    $time = $datetime.Substring(11, 8)

    # Parse date
    $dateParts = $date -split '-'
    $year = $dateParts[0]
    $month = $dateParts[1]
    $day = $dateParts[2]

    $monthName = switch ($month) {
        "08" { "srpna" }
        "09" { "září" }
        default { "?" }
    }

    # Print date header if new
    if ($date -ne $currentDate) {
        if ($currentDate -ne "") {
            $output += "`n"
        }
        $output += "### $day. $monthName $year`n`n"
        $currentDate = $date
    }

    # Print commit
    $output += "**$hash** - $message ($time)`n"
}

$output | Out-File -FilePath "C:\Proj_Net\_ZaPo\portal-ui\ChangeLog\detailed-commits-temp.md" -Encoding UTF8
Write-Host "Generated changelog saved to detailed-commits-temp.md"
Write-Host "Total commits: $($commits.Count)"
