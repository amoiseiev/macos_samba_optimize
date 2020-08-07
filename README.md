# Optimizing Samba performance for MacOS catalina

Implements:

>https://support.apple.com/en-us/HT208209  
https://support.apple.com/en-us/HT205926

and common internet workaround for "Time Machine": `sysctl debug.lowpri_throttle_enabled=0`

that particular sysctl setting DOES affect SMB performance even for regular usage. In my case 10x decrease when the throttling kicks in at seemeingly random moments.

The script allows running sysctl without sudo password, adds itself to user's launchd Agent configuration for resetting sysctl on login. It DOES NOT require disabling System Integrity Protection.

## Usage

>`samba_optimize.sh init` (will ask for your password), adds configuration tweaks and applies sysctl change  
`samba_optimize.sh run` (apply sysctl change, the mode it run on user login)  
`samba_optimize.sh remove` (remove the tweaks and clean up the logs)
