# VARIABLE GROUP: CONNECTION-PARAMETERS

|Variable Name	|Description|
|---------------|-----------|
|**ClientID**	|App Registration’s ClientID (ApplicationID – SPN for Dataverse Environments’ App User (assumes 1 SPN for multiple environments)|
|**DeploymentProfile-PROD**|	Portals ->  PROD Global settings (located in Deployment-Profiles folder in repository – prod.deployment.yml|
|**DeploymentProfile-TEST**|	Portals -> TEST Global settings (located in Deployment-Profiles folder in repository – test.deployment.yml|
|**DeploymentProfile-UAT**|	Portals -> UAT Global settings (located in Deployment-Profiles folder in repository – uat.deployment.yml|
|**Secret**	|App Registration’s Client Secret (SPN for Dataverse Environments’ App User (assumes 1 SPN for multiple environments)|
|**SourceConnection-DEV**|	Value is populated by ClientID, Secret, Source and Target URLs, and TenantID – this is for data transfers |
|**SourceConnection-UAT**|	Value is populated by ClientID, Secret, Source and Target URLs, and TenantID – this is for data transfers|
|**SourceSPN-DEV**|	Service Connection name for DEV (Source environment)|
|**SourceSPN-UAT**|	Service Connection name for UAT (Source environment)|
|**SourceURL-DEV**|	Source URL for DEV (feeds SourceConnection variable)|
|**SourceURL-UAT**|	Source URL for UAT (feeds SourceConnection variable)|
|**TargetConnection-DEV**|	Value is populated by ClientID, Secret, Source and Target URLs, and TenantID – this is for data transfers (source environment connection string)|
|**TargetConnection-UAT**|	Value is populated by ClientID, Secret, Source and Target URLs, and TenantID – this is for data transfers (target environment connection string)|
|**TargetSPN-DEV**|	Service Connection name for DEV (Target environment)|
|**TargetSPN-UAT**|	Service Connection name for UAT (Target environment)|
|**TargetURL-PROD**|	Target URL for PROD (feeds TargetConnection variable)|
|**TargetURL-UAT**|	Target URL for PROD (feeds TargetConnection variable)|
|**TargetURL-DEV**|	Target URL for DEV (feeds TargetConnection variable)|
|**TenantID**|	Azure tenant ID hosting App registration record|
