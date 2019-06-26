[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][System.Management.Automation.Runspaces.RunspacePool]$RunspacePool,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][scriptblock]$Scriptblock,
    $Arguments
)

begin {
    $ArgumentsArray = @()

    Write-Verbose "Adding arguments to an array."
    if (($Arguments | Measure-Object | Select-Object -ExpandProperty "Count") -gt 1) {
        foreach ($a in $Arguments) {
            $ArgumentsArray += $a
        }
    }
    elseif (($Arguments | Measure-Object | Select-Object -ExpandProperty "Count") -eq 1) {
        $ArgumentsArray += $Arguments
    }
    else {
        Write-Verbose "No arguments provided. Skipping."
    }
}

process {
    Write-Verbose "Creating PowerShell object."
    $Job = [powershell]::Create()

    Write-Verbose "Adding scriptblock to PowerShell object."
    $null = $Job.AddScript($Scriptblock)

    if ($ArgumentsArray.Count -ge 1) {
        Write-Verbose "Passing arguments to PowerShell object."
        foreach ($a in $ArgumentsArray) {
            $null = $Job.AddArgument($a)
        }
    }

    Write-Verbose "Assigning PowerShell object to the provided runspace pool."
    $null = $Job.RunspacePool = $RunspacePool
}

end {
    Add-Member -InputObject $Job -MemberType NoteProperty -Name "JobStatus" -Value $Job.BeginInvoke()
    return $Job
}