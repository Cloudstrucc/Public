# Steps to configure SharePoint Integration

Navigate to https://make.powerapps.com and select the environment where SharePoint integration will be configured. Once selected, click on the Gear icon and “Advanced Settings”

![image info](./../Images/Picture9.png)

In the advanced settings navigate to document management.

![image info](./../Images/Picture10.png)

In the Document Management Settings, click on “Configure Server-Based SharePoint Integration” and in the modal press next, enter the SharePoint Subsite URL, press next again

![image info](./../Images/Picture11.png)

![image info](./../Images/Picture12.png)

In the Validate Sites step, press finish, once validated. If you receive an error it is likely due to permission issues.

![image info](./../Images/Picture13.png)

Next, click on “Document Management Settings” and select the tables whose records allow document attachments to be stored in SharePoint, paste in the Subsite and press next.

![image info](./../Images/Picture14.png)

Select “based on entity”. This will ensure that each configured table will have a dedicated folder and within these folders, a folder for each record will be created that houses the attachments associated to the record.

![image info](./../Images/Picture15.png)

Press “Finish” once completed

![image info](./../Images/Picture16.png)

Now that the SharePoint Subsite is integration with this environment, you can test by navigating to any record from a table you’ve configured and you will notice a new relationship entitled “Documents”. 

![image info](./../Images/Picture17.png)

You can test uploading a document and verifying that the document is found in the SharePoint Subsite 

![image info](./../Images/Picture18.png)

![image info](./../Images/Picture19.png)


