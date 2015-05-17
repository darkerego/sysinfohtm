#!/bin/bash

# system_page - A script to produce an system information HTML file

##### Constants

TITLE="System Information for $HOSTNAME"
RIGHT_NOW=$(date +"%x %r %Z")
TIME_STAMP="Updated on $RIGHT_NOW by user $USER"
PAGEPATH="/var/www/includes/pages/system_info.php"
results="/var/www/includes/pages/vpn.php"

##### Functions

function show_uptime
{
    echo "<h3>System uptime</h3>"
    echo "<p><pre>"
	    uptime
    echo "</pre></p>"
}


function system_info
{
    # Find any release files in /etc

    if ls /etc/*release 1>/dev/null 2>&1; then
	echo "<h2> System Stats:</h2>"
        echo "<h3>Linux Release</h3>"
        echo "<p><pre>"
        for i in /etc/*release; do

            # Since we can't be sure of the
            # length of the file, only
            # display the first line.

            head -n 1 $i
        done
        uname -orp
	echo "</p><p><h3>Currently logged in users</h3>"
	who
        echo "</pre></p>"
    fi
}

function home_space
{
    echo "<h3>Home directory space by user</h3>"
    echo "<p><pre>"
    format="%8s%10s%10s   %-s\n"
    printf "$format" "Dirs" "Files" "Blocks" "Directory"
    printf "$format" "----" "-----" "------" "---------"
    if [ $(id -u) = "0" ]; then
        dir_list="/home/*"
    else
        dir_list=$HOME
    fi
    for home_dir in $dir_list; do
        total_dirs=$(find $home_dir -type d | wc -l)
        total_files=$(find $home_dir -type f | wc -l)
        total_blocks=$(du -s $home_dir)
        printf "$format" $total_dirs $total_files $total_blocks
    done
    echo "</pre></p>"

}   # end of home_space


function drive_space
{
    echo "<h3>Filesystem space</h3>"
    echo "<p><pre>"
    df
    echo "</pre></p>"
}

function active_processes
{
	echo "<h2>Running Processes</h2>"
	echo "<p><pre>"
	ps aux | less
	echo "</pre></p>"
}

function current_net
{
	echo "<h2> Network Stats</h2>"
	echo "<h3>Active Network Connections</h3>"
	echo "<p><pre>"
	netstat -taupenv
	echo "</pre></p>"
	cp '/etc/openvpn/openvpn-status.log' $results
	echo "<h3>OpenVPN Status:</h3>"
	echo "<pre>"
	cat $results
	echo "</pre>"


}

function kern_msg
{
        echo "<h3>Recent Kernel Logs</h3>"
        echo "<p><pre>"
        dmesg | less
        echo "</pre></p>"
}


##### Main Function (what this script does)
function write_page
{
cat <<- _EOF_
  <html>
  <head>
      <title>$TITLE</title>
  </head>

  <body bgcolor="black" text="white">
      <h2>$TITLE</h2>
      <p>$TIME_STAMP</p>
      $(system_info)
      $(show_uptime)
      $(drive_space)
      $(home_space)
      $(current_net)
      $(kern_msg)
      $(active_processes)
  </body>
  </html>
_EOF_
}

function usage
{
    echo "usage: system_page [[[-f file ] [-i]] | [-h]]"
}


##### still figuring this all out

interactive=
filename=system_info.php

while [ "$1" != "" ]; do
    case $1 in
        -f | --file )           shift
                                filename=$1
                                ;;
        -i | --interactive )    interactive=1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done


# Test code to verify command line processing

if [ "$interactive" = "1" ]; then
	echo "interactive is on"
else
	echo "interactive is off"
fi
echo "output file = $filename"


# Write page (comment out until testing is complete)

write_page > $PAGEPATH
