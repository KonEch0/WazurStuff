#!/bin/bash

base64 -d <<<"H4sIAAAAAAAAA6WPUQ7DMAhD/3cK/y2VJnEhJHYQDl8bkjXqZ+cIlQAvpojAT3t+1SjchlTR9wXn
mTKeu6z4RG6FVJB24s2bFy2btgMqTwzdiPcGeqiC+YEkLp6uLu/4Vsc0z/OOcNGe6A1qi+jQvPDL
fWiG5WlRs9SB5bmeYEOXxpc7nT5h+tXKmpCqtRdJDr468cf6Fz8BM0kDi/gBAAA=" | gunzip
base64 -d <<<"H4sIAAAAAAAAA01Nuw6CMBTd+YoTJh30FwhxciPB6EAcbuxFmtRectuC+PVW4sB23qer7rjRJ2kb
U99XsAG0CgPq5gwKwYZIPiIOFGFk9k7IhEwZ1k/so+gC6cETZ1A/swLxqz86ir3oC+QN+D2KxgCb
pwSn9nosuvzdOKbAyC1WLJJ0c/5QNtmw5AJ2l4FzjpTX6XL+pUqI/uFhTrbcNvbFF/LniRPbAAAA" | gunzip

# Define the Wazuh API URL and credentials
while true; do
	read -p "[#] Username: " API_USERNAME
	read -sp "[#] Password: " API_PASSWORD
	echo
	read -p "[#] IP Address: " API_URL

	echo "[+] Authenticating..."
	API_URL_FULL="https://${API_URL}:55000"
	API_AUTH_URL_FULL="https://${API_URL}:55000/security/user/authenticate"

	# Get JWT token
	JWT=$(curl -s -k -u "${API_USERNAME}:${API_PASSWORD}" "${API_AUTH_URL_FULL}" | jq -r '.data.token') 2> /dev/null

	if [ "$JWT" = "null" ]; then
		echo "[!] Authentication failed, please try again."
	else
		echo "[$] Authentication successful."
		break
	fi
done

echo "[+] Fetching Agent list..."
# Get the list of all Wazuh agents
AGENT_LIST=$(curl -s -k -H "Authorization: Bearer $JWT" "${API_URL_FULL}/agents" | jq -r '.data.affected_items[].id') 2> /dev/null
CSV_AGENT=$(curl -s -k -H "Authorization: Bearer $JWT" "${API_URL_FULL}/agents" | jq -r '.data.affected_items[] | [.id, .name] | @csv') 2> /dev/null

echo "$CSV_AGENT" >> agents.csv
echo "[+] Creating CSV..."

# Create a CSV file and add the header row
echo "Agent Name,Agent IP,Agent ID,Installed Packages,Package version" > wazuh_inventory.csv

# Loop through the agents and get their inventory information
IFS=$'\n'
for AGENT_ID in $AGENT_LIST; do
  INVENTORY=$(curl -s -k -H "Authorization: Bearer $JWT" "${API_URL_FULL}/syscollector/${AGENT_ID}/packages")
  AGENT_NAME=$(curl -s -k -H "Authorization: Bearer $JWT" "${API_URL_FULL}/agents?agents_list=${AGENT_ID}" | jq -r '.data.affected_items[].name')
  AGENT_IP=$(curl -s -k -H "Authorization: Bearer $JWT" "${API_URL_FULL}/agents?agents_list=${AGENT_ID}" | jq -r '.data.affected_items[].ip')
  # Extract the inventory fields using jq and format them for CSV output
  PACKAGES=$(echo "${INVENTORY}" | jq -r --arg agent_name "$AGENT_NAME" --arg agent_ip "$AGENT_IP" '.data.affected_items[] | [$agent_name, $agent_ip, .agent_id, .name, .version] | @csv') 2> /dev/null

  # Add a row to the CSV file with the inventory information
  echo "${PACKAGES}" >> wazuh_inventory.csv
done

echo "[+] Cleaning up..."
echo
echo "[!] Inventory stored to wazuh_inventory.csv"
rm agents.csv
echo