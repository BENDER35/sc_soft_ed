<#
.SYNOPSIS
Instalador de software educativo para Windows / Educational software installer for Windows.
Usa winget (Microsoft Store incluido), Chocolatey, Scoop y pacman de MSYS2.
.DESCRIPTION
Uso: .\install.ps1 [-DryRun] [-AllStores] [-Stores winget,choco] [-Group core|extra|all] [-Yes]
#>
param(
    [switch]$DryRun,
    [switch]$AllStores,
    [string]$Stores = "",
    [ValidateSet("core", "extra", "all")][string]$Group = "core",
    [switch]$Yes,
    [switch]$ListStores
)

$ErrorActionPreference = "Continue"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Catalog = Join-Path $Root "catalog/packages.tsv"
$AppsFile = Join-Path $Root "catalog/apps.tsv"

function Log($msg)  { Write-Host "[soft_ed] $msg" -ForegroundColor Cyan }
function Warn($msg) { Write-Host "[aviso]  $msg" -ForegroundColor Yellow }
function Fail($msg) { Write-Host "[error]  $msg" -ForegroundColor Red }

function Invoke-Step([string[]]$Arguments) {
    if ($DryRun) { Write-Host "  DRY: $($Arguments -join ' ')"; return $true }
    try {
        & $Arguments[0] @($Arguments[1..($Arguments.Count - 1)])
        return ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE)
    } catch {
        Fail $_.Exception.Message
        return $false
    }
}

if (-not (Test-Path $Catalog) -or -not (Test-Path $AppsFile)) {
    Fail "No se encuentran los archivos del catálogo en $Root"
    exit 1
}

$available = @()
foreach ($c in @(@("winget", "winget"), @("choco", "choco"), @("scoop", "scoop"), @("msys2", "pacman"))) {
    if (Get-Command $c[1] -ErrorAction SilentlyContinue) { $available += $c[0] }
}
if ($ListStores) { Log "Tiendas detectadas: $($available -join ', ')"; exit 0 }
if ($available.Count -eq 0) { Fail "No se detectó winget, Chocolatey, Scoop ni MSYS2"; exit 1 }
Log "Tiendas detectadas: $($available -join ', ')"

$selected = @()
if ($Stores -ne "") {
    foreach ($w in ($Stores -split ",")) {
        $w = $w.Trim()
        if ($available -contains $w) { $selected += $w } else { Warn "La tienda '$w' no está disponible" }
    }
} elseif ($AllStores) {
    $selected = $available
} else {
    $selected += @("winget", "choco", "scoop", "msys2") | Where-Object { $available -contains $_ }
}

# Catálogo de aplicaciones permitidas
$allowed = @{}
foreach ($line in (Get-Content $AppsFile)) {
    if ($line -match '^\s*#' -or [string]::IsNullOrWhiteSpace($line)) { continue }
    $f = $line -split "`t"
    if ($f.Count -lt 4) { continue }
    if ($Group -eq "all" -or $f[3] -eq $Group) { $allowed[$f[0]] = $true }
}

function Get-Packages([string]$store) {
    $rows = @()
    foreach ($line in (Get-Content $Catalog)) {
        if ($line -match '^\s*#') { continue }
        $f = $line -split "`t"
        if ($f.Count -ge 3 -and $f[0] -eq $store) {
            $rows += [pscustomobject]@{ Key = $f[1]; Package = $f[2] }
        }
    }
    return $rows
}

$done = @{}
$installed = 0
$errors = 0

foreach ($store in $selected) {
    $nameByKey = @{}
    foreach ($line in (Get-Content $AppsFile)) {
        if ($line -match '^\s*#') { continue }
        $f = $line -split "`t"
        if ($f.Count -ge 2) { $nameByKey[$f[0]] = $f[1] }
    }

    $todo = @()
    foreach ($row in (Get-Packages $store)) {
        if (-not $allowed.ContainsKey($row.Key)) { continue }
        if ($done.ContainsKey($row.Key)) { continue }
        $todo += $row
    }
    if ($todo.Count -eq 0) { Log "$store`: sin paquetes nuevos"; continue }

    Log "$store`: $($todo.Count) paquete(s) -> $(($todo.Package) -join ', ')"
    if (-not $Yes -and -not $DryRun) {
        $answer = Read-Host "  ¿Continuar con $store? [s/N]"
        if ($answer -notmatch '^(s|S|si|SI|y|Y|yes|YES)$') { Warn "$store`: omitido"; continue }
    }

    $rc = $true
    foreach ($row in $todo) {
        $pkg = $row.Package
        $display = if ($nameByKey.ContainsKey($row.Key)) { $nameByKey[$row.Key] } else { $row.Key }
        switch ($store) {
            "winget" {
                $ok = Invoke-Step @("winget", "install", "--id", $pkg, "--exact", "--accept-source-agreements", "--accept-package-agreements", "--disable-interactivity")
                if (-not $ok) {
                    Warn "winget id '$pkg' no encontrado; se busca por nombre '$display'"
                    $ok = Invoke-Step @("winget", "install", $display, "--accept-source-agreements", "--accept-package-agreements", "--disable-interactivity")
                }
                $rc = $rc -and $ok
            }
            "choco"  { $rc = $rc -and (Invoke-Step @("choco", "install", $pkg, "-y", "--no-progress")) }
            "scoop"  { $rc = $rc -and (Invoke-Step @("scoop", "install", $pkg)) }
            "msys2"  { $rc = $rc -and (Invoke-Step @("pacman", "-S", "--noconfirm", "--needed", $pkg)) }
        }
    }

    if ($rc) {
        foreach ($row in $todo) { $done[$row.Key] = $true }
        $installed += $todo.Count
    } else {
        Fail "$store`: hubo errores; se continúa con las demás tiendas"
        $errors++
    }
}

Write-Host ""
Log "Resumen: $installed aplicación(es) procesadas; tiendas con errores: $errors"
Log "Tiendas detectadas: $($available -join ', ')"
if ($errors -gt 0) { Warn "Prueba -Stores con otra tienda o -AllStores para más alternativas." }
exit 0
