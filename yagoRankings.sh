#!/bin/bash
#This script creates entity scores for Yago
#The Yago indexer uses the incoming links from other wikipages to calculate the rank of entities 
#Entities with more incoming links get an higher rank

WORKSPACE=indexing/resources
OUTGOING_LINKS=${WORKSPACE}/rdfdata/yagoWikipediaInfo.ttl
INCOMING_LINKS=${WORKSPACE}/incoming_links.txt

create_links()
{
   echo "Creating incoming links..."
   sed -e '/#.*/d' -e '/@.*/d' -e '/.*has.*/d' -e '/^\s*$/d' -e 's/.*<\([^>]*\)> ./\1/' $OUTGOING_LINKS \
    | sort \
    | uniq -c  \
    | sort -nr > $INCOMING_LINKS
}


if [ -f "$OUTGOING_LINKS" ];
then
   echo "yagoWikipediaInfo found in rdfdata"
   create_links
else
   echo "Cannot find yagoWikipediaInfo in rdfdata"
   echo "Downloading yagoWikipediaInfo....."
   curl -o yagoWikipediaInfo.ttl.7z resources.mpi-inf.mpg.de/yago-naga/yago/download/yago/yagoWikipediaInfo.ttl.7z
   echo "Download Completed..."
   7z e yagoWikipediaInfo.ttl.7z
   mv yagoWikipediaInfo.ttl $OUTGOING_LINKS
   rm yagoWikipediaInfo.ttl.7z
   create_links
fi

