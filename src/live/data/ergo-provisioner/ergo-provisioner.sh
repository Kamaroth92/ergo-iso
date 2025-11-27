#!/usr/bin/env bash

PROVISIONER_PATH=/ergo/provisioner
PROVISIONER_FILES=$PROVISIONER_PATH/files
JSON=%CONFIG_FILE%
WEBSERVER_URL=%WEBSERVER_URL%

export UUID=$(dmidecode -s system-uuid)

if [[ -z "$UUID" ]]; then
	echo "Error: Unable to retrieve system UUID."
	exit 1
fi

RESPONSE=$(curl -s --max-time 3 "$WEBSERVER_URL")
if echo "$RESPONSE" | jq -e .globals > /dev/null 2>&1; then
	echo "Using config from $WEBSERVER_URL"
	JSON=$PROVISIONER_FILES/config.json
	$RESPONSE > $JSON
else
	echo "Error: Response from $WEBSERVER_URL is not valid JSON."
fi

if [[ ! -f "$JSON" ]]; then
	echo "Error: $JSON does not exist."
	exit 1
fi

echo "Loading $JSON"
NODE_JSON=$(
	jq --arg uuid "$UUID" '
  . as $root
  | $root.nodes
  | to_entries
  | map(select(.value.uuid == $uuid))
  | .[0] as $node
  | {
      name: $node.key
    } + 
    ($root.globals + $node.value)
' $JSON
)
echo $NODE_JSON

echo "#!/usr/bin/env bash" >$PROVISIONER_FILES/node_exports.sh
echo "$NODE_JSON" | jq -r 'to_entries[] | "export VAR_\(.key)=\(.value)"' | while read -r line; do
	echo "$line" >>$PROVISIONER_FILES/node_exports.sh
done
source $PROVISIONER_FILES/node_exports.sh

for script in $PROVISIONER_PATH/provisioner.d/*.sh; do
	[ -f "$script" ] || continue # skip if no .sh files
	source $script
	if [[ $? -ne 0 ]]; then
		# error_occurred=1
		echo $script >>$PROVISIONER_PATH/errors.txt
	else
		echo $script >>$PROVISIONER_PATH/success.txt
	fi
done
