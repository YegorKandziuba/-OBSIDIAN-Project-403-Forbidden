# MapTools.ps1 — инструменты для векторных карт Project 403: Forbidden
# Подключение: . "$PSScriptRoot\MapTools.ps1"
# Все функции детерминированы: один и тот же seed даёт одну и ту же линию.

$script:Inv = [Globalization.CultureInfo]::InvariantCulture

# Число -> строка для SVG (точка как разделитель, один знак после запятой)
function F([double]$v) { $v.ToString('0.#', $script:Inv) }

function New-MapRng([int]$Seed) { New-Object System.Random $Seed }

# Неровная линия методом смещения средней точки.
# $Points — массив точек @(x, y, r): r — шероховатость отрезка, который НАЧИНАЕТСЯ в этой точке
#   0      — прямой отрезок (рамка карты, край листа)
#   0.03   — инженерная набережная, гранит
#   0.08   — укреплённый, но живой берег
#   0.15+  — дикий берег, болото, скалы
# $Depth — сколько раз делить отрезки (5 = каждый отрезок станет 32 частями).
function Get-RoughPoints {
    param([object[]]$Points, [bool]$Closed = $true, [int]$Depth = 5, [System.Random]$Rng)
    $cur = New-Object 'System.Collections.Generic.List[double[]]'
    foreach ($p in $Points) {
        $r = 0.12
        if ($p.Count -ge 3) { $r = [double]$p[2] }
        $cur.Add([double[]]@([double]$p[0], [double]$p[1], $r))
    }
    for ($d = 0; $d -lt $Depth; $d++) {
        $next = New-Object 'System.Collections.Generic.List[double[]]'
        $n = $cur.Count
        $segs = if ($Closed) { $n } else { $n - 1 }
        for ($i = 0; $i -lt $segs; $i++) {
            $a = $cur[$i]; $b = $cur[($i + 1) % $n]
            $next.Add($a)
            $dx = $b[0] - $a[0]; $dy = $b[1] - $a[1]
            $len = [Math]::Sqrt($dx * $dx + $dy * $dy)
            if ($len -lt 0.5 -or $a[2] -eq 0) { continue }
            $off = ($Rng.NextDouble() * 2 - 1) * $len * $a[2]
            $mx = ($a[0] + $b[0]) / 2 - $dy / $len * $off
            $my = ($a[1] + $b[1]) / 2 + $dx / $len * $off
            $next.Add([double[]]@($mx, $my, $a[2]))
        }
        if (-not $Closed) { $next.Add($cur[$n - 1]) }
        $cur = $next
    }
    return , $cur
}

# Точки -> атрибут d для <path>. Smooth = сглаживание сплайном Катмулла — Рома (кубические кривые Безье).
function ConvertTo-SvgPath {
    param($Pts, [bool]$Closed = $true, [bool]$Smooth = $true)
    $n = $Pts.Count
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.Append("M$(F $Pts[0][0]),$(F $Pts[0][1])")
    if (-not $Smooth) {
        for ($i = 1; $i -lt $n; $i++) { [void]$sb.Append(" L$(F $Pts[$i][0]),$(F $Pts[$i][1])") }
        if ($Closed) { [void]$sb.Append(' Z') }
        return $sb.ToString()
    }
    $segs = if ($Closed) { $n } else { $n - 1 }
    for ($i = 0; $i -lt $segs; $i++) {
        if ($Closed) { $p0 = $Pts[($i - 1 + $n) % $n] } elseif ($i -eq 0) { $p0 = $Pts[0] } else { $p0 = $Pts[$i - 1] }
        $p1 = $Pts[$i]; $p2 = $Pts[($i + 1) % $n]
        if ($Closed) { $p3 = $Pts[($i + 2) % $n] } elseif ($i + 2 -ge $n) { $p3 = $Pts[$n - 1] } else { $p3 = $Pts[$i + 2] }
        $c1x = $p1[0] + ($p2[0] - $p0[0]) / 6; $c1y = $p1[1] + ($p2[1] - $p0[1]) / 6
        $c2x = $p2[0] - ($p3[0] - $p1[0]) / 6; $c2y = $p2[1] - ($p3[1] - $p1[1]) / 6
        [void]$sb.Append(" C$(F $c1x),$(F $c1y) $(F $c2x),$(F $c2y) $(F $p2[0]),$(F $p2[1])")
    }
    if ($Closed) { [void]$sb.Append(' Z') }
    return $sb.ToString()
}

# Сразу: контрольные точки -> неровный сглаженный путь
function Get-RoughPath {
    param([object[]]$Points, [bool]$Closed = $true, [int]$Depth = 5, [System.Random]$Rng, [bool]$Smooth = $true)
    $pts = Get-RoughPoints -Points $Points -Closed $Closed -Depth $Depth -Rng $Rng
    return ConvertTo-SvgPath -Pts $pts -Closed $Closed -Smooth $Smooth
}

# Сетка улиц в прямоугольнике (её потом обрезают маской района).
# StepU / StepV — шаг кварталов вдоль и поперёк, Angle — поворот сетки, Jitter — неровность шага.
function Get-StreetGrid {
    param([double]$X, [double]$Y, [double]$W, [double]$H, [double]$StepU, [double]$StepV,
          [double]$Angle = 0, [double]$Jitter = 0, [System.Random]$Rng)
    $cx = $X + $W / 2; $cy = $Y + $H / 2
    $a = $Angle * [Math]::PI / 180; $ca = [Math]::Cos($a); $sa = [Math]::Sin($a)
    $R = [Math]::Sqrt($W * $W + $H * $H) / 2 + [Math]::Max($StepU, $StepV)
    $sb = New-Object System.Text.StringBuilder
    foreach ($dir in 0, 1) {
        $step = if ($dir -eq 0) { $StepV } else { $StepU }
        for ($k = -$R; $k -le $R; $k += $step) {
            $o = $k + ($Rng.NextDouble() * 2 - 1) * $Jitter
            if ($dir -eq 0) { $x1 = -$R; $y1 = $o; $x2 = $R; $y2 = $o } else { $x1 = $o; $y1 = -$R; $x2 = $o; $y2 = $R }
            $X1 = $cx + $x1 * $ca - $y1 * $sa; $Y1 = $cy + $x1 * $sa + $y1 * $ca
            $X2 = $cx + $x2 * $ca - $y2 * $sa; $Y2 = $cy + $x2 * $sa + $y2 * $ca
            [void]$sb.Append("M$(F $X1),$(F $Y1) L$(F $X2),$(F $Y2) ")
        }
    }
    return $sb.ToString().Trim()
}

# Старый город: лучи от площади и неровные кольца — средневековая путаница улиц.
function Get-RadialStreets {
    param([double]$Cx, [double]$Cy, [double]$Radius, [int]$Rays = 12, [int]$Rings = 4, [System.Random]$Rng)
    $sb = New-Object System.Text.StringBuilder
    for ($i = 0; $i -lt $Rays; $i++) {
        $ang = (2 * [Math]::PI / $Rays) * $i + ($Rng.NextDouble() - 0.5) * 0.35
        $pts = @()
        for ($s = 0; $s -le 4; $s++) {
            $rr = $Radius * $s / 4
            $aa = $ang + ($Rng.NextDouble() - 0.5) * 0.25
            $pts += , @(($Cx + $rr * [Math]::Cos($aa)), ($Cy + $rr * [Math]::Sin($aa)), 0.1)
        }
        [void]$sb.Append((Get-RoughPath -Points $pts -Closed $false -Depth 2 -Rng $Rng) + ' ')
    }
    for ($j = 1; $j -le $Rings; $j++) {
        $rr = $Radius * $j / ($Rings + 0.5)
        $pts = @()
        for ($s = 0; $s -lt 10; $s++) {
            $aa = 2 * [Math]::PI * $s / 10
            $k = 1 + ($Rng.NextDouble() - 0.5) * 0.18
            $pts += , @(($Cx + $rr * $k * [Math]::Cos($aa)), ($Cy + $rr * $k * [Math]::Sin($aa)), 0.08)
        }
        [void]$sb.Append((Get-RoughPath -Points $pts -Closed $true -Depth 2 -Rng $Rng) + ' ')
    }
    return $sb.ToString().Trim()
}

# Бастионная крепость (звезда Вобана): N бастионов, R — до остриёв, Inner — доля внутренней стены.
function Get-StarFortPath {
    param([double]$Cx, [double]$Cy, [double]$R, [int]$N = 5, [double]$Inner = 0.62, [double]$Rot = -90)
    $pts = @()
    for ($i = 0; $i -lt 2 * $N; $i++) {
        $ang = ($Rot + 180 * $i / $N) * [Math]::PI / 180
        $rr = if ($i % 2 -eq 0) { $R } else { $R * $Inner }
        $pts += , @(($Cx + $rr * [Math]::Cos($ang)), ($Cy + $rr * [Math]::Sin($ang)))
    }
    return ConvertTo-SvgPath -Pts $pts -Closed $true -Smooth $false
}

# Река или протока по осевой линии. $Center — точки @(x, y, полуширина).
# Возвращает @{ Fill = залитая полоса; Left/Right = открытые линии берегов (для обводки) }.
function Get-RiverShape {
    param([object[]]$Center, [double]$R = 0.04, [int]$Depth = 4, [System.Random]$Rng)
    $n = $Center.Count
    $left = @(); $right = @()
    for ($i = 0; $i -lt $n; $i++) {
        $p = $Center[$i]
        $a = $Center[[Math]::Max(0, $i - 1)]; $b = $Center[[Math]::Min($n - 1, $i + 1)]
        $tx = $b[0] - $a[0]; $ty = $b[1] - $a[1]; $tl = [Math]::Sqrt($tx * $tx + $ty * $ty)
        $nx = -$ty / $tl; $ny = $tx / $tl; $h = [double]$p[2]
        $left += , @(($p[0] + $nx * $h), ($p[1] + $ny * $h), $R)
        $right += , @(($p[0] - $nx * $h), ($p[1] - $ny * $h), $R)
    }
    $L = Get-RoughPoints -Points $left -Closed $false -Depth $Depth -Rng $Rng
    $Rr = Get-RoughPoints -Points $right -Closed $false -Depth $Depth -Rng $Rng
    $all = New-Object 'System.Collections.Generic.List[double[]]'
    foreach ($q in $L) { $all.Add($q) }
    for ($i = $Rr.Count - 1; $i -ge 0; $i--) { $all.Add($Rr[$i]) }
    return @{
        Fill  = (ConvertTo-SvgPath -Pts $all -Closed $true)
        Left  = (ConvertTo-SvgPath -Pts $L -Closed $false)
        Right = (ConvertTo-SvgPath -Pts $Rr -Closed $false)
    }
}

# Точки по дуге окружности (для круглых заливов): углы в градусах, 0 = восток, 90 = юг (ось y вниз).
function Get-ArcPoints {
    param([double]$Cx, [double]$Cy, [double]$Rad, [double[]]$Angles, [double[]]$Rough)
    $pts = @()
    for ($i = 0; $i -lt $Angles.Count; $i++) {
        $t = $Angles[$i] * [Math]::PI / 180
        $pts += , @(($Cx + $Rad * [Math]::Cos($t)), ($Cy + $Rad * [Math]::Sin($t)), $Rough[$i])
    }
    return , $pts
}

# Запись SVG в UTF-8 без BOM (так Inkscape и Obsidian читают кириллицу без проблем)
function Save-Svg([string]$Path, [string]$Content) {
    $dir = Split-Path $Path -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force $dir | Out-Null }
    [IO.File]::WriteAllText($Path, $Content, (New-Object System.Text.UTF8Encoding $false))
}

# Обёртка слоя Inkscape: видимый или скрытый (скрытые слои включаются в панели «Слои»)
function New-Layer([string]$Id, [string]$Label, [string]$Body, [bool]$Hidden = $false) {
    $style = if ($Hidden) { ' style="display:none"' } else { '' }
    return "<g inkscape:groupmode=`"layer`" id=`"$Id`" inkscape:label=`"$Label`"$style>`n$Body`n</g>`n"
}
