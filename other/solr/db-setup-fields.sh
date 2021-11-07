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
"add-field": {'stored': 'true', 'name': 'TrialId', 'indexed': 'true', 'required': 'false', 'type': 'long', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'TraitId', 'indexed': 'true', 'required': 'false', 'type': 'long', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'TrialStartDate', 'indexed': 'true', 'required': 'false', 'type': 'date', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'TrialEndDate', 'indexed': 'true', 'required': 'false', 'type': 'date', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'SiteName', 'indexed': 'true', 'required': 'false', 'type': 'text_general', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'GenotypeId', 'indexed': 'true', 'required': 'false', 'type': 'long', 'multiValued': 'false'}
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
"add-field": {'stored': 'true', 'name': 'AVG_TraitValue', 'indexed': 'true', 'required': 'false', 'type': 'float', 'multiValued': 'false'}
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
"add-field": {'stored': 'true', 'name': 'SpecimenId', 'indexed': 'true', 'required': 'false', 'type': 'long', 'multiValued': 'false'}
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
"add-field": {'stored': 'true', 'name': 'GenotypeAliasType', 'indexed': 'true', 'required': 'false', 'type': 'int', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'GenotypeAliasStatus', 'indexed': 'true', 'required': 'false', 'type': 'int', 'multiValued': 'false'}
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
"add-field": {'stored': 'true', 'name': 'BreedingMethodId', 'indexed': 'true', 'required': 'false', 'type': 'long', 'multiValued': 'false'}
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
"add-field": {'stored': 'true', 'name': 'FilialGeneration', 'indexed': 'true', 'required': 'false', 'type': 'int', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'stored': 'true', 'name': 'GenusId', 'indexed': 'true', 'required': 'false', 'type': 'int', 'multiValued': 'false'}
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
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'long', 'name': 'TraitUnitId', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'int', 'name': 'ItemUnitId', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'long', 'name': 'TrialUnitSpecimenId', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'int', 'name': 'ItemSourceId', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'int', 'name': 'ContainerTypeId', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'int', 'name': 'ScaleId', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'ture', 'type': 'int', 'name': 'StorageId', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'int', 'name': 'ItemTypeId', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'int', 'name': 'ItemStateId', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'text_general', 'name': 'ItemBarcode', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'float', 'name': 'Amount', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'date', 'name': 'DateAdded', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'int', 'name': 'AddedByUserId', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'date', 'name': 'LastMeasuredDate', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'int', 'name': 'LastMeasuredUserId', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'text_general', 'name': 'ItemOperation', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'text_general', 'name': 'ItemNote', 'required': 'false', 'multiValued': 'false'}
}' "${SOLRURL}/solr/db/schema"

#


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'int', 'name': 'GenotypeList', 'required': 'false', 'multiValued': 'true'}
}' "${SOLRURL}/solr/db/schema"


curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'int', 'name': 'SpecimenList', 'required': 'false', 'multiValued': 'true'}
}' "${SOLRURL}/solr/db/schema"

curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'int', 'name': 'GenotypeAnalysisGroupList', 'required': 'false', 'multiValued': 'true'}
}' "${SOLRURL}/solr/db/schema"

curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'int', 'name': 'GenotypeDataSetList', 'required': 'false', 'multiValued': 'true'}
}' "${SOLRURL}/solr/db/schema"

curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'int', 'name': 'ItemGroupList', 'required': 'false', 'multiValued': 'true'}
}' "${SOLRURL}/solr/db/schema"

curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'int', 'name': 'ItemGroupAnalysisGroupList', 'required': 'false', 'multiValued': 'true'}
}' "${SOLRURL}/solr/db/schema"

curl -X POST -H 'Content-type:application/json' --data-binary '{
"add-field": {'indexed': 'true', 'stored': 'true', 'type': 'int', 'name': 'ItemGroupDataSetList', 'required': 'false', 'multiValued': 'true'}
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

curl -X POST -H 'Content-type:application/json' --data-binary '{
"delete-field": { "name":"id" }
}' "${SOLRURL}/solr/db/schema"
