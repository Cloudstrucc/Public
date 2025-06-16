# CONFIGURING A STANDALONE USER FLOW FOR LOCAL AUTHENTICATION (WITHOUT LEVERAGING A THIRD PARTY IDP LIKE EAB OR SIC)

Select User Flows, and click on New user flow

![image info](./../Images/Picture37.png)

Next, select Sing up and sign in and the recommended tile under “Version”

![image info](./../Images/Picture38.png)

Select Email Signup, TOTP, and Conditional for MFA enforcement (policies to be defined in a later section). For user attributes, select Email Address, Given Name and Surname, press Ok and Create


![image info](./../Images/Picture39.png)

Once created, navigate to the newly created user flow and click on properties. Ensure to check “Require ID Token in Logout Requests”. 

Next, create a profile and password reset policy.

![image info](./../Images/Picture40.png)

***Apply the same settings from the Sign up and sign in user flow for both policies. For the Password reset policy ensure that the Reset password using email address option is checked.**

![image info](./../Images/Picture41.png)




