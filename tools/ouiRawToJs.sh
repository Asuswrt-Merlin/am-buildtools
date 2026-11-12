#!/bin/sh
# Generate the two OUI vendor databases from the IEEE registry:
#   www/ajax/ouiDB.json          - web UI (one entry per line, sorted, with timestamp)
#   networkmap/db/ieee.oui.json  - networkmap daemon (minified, de-duplicated, no timestamp)
#
# Usage: ouiRawToJs.sh [router_dir] [oui.txt]
#   router_dir defaults to ~/dev/amng/release/src/router
#   oui.txt    optional local copy; downloaded from IEEE if omitted

ROUTER=${1:-$HOME/dev/amng/release/src/router}
SRC=$2

WEBDB=$ROUTER/www/ajax/ouiDB.json
NMDB=$ROUTER/networkmap/db/ieee.oui.json

for d in "$(dirname "$WEBDB")" "$(dirname "$NMDB")"; do
	if [ ! -d "$d" ]; then
		echo "Directory $d does not exist!"
		exit 1
	fi
done

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

if [ -z "$SRC" ]; then
	SRC=$TMP/oui.txt
	if ! wget -q -O "$SRC" https://standards-oui.ieee.org/oui.txt || [ ! -s "$SRC" ]; then
		echo "Download failed!"
		exit 1
	fi
fi

# "00-00-00   (hex)\t\tXEROX CORPORATION\r" -> "000000":"XEROX CORPORATION"
# Sorted, so duplicates (same OUI registered more than once) end up adjacent.
grep '(hex)' "$SRC" | tr -d '\r' | sed -e 's/，//' | awk -F'\t' '
{
	oui = $1
	sub(/[ \t]*\(hex\).*/, "", oui)
	gsub(/-/, "", oui)
	vendor = $NF
	gsub(/\\/, "\\\\", vendor)
	gsub(/"/, "\\\"", vendor)
	printf "\"%s\":\"%s\"\n", oui, vendor
}' | LC_ALL=C sort > "$TMP/entries"

if [ ! -s "$TMP/entries" ]; then
	echo "No OUI entries found in $SRC!"
	exit 1
fi

# Web UI database
{
	echo '{'
	sed 's/$/,/' "$TMP/entries"
	echo "\"timestamp\":\"$(date +%s)\""
	echo '}'
} > "$TMP/ouiDB.json"

# networkmap database: keep the first entry of each OUI, single line, no trailing newline
awk -F'"' '!seen[$2]++' "$TMP/entries" | awk '
BEGIN { printf "{" }
{ printf "%s%s", (NR > 1 ? "," : ""), $0 }
END { printf "}" }' > "$TMP/ieee.oui.json"

cp "$TMP/ouiDB.json" "$WEBDB"
cp "$TMP/ieee.oui.json" "$NMDB"

echo "$WEBDB: $(($(wc -l < "$WEBDB") - 3)) entries"
echo "$NMDB: $(tr ',' '\n' < "$NMDB" | grep -c '":"') entries"
