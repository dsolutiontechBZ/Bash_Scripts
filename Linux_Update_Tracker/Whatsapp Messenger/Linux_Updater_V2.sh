#!/bin/bash

##############################################
# Script Name: Linux Updater
#
# Description: This script checks for available Linux updates
# 			   and sends the list of packages via Signal API.
#			   After sending it, it auto proceed with the upgrade.
#			   After the upgrade, it sends a success message.
#			   If any error occurs in the update an error is sent
# Version: 2.0
# Author: DsolutionTech
# Date: January 25, 2024
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

# Define the API key and chat ID
API_KEY="7103897494"
ApiTokenInstance="76009c17a06143e99a6d830bea1040fa549ede4982de46bca3"
CHAT_ID_1="5016151855@c.us"
CHAT_ID_2="5016106669@c.us"

# Function to send messages via WhatsApp API
send_message() {
    message="$1"
    chat_ids=("${CHAT_ID_1}" "${CHAT_ID_2}")

    for chat_id in "${chat_ids[@]}"; do
        curl --location "https://7103.api.greenapi.com/waInstance${API_KEY}/sendMessage/${ApiTokenInstance}" \
            --header 'Content-Type: application/json' \
            --data-raw "{
                \"chatId\": \"${chat_id}\",
                \"message\": \"${message}\"
            }"
    done
}

# Define the variable
updates_available=$(apt list --upgradable 2>/dev/null | grep -v Listing)
hostname=$(hostname)

# If updates are available
if [[ -n "$updates_available" ]]; then
    message="*Updates Are Available For: $hostname*\n\n"
    
    # Loop through the updates and append package information to the message
    while read -r line; do
        package_name=$(echo "$line" | awk -F '/' '{print $1}')
        available_version=$(echo "$line" | awk -F ' ' '{print $2}')
        current_version=$(echo "$line" | awk -F ' ' '{print $4,$5,$6}')
        
        # Append package information to the message
        message+="*Package Name:* $package_name\n [available version: $available_version]\n $current_version\n\n"
    done <<< "$updates_available"
    
    # Send the message
    send_message "$message"
	
	echo "Auto updating the now."
	send_message "*$hostname*: Auto-update is enabled. Proceeding with the update process."
	
	# Proceed with the updates
		sudo apt upgrade -y
	# Error handler. If an update fails to install, send an error notification
		if [[ $? -ne 0 ]]; then
    send_message "Error: *$hostname* updates failed to install."
else
	# Send a notification when the updates are completed
	 send_message "*$hostname*: updates have been installed successfully."
fi
	
else
    echo "All Packages Are Up To Date For $hostname."
    send_message "*Great job! All Packages Are Up To Date For $hostname.*"
fi
