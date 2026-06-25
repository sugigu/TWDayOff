# HolidayDisplay.ps1
# PowerShell 7

$BaseDir =
    if ($PSScriptRoot) {
        $PSScriptRoot
    }
    else {
        Split-Path -Parent $PSCommandPath
    }

$CacheDir  = Join-Path $BaseDir "cache"
$OutputDir = Join-Path $BaseDir "output"

New-Item -ItemType Directory -Force -Path $CacheDir  | Out-Null
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$CsvPath  = Join-Path $CacheDir "taiwan-holiday.csv"
$MetaPath = Join-Path $CacheDir "meta.json"

$HtmlOut  = Join-Path $OutputDir "dayoff.html"

$CsvUrl = "https://data.ntpc.gov.tw/api/datasets/308dcd75-6434-45bc-a95f-584da4fed251/csv/file"

function Need-Refresh {
    if (!(Test-Path $CsvPath) -or !(Test-Path $MetaPath)) {
        return $true
    }

    try {
        $meta = Get-Content $MetaPath -Raw | ConvertFrom-Json
        return ([int]$meta.Year -ne (Get-Date).Year)
    }
    catch {
        return $true
    }
}

function Update-HolidayCsv {
    Invoke-WebRequest -Uri $CsvUrl -OutFile $CsvPath

    @{
        Year      = (Get-Date).Year
        UpdatedAt = (Get-Date).ToString("s")
        SourceUrl = $CsvUrl
    } | ConvertTo-Json | Set-Content -Path $MetaPath -Encoding UTF8
}

function Get-FieldValue {
    param (
        [object]$Row,
        [string[]]$Names
    )

    foreach ($name in $Names) {
        if ($Row.PSObject.Properties.Name -contains $name) {
            return $Row.$name
        }
    }

    return $null
}

function Parse-TwDate {
    param ([string]$Value)

    $dateText = $Value -replace "\D", ""

    if ($dateText.Length -eq 8) {
        return [datetime]::ParseExact($dateText, "yyyyMMdd", $null)
    }

    throw "無法解析日期：$Value"
}

if (Need-Refresh) {
    Update-HolidayCsv
}

$rows = Import-Csv $CsvPath
$today = (Get-Date).Date

$holidays = foreach ($row in $rows) {
    $dateRaw = Get-FieldValue $row @("date", "日期")
    $name    = Get-FieldValue $row @("name", "節日")
    $isHol   = Get-FieldValue $row @("isholiday", "是否放假")
    $cat     = Get-FieldValue $row @("holidaycategory", "假期分類", "周末假期等")
    $desc    = Get-FieldValue $row @("description", "備註")

    if (!$dateRaw) {
        continue
    }

    $date = Parse-TwDate $dateRaw
    $text = "$name $cat $desc"

    $isHoliday =
        $isHol -in @("2", "是", "Y", "y", "true", "True", "TRUE")

    if (
        $isHoliday -and
        $date -ge $today -and
        $text -notmatch "軍人節"
    ) {
        [pscustomobject]@{
            Date = $date
            Name = if ($name) { $name } elseif ($desc) { $desc } else { $cat }
            Description = $desc
        }
    }
}

$daysToScan = 370
$next = $null

for ($i = 0; $i -le $daysToScan; $i++) {
    $d = $today.AddDays($i)

    $isWeekend =
        $d.DayOfWeek -eq [DayOfWeek]::Saturday -or
        $d.DayOfWeek -eq [DayOfWeek]::Sunday

    $isGovHoliday =
        $holidays |
        Where-Object { $_.Date.Date -eq $d.Date } |
        Select-Object -First 1

    if ($isWeekend -or $isGovHoliday) {
        $next = [pscustomobject]@{
            Date = $d
        }
        break
    }
}

if ($next) {
    $days = ($next.Date - $today).Days

    if ($days -eq 0) {

		$label = "放假"

	}
	else {

		$label = "D-$days"

	}

    $html = "<span>$label</span>"
}
else {
    $label = ""
    $html = "<span></span>"
}

[System.IO.File]::WriteAllText(
    $HtmlOut,
    "<span>$label</span>",
    [System.Text.UTF8Encoding]::new($false)
)

Write-Host $label