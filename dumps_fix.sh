#!/bin/bash

WORKSPACE=indexing/resources/rdfdata

for file in ${WORKSPACE}/*.ttl
do
   echo "Processing $file" 
   sed -i -e '/.*<\/text.*/d' \
	-e '/.*<\/comment.*/d' \
	-e 's/\\n//g' \
	-e 's/\\//g' $file
done
