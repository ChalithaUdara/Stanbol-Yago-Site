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

but before doing this please note the points (2) to (6)

### (2) Download YAGO

Yago can be downloaded from
	
    http://www.mpi-inf.mpg.de/departments/databases-and-information-systems/research/yago-naga/yago/downloads/

Here you can download complete yago dataset or the better approach would
be to download files seperately according to needs (Can preview files before downloading).
The actual files needed depend on the configuration of the mappings
(indexing/config/mappings.txt). Generally one need to make sure that
all the RDF dumps with the source data for the specified mappings
are available. 
It is also important to download the files in NTurtle(.ttl) format.

Typically useful files may include the followings

    yagoSchema
    yagoTypes
    yagoTransitiveType
    yagoTaxonomy
    yagoFacts
    yagoLabels
    yagoLiteralFacts
    yagoMultilingualInstanceLabels
    yagoDBpediaClasses
    yagoDBpediaInstances

Once downloaded these RDF files need to be stored in

    indexing/resources/rdfdata

but before storing these files you need to preprocess these dumps in order to
successfully index using this indexer tool. Preprocessing steps are given below(see points (3) and (4))

### (3) Fixing Language Codes

One important thing to do is to convert Yago language codes (Yago uses ISO 639-2 codes)
to language codes used by Apache Stanbol (Stanbol uses ISO 639-1 codes).

Dump files

    yagoLabels.ttl
    yagoMultilingualInstanceLabels.ttl 

contains labels for entities.

In order to fix language codes once you have copied these files to indexing/resources/rdfdata
you have to copy the script language_code_convert.sh to indexing root directory(same directory
contaning yago indexer jar file) and run it.  

NOTE: If you did not perform this step you will not be able to correctly link mentions with entities
in your referenced site. Therefore it is very important to perform this step.

### (4) Fixing corrupted RDF files

There are URIs in the downloaded Yago dumps (found in yagoTransitiveType.ttl and yagoMultilingualInstanceLabels.ttl) 
that will not be parsed by Jena RDF Parser.(these will generate RiotExceptions 
and files will not be indexed correctly)

In Order to fix these dumps you need to copy dumps_fix.sh script to the indexing root directory(same directory
contaning yago indexer jar file) and run it (This may take a while to complete depending on your system resources)

### (5) Entity Scores

The Yago indexer uses the incoming links from other wikipages to
calculate the rank of entities. Entities with more incoming links get an
higher rank. The file containing outgoing links to other pages is "yagoWikipediaInfo.ttl". 
In addition to outlinks this file contain the sizes of the wiki articles and urls for articles.
This file need to be preprocessed to remove informations other than outlinks.

In order to calculate entity scores you need to copy "yagoRankings.sh" script to indexing
root directory and run it. If you have already copied "yagoWikipediaInfo.ttl" to
"indexing/resources/rdfdata", this will use that file. Otherwise it will automatically 
download "yagoWikipediaInfo.ttl" and calculate entity scores. 

The result of this script is the 

    indexing/resources/incoming_links.txt

which contains entity rankings

### (6) Create the Index

    java -Xmx1024m -jar org.apache.stanbol.entityhub.indexing.yago-*.jar index

Note that calling the utility with the option -h will print the help.


## Use the created index with the Entityhub

After the indexing completes the distribution folder 

    /indexing/dist

will contain two files

1. org.apache.stanbol.data.site.yago-{version}.jar: This is a Bundle that can 
be installed to any OSGI environment running the Apache Stanbol Entityhub. When 
Started it will create and configure

 * a "ReferencedSite" accessible at "http://{host}/{root}/entityhub/site/yago"
 * a "Cache" used to connect the ReferencedSite with your Data and
 * a "SolrYard" that managed the data indexed by this utility.

 When installing this bundle the Site will not be yet work, because this Bundle 
 does not contain the indexed data but only the configuration for the Solr Index.

2. yago.solrindex.zip: This is the ZIP archive with the indexed data. This 
file will be requested by the Apache Stanbol Data File Provider after installing 
the Bundle described above. To install the data you need copy this file to the 
"/stanbol/datafiles" folder within the working directory of your Stanbol Server.

 If you copy the ZIP archive before installing the bundle, the data will be 
 picked up during the installation of the bundle automatically. If you provide 
 the file afterwards you will also need to restart the SolrYard installed by the 
 Bundle.

## configuring Enhancements Engines Using YAGO Referenced Site

This section gives the configuration parameters and values to be used 
when configuring entity linking engines with Yago Referenced site

### configuring Named Entity Tagging Engine

Details regarding Named Entity Tagging is given in

    https://stanbol.apache.org/docs/trunk/components/enhancer/engines/namedentitytaggingengine.html

Following gives the values needed for configuration parameters

    Referenced Site: yago
    Persons: true
    Person Type: http://yago-knowledge.org/resource/wordnet_person_100007846    
    Organisations: true
    Organisation Type: http://yago-knowledge.org/resource/wordnet_organization_108008335
    Places: true
    Place Type: http://yago-knowledge.org/resource/yagoGeoEntity
    Label Field: rdfs:label

NOTE: In order to limit label search for types given above you need to index 
yagoTransitiveType dump. 

### Configuring Entityhub Linking Engine

Details regarding configuring Entityhub Linking engine is given
in

    https://stanbol.apache.org/docs/trunk/components/enhancer/engines/entityhublinking

Here only the values specific to yago site is given. You can use above documentation to configure values 
for other parameters (defaults for those will also work)

    Referenced Site: yago

In order to correctly classify results in to persons, orgaizations, places and others, you need
to add following type mappings in the configuration

    http://yago-knowledge.org/resource/wordnet_person_100007846 > dbp-ont:Person
    http://yago-knowledge.org/resource/wordnet_organization_108008335 > dbp-ont:Organisation
    http://yago-knowledge.org/resource/yagoGeoEntity > dbp-ont:Place 



    
    
