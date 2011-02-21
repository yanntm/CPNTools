#!/bin/bash

BASEPATH="$( dirname $0 )"
EXT="$1"
TEMPLATE="$BASEPATH/../license/notice.$EXT"
shift
YEAR="$( date +%Y )"

echo "Applying notice: $TEMPLATE"
cat "$TEMPLATE" | sed -e "s/##LAST##/$YEAR/g"
echo

for file in $*; do
	echo "Patching $file"
	echo "===================================================="
	head "$file"
	echo "===================================================="
	read -p "Continue [Y/n]?" ANSWER
	if [ "x$ANSWER" == "x" -o "x$ANSWER" == "xy" -o "x$ANSWER" == "xY" ]; then
		echo -ne "Patching $file..."
		cat "$TEMPLATE" | sed -e "s/##LAST##/$YEAR/g" > "$file.tmp"
		cat "$file" >> "$file.tmp"
		mv "$file.tmp" "$file"
		echo "Done"
	else
		echo "Skipping $file"
	fi
done
