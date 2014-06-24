#!/bin/bash

WORKSPACE=indexing/resources/rdfdata
TEMP_FILE=indexing/resources/rdfdata/temp.ttl

for file in ${WORKSPACE}/*.ttl          
do
   echo "Processing $file" 
   sed -e '/.*<\/text.*/d' \
       -e '/.*<\/comment.*/d' \
       -e 's/\\n//g' \
       -e 's/\\//g' $file > $TEMP_FILE
   mv $TEMP_FILE $file
done
