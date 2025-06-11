# RUNTIME VARIABLES

|Variable Name|	Description|
|-------------|-------------|
|**Artefact1**|	Provide the name of a solution (doesn’t need to be in the repository, the pipeline will perform the export and commit etc.) or configuration migration xml file (must be in the data directory in the repo)|
|**Artefact1-Target-Solution**|	If Artefact1 is a solution, and you need to copy its component to a primary solution, provide the name of the primary solution here|
|**Artefact2**|	Provide the name of a solution (doesn’t need to be in the repository, the pipeline will perform the export and commit etc.) or configuration migration xml file (must be in the data directory in the repo)|
|**Artefact2-Target-Solution**|	If Artefact2 is a solution, and you need to copy its component to a primary solution, provide the name of the primary solution here|
|**Artefact3**|	Provide the name of a solution (doesn’t need to be in the repository, the pipeline will perform the export and commit etc.) or configuration migration xml file (must be in the data directory in the repo)|
|**Artefact3-Target-Solution**|	If Artefact3 is a solution, and you need to copy its component to a primary solution, provide the name of the primary solution here|
|**Artefact4**	|Provide the name of a solution (doesn’t need to be in the repository, the pipeline will perform the export and commit etc.) or configuration migration xml file (must be in the data directory in the repo)|
|**Artefact4-Target-Solution**|	If Artefact4 is a solution, and you need to copy its component to a primary solution, provide the name of the primary solution here|
|**Deploy Portal?**|If set to yes, the pipeline will export the portal via CLI and commit to source. It will also deploy the portal to the target environment (using SourceURL and TargetURL)|
|**Comments**	|Used to issue the git comments when the pipelines automatically commit your artefacts|
|**Project Name**|	Optional, provides project context|
|**Variable-Group**|	Name of the variable group that is linked to the pipeline to leverage. The group must have the same variable names (and types) as the “Connection-Parameters” variable group. This is useful to isolated dev environments with specific Dataverse environments that fall outside the main dev stream.|

