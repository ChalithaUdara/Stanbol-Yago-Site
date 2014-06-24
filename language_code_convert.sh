#!/bin/bash
#Script to Change ISO 639-2 codes (3 letter) to ISO 639-1 codes (2 letter)
#Only converts the 53 languages supported by Stanbol

WORKSPACE=indexing/resources/rdfdata
TEMP_FILE=indexing/resources/temp.ttl 

if [ -f "${WORKSPACE}/yagoLabels.ttl" ];  
then
   echo "fixing yagoLabels" 
   sed 's/@eng ./@en ./' ${WORKSPACE}/yagoLabels.ttl > $TEMP_FILE
   mv $TEMP_FILE ${WORKSPACE}/yagoLabels.ttl
else
   echo "[ERROR] Yago labels file is not found"
fi

if [ -f "${WORKSPACE}/yagoMultilingualInstanceLabels.ttl" ]; 
then
    echo "fixing yagoMultilingualInstanceLabels"
    sed -e 's/@afr ./@af ./' \
	-e 's/@ara ./@ar ./' \
	-e 's/@bul ./@bg ./' \
	-e 's/@ben ./@bn ./' \
	-e 's/@ces ./@cs ./' \
	-e 's/@dan ./@da ./' \
	-e 's/@deu ./@de ./' \
	-e 's/@ell ./@el ./' \
	-e 's/@eng ./@en ./' \
	-e 's/@spa ./@es ./' \
	-e 's/@est ./@et ./' \
	-e 's/@fas ./@fa ./' \
	-e 's/@fin ./@fi ./' \
	-e 's/@fra ./@fr ./' \
	-e 's/@guj ./@gu ./' \
	-e 's/@heb ./@he ./' \
	-e 's/@hin ./@hi ./' \
	-e 's/@hrv ./@hr ./' \
	-e 's/@hun ./@hu ./' \
	-e 's/@ind ./@id ./' \
	-e 's/@ita ./@it ./' \
	-e 's/@jpn ./@ja ./' \
	-e 's/@kan ./@kn ./' \
	-e 's/@kor ./@ko ./' \
	-e 's/@lit ./@lt ./' \
	-e 's/@lav ./@lv ./' \
	-e 's/@mkd ./@mk ./' \
	-e 's/@mal ./@ml ./' \
	-e 's/@mar ./@mr ./' \
	-e 's/@nep ./@ne ./' \
	-e 's/@nld ./@nl ./' \
	-e 's/@nor ./@no ./' \
	-e 's/@pan ./@pa ./' \
	-e 's/@pol ./@pl ./' \
	-e 's/@por ./@pt ./' \
	-e 's/@ron ./@ro ./' \
	-e 's/@rus ./@ru ./' \
	-e 's/@slk ./@sk ./' \
	-e 's/@slv ./@sl ./' \
	-e 's/@som ./@so ./' \
	-e 's/@sqi ./@sq ./' \
	-e 's/@swe ./@sv ./' \
	-e 's/@swa ./@sw ./' \
	-e 's/@tam ./@ta ./' \
	-e 's/@tel ./@te ./' \
	-e 's/@tha ./@th ./' \
	-e 's/@tgl ./@tl ./' \
        -e 's/@tur ./@tr ./' \
	-e 's/@ukr ./@uk ./' \
	-e 's/@urd ./@ur ./' \
	-e 's/@vie ./@vi ./' \
        -e 's/@zho ./@zh ./' \
	-e '/.*\".*\"@[A-Za-z][A-Za-z][A-Za-z][A-Za-z]*/d' \
	-e '/.*\".*\"@[A-Za-z] ./d' ${WORKSPACE}/yagoMultilingualInstanceLabels.ttl > $TEMP_FILE
   mv $TEMP_FILE ${WORKSPACE}/yagoMultilingualInstanceLabels.ttl
else
   echo "[WARNING] Yago dump for multilingual labels is not found"
fi


