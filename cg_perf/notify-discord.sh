#!/bin/bash

outfile="$1"

if [ -z $outfile ]; then
	echo "$0: specify a cg cache file as first argument (TODO or stdin)"
	exit 1
fi

if [ -z $WEBHOOK_URL ]; then
	echo "$0: specify discord WEBHOOK_URL env variable"
	exit 1
fi

# TODO cache this on disk and just read from there
validators=(attractive-vermilion-urchin short-nylon-frog broad-hemp-corgi noisy-iris-loris)

for name in ${validators[@]}; do
	echo "checking for $name ..."
	match=$(grep "$name" "$outfile")
	if [ $match ]; then
		echo "zomg we have a match in the CG!!"

		# message="short-nylon-frog,13/13,715/715,0,0,3,1.29"
		message="$outfile - CG match: $match"
		payload=$(jq -n --arg message "$message" '{content: $message}')
		echo "$payload"

		# webhook_url="http://localhost:8080"
		curl -X POST -d "$payload" -H 'Content-Type: application/json' "$webhook_url"
	fi
done
