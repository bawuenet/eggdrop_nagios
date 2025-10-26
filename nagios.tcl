# nagios.tcl
# Adds a .nagios <type> <status> <msg> DCC/partyline command that sends <msg> to the alerts channel.
# Colorizes messages according to https://forum.eggheads.org/viewtopic.php?t=3867
# Only users with the required flag may use this command.

set alerts_channel "#bawue-alerts"
set nagios_flag "N"

bind dcc - nagios dcc:nagios

proc dcc:nagios {hand idx text} {
    global alerts_channel nagios_flag

    if {![matchattr $hand $nagios_flag] && ![matchattr $hand m] && ![matchattr $hand n]} {
        putdcc $idx "You do not have permission to use .nagios (need +$nagios_flag, global master, or owner)."
        return
    }

    set parts [split $text " "]
    if {[llength $parts] < 4} {
        putdcc $idx "Usage: .nagios <type> <status> <msg>"
        return
    }

    set type   [lindex $parts 0]
    set status [lindex $parts 1]
    set msg    [join [lrange $parts 2 end]]

    if {$type eq "RECOVERY"} {
        set color "03"
    } elseif {$type eq "PROBLEM" && $status eq "WARNING"} {
        set color "07"
    } elseif {$type eq "PROBLEM" && ($status eq "CRITICAL" || $status eq "DOWN")} {
        set color "04"
    } elseif {$type eq "PROBLEM" && $status eq "UNREACHABLE"} {
        set color "05"
    } elseif {$type eq "PROBLEM" && $status eq "UNKNOWN"} {
        set color "17"
    } elseif {$type eq "DOWNTIMESTART" || $type eq "DOWNTIMEEND"} {
        set color "02"
    } elseif {$type eq "ACKNOWLEDGEMENT"} {
        set color "13"
    } else {
        set color "00"
    }

    set formatted "\[\002$hand\002\] \[\003${color}$type: $status\003\] $msg"

    putserv "PRIVMSG $alerts_channel :$formatted"
    putdcc $idx "Sent to $alerts_channel: $formatted"
}

putlog "nagios.tcl loaded"
