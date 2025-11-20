# PowerShell backup script for PostgreSQL
# Usage: .\scripts\backup_db.ps1 -BackupDir .\backups
param(
    [string]$BackupDir = "./backups"
)

$ErrorActionPreference = 'Stop'
$Timestamp = Get-Date -Format yyyyMMdd_HHmmss
$Filename = "backup_$Timestamp.sql"
New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null

# If Docker Compose has a service named 'db', use it
try {
    $compose = docker compose ps db 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Using docker compose exec db pg_dump"
        docker compose exec -T db pg_dump -U catalogo_user catalogo_db > "$BackupDir\$Filename"
        Write-Host "Backup saved to $BackupDir\$Filename"
        return
    }
} catch {}

# Fallback to local pg_dump using DATABASE_URL env var
if (-not $env:DATABASE_URL) {
    Write-Error "DATABASE_URL environment variable not set and no docker-compose 'db' service detected."
    exit 1
}

# Parse DATABASE_URL format: postgresql://user:pass@host:port/dbname
$pattern = 'postgresql://(?<user>[^:]+):(?<pass>[^@]+)@(?<host>[^:]+):(?<port>\d+)/(?<db>[^/?]+)'
$m = [regex]::Match($env:DATABASE_URL, $pattern)
if (-not $m.Success) { Write-Error "DATABASE_URL parsing failed"; exit 1 }

$env:PGPASSWORD = $m.Groups['pass'].Value
$pgUser = $m.Groups['user'].Value
$pgHost = $m.Groups['host'].Value
$pgPort = $m.Groups['port'].Value
$pgDb = $m.Groups['db'].Value

pg_dump -h $pgHost -U $pgUser -p $pgPort -F p -d $pgDb > "$BackupDir\$Filename"
Write-Host "Backup saved to $BackupDir\$Filename"
