# Portal Conventions

**Basic Forms/wizards:**

- When creating basic forms always make sure to redirect the user post successful submission – and the successful message should always be worded in the correct context (e.g in the notifcaiton centre when the user checks “Mark as read” and they press submit, they should be redirected to the notification center home page and not just the default behavior of the form disappearing. This is important for demos with clients and these are quick items that should not be overlooked.

- Always re-label the submit button to describe its context. For example, the first step of a wizard form (insert) should read “agree and continue” instead of “submit”

- Always (or for the most part), render lookups as drop downs. In very rare cases will keep the. Default lookup control behavior

- We should always have the right validation messages (and never the defaults)

- If there is a long running process, we should show a loading indicator with opacity in the background so that the user knows something is happening 

- In general, always use a 1 column layout for portal wizard steps

- Each portal wizard step which is a basic form should have its submit button re-labelled to “Complete this step” or “Save and Continue”-

- Always include a cache string in tables rendereded using FETCHXML so the user will see the most up to date data

- For long step wizards (3+ steps) add a 'save and exit' button





 
