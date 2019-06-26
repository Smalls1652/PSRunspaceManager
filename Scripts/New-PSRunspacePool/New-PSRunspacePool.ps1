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