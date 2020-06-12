# TermColors
Utility script for reporting and testing terminal colors.

This script uses Operating System Commands (OSC) Command Sequences and either outputs the number of maximum colors allowed or a sam. If OSC sequences are not supported, then default to using the less accurate `tput` command.

## Arguments
| Argument | Description |
|--|--|
| -c | Display samples of all supported colors with their corresponding XTerm number (0-256). |
| -n | Display the maximum number of supported colors. |
| -fg \<INT> | Displays a test string with foreground color INT. Using this argument will disable -c argument if used. |
| -bg \<INT> | Displays a test string with background color INT. Using this argument will disable -c argument if used. |

## References
* OSC Command Sequences
https://invisible-island.net/xterm/ctlseqs/ctlseqs.txt
**Note:** search for 'OSC Ps ; Pt ST' to get the the relevant section. This script uses Ps code 4.
