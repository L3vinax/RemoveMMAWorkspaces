$InformationPreference = "Continue"
Write-Information -MessageData "Starting Log Analytics Workspace removal script for the Microsoft Monitoring Agent."

[System.Collections.ArrayList]$WorkspacesToRemove = @()

$mma = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg'
$mma.GetCloudWorkspaces() | ForEach-Object -Process {
    $WorkspacesToRemove.Add($_)
}

[System.Int32]$i = 1
[System.Int32]$WorkspacesToRemoveCount = $WorkspacesToRemove.Count

foreach ($Object in $WorkspacesToRemove) {
    [System.String]$WorkspaceID = $Object.WorkspaceID

    Write-Information -MessageData "Working on Log Analytics Workspace ID: '$WorkspaceID'. Workspace: '$i' of: '$WorkspacesToRemoveCount' workspaces to remove."

    if ($mma.GetCloudWorkspace($WorkspaceID)) {
        Write-Information -MessageData "Log Analytics Workspace ID: '$WorkspaceID' detected. Removing it."
        $mma.RemoveCloudWorkspace($WorkspaceID)

        Write-Information -MessageData "Log Analytics Workspace ID: '$WorkspaceID' removed. Reloading MMA configuration."
        $mma.ReloadConfiguration()

        Write-Information -MessageData "MMA configuration reloaded."
    }
    else {
        Write-Information -MessageData "Log Analytics Workspace ID: '$WorkspaceID' not detected. Moving on."
    }

    $i++
}
