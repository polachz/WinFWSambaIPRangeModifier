#
#title           :smb_fw_ranges.ps1
#description     :modify remote IP ranges for Incomming Samba FW rules 
#author          :zdenek polach ( https://github.com/polachz )
#date            :16.05.2017
#version         :0.1
#usage           :smb_fw_ranges.ps1 public 10.10.1.0/24, 10.10.2.3-10.10.2.20
#notes           :
#==============================================================================
#
# MIT License
#
# Copyright (c) 2017 Zdenek Polach

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#==============================================================================

param (
	[parameter(Mandatory=$true, Position=1)]
        [alias("p")][string]$fwprofile,
		[parameter(Position=2)]
	    [alias("s")][string[]]$Subnets
)

If ("Private","Public" -NotContains $fwprofile) 
{ 
    write-host "The value '$($fwprofile)' is not a valid profile!! Please use 'Private' or 'Public'" -foregroundcolor "red"
    exit
} 
if($Subnets.Count -eq 0 ){
   write-host "You have to specify one or more subnets here" -foregroundcolor "red"
	exit
}

		 
# Get all public profiles in FileSharing group
$RulesSet = Get-NetFirewallRule | where {$_.DisplayGroup -match "File and Printer Sharing" -and $_.Direction -eq "Inbound" -and $_.Profile -match "Public" }
#Sometimes, one rule has privatge and public profile set together
#We have to split them, one rule for public and another for private
$Mixed = write-output $RulesSet  Get-NetFirewallRule | where {$_.DisplayGroup -match "File and Printer Sharing" -and $_.Direction -eq "Inbound" -and $_.Profile -match "Private" }
if($Mixed.Count){
	write-host ("{0} mixed rules detected. Splitting them to Private and Public" -f $Mixed.Count)
}
foreach ($x in $Mixed) {
	#generate new GUID as name for copy the rule
	$NewName = [guid]::NewGuid().ToString("B").ToUpper()
	#Set current rule just to be private
	write-host ("Splitting Rule '{0}' " -f $x.DisplayName)
	write-output $x | Set-NetFirewallRule -Profile "Private"
	#Copy the rule with new name (GUID)
	write-output $x | Copy-NetFirewallRule -NewName $NewName 
	#Set the public profile to the rule
	Set-NetFirewallRule -Name $NewName -Profile "Public"
}

#now collect all rules in the $fwprofile rules again and 
#set them ranges tom $subnets
$RulesSet = Get-NetFirewallRule | where {$_.DisplayGroup -match "File and Printer Sharing" -and $_.Direction -eq "Inbound" -and $_.Profile -match $fwprofile }
foreach ($x in $RulesSet) {
	write-host ("Adding ranges to Rule '{0}'" -f $x.DisplayName)
	write-output $x | Set-NetFirewallRule -RemoteAddress $Subnets -Enabled True
}
write-host ("{0} Rules has been modified" -f $RulesSet.Count)
