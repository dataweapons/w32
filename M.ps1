[cmdletbinding()]
param (
[parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
[string[]]$ComputerName = $env:computername,
[string]$UserName
)            

foreach ($Computer in $ComputerName) {
 $Profiles = Get-WmiObject -Class Win32_UserProfile -Computer $Computer -ea 0
 foreach ($profile in $profiles) {
  $objSID = New-Object System.Security.Principal.SecurityIdentifier($profile.sid)
  $objuser = $objsid.Translate([System.Security.Principal.NTAccount])
  switch($status.Status) {
   1 { $profileType="Temporary" }
   2 { $profileType="Roaming" }
   4 { $profileType="Mandatory" }
   8 { $profileType="Corrupted" }
   default { $profileType = "LOCAL" }
  }
  $User = $objUser.Value
  $ProfileLastUseTime = ([WMI]"").Converttodatetime($profile.lastusetime)
  $OutputObj = New-Object -TypeName PSobject
  $OutputObj | Add-Member -MemberType NoteProperty -Name ComputerName -Value $Computer.toUpper()
  $OutputObj | Add-Member -MemberType NoteProperty -Name ProfileName -Value $objuser.value
  $OutputObj | Add-Member -MemberType NoteProperty -Name ProfilePath -Value $profile.localpath
  $OutputObj | Add-Member -MemberType NoteProperty -Name ProfileType -Value $ProfileType
  $OutputObj | Add-Member -MemberType NoteProperty -Name IsinUse -Value $profile.loaded
  $OutputObj | Add-Member -MemberType NoteProperty -Name IsSystemAccount -Value $profile.special
  if($UserName) {
   if($User -match $UserName) {
    $OutputObj
   }
  } else {
   $OutputObj
  }
 }
}
