﻿using Microsoft.Xrm.Sdk;
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

        [Input("Record ID (as string)")]
        [RequiredArgument]
        public InArgument<string> RecordId { get; set; }

        protected override void Execute(CodeActivityContext context)
        {
            // Initialize services
            IWorkflowContext workflowContext = context.GetExtension<IWorkflowContext>();
            IOrganizationService service = context.GetExtension<IOrganizationServiceFactory>().CreateOrganizationService(workflowContext.UserId);

            // Get input arguments
            string tableName = TableName.Get(context);
            string columnName = ColumnName.Get(context);
            int stepNumber = StepNumber.Get(context);
            string recordIdString = RecordId.Get(context);

            // Convert the record ID string to a Guid
            if (!Guid.TryParse(recordIdString, out Guid recordId))
            {
                throw new InvalidPluginExecutionException("The provided Record ID is not a valid GUID.");
            }

            // Retrieve the record based on the provided ID and table name
            Entity record = service.Retrieve(tableName, recordId, new ColumnSet(columnName));

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
                        Entity updatedRecord = new Entity(tableName, recordId);
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
}