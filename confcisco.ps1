Import-Module Posh-SSH

[System.Collections.ArrayList]$ciscos = Import-Csv "E:\ps\confcisco\hosts.csv"
[System.Collections.ArrayList]$commands = Import-Csv "E:\ps\confcisco\command.csv"
$Cred = Get-Credential netadmin


#create session's
foreach($cisco in $ciscos){
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
