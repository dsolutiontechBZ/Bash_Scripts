#!/bin/bash

##############################################
# Script Name: Linux Updater
#
# Description: This script checks for available Linux updates
# 			   and sends the list of packages via Signal API.
#			   After sending it, it auto proceed with the upgrade.
#			   After the upgrade, it sends a success message.
#			   If any error occurs in the update an error message is sent
# Version: 1.0
# Date: December 11, 2023
# Author: DsolutionTech
# Contact Email: dsolutiontech@outlook.com
# Contact Number: +501 615-1855
# https://github.com/dsolutiontechBZ/Bash_Scripts.git
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
#```````````
#30 14 * * * /bin/bash /path/to/your/script.sh
#```````````
header_info() {
clear
cat <<"EOF"
 _____            _       _   _          _______        _
|  __ \          | |     | | (_)        |__   __|      | |
| |  | |___  ___ | |_   _| |_ _  ___  _ __ | | ___  ___| |__
| |  | / __|/ _ \| | | | | __| |/ _ \| '_ \| |/ _ \/ __| '_ \
| |__| \__ \ (_) | | |_| | |_| | (_) | | | | |  __/ (__| | | |
|_____/|___/\___/|_|\__,_|\__|_|\___/|_| |_|_|\___|\___|_| |_|
+-+-+-+-+-+-+-+-+-+-+-+-+-+
|L|i|n|u|x|_|U|p|d|a|t|e|r|
+-+-+-+-+-+-+-+-+-+-+-+-+-+
EOF
}
header_info
echo -e "Executing script.............."


# Function to send messages via Signal API
send_message() {
    curl -X POST -H "Content-Type: application/json" 'http://192.168.20.4:8080/v2/send' \
         -d "{\"message\": \"$1\", \"number\": \"+5016341888\", \"recipients\": [ \"+5016341888\",\"+5016151855\" ]}"
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
	
	echo "Auto updating the now."
	send_message "$hostname: Auto-update is enabled. Proceeding with the update process."
	
	# Proceed with the updates
		sudo apt upgrade -y
	# Error handler. If an update fails to install, send an error notification
		if [[ $? -ne 0 ]]; then
    send_message "Error: $hostname updates failed to install."
else
	# Send a notification when the updates are completed
	 send_message "$hostname: updates have been installed successfully."
fi
	
else
    echo "All Packages Are Up To Date For $hostname."
    send_message "Great job! All Packages Are Up To Date For $hostname."
fi
