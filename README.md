# eggdrop_nagios
Eggdrop script adding a .nagios command for sending notifications to an IRC channel

## Eggdrop configuration
Copy the `nagios.tcl` script into the eggdrop scriptdir and configure the bot to load the script.
Additionally, a listen port needs to be opened for the nagios server to be able to telnet into
the bot.

```eggdrop.conf
listen 5555 all
source scripts/nagios.tcl
```
Reload the bot using `.rehash` on the partyline.


## Nagios configuration
Copy the `irc_notify.expect` script to a location reachable on your nagios server.
Ensure the `expect` package is installed.

Add the `notify-host-by-irc` and `notify-service-by-irc` commands to the nagios configuration and
add a new contact using these commands.

```commands.conf
define command {
        command_name    notify-host-by-irc
        command_line    /usr/bin/expect /usr/local/share/nagios/irc_notify.expect \
                "$NOTIFICATIONTYPE$" \
                "$HOSTNAME$" \
                "Host" \
                "$HOSTSTATE$" \
                "$HOSTOUTPUT$"
}

define command {
        command_name    notify-service-by-irc
        command_line    /usr/bin/expect /usr/local/share/nagios/irc_notify.expect \
                "$NOTIFICATIONTYPE$" \
                "$HOSTNAME$" \
                "$SERVICEDESC$" \
                "$SERVICESTATE$" \
                "$SERVICEOUTPUT$"
}
```

```contacts.cfg
define contact{
        contact_name                    irc
        alias                           #bawue-alerts IRC Channel
        host_notifications_enabled      1
        service_notifications_enabled   1
        host_notification_period        24x7
        service_notification_period     24x7
        host_notification_options       d,u,r,s,f
        service_notification_options    w,u,c,r
        host_notification_commands      notify-host-by-irc
        service_notification_commands   notify-service-by-irc
}
```

## Reference documentation
* https://docs.eggheads.org/using/core.html
* https://assets.nagios.com/downloads/nagioscore/docs/nagioscore/3/en/notifications.html
* https://assets.nagios.com/downloads/nagioscore/docs/nagioscore/3/en/objectdefinitions.html
