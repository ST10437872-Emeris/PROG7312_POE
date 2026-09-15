#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
if ! command -v dotnet >/dev/null 2>&1 || ! dotnet --list-sdks | grep -q '^10\.'; then
  echo 'Install the .NET 10 SDK: https://dotnet.microsoft.com/download/dotnet/10.0'
  exit 1
fi
echo 'Starting Smart-X. Open http://localhost:5080 after the gateway starts.'
echo 'Keep this terminal open. Press Ctrl+C to stop.'
exec dotnet run --project src/SmartX.Api -c Release
