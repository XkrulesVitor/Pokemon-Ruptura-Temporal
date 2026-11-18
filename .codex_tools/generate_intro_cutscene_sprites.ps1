$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$outDir = Join-Path (Resolve-Path ".").Path "datafiles\sprites\cutscene"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

function New-Brush([int]$r, [int]$g, [int]$b, [int]$a = 255) {
    return New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb($a, $r, $g, $b))
}

function Draw-Rect($g, [int]$x, [int]$y, [int]$w, [int]$h, $brush) {
    $g.FillRectangle($brush, $x, $y, $w, $h)
}

function Draw-Poly($g, [int[]]$points, $brush) {
    $pts = New-Object System.Drawing.Point[] ($points.Length / 2)
    for ($i = 0; $i -lt $points.Length; $i += 2) {
        $pts[$i / 2] = New-Object System.Drawing.Point ($points[$i], $points[$i + 1])
    }
    $g.FillPolygon($brush, $pts)
}

function Draw-PixelCloud($g, [int]$x, [int]$y, [double]$s, $main, $shade, $light) {
    $parts = @(
        @(-18, 8, 18, 12), @(-8, -2, 22, 18), @(8, -6, 18, 18),
        @(22, 4, 22, 14), @(-26, 14, 58, 10), @(-12, 4, 44, 14)
    )
    foreach ($p in $parts) {
        $g.FillEllipse($main, [int]($x + $p[0] * $s), [int]($y + $p[1] * $s), [int]($p[2] * $s), [int]($p[3] * $s))
    }
    Draw-Rect $g ([int]($x - 22 * $s)) ([int]($y + 17 * $s)) ([int](62 * $s)) ([int](7 * $s)) $shade
    Draw-Rect $g ([int]($x - 7 * $s)) ([int]($y + 1 * $s)) ([int](18 * $s)) ([int](3 * $s)) $light
    Draw-Rect $g ([int]($x + 18 * $s)) ([int]($y + 9 * $s)) ([int](18 * $s)) ([int](3 * $s)) $light
}

function Draw-RuinedBuilding($g, [int]$x, [int]$base, [int]$w, [int]$h, [int]$seed, $wall, $dark, $edge, $window, $ember) {
    $top = $base - $h
    Draw-Rect $g ($x + 2) ($top + 5) ($w + 5) ($h + 8) $dark
    Draw-Rect $g $x ($top + 8) $w $h $wall

    $notches = @(0, 8, 13, 6, 22, 11, 31, 3, 42, 9)
    foreach ($n in 0..4) {
        $nx = $x + $notches[$n * 2] % [Math]::Max(1, $w - 8)
        $nh = 4 + (($seed + $n * 3) % 8)
        Draw-Rect $g $nx ($top + 8) (5 + (($seed + $n) % 5)) $nh $dark
    }

    Draw-Rect $g ($x - 3) ($base - 4) ($w + 8) 5 $edge
    Draw-Rect $g ($x + 4) ($top + 8) 2 ($h - 7) $edge
    Draw-Rect $g ($x + $w - 6) ($top + 12) 2 ($h - 12) $dark

    for ($i = 0; $i -lt 8; $i++) {
        $wx = $x + 6 + (($i % 2) * [Math]::Max(10, [int]($w * 0.48)))
        $wy = $top + 16 + ($i * 8)
        if ($wy -lt $base - 10) {
            Draw-Rect $g $wx $wy 3 5 $window
        }
    }

    $pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(185, 74, 86, 84)), 1
    $g.DrawLine($pen, $x + 7, $top + 22, $x + $w - 7, $top + 38 + ($seed % 14))
    $g.DrawLine($pen, $x + $w - 9, $top + 14, $x + 12, $top + 55)
    $pen.Dispose()

    for ($r = 0; $r -lt 6; $r++) {
        $rx = $x - 7 + (($seed * 11 + $r * 13) % ($w + 14))
        $ry = $base + (($r * 3 + $seed) % 10)
        Draw-Rect $g $rx $ry (5 + ($r % 4)) 3 $dark
    }

    for ($e = 0; $e -lt 12; $e++) {
        $ex = $x + (($seed * 17 + $e * 7) % [Math]::Max(1, $w))
        $ey = $base - 5 - (($e * 3 + $seed) % 15)
        Draw-Rect $g $ex $ey (1 + ($e % 2)) 1 $ember
    }
}

function Draw-Lightning($g, [int]$x, [int]$y, $bright, $soft) {
    $wide = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(110, 115, 240, 255)), 3
    $thin = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(245, 234, 255, 255)), 1
    $pts = @(
        (New-Object System.Drawing.Point -ArgumentList $x, $y),
        (New-Object System.Drawing.Point -ArgumentList ($x - 5), ($y + 13)),
        (New-Object System.Drawing.Point -ArgumentList ($x + 3), ($y + 13)),
        (New-Object System.Drawing.Point -ArgumentList ($x - 8), ($y + 34)),
        (New-Object System.Drawing.Point -ArgumentList ($x + 5), ($y + 25))
    )
    $g.DrawLines($wide, $pts)
    $g.DrawLines($thin, $pts)
    $wide.Dispose()
    $thin.Dispose()
}

function Draw-FireCluster($g, [int]$x, [int]$base, [double]$s, [int]$seed, $outer, $mid, $inner, $dark, $smoke) {
    $glow = New-Brush 255 86 28 (34 + (($seed * 9) % 28))
    $g.FillEllipse($glow, [int]($x - 16 * $s), [int]($base - 16 * $s), [int](36 * $s), [int](25 * $s))
    $glow.Dispose()

    Draw-Rect $g ([int]($x - 17 * $s)) ([int]($base - 3 * $s)) ([int](39 * $s)) ([int](4 * $s)) $dark

    $blocks = @(
        @(-13,-9,7,9,0), @(-7,-16,7,16,1), @(0,-23,7,23,2), @(7,-15,8,15,1), @(14,-8,6,8,0),
        @(-4,-28,5,10,1), @(4,-32,5,12,2), @(10,-24,4,9,1), @(-11,-21,4,8,0)
    )

    foreach ($b in $blocks) {
        $brush = $outer
        if ($b[4] -eq 1) { $brush = $mid }
        if ($b[4] -eq 2) { $brush = $inner }
        Draw-Rect $g ([int]($x + $b[0] * $s)) ([int]($base + $b[1] * $s)) ([int]($b[2] * $s)) ([int]($b[3] * $s)) $brush
    }

    for ($e = 0; $e -lt 9; $e++) {
        $ex = $x - 20 + (($seed * 7 + $e * 11) % 42)
        $ey = $base - 10 - (($seed * 5 + $e * 7) % 30)
        Draw-Rect $g $ex $ey (1 + ($e % 2)) 1 $(if (($e % 3) -eq 0) { $inner } else { $mid })
    }

    $g.FillEllipse($smoke, [int]($x - 18 * $s), [int]($base - 56 * $s), [int](20 * $s), [int](18 * $s))
    $g.FillEllipse($smoke, [int]($x + 2 * $s), [int]($base - 66 * $s), [int](24 * $s), [int](20 * $s))
}

function Draw-RubblePile($g, [int]$x, [int]$y, [int]$w, [int]$seed, $dark, $edge, $ember) {
    Draw-Rect $g $x $y $w 4 $dark

    for ($i = 0; $i -lt 10; $i++) {
        $rx = $x + (($seed * 13 + $i * 17) % [Math]::Max(1, $w))
        $ry = $y - (($i * 3 + $seed) % 10)
        Draw-Rect $g $rx $ry (4 + ($i % 5)) (2 + ($i % 3)) $(if (($i % 3) -eq 0) { $edge } else { $dark })
    }

    for ($e = 0; $e -lt 8; $e++) {
        Draw-Rect $g ($x + (($seed * 19 + $e * 23) % [Math]::Max(1, $w))) ($y - 2 - (($e * 5) % 12)) (1 + ($e % 2)) 1 $ember
    }
}

function Save-Scaled($src, [string]$path) {
    $dst = New-Object System.Drawing.Bitmap 1365, 432, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g2 = [System.Drawing.Graphics]::FromImage($dst)
    $g2.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $g2.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
    $g2.Clear([System.Drawing.Color]::Transparent)
    $g2.DrawImage($src, 0, 0, 1365, 432)
    $dst.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g2.Dispose()
    $dst.Dispose()
}

function New-CutsceneSprite([bool]$night, [string]$path) {
    $bmp = New-Object System.Drawing.Bitmap 455, 144, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::None
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $g.Clear([System.Drawing.Color]::Transparent)

    if ($night) {
        $mountA = New-Brush 25 55 65 210
        $mountB = New-Brush 34 76 82 225
        $mountHi = New-Brush 70 112 112 105
        $cloud = New-Brush 38 55 68 218
        $cloudShade = New-Brush 20 30 44 235
        $cloudLight = New-Brush 88 118 132 140
        $wall = New-Brush 20 34 40 235
        $dark = New-Brush 8 15 22 245
        $edge = New-Brush 48 72 72 185
        $window = New-Brush 214 150 72 210
        $ember = New-Brush 255 112 44 240
        $fireOuter = New-Brush 202 50 32 245
        $fireMid = New-Brush 255 118 42 248
        $fireInner = New-Brush 255 224 106 248
        $rubble = New-Brush 10 18 22 235
    } else {
        $mountA = New-Brush 44 100 102 155
        $mountB = New-Brush 62 128 124 165
        $mountHi = New-Brush 158 220 208 96
        $cloud = New-Brush 190 238 228 160
        $cloudShade = New-Brush 146 210 204 118
        $cloudLight = New-Brush 232 255 248 120
        $wall = New-Brush 24 40 46 218
        $dark = New-Brush 8 18 24 230
        $edge = New-Brush 64 92 92 165
        $window = New-Brush 236 174 74 225
        $ember = New-Brush 255 114 42 240
        $fireOuter = New-Brush 224 58 34 245
        $fireMid = New-Brush 255 130 42 248
        $fireInner = New-Brush 255 232 112 248
        $rubble = New-Brush 18 34 36 215
    }

    Draw-Poly $g @(0,116, 56,73, 118,116) $mountA
    Draw-Poly $g @(82,116, 196,48, 306,116) $mountB
    Draw-Poly $g @(230,116, 356,62, 455,116) $mountA
    Draw-Poly $g @(150,116, 226,66, 288,116) $mountHi
    Draw-Poly $g @(318,116, 400,72, 455,116) $mountHi

    Draw-Rect $g 0 115 455 6 (New-Brush 35 86 76 190)
    Draw-Rect $g 0 121 455 5 (New-Brush 21 56 52 180)
    Draw-Rect $g 0 127 455 3 (New-Brush 8 22 24 105)
    for ($i = 0; $i -lt 42; $i++) {
        Draw-Rect $g (($i * 31 + 7) % 455) (117 + (($i * 7) % 12)) (7 + ($i % 5)) 2 (New-Brush 22 46 44 170)
    }

    Draw-PixelCloud $g 44 34 0.72 $cloud $cloudShade $cloudLight
    Draw-PixelCloud $g 83 24 0.98 $cloud $cloudShade $cloudLight
    Draw-PixelCloud $g 193 11 0.64 $cloud $cloudShade $cloudLight
    Draw-PixelCloud $g 309 31 0.82 $cloud $cloudShade $cloudLight
    Draw-PixelCloud $g 397 19 0.72 $cloud $cloudShade $cloudLight
    Draw-PixelCloud $g 430 44 0.60 $cloud $cloudShade $cloudLight
    if ($night) {
        Draw-PixelCloud $g 130 35 1.12 $cloud $cloudShade $cloudLight
        Draw-PixelCloud $g 246 27 0.82 $cloud $cloudShade $cloudLight
        Draw-PixelCloud $g 354 37 1.08 $cloud $cloudShade $cloudLight
        Draw-Lightning $g 139 53 (New-Brush 230 255 255 255) (New-Brush 100 220 255 110)
        Draw-Lightning $g 250 46 (New-Brush 230 255 255 255) (New-Brush 100 220 255 110)
        Draw-Lightning $g 366 50 (New-Brush 230 255 255 255) (New-Brush 100 220 255 110)
    }

    $buildings = @(
        @(18,122,24,55,1), @(73,122,27,70,4), @(130,120,29,62,7),
        @(177,121,38,86,10), @(229,122,25,56,13), @(272,121,32,78,16),
        @(330,120,36,66,19), @(394,121,35,82,22)
    )
    foreach ($b in $buildings) {
        Draw-RuinedBuilding $g $b[0] $b[1] $b[2] $b[3] $b[4] $wall $dark $edge $window $ember
    }

    $rubblePiles = @(
        @(12,128,42,3), @(63,129,56,6), @(150,127,48,9), @(214,129,64,12),
        @(291,128,58,15), @(373,129,66,18)
    )
    foreach ($rp in $rubblePiles) {
        Draw-RubblePile $g $rp[0] $rp[1] $rp[2] $rp[3] $rubble $edge $ember
    }

    $fires = @(
        @(24,123,0.72,2), @(92,124,0.58,5), @(178,123,0.78,8), @(222,123,0.52,11),
        @(282,124,0.68,14), @(340,124,0.54,17), @(405,123,0.76,20)
    )
    foreach ($f in $fires) {
        Draw-FireCluster $g $f[0] $f[1] $f[2] $f[3] $fireOuter $fireMid $fireInner $dark $(if ($night) { New-Brush 8 12 18 92 } else { New-Brush 34 50 52 72 })
    }

    for ($s = 0; $s -lt 20; $s++) {
        $sx = (18 + $s * 37) % 455
        $sy = 122 + (($s * 5) % 18)
        $smoke = if ($night) { New-Brush 8 12 18 (80 + (($s * 11) % 60)) } else { New-Brush 34 50 52 (58 + (($s * 13) % 58)) }
        $g.FillEllipse($smoke, $sx, $sy - 58 - (($s * 7) % 30), 16 + ($s % 4) * 4, 14 + ($s % 3) * 5)
        $smoke.Dispose()
    }

    Save-Scaled $bmp $path
    $g.Dispose()
    $bmp.Dispose()

    $mountA.Dispose(); $mountB.Dispose(); $mountHi.Dispose()
    $cloud.Dispose(); $cloudShade.Dispose(); $cloudLight.Dispose()
    $wall.Dispose(); $dark.Dispose(); $edge.Dispose(); $window.Dispose(); $ember.Dispose()
    $fireOuter.Dispose(); $fireMid.Dispose(); $fireInner.Dispose(); $rubble.Dispose()
}

New-CutsceneSprite $false (Join-Path $outDir "intro_destroyed_horizon_day.png")
New-CutsceneSprite $true (Join-Path $outDir "intro_destroyed_horizon_night.png")
Write-Output "Generated intro cutscene sprites in $outDir"
