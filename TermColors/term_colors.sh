#!/usr/bin/env bash

# Display the maximum colors supported by the terminal using Operating System Commands (OSC) Command Sequences. If
# OSC sequences are not supported, then default to terminfo using the tput command.
#
# Arguments:
# -c
#   Display samples of all supported colors with their corresponding XTerm number (0-256).
# -n    
#   Display the maximum number of supported colors.
# -fg <INT>
#   Displays a test string with foreground color INT. Will disable -c argument if both are used.
# -bg <INT>
#   Displays a test string with background color INT. Will disable -c argument if both are used.
#
# OSC Reference:
# https://invisible-island.net/xterm/ctlseqs/ctlseqs.txt
#   * search for 'OSC Ps ; Pt ST' to get the the relevant section. This script uses Ps code 4.
#
# Known Bugs:
# - OSC command will, on occasion, be visible on the console. This issue cannot be reliably reproduced at time of
#   reporting.

# Always reset all attributes to their default values on exit (should also protect us from CTRL+C)
trap 'printf "\e[0m"' exit

main() {
    max=256

    # Determine the maximum number of colors available.
    printf '\e]4;0;?\a' > /dev/tty
    read -d $'\a' -s -t 1 < /dev/tty
    if [ -z "$REPLY" ]; then
        # OSC code sequence is not supported. Default to tput.
        max=$(tput colors)
    else
        # Use OSC code sequences to test color range.
        # Check 8, 16, 88, 256 values only (most common)
        for i in 8 16 88 256; do
            printf '\e]4;$i;?\a' > /dev/tty
            read -d $'\a' -s -t 1 < /dev/tty
            if [ -z "$REPLY" ]; then
                max=$i
                break
            fi
        done
    fi

    if [ -z "$1" ]; then
        # Default behavior if no command line arguments are passed
        show_color_samples=false
        show_max_color_num=true
        fg_code=''
        bg_code=''
    else
        # Parse Command Arguments
        while [ -n "$1" ]; do
            case $1 in
                -c)
                    show_color_samples=true
                    ;;
                -n)
                    show_max_color_num=true
                    ;;
                -fg)
                    fg_code=$2
                    shift
                    if [[ $fg_code -gt $max ]]; then
                        critical_error 2 "Foreground color code $fg_code is outside of max range of $max"
                    elif [[ $fg_code -lt 0 ]]; then
                        critical_error 2 "Foreground color code cannot be less than 0"
                    fi
                    ;;
                -bg)
                    bg_code=$2
                    shift
                    if [[ $fg_code -gt $max ]]; then
                        critical_error 2 "Background color code $bg_code is outside of max range of $max"
                    elif [[ $fg_code -lt 0 ]]; then
                        critical_error 2 "Background color code cannot be less than 0"
                    fi
                    ;;
                *)
                    printf "Invalid option: %s\n" "$1"
                    ;;
            esac
            shift
        done
    fi

    # Display the results based on user arguments.
    if [ -n "$fg_code" ] || [ -n "$bg_code" ]; then
        show_color_samples=false
        display_color_sample "$fg_code" "$bg_code"
    fi
    if [ "$show_color_samples" = true ]; then dislay_clor_sample_range $max; fi
    if [ "$show_max_color_num" = true ]; then printf "Max Colors: %d\n" $max; fi
}

critical_error() {
    # Prints MSG and exits with exit code EC.
    # 
    # Usage:
    # critical_error <EC> "<MSG>"
    printf "CRITICAL ERROR: $2\n"
    exit $1
}

dislay_clor_sample_range() {
    # Display FG and BG samples of all colors from 0 to N.
    #
    # Usage:
    # dislay_clor_sample_range <N>
    count=0
    for ((i=0; i<$1; i++)); do
        printf "\e[38;5;%dm#%03d \e[0m\e[48;5;%dm #%03d \e[0m " $i $i $i $i
        if [ $count -eq 7 ]; then
            printf "\n"
            count=0
        else
            count=$(( count + 1 ))
        fi
    done
}

display_color_sample() {
    # Prints a generic text string using <FG> and <BG> xterm color codes. If FG or BG is empty, terminal default values
    # are used.
    #
    # Usage:
    # display_color_sample <FG> <BG>
    sample_text="Lorem ipsum dolor sit amet, erant diceret delenit ea vim."
    printf "\e[38;5;$1m\e[48;5;$2m%s\e[0m\n" "$sample_text"
}

main $@
