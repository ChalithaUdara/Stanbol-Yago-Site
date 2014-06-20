#!/bin/bash

for file in *.ttl
do
   echo "Processing $file" 
   sed -i -e '/.*<\/text.*/d' \
	-e '/.*<\/comment.*/d' \
	-e 's/\\n//g' \
	-e 's/\\//g' $file
done
