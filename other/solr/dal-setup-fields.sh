#!/bin/bash

SOLRHOST='localhost'
SOLRPORT='8983'

SOLRPROTOCOL='http'

SOLRURL="${SOLRPROTOCOL}://${SOLRHOST}:${SOLRPORT}"

curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'SolrId', 'indexed': 'true', 'required': 'true', 'type': 'string', 'multiValued': 'false'}
}' "${SOLRURL}/solr/dal/schema"

curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'NumberOfGenotypes', 'indexed': 'true', 'required': 'false', 'type': 'int', 'multiValued': 'false'}
}' "${SOLRURL}/solr/dal/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'GenotypeId', 'indexed': 'true', 'required': 'false', 'type': 'long', 'multiValued': 'false'}
}' "${SOLRURL}/solr/dal/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'Level', 'indexed': 'true', 'required': 'false', 'type': 'int', 'multiValued': 'false'}
}' "${SOLRURL}/solr/dal/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'AncestorTypeName', 'indexed': 'true', 'required': 'false', 'type': 'text_general', 'multiValued': 'false'}
}' "${SOLRURL}/solr/dal/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'AncestorName', 'indexed': 'true', 'required': 'false', 'type': 'text_general', 'multiValued': 'false'}
}' "${SOLRURL}/solr/dal/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'long', 'name': 'AncestorId', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/dal/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'text_general', 'name': 'GenotypeName', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/dal/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'entity_name', 'indexed': 'true', 'required': 'true', 'type': 'text_general', 'multiValued': 'false'}
}' "${SOLRURL}/solr/dal/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'text_general', 'name': 'AnalysisGroupName', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/dal/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'text_general', 'name': 'AnalysisGroupDescription', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/dal/schema"

curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'false', 'type': 'text_general', 'name': 'text', 'multiValued': 'true'}
}' "${SOLRURL}/solr/dal/schema"

curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-copy-field": {'dest': 'text', 'source': 'SolrId'}
}' "${SOLRURL}/solr/dal/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-copy-field": {'dest': 'text', 'source': 'AnalysisGroupName'}
}' "${SOLRURL}/solr/dal/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-copy-field": {'dest': 'text', 'source': 'AnalysisGroupDescription'}
}' "${SOLRURL}/solr/dal/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-copy-field": {'dest': 'text', 'source': 'AncestorTypeName'}
}' "${SOLRURL}/solr/dal/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-copy-field": {'dest': 'text', 'source': 'AncestorName'}
}' "${SOLRURL}/solr/dal/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-copy-field": {'dest': 'text', 'source': 'GenotypeName'}
}' "${SOLRURL}/solr/dal/schema"

curl -X POST -H 'Content-type:application/json' --data-binary '{
"delete-field": { "name":"id" }
}' "${SOLRURL}/solr/dal/schema"
