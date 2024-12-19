# Redis Cache
## eters
* *name*: **Required** - The name of the Redis cache resource. Start and end with alphanumeric. Consecutive hyphens not allowed
* *location*: **Optional** - The location to deploy the Redis cache service.
* *tags*: **Optional** - Tags of the resource.
* *keyvaultName*: The name of an existing keyvault, that it will be used to store secrets (connection)
* *enableNonSslPort*: **Optional** - Specifies whether the non-ssl Redis server port (6379) is enabled.
* *redisConfiguration*: **Optional** - All Redis Settings. Few possible keys: rdb-backup-enabled,rdb-storage-connection-,rdb-backup-frequency,maxmemory-delta,maxmemory-policy,notify-keyspace-events,maxmemory-samples,slowlog-log-slower-than,slowlog-max-len,list-max-ziplist-entries,list-max-ziplist-value,hash-max-ziplist-entries,hash-max-ziplist-value,set-max-intset-entries,zset-max-ziplist-entries,zset-max-ziplist-value etc.
* *replicasPerMaster*: **Optional** - The number of replicas to be created per primary.
* *replicasPerPrimary*: **Optional** - The number of replicas to be created per primary.
* *shardCount*: **Optional** - The number of shards to be created on a Premium Cluster Cache.
* *capacity*: **Optional** - The size of the Redis cache to deploy. Valid values: for C (Basic/Standard) family (0, 1, 2, 3, 4, 5, 6), for P (Premium) family (1, 2, 3, 4).
* *skuName*: Optional, default is Standard. The type of Redis cache to deploy.
* *subnetId*: **Optional** - The full resource ID of a subnet in a virtual network to deploy the Redis cache in. Example format: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/Microsoft.{Network|ClassicNetwork}/VirtualNetworks/vnet1/subnets/subnet1.
* *diagnosticSettingsName*: **Optional** - The name of the diagnostic setting, if deployed.
* *diagnosticWorkspaceId*: **Optional** - Resource ID of the diagnostic log analytics workspace. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.
* *diagnosticLogCategoriesToEnable*: **Optional** - The name of logs that will be streamed. "allLogs" includes all possible logs for the resource.
* *diagnosticMetricsToEnable*: **Optional** - The name of metrics that will be streamed.
* *hasPrivateLink*: **Optional** - Has the resource a private endpoint?

## Resources
[Bicep Module](/code/01%20-%20Modules/modules/redisCache.bicep)