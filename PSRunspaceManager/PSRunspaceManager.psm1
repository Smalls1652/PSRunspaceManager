function Add-PSRunspaceJob {
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
}

function Close-RunspacePool {
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
                $RunspacePool.Close()
            }
            "Closed" {
                Write-Warning "Runspace is already in a closed state."
            }
        }
    }

    end {
        return [pscustomobject]@{
            "RunspaceId" = $RunspacePool.InstanceId;
            "State"      = $RunspacePool.RunspacePoolStateInfo.State
        }
    }
}

function New-PSRunspacePool {
    [CmdletBinding()]
    param()

    begin {
        $RunspacePool = [runspacefactory]::CreateRunspacePool()

        $MaxNumberOfRunspaces = ($env:NUMBER_OF_PROCESSORS + 1)
    }
    process {
        $null = $RunspacePool.ApartmentState = 1 #Set to multithreaded performance
        $null = $RunspacePool.SetMinRunspaces(1)
        $null = $RunspacePool.SetMaxRunspaces($MaxNumberOfRunspaces)
    }

    end {
        return $RunspacePool
    }
}

function Open-PSRunspacePool {
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
            "State"      = $RunspacePool.RunspacePoolStateInfo.State
        }
    }
}

function Receive-PSRunspaceJob {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()]$Job,
        [switch]$AddJobId
    )

    begin {

        if (($Job | Measure-Object | Select-Object -ExpandProperty "Count") -eq 1) {
            $JobList = @($Job)
        }
        else {
            $JobList = $Job
        }

        if ($JobList.JobStatus.IsCompleted -contains $false) {
            Write-Verbose "Waiting for jobs to finish."
            while ($JobList.JobStatus.IsCompleted -contains $false) {
                Start-Sleep -Seconds 1
            }
        }

        $returnObj = @()
    }

    process {
        foreach ($j in $JobList) {
            $ReceivedData = $j.EndInvoke($j.JobStatus)

            $j.Dispose()

            $returnObj += $ReceivedData
        }
    }

    end {
        return $returnObj
    }
}

function Remove-PSRunspacePool {
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
}