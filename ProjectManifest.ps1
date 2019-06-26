$ManifestSplat = @{
    "Path" = "./PSRunspaceManager/PSRunspaceManager.psd1";
    "ModuleVersion" = 1906.26.01;
    "FunctionsToExport" = @(
        "Add-PSRunspaceJob",
        "Close-PSRunspacePool",
        "New-PSRunspacePool",
        "Open-PSRunspacePool",
        "Receive-PSRunspaceJob",
        "Remove-PSRunspacePool"
    );
    "ReleaseNotes" = "
    1906.26:
    - Initial release.
    "
}

Update-ModuleManifest @ManifestSplat