# Windows 8.1 SMB on custom port

### 1. Install Powershell 5

Download and install: https://avacyn.radiance.hr/stuff/Win8.1AndW2K12R2-KB3191564-x64.msu

Reboot.

### 2. (cmd) Delay LanmanServer start

```bat
sc config lanmanserver start= delayed-auto
```

Also make sure `IP Helper` is set to Automatic.

Reboot.

### 3. (powershell) Enable unrestricted execution

```ps1
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -Force
```

### 4. (powershell) Change PowerShell TLS to 1.2

```ps1
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
```

### 5. (powershell) Install Loopback Adapter

```ps1
Install-Module -Name LoopbackAdapter -MinimumVersion 1.2.0.0
```

### 6. Save setup script

smb.ps1

https://gist.github.com/Hashbrown777/081e57ff9673a1f457e1c3a71b55cfaf

```ps1
<#
	#Required:
	Install-Module -Name LoopbackAdapter -MinimumVersion 1.2.0.0
	#run in admin terminal
	#you do NOT need to disable/remove SMB 1.0/CIFS
	
	
	#Troubleshooting:
	#You can check [attempted] forwardings and [successful] listeners here, respectively
	netsh interface portproxy show v4tov4
	netstat -an | sls ':445'
	#With the server running (or `ssh -L` tunnel to the SMB on another network listening)
	#you can check whether both the unforwarded and forwarded ports are operating with
	Test-NetConnection -ComputerName IP -Port PORT
	
	
	#This might be needed if the above shows forwardings are present, server is accessible, yet the port isn't listening.
	#I'm only including it because it was mentioned in a tutorial I came across;
	#like the SMB1.0 note above, I did not need to do it at all for my script to work
	#and it runs fine (on my Win10 19044) with a stock/opposing setup.
	#
	#lanmanserver (local SMB) may be stealing ports (all interfaces) before iphlpsvc (netsh portproxy) can
	#So add iphlpsvc as a dependant, takes effect upon reboot
	sc.exe `
		config `
		lanmanserver `
		depend= `
		((&{ Get-Service -Name lanmanserver -RequiredServices | %{ $_.Name }; 'iphlpsvc'}) -join '/')
	#similarly apparently workstation might be problematic
	sc.exe `
		config `
		lanmanworkstation `
		depend= `
		((&{ Get-Service -Name lanmanworkstation -RequiredServices | %{ $_.Name }; 'iphlpsvc'}) -join '/')

	#To Undo
	sc.exe `
		config `
		lanmanserver `
		depend= `
		((Get-Service -Name lanmanserver -RequiredServices | %{ $_.Name } | ?{ $_ -ne 'iphlpsvc' }) -join '/')
	sc.exe `
		config `
		lanmanworkstation `
		depend= `
		((Get-Service -Name lanmanworkstation -RequiredServices | %{ $_.Name } | ?{ $_ -ne 'iphlpsvc' }) -join '/')
#>

Import-Module -Name LoopbackAdapter

#Creates a link between this new hostname's ip's SMB port and the given destination ip/port
#Effectively making it so that you can visit \\newhost
#this is achieved by
#-adding a loopback device with the given IP
#-using netsh portproxy to link this IP's 445 with the destination
#-calling Add-Host so you no longer need to rememeber this IP
# (I attempt to detect clashes, but be careful of subnet intrusion,
# and arbituary windows limitations like 127.x.x.x not being available)
#
#The server does not need to be available at time of creation, it will merely be inaccessible
Function Create-Host { Param(
	[Parameter(Mandatory=$true)]$Name,
	[Parameter(Mandatory=$true)]$Ip,
	[Parameter(Mandatory=$true)]$Dest,
	[Parameter(Mandatory=$true)]$Port,
	[switch]$Force
)
	if (
		(Get-NetIPAddress -IPAddress $Ip -ErrorAction SilentlyContinue) -or
		(Test-Connection $Ip -Quiet)
	) {
		throw "$Ip exists"
	}
	netsh `
		interface portproxy `
		add       v4tov4 `
		listenaddress=$Ip `
		listenport=445 `
		connectaddress=$Dest `
		connectport=$Port
	if (!$?) {
		return
	}
	Add-Host `
		-Name $Name `
		-Ip $Ip `
		-Comment 'Loopback machine for custom SMB' `
		-Force:$Force
	
	#the -PassThru of the cmdlets following this one return absolute junk so we cannot do it in one chain
	$adapter = New-LoopbackAdapter -Name $Name -Force:$Force

	$adapter `
	| Disable-NetAdapterBinding `
		-ComponentID ms_msclient,ms_pacer,ms_server,ms_lltdio,ms_rspndr

	$adapter `
	| Set-DnsClient `
		-RegisterThisConnectionsAddress $False `
		-PassThru `
	| Set-NetIPInterface `
		-InterfaceMetric '254' `
		-WeakHostSend    Enabled `
		-WeakHostReceive Enabled `
		-Dhcp Disabled
#this breaks hostname resolution, it also doesnt seem necessary as everything works
#(just keeping it here as it was present in a different tutorial I saw)
#		-SkipAsSource $True

	$adapter `
	| New-NetIPAddress `
		-IPAddress     $Ip `
		-PrefixLength  32 `
		-AddressFamily IPv4 `
	| Out-Null
	
	'Reboot your machine'
}

#cleans up after Create-Host
#NB Create-Host is persistent across reboots, you only need to call it once
#this is for when you will no longer be using the host at all
Function Retire-Host { Param(
	[Parameter(Mandatory=$true)]$Name,
	[switch]$Force
)
	netsh `
		interface portproxy `
		delete    v4tov4 `
		listenaddress=$(Reach-Host -Name $Name -Local) `
		listenport=445
	if (!$?) {
		return
	}
	Remove-Host -Name $Name -Force:$Force
	Remove-LoopbackAdapter -Name $Name -Force:$Force
}

#internal function for grabbing hosts from the hosts file
Function Local-Hosts { Param(
	[Parameter(Mandatory=$true)]$Name,
	[switch]$NotMatch
)
	Select-String `
		-Path    "$([Environment]::SystemDirectory)\drivers\etc\hosts" `
		-Pattern "^\s*([a-f0-9:.]+)\s+$([regex]::Escape($Name))(\s|$)" `
		-NotMatch:$NotMatch
}

#detects whether a hostname resolves on your machine
#-Local forces use only of the hosts file, ignoring DNS
Function Reach-Host { Param(
	[Parameter(Mandatory=$true)]$Name,
	[switch]$Local
)
	if ($Local) {
		Local-Hosts -Name $Name `
		| %{ $_.Matches.Groups[1].Value }
		return
	}
	try {
		Resolve-DnsName $Name -ErrorAction SilentlyContinue `
		| %{ $_.IPAddress }
	}
	catch {
	}
}

#Adds the hostname to your hosts file with the given IP, adding any comment alongside
#without -Force I make sure you're not blocking any reachable hostname
Function Add-Host { Param(
	[Parameter(Mandatory=$true)]$Name,
	[Parameter(Mandatory=$true)]$Ip,
	[switch]$Force,
	$Comment=''
)
	$exists = Reach-Host -Name $Name
	if ($exists) {
		if (!$Force) {
			throw $exists
		}
		if (Local-Hosts -Name $Name) {
			Remove-Host -Name $Name -Force
		}
	}
	if ($Comment) {
		$Comment = '#' + $Comment
	}
	[System.IO.File]::AppendAllText(
		"$([Environment]::SystemDirectory)\drivers\etc\hosts",
		("`r`n" + $Ip,$Name,$Comment -join "`t"),
		[System.Text.Encoding]::ASCII
	)    
}

#Removes the hostname from the hosts file
#-Force skips the check that the host is actually present there
Function Remove-Host { Param(
	[Parameter(Mandatory=$true)]$Name,
	[switch]$Force
)
	if ($Force) {
	}
	elseif (Local-Hosts -Name $Name) {
	}
	else {
		throw "$Name not present"
	}
	
	[System.IO.File]::WriteAllLines(
		"$([Environment]::SystemDirectory)\drivers\etc\hosts",
		(Local-Hosts -Name $Name -NotMatch | %{ $_.Line }),
		[System.Text.Encoding]::ASCII
	)
}
```

### 7. (powershell) Source the script and Create-Host

```ps1
. .\smb.ps1
Create-Host -Name radiance -Ip 10.254.0.1 -Dest 116.202.8.165 -Port 44555
```

Reboot.

### 8. (powershell) Verify that the port is listening

```ps1
netstat -an | sls ':445'
```
Should be:
```ps1
TCP    10.254.0.1:445         0.0.0.0:0              LISTENING
```

### 9. Add SMB server

```
\\10.254.0.1\public
or
\\radiance\public
```

## References

https://superuser.com/questions/702948/how-to-mount-a-samba-share-on-non-standard-port
https://apolonioserafim.blogspot.com/2021/05/acessar-servidor-samba-em-porta.html
https://superuser.com/questions/1094931/ssh-tunnel-on-windows-10-to-linux-samba
https://stackoverflow.com/questions/4037939/powershell-says-execution-of-scripts-is-disabled-on-this-system
https://devblogs.microsoft.com/powershell/when-powershellget-v1-fails-to-install-the-nuget-provider/