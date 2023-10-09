# WazurStuff
WazuhStuff is a simple Bash script to export the inventory of every agent on a Wazuh manager.

# Requirements
Please install the below if not already installed
1. curl
```bash
apt-get install curl # Debian
yum install curl # RHEL
```
2. jq
```bash
apt-get install jq # Debian
yum install jq # RHEL
```

# Usage
```bash
git clone https://github.com/KonEch0/WazurStuff.git
cd WazurStuff
chmod +x WazurStuff.sh
./WazurStuff.sh
```
# Example
![image](https://github.com/KonEch0/WazurStuff/assets/102297040/218322b4-6429-4a3d-a657-8c2bfc9b24de)

# Additional Info
1. The script will attempt to connect to the Wazuh API to retrieve the associated data.
2. The script will prompt you for these credentials
   
# Disclaimer
The tools and code within this repository have no guarantee, usage comes at own risk. I do not take responsibility for how anyone chooses to use these tools, with usage, you understand that it is at your own risk. All tools and code here is designed for educational/research and operational purposes.
