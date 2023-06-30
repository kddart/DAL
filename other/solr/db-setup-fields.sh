#!/bin/bash

SOLRHOST='localhost'
SOLRPORT='8983'

SOLRPROTOCOL='http'

SOLRURL="${SOLRPROTOCOL}://${SOLRHOST}:${SOLRPORT}"

curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'SolrId', 'indexed': 'true', 'required': 'true', 'type': 'text_general', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'TrialName', 'indexed': 'true', 'required': 'false', 'type': 'text_general', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'TrialId', 'indexed': 'true', 'required': 'false', 'type': 'plong', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'TraitId', 'indexed': 'true', 'required': 'false', 'type': 'plong', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'TrialStartDate', 'indexed': 'true', 'required': 'false', 'type': 'pdate', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'TrialEndDate', 'indexed': 'true', 'required': 'false', 'type': 'pdate', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'SiteName', 'indexed': 'true', 'required': 'false', 'type': 'text_general', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'GenotypeId', 'indexed': 'true', 'required': 'false', 'type': 'plong', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'GenotypeName', 'indexed': 'true', 'required': 'false', 'type': 'text_general', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'TraitName', 'indexed': 'true', 'required': 'false', 'type': 'text_general', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'SampleTypeName', 'indexed': 'true', 'required': 'false', 'type': 'text_general', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'AVG_TraitValue', 'indexed': 'true', 'required': 'false', 'type': 'pfloat', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'entity_name', 'indexed': 'true', 'required': 'true', 'type': 'text_general', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'TraitUnitName', 'indexed': 'true', 'required': 'false', 'type': 'text_general', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'ItemUnitName', 'indexed': 'true', 'required': 'false', 'type': 'text_general', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'SpecimenId', 'indexed': 'true', 'required': 'false', 'type': 'plong', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'SpecimenName', 'indexed': 'true', 'required': 'false', 'type': 'text_general', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'KnownForTraitName', 'indexed': 'true', 'required': 'false', 'type': 'text_general', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'KnownForTraitValue', 'indexed': 'true', 'required': 'false', 'type': 'text_general', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'GenotypeAliasName', 'indexed': 'true', 'required': 'false', 'type': 'string', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'GenotypeAliasType', 'indexed': 'true', 'required': 'false', 'type': 'pint', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'GenotypeAliasStatus', 'indexed': 'true', 'required': 'false', 'type': 'pint', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'GenotypeAliasLang', 'indexed': 'true', 'required': 'false', 'type': 'text_general', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'GenotypeAliasTypeName', 'indexed': 'true', 'required': 'false', 'type': 'string', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'GenotypeAliasStatusName', 'indexed': 'true', 'required': 'false', 'type': 'string', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'ItemTypeName', 'indexed': 'true', 'required': 'false', 'type': 'string', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'ItemStatusName', 'indexed': 'true', 'required': 'false', 'type': 'string', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'StorageLocation', 'indexed': 'true', 'required': 'false', 'type': 'string', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'BreedingMethodId', 'indexed': 'true', 'required': 'false', 'type': 'plong', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'SpecimenBarcode', 'indexed': 'true', 'required': 'false', 'type': 'string', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'IsActive', 'indexed': 'true', 'required': 'false', 'type': 'boolean', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'Pedigree', 'indexed': 'true', 'required': 'false', 'type': 'text_general', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'SelectionHistory', 'indexed': 'true', 'required': 'false', 'type': 'text_general', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'FilialGeneration', 'indexed': 'true', 'required': 'false', 'type': 'pint', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'GenusId', 'indexed': 'true', 'required': 'false', 'type': 'pint', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'SpeciesName', 'indexed': 'true', 'required': 'false', 'type': 'string', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'GenotypeAcronym', 'indexed': 'true', 'required': 'false', 'type': 'string', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'GenotypeNote', 'indexed': 'true', 'required': 'false', 'type': 'text_general', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'plong', 'name': 'TraitUnitId', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'pint', 'name': 'ItemUnitId', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'plong', 'name': 'TrialUnitSpecimenId', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'pint', 'name': 'ItemSourceId', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'pint', 'name': 'ContainerTypeId', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'pint', 'name': 'ScaleId', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'ture', 'type': 'pint', 'name': 'StorageId', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'pint', 'name': 'ItemTypeId', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'pint', 'name': 'ItemStateId', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'text_general', 'name': 'ItemBarcode', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'pfloat', 'name': 'Amount', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'pdate', 'name': 'DateAdded', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'pint', 'name': 'AddedByUserId', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'pdate', 'name': 'LastMeasuredDate', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'pint', 'name': 'LastMeasuredUserId', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'text_general', 'name': 'ItemOperation', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'text_general', 'name': 'ItemNote', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"

#


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'pint', 'name': 'GenotypeList', 'required': 'false', 'multiValued': 'true'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'pint', 'name': 'SpecimenList', 'required': 'false', 'multiValued': 'true'}
}' "${SOLRURL}/solr/db/schema"

curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'pint', 'name': 'GenotypeAnalysisGroupList', 'required': 'false', 'multiValued': 'true'}
}' "${SOLRURL}/solr/db/schema"

curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'pint', 'name': 'GenotypeDataSetList', 'required': 'false', 'multiValued': 'true'}
}' "${SOLRURL}/solr/db/schema"

curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'pint', 'name': 'ItemGroupList', 'required': 'false', 'multiValued': 'true'}
}' "${SOLRURL}/solr/db/schema"

curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'pint', 'name': 'ItemGroupAnalysisGroupList', 'required': 'false', 'multiValued': 'true'}
}' "${SOLRURL}/solr/db/schema"

curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'pint', 'name': 'ItemGroupDataSetList', 'required': 'false', 'multiValued': 'true'}
}' "${SOLRURL}/solr/db/schema"

#

curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'false', 'type': 'text_general', 'name': 'text', 'multiValued': 'true'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-copy-field": {'dest': 'text', 'source': 'SolrId'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-copy-field": {'dest': 'text', 'source': 'TrialName'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-copy-field": {'dest': 'text', 'source': 'SiteName'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-copy-field": {'dest': 'text', 'source': 'SampleTypeName'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-copy-field": {'dest': 'text', 'source': 'TraitName'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-copy-field": {'dest': 'text', 'source': 'GenotypeName'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-copy-field": {'dest': 'text', 'source': 'SpecimenName'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-copy-field": {'dest': 'text', 'source': 'ItemNote'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-copy-field": {'dest': 'text', 'source': 'entity_name'}
}' "${SOLRURL}/solr/db/schema"

# curl -X POST -H 'Content-type:application/json' --data-binary '{
# "delete-field": { "name":"id" }
# }' "${SOLRURL}/solr/db/schema"
