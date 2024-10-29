# Naming conventions

Naming conventions play a crucial role in Dynamics 365 field names as they contribute significantly to the clarity, consistency, and usability of the system. Consistent and descriptive field names enhance understandability, making it easier for users, developers, and administrators to interpret and interact with the data. Clear naming conventions facilitate efficient data management, customization, and reporting processes within Dynamics 365, reducing ambiguity, errors, and misunderstandings. Moreover, adherence to naming conventions ensures that the system remains organized and scalable, promoting better collaboration, maintenance, and long-term sustainability of the platform. Ultimately, well-defined naming conventions improve user productivity, data quality, and overall user satisfaction within Dynamics 365 environments.

## General guidelines

For Dynamics 365 naming conventions, it's crucial to maintain consistency, clarity, and relevance. Based on the examples provided and general guidelines, here's a summary of recommended naming conventions:

**Field Name (Label):** Ensure the field name accurately describes the data it holds. Use clear, concise terms that are easily understandable by users. For example, "Number of employees worldwide" and "Select the type of technology you support" are descriptive and intuitive labels.

**Schema Name (Technical Name):** The schema name should be a concise representation of the field's purpose and content, adhering to a consistent naming convention across all custom fields. Include prefixes that denote the field type to facilitate sorting and categorization. For instance, "core_numemployeesworldwide" and "core_technologysupportedcode" follow this pattern.

**Prefixes (not publisher prefix but column name prefix):** Utilize prefixes to signify the data type of the field, such as "num" for numeric fields, "amt" for currency fields, "date" for date and time fields, and so on. This helps in organizing and identifying fields within the system. For example, "core_numcomplianceemployeesvstotalemployees" clearly indicates the data type and purpose of the field.

**Avoid Ambiguity:** Ensure that schema names are unambiguous and distinct, reducing the likelihood of confusion or misinterpretation. Use specific terms and avoid generic or overly broad names. For instance, "core_technologysupportedcode" is clearer than a generic name like "field1" or "value."

**Consistency:** Maintain consistency in naming conventions across all custom fields within the system. Consistency improves usability and reduces the learning curve for users interacting with the system. Follow the established conventions rigorously to ensure uniformity and coherence in field naming.

By following these naming conventions, you can create a well-organized and intuitive data structure within Dynamics 365, enhancing usability, maintainability, and overall user experience.

| Power Apps data type            | Example Field Name                                                    | Example Schema name                                                           |
| ------------------------------- | --------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| **Big Integer**           | **Number of employees worldwide**                               | core_**num**employeesworldwide                                       |
| **Choice**                | **Select the type of technology you support**                   | core_technologysupported**code**                                     |
| **Choices**               | **Select one or more of the Canadian provinces you operate in** | core_provincesoperating**code**                                      |
| **Currency**              | **Total expenses**                                              | core_**amt**totalexpenses                                            |
| **Customer**              | **Customer**                                                    | core_customer**id (postfix id)**                                     |
| **Date and Time**         | **Date and Time** `<br>`*Date and Time* Format              | core_**date**incorporated                                            |
| **Date Only**             | **Date and Time** `<br>`*Date Only* Format                  | core_**date**registered                                              |
| **Decimal Number**        | **Decimal Number**                                              | core_**num**complianceemployeesvstotalemployees                      |
| **Duration**              | **Whole Number** `<br>`*Duration* Format                    | core_**num**employeesworldwide                                       |
| **Email**                 | **Single Line of Text** `<br>`*Email* Format                | core_email (no prefix required for type)                                   |
| **File**                  | **File**                                                        | core_**file**transactionreport                                       |
| **Floating Point Number** | **Floating Point Number**                                       | core_**num**proportionbranchvsheadquarters                           |
| **Image**                 | **Image**                                                       | core_**img**logo                                                     |
| **Language**              | **Whole Number** `<br>`*Language* Format                    | core_**num**employees                                                |
| **Lookup**                | **Lookup**                                                      | core_caser**id (postfix id)**                                       |
| **Multiline Text**        | **Multiple Lines of Text**                                      | core_description (no prefix required for type)                            |
| **Owner**                 | **Owner**                                                       | N/A                                                                           |
| **Phone**                 | **Single Line of Text** `<br>`*Phone* Format                | core_phone (no prefix required for type)                                  |
| **Status**                | **Status**                                                      | N/A                                                                           |
| **Status Reason**         | **Status Reason**                                               | N/A                                                                           |
| **Text**                  | **Single Line of Text** `<br>`*Text* Format                 | core_legalname (no prefix required for type)                               |
| **Text Area**             | **Single Line of Text** `<br>`*Text Area* Format            | core_description (no prefix required for type)                            |
| **Ticker Symbol**         | **Single Line of Text** `<br>`Ticker Symbol Format            | core_tickersymbol (no prefix required for type)                           |
| **Timezone**              | **Whole Number** `<br>`*Time Zone* Format                   | N/A                                                                           |
| **Unique Identifier**     | **Unique Identifier** or **Primary Key**                  | N/A                                                                           |
| **URL**                   | **Single Line of Text** `<br>`*URL* Format                  | core_websiteurl (no prefix required for type)                              |
| **Whole Number**          | **Whole Number** `<br>`*None* Format                        | core_**num**employeesworldwide                                       |
| **Yes/No**                | **Two Options**                                                 | core_**is**registered or core_**has**locationsoutsidecanada |
