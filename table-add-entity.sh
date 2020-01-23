#!/bin/bash
# Create an Azure Storage Queue via the REST API.

# Usage
display_usage() {
	echo -e "\nUsage:\n__g5_token5e21333f396a1 [storage account name] [storage account access key] [table name] [entity_json] \n"
}

# if less than 3 arguments supplied, display usage
if [  $# -le 2 ]
then
	display_usage
	exit 1
fi

storage_account=$1
access_key=$2
table_name=$3
entity_json=$4

request_date=$(TZ=GMT date "+%a, %d %h %Y %H:%M:%S %Z")
resource="/${storage_account}/${table_name}"
request_method="POST"
content_type="application/json"
string_to_sign="${request_method}\n\n${content_type}\n${request_date}\n${resource}"
hex_key="$(echo -n $access_key | base64 -d -w0 | xxd -p -c256)"
signature=$(printf "$string_to_sign" | openssl dgst -sha256 -mac HMAC -macopt "hexkey:$hex_key" -binary |  base64 -w0)
authorization_header="SharedKey $storage_account:$signature"

# Request
curl -X $request_method -H "Date:$request_date" -H "Content-Type:$content_type" -H "Authorization:$authorization_header" -H "DataServiceVersion:3.0;NetFx" -H "x-ms-version:2019-02-02" -d "${entity_json}" "https://${storage_account}.table.core.windows.net/${table_name}"
