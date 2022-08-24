# Bloodhound

## The syntax change

Legacy Broken queries
```
MATCH p=(m:Group)-[r:Owns|:WriteDacl|:GenericAll|:WriteOwner|:ExecuteDCOM|:GenericWrite|:AllowedToDelegate|:ForceChangePassword]->(n:Computer) WHERE m.name STARTS WITH ‘DOMAIN USERS’ RETURN p
```
To fix - remove the ":" in the relationship
```
MATCH p=(m:Group)-[r:Owns|WriteDacl|GenericAll|WriteOwner|ExecuteDCOM|GenericWrite|AllowedToDelegate|ForceChangePassword]->(n:Computer) WHERE m.name STARTS WITH 'DOMAIN USERS' RETURN p
```
## Cobaltstrike integration 
https://github.com/vysecurity/ANGRYPUPPY/blob/master/cypher.cna

Create Bloodhound queries from beacon information.

## Useful Bloodhound queries
### Console
Find user members of a group
```
MATCH p=(m:User)-[r:MemberOf]->(n:Group)
WHERE n.name = "DOMAIN ADMINS@<DOMAIN>"
RETURN m.name, n.name ORDER BY m.name
```

Find computer members of a group
```
MATCH p=(m:Computer)-[r:MemberOf]->(n:Group)
WHERE n.name = "DOMAIN CONTROLLERS@<DOMAIN>"
RETURN m.name, n.name ORDER BY m.name

```

Filtering on Labels
```
MATCH (n:User) WHERE n:Foreignsecurityprincipal
RETURN n.name, labels(n)
```


Show hosts with unconstrained delegation 
```
Match (n:Computer) where n.unconstraineddelegation = true
RETURN n.name
```

Find Cross domain privs
```
MATCH p=(n)-[r]->(d) WHERE NOT d.domain=n.domain RETURN n.name,type(r),d.name

Or for rights from a specific domain outbound
MATCH p=(n {domain:'<domain>'})-[r]->(d) WHERE NOT d.domain=n.domain RETURN n.name,n.owned,type(r),d.name

Filter for owned users only 
MATCH p=(n {domain:'DS.CCEP.COM'})-[r]->(d) WHERE NOT d.domain=n.domain AND n.owned RETURN n.name,n.owned,type(r),d.name
```

Find legacy systems
```
MATCH (H:Computer) WHERE H.operatingsystem =~ '.*(2000|2003|xp|vista|7|me).*' AND H.domain = "<domain>" RETURN H.name, H.operatingsystem, H.domain, H.labels, H.description, H.haslaps
```

Total admins on a host
```
MATCH (c:Computer {domain:'<domain>'}) WITH c
OPTIONAL MATCH (n)-[r:AdminTo]->(c) WITH c,COUNT(n) as explicitAdmins
OPTIONAL MATCH (n)-[r:MemberOf*1..]->(g:Group)-[r2:AdminTo]->(c) WITH c,explicitAdmins,COUNT(DISTINCT(n)) as unrolledAdmins
RETURN c.name,explicitAdmins,unrolledAdmins,explicitAdmins + unrolledAdmins as totalAdmins
ORDER BY totalAdmins DESC
```
Find high priv groups
```
MATCH (m:Group)-[r:Owns|WriteDacl|GenericAll|WriteOwner|ExecuteDCOM|GenericWrite|AllowedToDelegate|ForceChangePassword]->(n:Computer) RETURN type(r), m.name , n.name
![image](https://user-images.githubusercontent.com/62152036/135095957-57751ec4-d9e2-4ec1-9de2-46c1fb985d02.png)

```

Adding high value tag to additional users
```
Updating in dashboard is slow, especially with large datasets and no GPU passthrough - USE SET!
MATCH (m:Group)-[r:Owns|WriteDacl|GenericAll|WriteOwner|ExecuteDCOM|GenericWrite|AllowedToDelegate|ForceChangePassword]->(n:Computer) 
SET m.highvalue=TRUE
RETURN type(r), m.name,m.highvalue , n.name
```

Removing high value tag to additional users
```
MATCH (m:Group)-[r:Owns|WriteDacl|GenericAll|WriteOwner|ExecuteDCOM|GenericWrite|AllowedToDelegate|ForceChangePassword]->(n:Computer) 
SET m.highvalue=FALSE
RETURN type(r), m.name,m.highvalue , n.name
```

Mark groups as owned if a member is owned
```
MATCH (n:User {owned: true})-[r:MemberOf]->(g:Group) SET g.owned=true
```

Count high permissions on groups
```
MATCH (m:Group)-[r:Owns|WriteDacl|GenericAll|WriteOwner|ExecuteDCOM|GenericWrite|AllowedToDelegate|ForceChangePassword]->(n:Computer) 
RETURN count(Distinct(m.name)),m.name

MATCH (m:Group)-[r:Owns|WriteDacl|GenericAll|WriteOwner|ExecuteDCOM|GenericWrite|AllowedToDelegate|ForceChangePassword]->(n:Computer) 
RETURN count(m.name),m.name
```
