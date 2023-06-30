#!/bin/bash

SOLRHOST='localhost'
SOLRPORT='8983'

SOLRPROTOCOL='http'

SOLRURL="${SOLRPROTOCOL}://${SOLRHOST}:${SOLRPORT}"

curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'SolrId', 'indexed': 'true', 'required': 'true', 'type': 'text_general', 'multiValued': 'false'}
}' "${SOLRURL}/solr/monetdb/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'entity_name', 'indexed': 'true', 'required': 'true', 'type': 'text_general', 'multiValued': 'false'}
}' "${SOLRURL}/solr/monetdb/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'false', 'stored': 'true', 'type': 'pint', 'name': 'DataSetId', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/monetdb/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'string', 'name': 'MarkerName', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/monetdb/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'string', 'name': 'MarkerSequence', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/monetdb/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'string', 'name': 'MarkerDescription', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/monetdb/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'string', 'name': 'MarkerExtRef', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/monetdb/schema"

#

curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'pint', 'name': 'ExtractId', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/monetdb/schema"

curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'pint', 'name': 'GenotypeId', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/monetdb/schema"

curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'pint', 'name': 'ItemGroupId', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/monetdb/schema"

curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'pint', 'name': 'AnalysisGroupId', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/monetdb/schema"

curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'pint', 'name': 'GenotypeTrialList', 'required': 'false', 'multiValued': 'true'}
}' "${SOLRURL}/solr/monetdb/schema"

curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'pint', 'name': 'GenotypeTrialUnitList', 'required': 'false', 'multiValued': 'true'}
}' "${SOLRURL}/solr/monetdb/schema"

curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'pint', 'name': 'GenotypeTrialUnitSpecimenList', 'required': 'false', 'multiValued': 'true'}
}' "${SOLRURL}/solr/monetdb/schema"

curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'pint', 'name': 'ItemGroupTrialList', 'required': 'false', 'multiValued': 'true'}
}' "${SOLRURL}/solr/monetdb/schema"

curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'pint', 'name': 'ItemGroupTrialUnitList', 'required': 'false', 'multiValued': 'true'}
}' "${SOLRURL}/solr/monetdb/schema"

curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'pint', 'name': 'ItemGroupTrialUnitSpecimenList', 'required': 'false', 'multiValued': 'true'}
}' "${SOLRURL}/solr/monetdb/schema"

curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'pint', 'name': 'ItemGroupSpecimenList', 'required': 'false', 'multiValued': 'true'}
}' "${SOLRURL}/solr/monetdb/schema"

curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'pint', 'name': 'ItemGroupGenotypeList', 'required': 'false', 'multiValued': 'true'}
}' "${SOLRURL}/solr/monetdb/schema"

#

curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'false', 'type': 'text_general', 'name': 'text', 'multiValued': 'true'}
}' "${SOLRURL}/solr/monetdb/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-copy-field": {'dest': 'text', 'source': 'MarkerName'}
}' "${SOLRURL}/solr/monetdb/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-copy-field": {'dest': 'text', 'source': 'MarkerSequence'}
}' "${SOLRURL}/solr/monetdb/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-copy-field": {'dest': 'text', 'source': 'MarkerDescription'}
}' "${SOLRURL}/solr/monetdb/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-copy-field": {'dest': 'text', 'source': 'MarkerExtRef'}
}' "${SOLRURL}/solr/monetdb/schema"

# curl -X POST -H 'Content-type:application/json' --data-binary '{
# "delete-field": { "name":"id" }
# }' "${SOLRURL}/solr/monetdb/schema"