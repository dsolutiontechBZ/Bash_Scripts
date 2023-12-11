#!/bin/bash

##############################################
# Script Name: Linux Update Checker
#
# Description: This script checks for available Linux updates and sends the list of packages via Signal API.
# Version: 1.0
# Author: DsolutionTech
# Contact Email: dsolutiontech@outlook.com
# Contact Number: +501 615-1855
# Facebook: https://www.facebook.com/dsolutiontech/
##############################################
#
#To schedule the automatic execution of a bash script, you can use the `cron` daemon in Linux. Here's how you can do it:
#
# 1. Open a terminal.
#
# 2. Run the following command to edit the user's cron file:
#
#   ```
#   crontab -e
#  ```
#
# 3. If prompted, choose a text editor to edit the cron file.
#
# 4. In the cron file, add a new line to schedule the script's execution. The general format is as follows:
#
#   ```
#  * * * * * /bin/bash /path/to/your/script.sh
#   ```
#
# m h  dom mon dow   command
#
#Using these fields, you can specify a precise schedule for your cron job. For example, to run a script every day at 2:30 PM, the corresponding cron entry would be:
#```
#
#30 14 * * * /bin/bash /path/to/your/script.sh
#```
header_info() {
clear
cat <<"EOF"
 _____            _       _   _          _______        _
|  __ \          | |     | | (_)        |__   __|      | |
| |  | |___  ___ | |_   _| |_ _  ___  _ __ | | ___  ___| |__
| |  | / __|/ _ \| | | | | __| |/ _ \| '_ \| |/ _ \/ __| '_ \
| |__| \__ \ (_) | | |_| | |_| | (_) | | | | |  __/ (__| | | |
|_____/|___/\___/|_|\__,_|\__|_|\___/|_| |_|_|\___|\___|_| |_|
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|L|i|n|u|x|_|U|p|d|a|t|e|_|C|h|e|c|k|e|r|
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
EOF
}
header_info
echo -e "Executing script.............."

# Function to send message via Signal API
send_message() {
    curl -X POST -H "Content-Type: application/json" 'http://192.168.20.4:8080/v2/send' \
         -d "{\"message\": \"$1\", \"number\": \"+5016151855\", \"recipients\": [ \"+5016341888\",\"+5016151855\" ]}"
}

# Define the variable
updates_available=$(apt list --upgradable 2>/dev/null | grep -v Listing)
hostname=$(hostname)

# If updates are available
if [[ -n "$updates_available" ]]; then
    message="Updates Are Available For: $hostname\n\n"
    
    # Loop through the updates and append package information to the message
    while read -r line; do
        package_name=$(echo "$line" | awk -F '/' '{print $1}')
        available_version=$(echo "$line" | awk -F ' ' '{print $2}')
        current_version=$(echo "$line" | awk -F ' ' '{print $4,$5,$6}')
        
        # Append package information to the message
        message+="Package Name: $package_name\n Available Version: $available_version\n $current_version\n\n"
    done <<< "$updates_available"
    
    # Send the message
    send_message "$message"
else
    echo "All Packages Are Up To Date For: $hostname."
    send_message "Great job! All Packages Are Up To Date For: $hostname."
fi
