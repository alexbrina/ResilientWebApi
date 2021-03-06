# =============================================================================
# Functions
# =============================================================================
function Get-ApiStatus {
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:5000/work"
        if ($response -eq "")
        {
            return "ok";
        }
    }
    catch [System.Net.Http.HttpRequestException] {
        return "retry";
    }
    return "failed"
}

# =============================================================================
# Main
# =============================================================================

# build api
$build = Start-Process -FilePath "dotnet" -ArgumentList "build" -WorkingDirectory "$PSScriptRoot/../Resilient.WebApi" -PassThru -RedirectStandardOutput "__build.log" -Wait

# evaluate success/failure
if($build.ExitCode -eq 0)
{
    # Success
}
else
{
    # Failure
    Write-Error "Could not build api"
    return
}

# start api
$sut = Start-Process -FilePath "dotnet" -ArgumentList "run" -WorkingDirectory "$PSScriptRoot/../Resilient.WebApi" -PassThru -RedirectStandardOutput "__output.log"

# wait ready status
$counter = 0
$status = Get-ApiStatus
while ($status -eq "retry" -and $counter++ -lt 10) {
    Start-Sleep -Milliseconds 500
    $status = Get-ApiStatus
}
if ($status -eq "failed")
{
    Write-Error "Could not start api"
    return
}

# run tests
D:\AP\k6\k6 run --vus 100 --duration 10s .\script.js

# wait key press to close api
Write-Output "Finished running load test!"
Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
Stop-Process $sut.Id 
