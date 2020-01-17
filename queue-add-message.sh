#!/bin/bash
# Add a message to an Azure Storage Queue via the REST API.

# Usage
display_usage() {
	echo -e "\nUsage:\n__g5_token5e21333f396a1 [storage account name] [storage account access key] [queue name] [message] \n"
}

# if less than 4 arguments supplied, display usage
if [  $# -le 3 ]
then
	display_usage
	exit 1
fi

storage_account=$1
access_key=$2
queue_name=$3
message=$4

request_date=$(TZ=GMT date "+%a, %d %h %Y %H:%M:%S %Z")
resource="/${storage_account}/${queue_name}/messages"
request_method="POST"
content_type="application/x-www-form-urlencoded; charset=utf-8"
storage_service_version="2018-11-09"
headers="x-ms-date:$request_date\nx-ms-version:$storage_service_version"
message_base64=$(echo $message | base64)
message_xml="<QueueMessage><MessageText>$message_base64</MessageText></QueueMessage>"
message_length=${#message_xml}
string_to_sign="${request_method}\n\n\n$message_length\n\n$content_type\n\n\n\n\n\n\n${headers}\n${resource}\nmessagettl:-1"
hex_key="$(echo -n $access_key | base64 -d -w0 | xxd -p -c256)"
signature=$(printf "$string_to_sign" | openssl dgst -sha256 -mac HMAC -macopt "hexkey:$hex_key" -binary |  base64 -w0)
authorization_header="SharedKey $storage_account:$signature"

# Request
curl -X $request_method -H "x-ms-date:$request_date" -H "x-ms-version:$storage_service_version" -H "Content-Type:$content_type" -H "Authorization:$authorization_header" --data "$message_xml" "https://${storage_account}.queue.core.windows.net/${queue_name}/messages?messagettl=-1"
