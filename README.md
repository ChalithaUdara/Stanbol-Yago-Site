<!--Licensed to the Apache Software Foundation (ASF) under one or more
contributor license agreements.  See the NOTICE file distributed with
this work for additional information regarding copyright ownership.
The ASF licenses this file to You under the Apache License, Version 2.0
(the "License"); you may not use this file except in compliance with
the License.  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-->

# Indexer for Yago knowledge base (see http://www.mpi-inf.mpg.de/yago-naga/yago/)

This tool creates local indexes of yago to be used with the Stanbol Entityhub

## Building

If not yet built during the build process of the entityhub call

    mvn install

to build the jar with all the dependencies used later for indexing.

If the build succeeds go to the /target directory and copy the

    org.apache.stanbol.entityhub.indexing.yago-*.jar

to the directory you would like to start the indexing.

## Indexing

### (1) Initialize the configuration

The default configuration is initialized by calling

    java -jar org.apache.stanbol.entityhub.indexing.yago-*.jar init

This will create a sub-folder "indexing" in the current directory.
Within this folder all the

* configurations (indexing/config)
* source files (indexing/resources)
* created files (indexing/destination)
* distribution files (indexing/distribution)

will be located.

The indexing itself can be started by

    java -jar org.apache.stanbol.entityhub.indexing.yago-*.jar index

but before doing this please note the points (2), (3) and (4)

### (2) Download YAGO

Yago can be downloaded from
	
    http://www.mpi-inf.mpg.de/yago-naga/yago/downloads.html

Here you can download complete yago dataset or the better approach would
be to download files seperately according to needs (Can preview files before downloading).
The actual files needed depend on the configuration of the mappings
(indexing/config/mappings.txt). Generally one need to make sure that
all the RDF dumps with the source data for the specified mappings
are available. 
It is also important to download the files in NTurtle(.ttl) format.

To Do: add typically useful files

Once downloaded these RDF files need to be stored in

    indexing/resources/rdfdata

### (3) Entity Scores

The Yago indexer uses the incoming links from other wikipages to
calculate the rank of entities. Entities with more incoming links get an
higher rank. The file containing outgoing links to other pages is "yagoWikipediaInfo.ttl". 
In addition to outlinks this file contain the sizes of the wiki articles and urls for articles.
This file need to be preprocessed to remove informations other than outlinks.

If you have already downloaded the full yago dataset, you can use following command to generate 
incoming links

    sed -e '/#.*/d' -e '/@.*/d' -e '/.*has.*/d' -e '/^\s*$/d' -e 's/.*<\([^>]*\)> ./\1/' yagoWikipediaInfo.ttl \
        | sort \
        | uniq -c  \
        | sort -nr > incoming_links.txt

Otherwise use the following command to download and create incoming links file

    curl www.mpi-inf.mpg.de/yago-naga/yago/download/yago/yagoWikipediaInfo.ttl.7z \
        | 7z \
        | sed -e '/#.*/d' -e '/@.*/d' -e '/.*has.*/d' -e '/^\s*$/d' -e 's/.*<\([^>]*\)> ./\1/' \
        | sort \
        | uniq -c  \
        | sort -nr > incoming_links.txt

The resulting file MUST BE copied to

    indexing/resources/incoming_links.txt

### (4) Create the Index

    java -Xmx1024m -jar org.apache.stanbol.entityhub.indexing.yago-*.jar index

Note that calling the utility with the option -h will print the help.


## Use the created index with the Entityhub

After the indexing completes the distribution folder 

    /indexing/dist

will contain two files

1. org.apache.stanbol.data.site.{name}-{version}.jar: This is a Bundle that can 
be installed to any OSGI environment running the Apache Stanbol Entityhub. When 
Started it will create and configure

 * a "ReferencedSite" accessible at "http://{host}/{root}/entityhub/site/{name}"
 * a "Cache" used to connect the ReferencedSite with your Data and
 * a "SolrYard" that managed the data indexed by this utility.

 When installing this bundle the Site will not be yet work, because this Bundle 
 does not contain the indexed data but only the configuration for the Solr Index.

2. {name}.solrindex.zip: This is the ZIP archive with the indexed data. This 
file will be requested by the Apache Stanbol Data File Provider after installing 
the Bundle described above. To install the data you need copy this file to the 
"/sling/datafiles" folder within the working directory of your Stanbol Server.

 If you copy the ZIP archive before installing the bundle, the data will be 
 picked up during the installation of the bundle automatically. If you provide 
 the file afterwards you will also need to restart the SolrYard installed by the 
 Bundle.

{name} denotes to the value you configured for the "name" property within the
"indexing.properties" file.

### A note about blank nodes

If your input data sets contain large numbers of blank nodes, you may find that
you have problems running out of heap space during indexing. This is because Jena
(like many semantic stores) keeps a store of blank nodes in core memory while 
importing. Keeping in mind that EntityHub does not support the use of blank nodes,
there is a means of indexing such data sets nonetheless. You can convert them to
named nodes and then index. There is a convenient tool packaged with Stanbol for
this purpose, called "Urify" (org.apache.stanbol.entityhub.indexing.Urify).
It is available in the runnable JAR file built by this indexer. To use it, put that
JAR on your classpath, and you can execute Urify, giving it a list of files to process.
Use the "-h" or "--help" flag to see options for Urify:

    java -Xmx1024m -cp org.apache.stanbol.entityhub.indexing.yago-*.jar \
    org.apache.stanbol.entityhub.indexing.Urify --help
    
    
