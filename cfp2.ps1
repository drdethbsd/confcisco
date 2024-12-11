Import-Module Posh-SSH

[System.Collections.ArrayList]$ciscos = Import-Csv "E:\ps\confcisco\hosts.csv"
[System.Collections.ArrayList]$commands = Import-Csv "E:\ps\confcisco\command.csv"
$Cred = Get-Credential netadmin

$jobs = New-Object System.Collections.ArrayList
$data = New-Object System.Collections.ArrayList
$finalresult = New-Object System.Collections.ArrayList

$RunspacePool = [runspacefactory]::CreateRunspacePool(1,4)
$RunspacePool.Open()

$Code = { param($cisco,$cred,$commands) 
    $cisconame = $cisco.host
    $SSHSession = New-SSHSession -ComputerName $cisco.host -Credential $Cred
    $SSH = $sshSession | New-SSHShellStream
    Start-Sleep -Seconds 1
    $ssh.read() | Out-File "E:\ps\confcisco\res-$cisconame.txt" -Append
        #run command
        foreach($command in $commands){
            $ssh.WriteLine( $command.command ) | Out-File "E:\ps\confcisco\res-$cisconame.txt" -Append
            Start-Sleep -Seconds 1
            $ssh.read() | Out-File "E:\ps\confcisco\res-$cisconame.txt" -Append
            Start-Sleep -Seconds 1
            }
    Get-SSHSession | Remove-SSHSession
    }   
    $i = 0
        foreach($cisco in $ciscos){
            $PSinstance = [powershell]::Create().AddScript($Code).AddArgument($cisco).AddArgument($Cred).AddArgument($commands)
            $PSinstance.RunspacePool = $RunspacePool
            $jobs.Add($PSinstance.BeginInvoke())
            #$data.Add($PSinstance.EndInvoke($jobs[$i]))
            #$i++
    }

    
    #$data

