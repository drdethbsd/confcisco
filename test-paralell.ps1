
$test1 = 4
$test2 = 5

$jobs = New-Object System.Collections.ArrayList
$data = New-Object System.Collections.ArrayList

$RunspacePool = [runspacefactory]::CreateRunspacePool(1,4)
$RunspacePool.Open()

$Code = { param($test1,$test2) 
    $test3 = $test1+$test2
    $test3
}

$code2 = {
    sleep(10)
    $test3 = $test1+$test2
    $test3
}
for ($i = 0; $i -lt 3; $i++) {
if($i -eq 1){
    $PSinstance = [powershell]::Create().AddScript($Code2).AddArgument($test1).AddArgument($test2)
    $PSinstance.RunspacePool = $RunspacePool
    $jobs.Add($PSinstance.BeginInvoke()) 
    $data.Add($PSinstance.EndInvoke($jobs[$i]))
}else{
    $PSinstance = [powershell]::Create().AddScript($Code).AddArgument($test1).AddArgument($test2)
    $PSinstance.RunspacePool = $RunspacePool
    $jobs.Add($PSinstance.BeginInvoke()) 
    $data.Add($PSinstance.EndInvoke($jobs[$i]))
}
}
$data