[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][System.Management.Automation.Runspaces.RunspacePool]$RunspacePool
)

begin {
    switch ($RunspacePool.IsDisposed) {
        $true {
            Write-Error -Message "Runspace pool is disposed." -Category ResourceUnavailable -ErrorId "PSRunspaceManager.OpenRunspace.PoolDisposed" -TargetObject $RunspacePool -RecommendedAction "Create a new Runspace pool." -CategoryActivity "OpenRunspace" -CategoryReason "Runspace pool is disposed." -ErrorAction Stop
        }
    }
}

process {
    Write-Verbose "Checking current status of Runspace pool."

    switch ($RunspacePool.RunspacePoolStateInfo.State) {
        Default {
            Write-Warning "Runspace pool is not in a BeforeOpen state."
        }
        "Closed" {
            Write-Warning "Runspace pool cannot be reopened from Closed state. Create a new Runspace pool."
        }
        "BeforeOpen" {
            Write-Verbose "Opening Runspace pool."
            $RunspacePool.Open()
        }
    }
}

end {
    return [pscustomobject]@{
        "RunspaceId" = $RunspacePool.InstanceId;
        "State" = $RunspacePool.RunspacePoolStateInfo.State
    }
}