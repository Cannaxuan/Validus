param([string]$inSource, [string]$dest)
Add-Type -assembly "system.io.compression.filesystem"
[io.compression.zipfile]::CreateFromDirectory($inSource, $dest)