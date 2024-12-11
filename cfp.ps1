Import-Module Posh-SSH

[System.Collections.ArrayList]$ciscos = Import-Csv "E:\ps\confcisco\hosts.csv"
[System.Collections.ArrayList]$commands = Import-Csv "E:\ps\confcisco\command.csv"
$Cred = Get-Credential netadmin

$jobs = New-Object System.Collections.ArrayList
$data = New-Object System.Collections.ArrayList

$RunspacePool = [runspacefactory]::CreateRunspacePool(1,4)
$RunspacePool.Open()

$Code = { param($cisco,$cred,$commands) 
    $SSHSession = New-SSHSession -ComputerName $cisco.host -Credential $Cred
    $SSH = $sshSession | New-SSHShellStream
    Start-Sleep -Seconds 1
    $ssh.read() 
        #run command
        foreach($command in $commands){
            $ssh.WriteLine( $command.command )
            Start-Sleep -Seconds 1
            $ssh.read()
            Start-Sleep -Seconds 1
            }
    Get-SSHSession | Remove-SSHSession 
    }
     

    forech($cisco in $ciscos){
        $PSinstance = [powershell]::Create().AddScript($Code).AddArgument($cisco).AddArgument($Cred).AddArgument($commands)
        $PSinstance.RunspacePool = $RunspacePool
        $jobs.Add($PSinstance.BeginInvoke()) 
    }

$data