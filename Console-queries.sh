#!/bin/bash


NEO4J_USERNAME='neo4j'
NEO4J_PASSWORD='XXXXXXXXX'
NEO4J_HOST='XXXXXXXXXX'


NEO4J_REQUEST(){
curl -v -X POST -H 'Content-type: application/json' http://${NEO4J_USERNAME}:${NEO4J_PASSWORD}@${NEO4J_HOST}:7474/db/data/transaction/commit -d "{\"statements\": [{\"statement\": \"${1}\"}]}" | jq .[][].data[]
}



NEO4J_REQUEST "MATCH (c {unconstraineddelegation:true}) return {Name: c.name, Desc: c.description}" \
> Unconstrained_Deleg_ALL.json

NEO4J_REQUEST "MATCH (c1:Computer)-[:MemberOf*1..]->(g:Group) WHERE g.objectid ENDS WITH '-516' WITH COLLECT(c1.name) AS domainControllers MATCH (c2:Computer {unconstraineddelegation:true}) WHERE NOT c2.name IN domainControllers RETURN {Name: c2.name}" \
> Unconstrained_Deleg_NoDCs.json
