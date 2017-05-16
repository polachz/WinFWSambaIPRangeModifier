# Windows Firewall Samba Rules IP Range Modifier

The PowerShell script to modify remote IP ranges for Windows Firewall Samba rules

## Usage:

*smb_fw_ranges.ps1 profile ipRange1, ipRange2.....*

**Supported profiles are:**
- Public
- Private

**IpRange can be specified as:**

- Single IPv4 Address: 1.2.3.4 
- Single IPv6 Address: fe80::1 
- IPv4 Subnet (by network bit count): 1.2.3.4/24 
- IPv6 Subnet (by network bit count): fe80::1/48 
- IPv4 Subnet (by network mask): 1.2.3.4/255.255.255.0 
- IPv4 Range: 1.2.3.4 through 1.2.3.7 
- IPv6 Range: fe80::1 through fe80::9 
- **Special Keyword:**
  * LocalSubnet
  * DNS
  * DHCP
  * WINS
  * DefaultGateway
  * Internet
  * Intranet
  * IntranetRemoteAccess
  * PlayToDevice.
