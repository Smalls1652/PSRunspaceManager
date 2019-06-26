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

        switch ($AddJobId) {
            $true {
                Add-Member -InputObject $ReceivedData -MemberType NoteProperty -Name "InstanceId" -Value $j.InstanceId
            }
        }
        $j.Dispose()

        $returnObj += $ReceivedData
    }
}

end {
    return $returnObj
}