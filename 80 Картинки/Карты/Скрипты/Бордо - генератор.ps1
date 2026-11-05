# Бордо — генератор карты города (SVG со слоями Inkscape)
# Запуск: powershell -NoProfile -ExecutionPolicy Bypass -File ".\Бордо - генератор.ps1"
# Результат: ..\Бордо - карта.svg
# Масштаб: 1 единица = 5 м; 200 единиц = 1 км. Север — вверху.
# Версия 2: круглый Лунный залив с узкой горловиной на северо-запад; город полумесяцем
# обнимает залив, центр (Кёрвиль) — у устья Дардонье, как Петербург у устья Невы.

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\MapTools.ps1"
$OutFile = Join-Path (Split-Path $PSScriptRoot -Parent) 'Бордо - карта.svg'
$Seed = 403                      # поменяйте seed — береговые линии лягут иначе
$rng = New-MapRng $Seed
$W = 1600; $H = 1100

function P([object[]]$pts, [bool]$closed = $true, [int]$depth = 5) {
    Get-RoughPath -Points $pts -Closed $closed -Depth $depth -Rng $script:rng
}

# ---------------------------------------------------------------- ГЕОГРАФИЯ
# Лунный залив: окружность с центром (610, 500), радиус 345 (≈3,5 км в поперечнике).
# Берег идёт по часовой от северного мыса (-105°) через восток до юго-западного мыса (195°).
# Горловина — между 195° и 255°: смотрит на северо-запад (225°).
$BayCx = 610; $BayCy = 500; $BayR = 345
$bayAngles = @(-105, -90, -75, -60, -45, -30, -18, -8, 0, 8, 18, 30, 45, 60, 75, 90, 105, 120, 135, 150, 165, 180, 195)
$bayRough  = @(0.12, 0.08, 0.05, 0.04, 0.03, 0.03, 0.03, 0.03, 0.03, 0.02, 0.02, 0.02, 0.02, 0.03, 0.02, 0.02, 0.02, 0.04, 0.06, 0.08, 0.1, 0.12, 0.15)
$bayShore = Get-ArcPoints -Cx $BayCx -Cy $BayCy -Rad $BayR -Angles $bayAngles -Rough $bayRough

# Полоса вдоль дуги залива (для районов-«полумесяцев»): углы a1..a2, радиусы r1..r2
function Band([double]$a1, [double]$a2, [double]$r1, [double]$r2, [double]$rough = 0.04) {
    $steps = [Math]::Max(3, [int][Math]::Ceiling(($a2 - $a1) / 8))
    $angs = [double[]](0..$steps | ForEach-Object { $a1 + ($a2 - $a1) * $_ / $steps })
    $rgh = [double[]](@($rough) * $angs.Count)
    $inner = Get-ArcPoints -Cx $script:BayCx -Cy $script:BayCy -Rad $r1 -Angles $angs -Rough $rgh
    [array]::Reverse($angs)
    $outer = Get-ArcPoints -Cx $script:BayCx -Cy $script:BayCy -Rad $r2 -Angles $angs -Rough $rgh
    return , ($inner + $outer)
}
function ArcPath([double]$a1, [double]$a2, [double]$r) {
    $steps = [Math]::Max(3, [int][Math]::Ceiling([Math]::Abs($a2 - $a1) / 6))
    $angs = [double[]](0..$steps | ForEach-Object { $a1 + ($a2 - $a1) * $_ / $steps })
    $pts = Get-ArcPoints -Cx $script:BayCx -Cy $script:BayCy -Rad $r -Angles $angs -Rough ([double[]](@(0) * $angs.Count))
    return ConvertTo-SvgPath -Pts $pts -Closed $false
}
function OnArc([double]$a, [double]$r) {
    $t = $a * [Math]::PI / 180
    return @(($script:BayCx + $r * [Math]::Cos($t)), ($script:BayCy + $r * [Math]::Sin($t)))
}

# Суша — одно кольцо: океанский берег к северному мысу, весь залив по часовой, от юго-западного мыса — океанский берег к западу.
$landPts = @(@(470, 0, 0.12), @(480, 70, 0.15), @(500, 130, 0.15)) + $bayShore +
           @(@(220, 400, 0.18), @(140, 385, 0.18), @(60, 372, 0.18), @(0, 368, 0), @(0, 1100, 0), @(1600, 1100, 0), @(1600, 0, 0))
# Сантинель — прямо в горловине залива
$sentinel = @(@(318, 282, 0.18), @(350, 246, 0.18), @(400, 222, 0.18), @(418, 236, 0.18), @(388, 268, 0.18), @(340, 294, 0.18))

# Дардонье и рукава дельты: точки @(x, y, полуширина)
$rvMain  = @(@(930, 546, 27), @(1000, 556, 27), @(1060, 560, 27), @(1150, 557, 28), @(1240, 543, 30), @(1300, 522, 31), @(1400, 520, 32), @(1500, 518, 33), @(1620, 515, 33))
$rvNorth = @(@(1300, 522, 18), @(1240, 470, 19), @(1160, 425, 20), @(1080, 400, 20), @(1000, 388, 20), @(925, 383, 21))
$rvSmall = @(@(1150, 557, 10), @(1090, 520, 11), @(1040, 495, 11), @(985, 474, 11), @(925, 462, 12))

$dLand = P $landPts
$dSen = P $sentinel
$rivers = @(
    (Get-RiverShape -Center $rvMain -R 0.03 -Rng $rng),
    (Get-RiverShape -Center $rvNorth -R 0.03 -Rng $rng),
    (Get-RiverShape -Center $rvSmall -R 0.03 -Rng $rng))

# ---------------------------------------------------------------- РАЙОНЫ
# Береговые районы — полосы по дуге залива; внутренний край заходит в воду, его обрезает маска суши.
$districts = @(
    @{ id = 'kerv'; name = 'Кёрвиль'; fill = 'built'; streets = 'radial'; cx = 1090; cy = 645; r = 118
       pts = @(@(975, 575, 0.03), @(1205, 570, 0.03), @(1220, 700, 0.03), @(1120, 740, 0.03), @(1010, 725, 0.03), @(970, 650, 0.03)) },
    @{ id = 'shant'; name = 'Шантьер'; fill = 'built'; streets = 'grid'; su = 30; sv = 14; ang = 110; jit = 2; pts = (Band 10 30 320 405) },
    @{ id = 'port'; name = 'Порт-Люн'; fill = 'built'; streets = 'grid'; su = 26; sv = 18; ang = 136; jit = 3; pts = (Band 30 64 320 415) },
    @{ id = 'jard'; name = 'Жарден'; fill = 'built'; streets = 'grid'; su = 42; sv = 34; ang = -20; jit = 4
       pts = @(@(930, 725, 0.03), @(1050, 730, 0.03), @(1115, 745, 0.03), @(1100, 865, 0.03), @(960, 885, 0.03), @(880, 845, 0.03)) },
    @{ id = 'arse'; name = 'Арсенал'; fill = 'built'; streets = 'grid'; su = 30; sv = 30; ang = 8; jit = 1
       pts = @(@(1210, 640, 0.03), @(1335, 650, 0.03), @(1345, 770, 0.03), @(1230, 795, 0.03), @(1120, 748, 0.03)) },
    @{ id = 'palu'; name = 'Палюдат'; fill = 'poor'; streets = 'grid'; su = 22; sv = 22; ang = 5; jit = 7; pts = (Band 64 118 320 430 0.06) },
    @{ id = 'south'; name = 'Южный берег'; fill = 'poor'; streets = 'grid'; su = 34; sv = 40; ang = 60; jit = 6; pts = (Band 120 190 320 410 0.06) },
    @{ id = 'forj'; name = 'Форж'; fill = 'built'; streets = 'grid'; su = 34; sv = 24; ang = 50; jit = 3; pts = (Band -62 -22 320 455) },
    @{ id = 'north'; name = 'Северный берег'; fill = 'poor'; streets = 'grid'; su = 30; sv = 34; ang = 0; jit = 6; pts = (Band -104 -62 320 420 0.06) },
    @{ id = 'subsE'; name = 'Предместья'; fill = 'poor'; streets = 'grid'; su = 28; sv = 30; ang = -10; jit = 5
       pts = @(@(1110, 870, 0.06), @(1240, 800, 0.06), @(1290, 880, 0.08), @(1170, 945, 0.08), @(1075, 925, 0.06)) },
    @{ id = 'subsN'; name = 'Северные предместья'; fill = 'poor'; streets = 'grid'; su = 28; sv = 26; ang = 25; jit = 5
       pts = @(@(1040, 200, 0.06), @(1160, 250, 0.06), @(1265, 335, 0.06), @(1160, 378, 0.06), @(1040, 330, 0.06)) },
    @{ id = 'don'; name = 'Ла-Донасьон'; fill = 'built'; streets = 'grid'; su = 22; sv = 34; ang = 18; jit = 1.5
       pts = @(@(925, 370, 0.02), @(1100, 375, 0.02), @(1310, 470, 0.02), @(1310, 545, 0.02), @(1150, 565, 0.02), @(1040, 500, 0.02), @(925, 470, 0.02)) },
    @{ id = 'sav'; name = 'Иль-Савант'; fill = 'built'; streets = 'grid'; su = 24; sv = 20; ang = 15; jit = 1.5
       pts = @(@(925, 450, 0.02), @(1050, 485, 0.02), @(1160, 555, 0.02), @(1050, 575, 0.02), @(925, 565, 0.02)) }
)

# ---------------------------------------------------------------- СБОРКА
$sb = New-Object System.Text.StringBuilder
function Add([string]$s) { [void]$script:sb.Append($s) }

Add @'
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
     xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
     xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
     width="1600" height="1100" viewBox="0 0 1600 1100">
<title>Бордо — карта города (385 НЭ)</title>
<style>
  .sea { fill: #9dbcc0; }
  .shallow { fill: none; stroke: #b9d2d3; stroke-width: 16; stroke-linejoin: round; }
  .land { fill: #efe4c8; stroke: #4c6b70; stroke-width: 1.6; stroke-linejoin: round; }
  .built { fill: #d6bf98; }
  .poor { fill: #cdbd98; opacity: 0.75; }
  .street { fill: none; stroke: #f4ead2; stroke-width: 2.4; }
  .avenue { fill: none; stroke: #f8f0dc; stroke-width: 5; stroke-linecap: round; }
  .road { fill: none; stroke: #a8875f; stroke-width: 3; stroke-dasharray: 10 4; stroke-linecap: round; }
  .canal-edge { fill: none; stroke: #4c6b70; stroke-width: 9; stroke-linecap: round; }
  .canal { fill: none; stroke: #9dbcc0; stroke-width: 6.5; stroke-linecap: round; }
  .dam { fill: none; stroke: #6b5a45; stroke-width: 7; stroke-linecap: round; }
  .bridge { fill: none; stroke: #6e5338; stroke-width: 7; }
  .district-edge { fill: none; stroke: #7a5a3a; stroke-width: 1.4; stroke-dasharray: 6 4; opacity: 0.8; }
  .fort { fill: #b7a27c; stroke: #3b2f25; stroke-width: 2; }
  .title { font-family: Georgia, 'Times New Roman', serif; font-size: 64px; letter-spacing: 10px; fill: #3b2f25; }
  .subtitle { font-family: Georgia, 'Times New Roman', serif; font-size: 17px; font-style: italic; fill: #5b4632; }
  .dist { font-family: Georgia, 'Times New Roman', serif; font-size: 22px; font-weight: bold; letter-spacing: 5px; fill: #5b3a22; text-anchor: middle; paint-order: stroke; stroke: #f4ead2; stroke-width: 5; stroke-linejoin: round; }
  .dist-s { font-family: Georgia, 'Times New Roman', serif; font-size: 14px; font-weight: bold; letter-spacing: 3px; fill: #5b3a22; text-anchor: middle; paint-order: stroke; stroke: #f4ead2; stroke-width: 4; stroke-linejoin: round; }
  .water { font-family: Georgia, 'Times New Roman', serif; font-size: 30px; font-style: italic; letter-spacing: 8px; fill: #2f5560; text-anchor: middle; }
  .water-s { font-family: Georgia, 'Times New Roman', serif; font-size: 17px; font-style: italic; letter-spacing: 2px; fill: #2f5560; text-anchor: middle; }
  .poi { font-family: Georgia, 'Times New Roman', serif; font-size: 12px; fill: #3b2f25; paint-order: stroke; stroke: #f4ead2; stroke-width: 3.5; stroke-linejoin: round; }
  .note { font-family: Georgia, 'Times New Roman', serif; font-size: 13px; font-style: italic; fill: #6b5640; paint-order: stroke; stroke: #f4ead2; stroke-width: 3.5; }
  .legend { font-family: Georgia, 'Times New Roman', serif; font-size: 12px; fill: #3b2f25; }
  .secret { font-family: Georgia, 'Times New Roman', serif; font-size: 14px; font-style: italic; fill: #7a1f1f; paint-order: stroke; stroke: #f4ead2; stroke-width: 3.5; }
</style>
<defs>
  <pattern id="pat-fields" width="26" height="26" patternUnits="userSpaceOnUse" patternTransform="rotate(18)">
    <rect width="26" height="26" fill="#ebe1bf"/><path d="M0,7 H26 M0,20 H26" stroke="#dccf9f" stroke-width="2.2"/>
  </pattern>
  <pattern id="pat-vine" width="11" height="11" patternUnits="userSpaceOnUse" patternTransform="rotate(-15)">
    <rect width="11" height="11" fill="#e7dcc0"/><circle cx="5.5" cy="5.5" r="1.5" fill="#7d6b8a"/>
  </pattern>
  <pattern id="pat-marsh" width="30" height="20" patternUnits="userSpaceOnUse">
    <path d="M5,14 h8 M7,14 v-4 M9,14 v-6 M11,14 v-4 M18,7 h8 M20,7 v-3 M22,7 v-5 M24,7 v-3" stroke="#6f8a6a" stroke-width="1" fill="none"/>
  </pattern>
  <pattern id="pat-salt" width="16" height="16" patternUnits="userSpaceOnUse">
    <rect width="16" height="16" fill="#e6ecec"/><path d="M0,0 H16 M0,0 V16" stroke="#aec2c6" stroke-width="1.2"/>
  </pattern>
  <pattern id="pat-park" width="18" height="18" patternUnits="userSpaceOnUse">
    <rect width="18" height="18" fill="#dfe0b8"/><circle cx="5" cy="6" r="3" fill="#9aae7a"/><circle cx="13" cy="13" r="3.4" fill="#8da26e"/>
  </pattern>
  <pattern id="pat-ruins" width="14" height="14" patternUnits="userSpaceOnUse" patternTransform="rotate(45)">
    <path d="M0,0 V14" stroke="#7a1f1f" stroke-width="1" opacity="0.5"/>
  </pattern>

  <symbol id="sym-church" viewBox="-10 -10 20 20"><circle r="7" fill="#c9a227" stroke="#3b2f25" stroke-width="1.4"/><circle r="3.2" fill="#f4ead2" stroke="#3b2f25" stroke-width="0.8"/></symbol>
  <symbol id="sym-palace" viewBox="-10 -10 20 20"><path d="M-8,6 L-8,-3 L-4,1 L0,-7 L4,1 L8,-3 L8,6 Z" fill="#c9a227" stroke="#3b2f25" stroke-width="1.3"/></symbol>
  <symbol id="sym-hall" viewBox="-10 -10 20 20"><rect x="-7" y="-2" width="14" height="9" fill="#e2d2b0" stroke="#3b2f25" stroke-width="1.2"/><rect x="-2" y="-9" width="4" height="7" fill="#e2d2b0" stroke="#3b2f25" stroke-width="1.2"/></symbol>
  <symbol id="sym-bank" viewBox="-10 -10 20 20"><path d="M-8,-2 L0,-8 L8,-2 Z" fill="#e2d2b0" stroke="#3b2f25" stroke-width="1.2"/><path d="M-6,-1 V6 M-2,-1 V6 M2,-1 V6 M6,-1 V6 M-8,7 H8" stroke="#3b2f25" stroke-width="1.4"/></symbol>
  <symbol id="sym-flag" viewBox="-10 -10 20 20"><path d="M-6,8 V-8" stroke="#3b2f25" stroke-width="1.6"/><path d="M-6,-8 L7,-5 L-6,-1 Z" fill="#2f3f6a" stroke="#3b2f25" stroke-width="1"/></symbol>
  <symbol id="sym-garrison" viewBox="-10 -10 20 20"><path d="M-7,-7 H7 V1 C7,6 0,9 0,9 C0,9 -7,6 -7,1 Z" fill="#2f3f6a" stroke="#3b2f25" stroke-width="1.2"/><path d="M-4,4 L4,-4 M-4,-4 L4,4" stroke="#e0c25a" stroke-width="1.4"/></symbol>
  <symbol id="sym-powder" viewBox="-10 -10 20 20"><rect x="-6" y="-8" width="12" height="16" rx="4" fill="#5a4030" stroke="#2b1f15" stroke-width="1.2"/><path d="M-6,-3 H6 M-6,3 H6" stroke="#c9a227" stroke-width="1.2"/></symbol>
  <symbol id="sym-univ" viewBox="-10 -10 20 20"><path d="M0,-4 C-3,-7 -7,-7 -9,-6 V6 C-7,5 -3,5 0,8 C3,5 7,5 9,6 V-6 C7,-7 3,-7 0,-4 Z" fill="#f4ead2" stroke="#3b2f25" stroke-width="1.2"/><path d="M0,-4 V8" stroke="#3b2f25" stroke-width="1"/></symbol>
  <symbol id="sym-anchor" viewBox="-10 -10 20 20"><circle cy="-6" r="2.2" fill="none" stroke="#3b2f25" stroke-width="1.4"/><path d="M0,-4 V8 M-6,2 C-6,7 6,7 6,2 M-4,-1 H4" fill="none" stroke="#3b2f25" stroke-width="1.6"/></symbol>
  <symbol id="sym-factory" viewBox="-10 -10 20 20"><path d="M-8,8 V0 L-3,-3 V0 L2,-3 V0 L4,0 V-8 H7 V8 Z" fill="#8a7a6a" stroke="#3b2f25" stroke-width="1"/></symbol>
  <symbol id="sym-house" viewBox="-10 -10 20 20"><path d="M-7,8 V-1 L0,-7 L7,-1 V8 Z" fill="#e2d2b0" stroke="#3b2f25" stroke-width="1.3"/><rect x="-2" y="2" width="4" height="6" fill="#3b2f25"/></symbol>
  <symbol id="sym-lantern" viewBox="-10 -10 20 20"><rect x="-4" y="-6" width="8" height="12" rx="3" fill="#d9572b" stroke="#3b2f25" stroke-width="1.1"/><path d="M-4,-1 H4 M-4,2 H4" stroke="#3b2f25" stroke-width="0.8"/></symbol>
  <symbol id="sym-ox" viewBox="-10 -10 20 20"><path d="M-8,-6 C-6,-2 -4,-2 -3,-2 L3,-2 C4,-2 6,-2 8,-6 M-3,-2 L-3,5 L0,8 L3,5 L3,-2" fill="#cdbd98" stroke="#3b2f25" stroke-width="1.3"/></symbol>
  <symbol id="sym-gate" viewBox="-10 -10 20 20"><rect x="-6" y="-6" width="12" height="13" fill="#b7a27c" stroke="#3b2f25" stroke-width="1.2"/><path d="M-6,-6 V-9 H-3 V-6 M-1.5,-6 V-9 H1.5 V-6 M3,-6 V-9 H6 V-6" fill="#b7a27c" stroke="#3b2f25" stroke-width="1"/><path d="M-2.5,7 V2 C-2.5,0 2.5,0 2.5,2 V7" fill="#3b2f25"/></symbol>
  <symbol id="sym-fish" viewBox="-10 -10 20 20"><path d="M-8,0 C-4,-6 4,-6 6,0 C4,6 -4,6 -8,0 Z M6,0 L9,-4 V4 Z" fill="#8fb2b7" stroke="#3b2f25" stroke-width="1.1"/></symbol>
  <symbol id="sym-ship" viewBox="-10 -10 20 20"><path d="M-8,4 H8 L5,8 H-5 Z" fill="#6e5338"/><path d="M0,4 V-9" stroke="#3b2f25" stroke-width="1"/><path d="M0.6,-8 L7,2 H0.6 Z M-0.6,-6 L-6,2 H-0.6 Z" fill="#f4ead2" stroke="#3b2f25" stroke-width="0.8"/></symbol>
  <symbol id="sym-collier" viewBox="-10 -10 20 20"><path d="M-8,4 H8 L5,8 H-5 Z" fill="#3b2f25"/><path d="M0,4 V-9" stroke="#3b2f25" stroke-width="1"/><path d="M0.6,-8 L7,2 H0.6 Z M-0.6,-6 L-6,2 H-0.6 Z" fill="#c9bfa8" stroke="#3b2f25" stroke-width="0.8"/></symbol>
  <symbol id="sym-rift" viewBox="-10 -10 20 20"><path d="M0,-9 L3,-2 L9,0 L3,2 L0,9 L-3,2 L-9,0 L-3,-2 Z" fill="#7a1f1f" opacity="0.85"/></symbol>

'@
Add ('  <clipPath id="clip-land"><path d="' + $dLand + '"/></clipPath>' + "`n")
$distPaths = @{}
foreach ($d in $districts) {
    $dp = P $d.pts $true 3
    $distPaths[$d.id] = $dp
    Add ('  <clipPath id="clip-' + $d.id + '"><path d="' + $dp + '"/></clipPath>' + "`n")
}
Add "  <path id=`"bay-arc`" d=`"M380,600 Q610,470 840,590`"/>`n"
Add "  <path id=`"river-arc`" d=`"M1370,528 Q1480,520 1595,523`"/>`n"
Add "</defs>`n"

function Use([string]$sym, [double]$x, [double]$y, [double]$s = 20) {
    $h = $s / 2
    return '<use xlink:href="#' + $sym + '" x="' + (F ($x - $h)) + '" y="' + (F ($y - $h)) + '" width="' + (F $s) + '" height="' + (F $s) + '"/>' + "`n"
}
function Txt([double]$x, [double]$y, [string]$cls, [string]$text, [string]$extra = '') {
    return '<text x="' + (F $x) + '" y="' + (F $y) + '" class="' + $cls + '"' + $extra + '>' + $text + '</text>' + "`n"
}

# ---- Слой: море
$L = '<rect class="sea" x="0" y="0" width="1600" height="1100"/>' + "`n"
$L += '<path class="shallow" d="' + $dLand + '"/>' + "`n"
$L += '<path class="shallow" d="' + $dSen + '"/>' + "`n"
Add (New-Layer 'layer-sea' 'Море и мелководье' $L)

# ---- Слой: суша
$L = '<path id="land" class="land" d="' + $dLand + '"/>' + "`n"
$L += '<path id="isl-sentinel" class="land" d="' + $dSen + '"/>' + "`n"
Add (New-Layer 'layer-land' 'Суша' $L)

# ---- Слой: угодья
$vineS = P @(@(1340, 575, 0.05), @(1620, 570, 0), @(1620, 780, 0.08), @(1360, 760, 0.08), @(1330, 690, 0.05))
$vineN = P @(@(1320, 470, 0.05), @(1380, 380, 0.08), @(1620, 330, 0), @(1620, 505, 0.05), @(1350, 505, 0.05))
$salt  = P @(@(470, 0, 0.1), @(700, 0, 0.1), @(650, 100, 0.1), @(540, 140, 0.1), @(500, 110, 0.1))
$marsh = P (Band 66 116 330 470 0.1)
$park  = P @(@(190, 590, 0.08), @(300, 600, 0.08), @(310, 690, 0.08), @(220, 705, 0.08), @(175, 650, 0.08))
$L = '<g clip-path="url(#clip-land)">' + "`n"
$L += '<rect x="0" y="0" width="1600" height="1100" fill="url(#pat-fields)"/>' + "`n"
$L += '<path d="' + $vineS + '" fill="url(#pat-vine)"/><path d="' + $vineN + '" fill="url(#pat-vine)"/>' + "`n"
$L += '<path d="' + $salt + '" fill="url(#pat-salt)"/><path d="' + $marsh + '" fill="url(#pat-marsh)"/><path d="' + $park + '" fill="url(#pat-park)"/>' + "`n"
$L += '</g>' + "`n"
Add (New-Layer 'layer-terrain' 'Угодья: поля, виноградники, солончаки, болота, парк' $L)

# ---- Слой: районы и улицы
$L = '<g clip-path="url(#clip-land)">' + "`n"
foreach ($d in $districts) {
    $L += '<g id="dist-' + $d.id + '" inkscape:label="' + $d.name + '">' + "`n"
    $L += '  <path class="' + $d.fill + '" d="' + $distPaths[$d.id] + '"/>' + "`n"
    if ($d.streets -eq 'radial') {
        $st = Get-RadialStreets -Cx $d.cx -Cy $d.cy -Radius $d.r -Rays 14 -Rings 4 -Rng $rng
    } else {
        $xs = $d.pts | ForEach-Object { $_[0] }; $ys = $d.pts | ForEach-Object { $_[1] }
        $x0 = ($xs | Measure-Object -Minimum).Minimum; $x1 = ($xs | Measure-Object -Maximum).Maximum
        $y0 = ($ys | Measure-Object -Minimum).Minimum; $y1 = ($ys | Measure-Object -Maximum).Maximum
        $st = Get-StreetGrid -X $x0 -Y $y0 -W ($x1 - $x0) -H ($y1 - $y0) -StepU $d.su -StepV $d.sv -Angle $d.ang -Jitter $d.jit -Rng $rng
    }
    $L += '  <path class="street" clip-path="url(#clip-' + $d.id + ')" d="' + $st + '"/>' + "`n"
    $L += '  <path class="district-edge" d="' + $distPaths[$d.id] + '"/>' + "`n"
    $L += '</g>' + "`n"
}
$L += '<rect x="1222" y="702" width="46" height="32" fill="#f4ead2" stroke="#7a5a3a" stroke-width="1" transform="rotate(8 1245 718)"/>' + "`n"
$avenues = @('M1090,645 L1060,594', 'M1090,645 L1240,580', 'M1090,645 L1300,642', 'M1090,645 L1066,800', 'M1090,645 L960,735', 'M955,425 L1290,512')
foreach ($a in $avenues) { $L += '<path class="avenue" d="' + $a + '"/>' + "`n" }
$L += '</g>' + "`n"
Add (New-Layer 'layer-districts' 'Районы и улицы' $L)

# ---- Слой: Дардонье и рукава (поверх районов — так острова вырезаются сами)
$L = '<g clip-path="url(#clip-land)">' + "`n"
foreach ($rv in $rivers) { $L += '<path fill="none" stroke="#4c6b70" stroke-width="3.2" d="' + $rv.Left + '"/><path fill="none" stroke="#4c6b70" stroke-width="3.2" d="' + $rv.Right + '"/>' + "`n" }
$L += '</g>' + "`n"
foreach ($rv in $rivers) { $L += '<path class="sea" d="' + $rv.Fill + '"/>' + "`n" }
$canals = @('M1005,585 C1012,690 1170,700 1180,582', 'M880,780 C940,800 1000,795 1060,770')
foreach ($c in $canals) { $L += '<path class="canal-edge" d="' + $c + '"/><path class="canal" d="' + $c + '"/>' + "`n" }
Add (New-Layer 'layer-rivers' 'Дардонье, рукава и каналы' $L)

# ---- Слой: дамба и дороги
$L = ''
$L += '<path id="dam-dig" class="dam" d="' + (ArcPath 70 118 343) + '"/>' + "`n"
$roads = @(
    'M1300,642 C1400,640 1500,641 1620,640',
    'M1066,800 C1060,880 1055,960 1050,1100',
    'M960,735 L916,757',
    (ArcPath 40 185 400),
    'M1080,377 C1070,300 1055,200 1040,0',
    'M1060,330 L952,302',
    (ArcPath -30 -104 395))
foreach ($r in $roads) { $L += '<path class="road" d="' + $r + '"/>' + "`n" }
Add (New-Layer 'layer-roads' 'Дамба и дороги' $L)

# ---- Слой: разводные мосты
function Bridge([double]$x1, [double]$y1, [double]$x2, [double]$y2, [string]$name) {
    $len = [Math]::Sqrt(($x2 - $x1) * ($x2 - $x1) + ($y2 - $y1) * ($y2 - $y1))
    $half = ($len - 7) / 2
    return '<line class="bridge" inkscape:label="' + $name + '" x1="' + (F $x1) + '" y1="' + (F $y1) + '" x2="' + (F $x2) + '" y2="' + (F $y2) + '" stroke-dasharray="' + (F $half) + ' 7 ' + (F $half) + '"/>' + "`n"
}
$L = ''
$L += Bridge 1060 527 1060 594 'Мост Кёрвиль — Иль-Савант'
$L += Bridge 1040 479 1040 511 'Мост Иль-Савант — Ла-Донасьон'
$L += Bridge 1080 375 1080 426 'Мост Ла-Донасьон — северный берег'
$L += Bridge 1240 507 1240 580 'Большой мост Кёрвиль — Ла-Донасьон'
Add (New-Layer 'layer-bridges' 'Разводные мосты' $L)

# ---- Слой: Сантинель
$L = '<path class="fort" d="' + (Get-StarFortPath -Cx 368 -Cy 258 -R 24 -N 5 -Rot -60) + '"/>' + "`n"
Add (New-Layer 'layer-fort' 'Крепость Сантинель' $L)

# ---- Слой: объекты
$L = ''
$poi = @(
    @('sym-church', 1090, 645, 'Собор', 12, 4),
    @('sym-palace', 1125, 596, 'Королевский дворец', 12, 4),
    @('sym-hall', 1030, 675, 'Магистрат', -70, 4),
    @('sym-anchor', 935, 606, 'Королевская верфь', -122, 0),
    @('sym-bank', 955, 422, 'Биржа и Имперский банк', -150, -6),
    @('sym-flag', 1050, 432, 'Посольство Аггру', 12, 4),
    @('sym-garrison', 1180, 452, 'Имперский гарнизон', 12, 4),
    @('sym-powder', 1268, 505, 'Пороховой погреб', 12, -10),
    @('sym-univ', 975, 512, 'Университет', -88, 4),
    @('sym-garrison', 1265, 690, 'Военное училище', 12, -8),
    @('sym-powder', 1305, 745, 'Пороховой погреб', 12, 4),
    @('sym-house', 975, 795, 'Вертмюр', 12, 4),
    @('sym-lantern', 1020, 770, '«Бумажный фонарь»', 12, 4),
    @('sym-ox', 576, 888, 'Скотобойни', 12, 4),
    @('sym-factory', 854, 209, '', 0, 0),
    @('sym-factory', 925, 254, 'Заводы и мануфактуры', 14, 4),
    @('sym-factory', 930, 330, '', 0, 0),
    @('sym-anchor', 872, 268, 'Угольные причалы', -112, 4),
    @('sym-powder', 368, 258, '', 0, 0),
    @('sym-house', 244, 633, 'Загородная резиденция', -70, 26),
    @('sym-fish', 520, 110, 'Рыбацкое село', -100, 4),
    @('sym-fish', 215, 428, 'Рыбацкое село', -40, 24),
    @('sym-gate', 1047, 150, 'Застава', 14, 4),
    @('sym-gate', 1052, 960, 'Застава', 14, 4),
    @('sym-gate', 1460, 641, 'Застава', -18, 26),
    @('sym-gate', 264, 700, 'Застава', 14, 4)
)
foreach ($p in $poi) {
    $L += Use $p[0] $p[1] $p[2]
    if ($p[3] -ne '') { $L += Txt ($p[1] + $p[4]) ($p[2] + $p[5]) 'poi' $p[3] }
}
foreach ($s in @(@('sym-ship', 600, 420), @('sym-ship', 760, 470), @('sym-ship', 430, 450), @('sym-ship', 820, 650), @('sym-ship', 560, 300), @('sym-collier', 844, 300), @('sym-collier', 800, 326), @('sym-ship', 250, 300), @('sym-ship', 420, 160))) {
    $L += Use $s[0] $s[1] $s[2] 22
}
for ($i = 0; $i -lt 5; $i++) { $x = 912 + $i * 6; $y = 626 - $i * 9; $L += '<line x1="' + (F $x) + '" y1="' + (F $y) + '" x2="' + (F ($x - 16)) + '" y2="' + (F ($y - 5)) + '" stroke="#6e5338" stroke-width="2"/>' + "`n" }
Add (New-Layer 'layer-poi' 'Объекты' $L)

# ---- Слой: подписи
$L = ''
$L += '<text class="water"><textPath xlink:href="#bay-arc" startOffset="50%">ЛУННЫЙ ЗАЛИВ</textPath></text>' + "`n"
$L += Txt 610 618 'water-s' 'Байе-де-Люн'
$L += '<text class="water-s"><textPath xlink:href="#river-arc" startOffset="50%">р. Дардонье</textPath></text>' + "`n"
$L += Txt 235 338 'water-s' 'ОКСИДЕНТАЛЬСКИЙ ОКЕАН'
$L += Txt 1100 712 'dist' 'КЁРВИЛЬ'
$L += Txt 950 632 'dist-s' 'ШАНТЬЕР'
$L += Txt 850 792 'dist' 'ПОРТ-ЛЮН'
$L += Txt 1005 845 'dist' 'ЖАРДЕН'
$L += Txt 1275 775 'dist-s' 'АРСЕНАЛ'
$L += Txt 1245 752 'note' "Плас-д'Арм" ' text-anchor="middle"'
$L += Txt 595 918 'dist' 'ПАЛЮДАТ'
$L += Txt 885 168 'dist' 'ФОРЖ'
$L += Txt 1100 497 'dist' 'ЛА-ДОНАСЬОН'
$L += Txt 1015 540 'dist-s' 'ИЛЬ-САВАНТ'
$L += Txt 1480 730 'dist' 'ЛА-ВИНЬ'
$L += Txt 1500 430 'dist-s' 'ЛА-ВИНЬ'
$L += Txt 1180 885 'note' 'предместья' ' text-anchor="middle"'
$L += Txt 1150 300 'note' 'предместья' ' text-anchor="middle"'
$L += Txt 650 130 'note' 'предместья' ' text-anchor="middle"'
$L += Txt 335 770 'note' 'виллы и сады' ' text-anchor="middle"'
$L += Txt 368 212 'dist-s' 'САНТИНЕЛЬ'
$L += Txt 582 822 'note' 'дамба Диг' ' text-anchor="middle"'
$L += Txt 640 40 'note' 'солончаки' ' text-anchor="middle"'
$L += Txt 1595 668 'note' 'к Катросту и королевскому лесу →' ' text-anchor="end"'
$L += Txt 1050 1088 'note' '↓ к Монтуа и Иверии' ' text-anchor="middle"'
$L += Txt 1040 26 'note' '↑ к Пэнтуа и Аггру' ' text-anchor="middle"'
Add (New-Layer 'layer-labels' 'Подписи' $L)

# ---- Слой: оформление
$L = ''
$L += '<rect x="24" y="24" width="520" height="118" fill="#f4ead2" fill-opacity="0.92" stroke="#3b2f25" stroke-width="1.5"/>' + "`n"
$L += Txt 44 92 'title' 'БОРДО'
$L += Txt 46 120 'subtitle' 'столица Королевства Дэлюн · Империя Аггру · 385 НЭ'
$L += '<g transform="translate(1530,995)"><path d="M0,-52 L9,0 L0,52 L-9,0 Z" fill="#3b2f25"/><path d="M-52,0 L0,-9 L52,0 L0,9 Z" fill="#8a7a6a"/><circle r="6" fill="#f4ead2" stroke="#3b2f25" stroke-width="1.2"/>'
$L += '<text y="-60" class="legend" text-anchor="middle" font-size="16">С</text><text y="74" class="legend" text-anchor="middle" font-size="14">Ю</text><text x="66" y="5" class="legend" text-anchor="middle" font-size="14">В</text><text x="-66" y="5" class="legend" text-anchor="middle" font-size="14">З</text></g>' + "`n"
$L += '<g transform="translate(40,1048)"><rect x="0" y="0" width="100" height="8" fill="#3b2f25"/><rect x="100" y="0" width="100" height="8" fill="#f4ead2" stroke="#3b2f25" stroke-width="1"/>'
$L += '<text x="0" y="24" class="legend" text-anchor="middle">0</text><text x="100" y="24" class="legend" text-anchor="middle">500 м</text><text x="200" y="24" class="legend" text-anchor="middle">1 км</text></g>' + "`n"
$lx = 1196; $ly = 24
$L += '<rect x="' + $lx + '" y="' + $ly + '" width="384" height="208" fill="#f4ead2" fill-opacity="0.92" stroke="#3b2f25" stroke-width="1.2"/>' + "`n"
$L += Txt ($lx + 12) ($ly + 22) 'legend' 'УСЛОВНЫЕ ЗНАКИ' ' font-weight="bold" letter-spacing="2"'
$leg = @(
    @('sym-church', 'Собор Вселенской Церкви'), @('sym-palace', 'Королевский дворец'), @('sym-hall', 'Магистрат'),
    @('sym-bank', 'Биржа и Имперский банк'), @('sym-flag', 'Посольство Аггру'), @('sym-garrison', 'Гарнизон, училище'),
    @('sym-powder', 'Пороховой погреб'), @('sym-univ', 'Университет'), @('sym-anchor', 'Верфь, причалы'),
    @('sym-factory', 'Заводы'), @('sym-gate', 'Застава'), @('sym-ship', 'Суда в заливе'))
for ($i = 0; $i -lt $leg.Count; $i++) {
    $col = [Math]::Floor($i / 6); $row = $i % 6
    $x = $lx + 22 + $col * 196; $y = $ly + 46 + $row * 24
    $L += Use $leg[$i][0] $x $y 18
    $L += Txt ($x + 14) ($y + 4) 'legend' $leg[$i][1]
}
$L += '<line x1="' + ($lx + 12) + '" y1="' + ($ly + 192) + '" x2="' + ($lx + 40) + '" y2="' + ($ly + 192) + '" class="bridge" stroke-dasharray="10 7 10"/>' + "`n"
$L += Txt ($lx + 48) ($ly + 196) 'legend' 'Разводной мост — разводят ночью'
$L += '<rect x="4" y="4" width="1592" height="1092" fill="none" stroke="#3b2f25" stroke-width="3"/><rect x="11" y="11" width="1578" height="1078" fill="none" stroke="#3b2f25" stroke-width="1"/>' + "`n"
Add (New-Layer 'layer-frame' 'Оформление' $L)

# ---- Слой мастера (скрыт)
$bur = P @(@(880, 730, 0.15), @(1060, 740, 0.15), @(1090, 850, 0.15), @(960, 890, 0.15), @(860, 830, 0.15))
$L = '<path d="' + $bur + '" fill="url(#pat-ruins)" stroke="#7a1f1f" stroke-width="1.6" stroke-dasharray="8 5"/>' + "`n"
$L += Txt 975 722 'secret' 'Бурдигала — под сваями (Нижний Бордо)' ' text-anchor="middle"'
$L += Use 'sym-rift' 975 818 22
$L += Txt 990 840 'secret' 'Прореха под Вертмюром'
Add (New-Layer 'layer-secret' 'Тайное — только мастер' $L $true)

Add "</svg>`n"
Save-Svg $OutFile $sb.ToString()
Write-Output ("Готово: " + $OutFile + " (" + [Math]::Round((Get-Item $OutFile).Length / 1KB) + " КБ)")
