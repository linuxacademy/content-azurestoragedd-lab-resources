#!/bin/bash
# Create an Azure Storage Queue via the REST API.

# Usage
display_usage() {
	echo -e "\nUsage:\n__g5_token5e21333f396a1 [storage account name] [storage account access key] [queue name] \n"
}

# if less than 3 arguments supplied, display usage
if [  $# -le 2 ]
then
	display_usage
	exit 1
fi

storage_account=$1
access_key=$2
queue_name=$3

request_date=$(TZ=GMT date "+%a, %d %h %Y %H:%M:%S %Z")
resource="/${storage_account}/${queue_name}"
request_method="PUT"
headers="x-ms-date:$request_date"
string_to_sign="${request_method}\n\n\n\n${headers}\n${resource}"
hex_key="$(echo -n $access_key | base64 -d -w0 | xxd -p -c256)"
signature=$(printf "$string_to_sign" | openssl dgst -sha256 -mac HMAC -macopt "hexkey:$hex_key" -binary |  base64 -w0)
authorization_header="SharedKey $storage_account:$signature"

# Request
curl -X $request_method -H "x-ms-date:$request_date" -H "Content-Length:0" -H "Authorization:$authorization_header" "https://${storage_account}.queue.core.windows.net/${queue_name}"
