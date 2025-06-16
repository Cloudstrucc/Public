# ALM CHECKLIST


| **CONVENTIONS** |
---------------
|Solutions are unpacked and version controlled in GIT hosted repo in Azure DevOps |
|Solutions are repacked through an automated process and stored as  artefacts for releasees|
|Packages are built through an automated process that combines the required solutions and configuration data into a PackageDeployer.zip file |
|Solutions are exported and imported as managed|
|There is at least one discrete development instance per solution being developed (by line of business). A base solution includes common components is imported into LOB environments|
|Where multiple solutions are developed for deployment to a single production environment, the same solution publisher and prefix are used |
|Pipeline can support both standard solutions and solution patches| 
|Solution.zip files and their contents are never manually edited| 
|Where a solution being developed has dependencies on one or more solutions, the dependencies are satisfied through always importing those solutions as managed solutions into the discrete development instance for the solution being developed (e.g. Base solution)|
|Only managed solutions are deployed to environments downstream of development| 
|All solutions are deployed via the release pipeline| 
|No unmanaged changes are made directly to environments downstream of development| 
|Each test case has traceability back to requirement |
|Test cases are automated |
|The pipeline supports configuration data transfers|
|Exported configuration data is saved as artefacts|
|The pipeline’s runtime variables map to their own stage and run in the sequence they are provided by the user|
|If any stage fails, the pipeline exits (so will not execute subsequent stages to avoid faulty deployments)|
|Each stage generates a log artefact (e.g. Solution, Portal checker, diagnostics)|
|Release managers can create a release from a build which will leverage the artefacts from the build (instead of exporting these from an environment)|
|Any issues that are deemed critical by the solution checker and the portal checker will exit the pipeline|
|A default variable group is available to the build team. Each developer can clone the variable group for specific connection parameters. Alternatively, the organization can opt to leverage a single variable group to govern the connection parameters to each environment. Developers will always have access to a runtime variable and successful builds will store the resulting artefacts from these variables for future release.|
|The primary development stream solution set is static. Developers can create as many solutions as they need however, their components must be migrated to the primary solutions that make up the system. The same applies for the schema files. The pipeline allows a developer to deploy their solutions to the primary dev environment where the pipeline will merge its components to the primary solution|
|(OPTIONAL) In a scenario where DEPT opts for developer environments or developer solutions, the pipeline will support solution component mover API calls to merge developer solution components to the BASE, CanExport, and Sonar 360 solutions (and others for future LOB implementations)|


