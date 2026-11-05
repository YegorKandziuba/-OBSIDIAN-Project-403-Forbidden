<#
  Шифр Виженера для раздаток ваншота «Сломанная бусина».
  Алфавит — 32 буквы (А–Я без Ё; Ё шифруется как Е). Пробелы и знаки препинания не шифруются,
  ключ сдвигается только на буквах. Результат — заглавными.
  Кириллицу в аргументах консоль Windows может испортить — надёжнее через файлы (UTF-8):
           pwsh -File Виженер.ps1 -Mode enc -KeyFile key.txt -InFile текст.txt -OutFile шифр.txt
           pwsh -File Виженер.ps1 -Mode dec -KeyFile key.txt -InFile шифр.txt -OutFile текст.txt
           pwsh -File Виженер.ps1 -Mode enc -PerLine -KeyFile key.txt -InFile депеши.txt -OutFile шифр.txt
             (-PerLine: каждая строка — отдельная депеша, ключ на ней начинается заново)
           pwsh -File Виженер.ps1 -Mode table -OutFile таблица.txt   (таблица Виженера)
#>
param([ValidateSet('enc','dec','table')][string]$Mode = 'enc', [string]$Key = '', [string]$Text = '', [string]$InFile = '', [string]$KeyFile = '', [string]$OutFile = '', [switch]$PerLine)
$A = 'АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ'
$n = $A.Length
if ($Mode -eq 'table') {
  $lines = @(('    ' + (($A.ToCharArray()) -join ' ')), ('    ' + ('-' * (2 * $n - 1))))
  for ($r = 0; $r -lt $n; $r++) { $row = for ($c = 0; $c -lt $n; $c++) { $A[($r + $c) % $n] }; $lines += ($A[$r] + ' | ' + ($row -join ' ')) }
  if ($OutFile) { [IO.File]::WriteAllText($OutFile, ($lines -join "`n"), [Text.UTF8Encoding]::new($false)) } else { $lines -join "`n" }; return
}
if ($InFile) { $Text = [IO.File]::ReadAllText($InFile) }
if ($KeyFile) { $Key = ([IO.File]::ReadAllText($KeyFile)).Trim() }
$k = ($Key.ToUpper() -replace 'Ё', 'Е').ToCharArray() | Where-Object { $A.IndexOf($_) -ge 0 }
if (-not $k) { throw 'Пустой ключ' }
$src = ($Text.ToUpper() -replace 'Ё', 'Е')
$sb = [System.Text.StringBuilder]::new(); $i = 0
foreach ($ch in $src.ToCharArray()) {
  $p = $A.IndexOf($ch)
  if ($ch -eq [char]10 -and $PerLine) { $i = 0 }
  if ($p -lt 0) { [void]$sb.Append($ch); continue }
  $s = $A.IndexOf($k[$i % $k.Count]); $i++
  $q = if ($Mode -eq 'enc') { ($p + $s) % $n } else { ($p - $s + $n) % $n }
  [void]$sb.Append($A[$q])
}
if ($OutFile) { [IO.File]::WriteAllText($OutFile, $sb.ToString(), [Text.UTF8Encoding]::new($false)) } else { $sb.ToString() }
