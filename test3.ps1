Import-Module Posh-SSH

[System.Collections.ArrayList]$ciscos = Import-Csv "E:\ps\confcisco\hosts.csv"
[System.Collections.ArrayList]$commands = Import-Csv "E:\ps\confcisco\command.csv"
$Cred = Get-Credential netadmin
$Date = Get-Date
$logs_path = "e:\ps\confcisco\logs-detailed"+"-"+$Date.Year.ToString()+"."+$Date.Month.ToString()+"."+$Date.Day.ToString()+"_"+$Date.Hour.ToString()+"-"+$Date.Minute.ToString()+"-"+$Date.Second.ToString()

$jobs = @()

$RunspacePool = [runspacefactory]::CreateRunspacePool(1,4)
$RunspacePool.Open()

$Code = { param($cisco,$cred,$logs_path,$commands) 
    $cisconame = $cisco.host
    $SSHSession = New-SSHSession -ComputerName $cisco.host -Credential $Cred
    $SSH = $sshSession | New-SSHShellStream
    $logs = $logs_path
    $dir_exist = Test-Path($logs)
    if($dir_exist -eq $false){
        New-Item -Path $logs -ItemType "directory" | Out-Null
    }
    $filepath +=$logs + "\"+$cisconame+".txt"
    
    Start-Sleep -Seconds 1
    $ssh.read() | Out-File $filepath -Append
        #run command
        foreach($command in $commands){
            $ssh.WriteLine( $command.command ) | Out-File $filepath -Append
            Start-Sleep -Seconds 1
            $ssh.read() | Out-File $filepath -Append
            Start-Sleep -Seconds 1
            }
    Get-SSHSession | Remove-SSHSession
    }   
    
    foreach($cisco in $ciscos){
            $PSinstance = [powershell]::Create().AddScript($Code).AddArgument($cisco).AddArgument($Cred).AddArgument($logs_path).AddArgument($commands)
            $PSinstance.RunspacePool = $RunspacePool
            $jobs += [PSCustomObject]@{ Pipe = $PSinstance; Status = $PSinstance.BeginInvoke() }
    }
    
    while ($jobs.Status -ne $null)
    {
        $completed = $jobs | Where-Object { $_.Status.IsCompleted -eq $true }
        foreach ($job in $completed)
        {
            $job.Pipe.EndInvoke($job.Status)
            $job.Status = $null
            $res
        }   
    }
    $RunspacePool.Close()
    $RunspacePool.Dispose()
