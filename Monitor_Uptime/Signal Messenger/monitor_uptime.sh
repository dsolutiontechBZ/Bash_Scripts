#!/bin/bash

##############################################
# Script Name: Monitor Uptime
#
# Description: This script does a contious check on the given URL(s) and KEYWORD(s) every 30 seconds
#              and store status UP or DOWN along with the date and time in a log file. If the 
#              status goes to DOWN, then a message is sent. Whenever connection is regain, it will send 
#              another message informing connection is up.
# Version: 1.0
# Date January 27, 2024
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
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|M|o||n|i|t|o||r|_|U|p|t|i|m|e|
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
EOF
}
header_info
echo -e "Executing script.............."


# Function to check if keyword is found in HTTP response for given URL
function check_keyword {
  url=$1
  keyword=$2
  response=$(curl -s $url)
  if [[ $response =~ $keyword ]]; then
    echo "Keyword found in response from $url!"
    return 0
  else
    echo "Keyword not found in response from $url!"
    return 1
  fi
}


# Function to send message via Signal API
send_message() {
    curl -X POST -H "Content-Type: application/json" 'http://192.168.20.4:8080/v2/send' \
         -d "{\"message\": \"$1\", \"number\": \"+5016341888\", \"recipients\": [ \"+5016341888\",\"+5016151855\" ]}"
}

# Function to get status icon based on status
get_status_icon() {
    status=$1
    if [[ "$status" == "UP" ]]; then
        echo "✅"  # Green check mark for UP
    else
        echo "🔴"  # Red circle for DOWN
    fi
}

# Create a configuration file (e.g., `config.txt`) with the URL, keyword, and hostname for each connection, separated by a delimiter (e.g., comma or space). For example:
# https://example1.com,keyword1,hostname1
# https://example2.com,keyword2,hostname2

# Read URLs, keywords, and hostnames from configuration file
config_file="config.txt"
urls=()
keywords=()
hostnames=()

# Read the configuration file and populate the arrays
read_config_file() {
  while IFS=',' read -r url keyword hostname || [[ -n "$url" ]]; do
    urls+=($url)
    keywords+=($keyword)
    hostnames+=($hostname)

    # Create log file for each URL
    if [[ ! -f "${hostname}_log.txt" ]]; then
      touch "${hostname}_log.txt"
    fi
  done < "$config_file"
}

# Get the last status from log file
get_last_status() {
  log_file=$1
  last_status=$(tail -n 1 "$log_file" | awk '{print $NF}')
  echo "$last_status"
}

# Update the status in the log file
update_status() {
  log_file=$1
  status=$2
  echo "$(date) - $status" >> "$log_file"
}

# Monitor all URLs
monitor_urls() {
  for ((i=0; i<${#urls[@]}; i++)); do
    url=${urls[i]}
    keyword=${keywords[i]}
    hostname=${hostnames[i]}
    log_file="${hostname}_log.txt"
    
    # Check if keyword is found in the HTTP response
    if check_keyword "$url" "$keyword"; then
      last_status=$(get_last_status "$log_file")
      if [[ $last_status == "DOWN" ]]; then
        send_message "[${hostname}] [$(get_status_icon "UP") UP]. Keyword found"
      fi
      update_status "$log_file" "UP"
    else
      last_status=$(get_last_status "$log_file")
      if [[ $last_status == "UP" ]]; then
        send_message "[${hostname}] [$(get_status_icon "DOWN") DOWN]. Keyword not found"
      fi
      update_status "$log_file" "DOWN"
    fi
  done
}

# Read the configuration file and initialize the arrays
read_config_file

# Start the infinite loop to monitor URLs
while :
do
  monitor_urls
  sleep 30
done