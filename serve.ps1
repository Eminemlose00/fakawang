Param(
  [string]$Port = "5173"
)

$Prefix = "http://localhost:$Port/"
$Root = (Get-Location).Path

function Get-ContentType($path) {
  $ext = [System.IO.Path]::GetExtension($path).ToLower()
  switch ($ext) {
    ".html" { return "text/html; charset=utf-8" }
    ".css"  { return "text/css; charset=utf-8" }
    ".js"   { return "application/javascript; charset=utf-8" }
    ".json" { return "application/json; charset=utf-8" }
    ".png"  { return "image/png" }
    ".jpg"  { return "image/jpeg" }
    ".jpeg" { return "image/jpeg" }
    ".svg"  { return "image/svg+xml" }
    default  { return "text/plain; charset=utf-8" }
  }
}

# Use .NET HttpListener directly without Add-Type
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($Prefix)
try {
  $listener.Start()
} catch {
  Write-Host ("Failed to start listener: " + $_.Exception.Message) -ForegroundColor Red
  exit 1
}

Write-Host ("Serving " + $Root + " at " + $Prefix) -ForegroundColor Green

while ($true) {
  try {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response

    $path = $request.Url.AbsolutePath.TrimStart('/')
    if ([string]::IsNullOrWhiteSpace($path)) { $path = "index.html" }

    # Prevent directory traversal
    $fullPath = [System.IO.Path]::GetFullPath((Join-Path $Root $path))
    if (-not $fullPath.StartsWith($Root)) {
      $response.StatusCode = 403
      $bytes = [System.Text.Encoding]::UTF8.GetBytes("Forbidden")
      $response.OutputStream.Write($bytes, 0, $bytes.Length)
      $response.OutputStream.Close()
      continue
    }

    if (Test-Path $fullPath) {
      $bytes = [System.IO.File]::ReadAllBytes($fullPath)
      $response.ContentType = Get-ContentType $fullPath
      $response.ContentLength64 = $bytes.Length
      $response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $response.StatusCode = 404
      $bytes = [System.Text.Encoding]::UTF8.GetBytes("Not Found")
      $response.OutputStream.Write($bytes, 0, $bytes.Length)
    }

    $response.OutputStream.Close()
  } catch {
    Write-Host ("Request error: " + $_.Exception.Message) -ForegroundColor Yellow
  }
}