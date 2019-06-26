[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][System.Management.Automation.Runspaces.RunspacePool]$RunspacePool
)

process {

    switch ($RunspacePool.RunspacePoolStateInfo.State) {
        "Closed" {
            Write-Verbose "Runspace pool is closed."
        }
        Default {
            Write-Verbose "Attempting to close Runspace pool."
            $RunspacePool.Close()
        }
    }

    switch ($RunspacePool.IsDisposed) {
        $true {
            Write-Warning "Runspace pool already disposed."
        }

        Default {
            $RunspacePool.Dispose()
        }
    }
}

end {
    return $RunspacePool
}