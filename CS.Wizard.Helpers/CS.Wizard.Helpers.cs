using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Workflow;
using Microsoft.Xrm.Sdk.Query;
using System;
using System.Collections.Generic;
using System.Activities;
using System.Text.Json;

namespace CustomWorkflow
{
    public class UpdateJsonStep : CodeActivity
    {
        [Input("Table Name")]
        [RequiredArgument]
        public InArgument<string> TableName { get; set; }

        [Input("Column Name (JSON Column)")]
        [RequiredArgument]
        public InArgument<string> ColumnName { get; set; }

        [Input("Step Number")]
        [RequiredArgument]
        public InArgument<int> StepNumber { get; set; }

        [Input("Record")]
        [RequiredArgument]
        [ReferenceTarget("fintrac_questionnaire")]
        public InArgument<EntityReference> RecordId { get; set; }

        protected override void Execute(CodeActivityContext context)
        {
            // Initialize services
            IWorkflowContext workflowContext = context.GetExtension<IWorkflowContext>();
            IOrganizationService service = context.GetExtension<IOrganizationServiceFactory>().CreateOrganizationService(workflowContext.UserId);

            // Get input arguments
            string tableName = TableName.Get(context);
            string columnName = ColumnName.Get(context);
            int stepNumber = StepNumber.Get(context);
            EntityReference recordReference = RecordId.Get(context);

            // Log the record details for debugging

            // Retrieve the record based on the provided ID and table name
            Entity record = service.Retrieve(tableName, recordReference.Id, new ColumnSet(columnName));

            if (record != null && record.Contains(columnName))
            {
                // Get the existing JSON from the column
                string jsonContent = record.GetAttributeValue<string>(columnName);

                if (!string.IsNullOrEmpty(jsonContent))
                {
                    try
                    {
                        // Parse the existing JSON using System.Text.Json
                        var jsonDict = JsonSerializer.Deserialize<Dictionary<string, bool>>(jsonContent);

                        // Convert the step number to string and set it to true
                        string stepKey = stepNumber.ToString();
                        if (jsonDict.ContainsKey(stepKey))
                        {
                            jsonDict[stepKey] = true;  // Mark the step as completed
                        }
                        else
                        {
                            jsonDict.Add(stepKey, true); // Add new step if missing
                        }

                        // Serialize the updated dictionary back to JSON
                        string updatedJson = JsonSerializer.Serialize(jsonDict);

                        // Update the record
                        Entity updatedRecord = new Entity(tableName, recordReference.Id);
                        updatedRecord[columnName] = updatedJson;
                        service.Update(updatedRecord);
                    }
                    catch (Exception ex)
                    {
                        throw new InvalidPluginExecutionException("Error parsing or updating JSON column: " + ex.Message);
                    }
                }
            }
        }
    }

    public class InitializeManifestFromWebLinkSet : CodeActivity
    {
        [Input("Record")]
        [RequiredArgument]
        [ReferenceTarget("fintrac_questionnaire")]
        public InArgument<EntityReference> RecordId { get; set; }

        [Output("Manifest JSON")]
        public OutArgument<string> ManifestJson { get; set; }

        protected override void Execute(CodeActivityContext context)
        {
            IWorkflowContext workflowContext = context.GetExtension<IWorkflowContext>();
            IOrganizationService service = context.GetExtension<IOrganizationServiceFactory>().CreateOrganizationService(workflowContext.UserId);

            EntityReference recordRef = RecordId.Get(context);

            // Retrieve the questionnaire record to get the parent case
            Entity questionnaire = service.Retrieve(recordRef.LogicalName, recordRef.Id, new ColumnSet("fintrac_case"));

            if (!questionnaire.Contains("fintrac_case"))
            {
                throw new InvalidPluginExecutionException("The questionnaire record does not have an associated case.");
            }

            EntityReference caseRef = (EntityReference)questionnaire["fintrac_case"];

            // Retrieve the parent case to get the fintrac_questionnairetemplate
            Entity parentCase = service.Retrieve(caseRef.LogicalName, caseRef.Id, new ColumnSet("fintrac_questionnairetemplate"));

            if (!parentCase.Contains("fintrac_questionnairetemplate"))
            {
                throw new InvalidPluginExecutionException("The parent case does not have a fintrac_questionnairetemplate (Web Link Set) specified.");
            }

            EntityReference webLinkSetRef = (EntityReference)parentCase["fintrac_questionnairetemplate"];

            // Query for child web links
            //QueryExpression query = new QueryExpression("mspp_weblink")
            //{
            //    ColumnSet = new ColumnSet("mspp_displayordernumber"),
            //    Criteria = new FilterExpression
            //    {
            //        Conditions =
            //    {
            //        new ConditionExpression("mspp_weblinksetid", ConditionOperator.Equal, webLinkSetRef.Id)
            //    }
            //    },
            //    Orders = { new OrderExpression("mspp_displayordernumber", OrderType.Ascending) }
            //};

            // Query for child web links (only active ones)
            QueryExpression query = new QueryExpression("mspp_weblink")
            {
                ColumnSet = new ColumnSet("mspp_displayordernumber"),
                Criteria = new FilterExpression
                {
                    FilterOperator = LogicalOperator.And,
                    Conditions =
                    {
                        new ConditionExpression("mspp_weblinksetid", ConditionOperator.Equal, webLinkSetRef.Id),
                        new ConditionExpression("statecode", ConditionOperator.Equal, 0) // 0 represents the Active state
                    }
                },
                Orders = { new OrderExpression("mspp_displayordernumber", OrderType.Ascending) }
            };

            EntityCollection webLinks = service.RetrieveMultiple(query);

            // Create the JSON array with unique keys
            Dictionary<string, bool> manifestDict = new Dictionary<string, bool>();
            int stepCounter = 1;
            foreach (var webLink in webLinks.Entities)
            {
                int displayOrder = webLink.GetAttributeValue<int>("mspp_displayordernumber");
                string key = stepCounter.ToString();

                // Ensure the key is unique
                while (manifestDict.ContainsKey(key))
                {
                    stepCounter++;
                    key = stepCounter.ToString();
                }

                manifestDict.Add(key, false);
                stepCounter++;
            }

            // Serialize the dictionary to JSON
            string json = JsonSerializer.Serialize(manifestDict);

            // Set the output argument
            ManifestJson.Set(context, json);

            // Update the record with the new manifest
            Entity updateRecord = new Entity(recordRef.LogicalName, recordRef.Id);
            updateRecord["fintrac_portalformmanifest"] = json;
            service.Update(updateRecord);
        }
    }
}
