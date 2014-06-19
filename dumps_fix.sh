#!/bin/bash

for file in *.ttl
do
   echo "Processing $file" 
   perl -i fixit $file
done


