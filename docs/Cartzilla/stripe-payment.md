# Stripe JavaScript APIs for Cartzilla Payment

___

Stripe is a suite of payment APIs that powers commerce for online businesses of all sizes, including fraud prevention, and subscription management.
This reference documents the JavaScript’ objects and methods of Stripe library used to process online payments in Cartzilla application.

In order to connect with Stripe payment server programmatically, we need to set up a Stripe developer account. We need to navigate to Stripe Registration page **https://dashboard.stripe.com/register**, fill in the appropriate fields and then select “Create your Stripe Account” button.
Once the account is set up, we will be redirected to the Stripe Dashboard and an email will be sent to verify the email address.
In the opened dashboard, we will need to navigate to the “API” tab and copy the created “Publishable” and “Secret” API key. These will be used in our code to communicate with Stripe payment gateway.

In our code, for the payment page, we need to include the Stripe.js library. That is:
```
<script src="https://js.stripe.com/v3/"></script>
```

Then, we use our Stripe publishable API key to create an instance of the Stripe object. The Stripe object is the entry point to the rest of the Stripe.js SDK.
```
var stripe = Stripe('pk_test_51KVzfLFJRJ8V5xCA7OWU4TGN0OX0RV4RHm8eIp7plpLkhluNBl53');
```

Note that this is just a test key, when we are ready to accept live payments, we need to replace the test key with our live key in production.

After that, we will be ready to create the Elements object. The Stripe Elements are customizable UI components used to collect sensitive information in the payment forms. They are embeddable components for securely collecting payment details. They support dozens of payment methods with a single integration.

```
var elements = stripe.elements();
var cardElement = elements.create('card', { style: { …} } );
```

We then mount the cardElement object, previously created, to the card id in the form. Here the card id is ‘card-element’)

```
 <form …
   <div class="group" >
       <label>
         <span>Card</span>
         <div class="mb-3 col-sm-12"> 
           <div id="card-element" class="field"></div>
         </div>
       </label>
   </div>
```
```
cardElement.mount('#card-element');
```

After that, we are ready to create a stripe token. In the submit event of the form, we try to create a token with:
```
stripe.createToken(cardElement).then(stripeResponseHandler);
```

The **_stripeResponeHandler_** is a callback function that issues an Ajax call to the Stripe server using our API secret key:

```
$.ajax({
  type: 'POST',
  url: 'https://api.stripe.com/v1/charges',
  headers: {
    Authorization: 'Bearer sk_test_51KVzfLFJRJ8V5xCAMQJEnlNbjYInuftHha5Z2IngtrE4C1dKgXhH5'
  },
  data: {
    amount: AmountValue, 
    currency: currencyCode, 
    source: response.token.id,
    description: "Charge for CartZilla.com"
  },
  success: (response) => {
    var token = response.id;
    var receipt = response.receipt_url;
    console.log('successful payment: ', response);
    SucessfulPayment(token,receipt);
  },
  error: (response) => {
    console.log('error payment: ', response);
    FailedPayment(response);  
  }
})

```
In the data object, **_AmountValue_** is the amount value to be paid and **_currencyCode_** is the currency applied to the amount.

If the call succeeds, we will receive a transaction token and an invoice receipt.

The rest of the code in the payment page is plain Javascript and Ajax async calls to manage the different responses from the Stripe payment server.

## Stripe Payment Response Processing


When the user clicks on the Pay button to submit the payment, the following event triggers:

```
$(form).submit(function(event) {
  if(all_is_done==false){
    // prevent the form from submitting by default
    event.preventDefault();
    stripe.createToken(cardElement).then(stripeResponseHandler);
  }
});
```
**All_is_done** is a Boolean initialized to false, it allows to have a condition on submit event as this event will be triggered more than once. On first submit, the event enters the if condition. But, on the following calls, when All_is_done set to true, the form submits without any processing.
**Event.preventDefault()** call allows the form to prevent from submitting, which is the default behavior, as we need to do some processing before going to checkout-complete page.
**stripe.createToken(cardElement).then(stripeResponseHandler)** call, first connects to Stripe server and tries to create the token from user inputs than executes stripeResponseHandler.

```
function stripeResponseHandler(response) {
  if ( response.error ){
    var errorText = response.error;
    var message = "Failed Transaction. " + errorText.message;
    sessionStorage.setItem('Message', message);
    all_is_done=true;
    $(form).submit();
  }
  else {  
    $.ajax({
      type: 'POST',
      url: 'https://api.stripe.com/v1/charges',
      headers: {
        Authorization: 'Bearer sk_test_51KVzfLFJRJ8V5xCAMQJEnlNbjYInuftHha5Z2'
      },
      data: {
        amount: AmountValue, 
        currency: currencyCode, //'usd',
        source: response.token.id,
        description: "Charge for CartZilla.com" 
      },
      success: (response) => {
        var token = response.id; 
        var receipt = response.receipt_url;
        console.log('successful payment: ', response);
        SucessfulPayment(token,receipt);
      },
      error: (response) => {
        console.log('error payment: ', response);
        FailedPayment(response);
      }
    })
  }
}
```
First we test if **response.error** which means an error occurs. This produces when the user enters incorrect values in the form (for example card number with less digits, expiry date in the past, etc.). So, if error, we assign to message variable the string **"Failed Transaction. " + errorText.message**, we put it in sessionStorage to get it when the checkout-complete page opens. Then **we assign true to Boolean all_is_done** because we finished our processing. Here, the event submit submits just the page and open the checkout-complete page without any other processing (without executing stripe.createToken(cardElement).then(stripeResponseHandler); again).

If there are no validation errors on user input, the ajax call will be submitted to stripe server with the required values needed for stripe. Here the call can succeed or fail. If it fails, we call the function 
**FailedPayment(response)**:

```
function FailedPayment (response){
  var errorText = response.responseJSON.error;
  var message = "Failed Transaction. " + errorText.message;
  sessionStorage.setItem('Message', message);
  all_is_done=true;
  $(form).submit();
}
```

Here the process is the same as the previous fail. We assign to message the string "Failed Transaction. " + errorText.message, then we put it in sessionStorage to get it when the checkout-complete page opens. Then we assign true to all_is_done Boolean because we finished our processing and when we call submit event it submits just the page and open the checkout-complete page without executing stripe.createToken(cardElement).then(stripeResponseHandler); again

If the call succeeds, a token and a receipt_url will be created by Stripe. Here we call the function **SucessfulPayment(token,receipt)** that does the following:

```
function SucessfulPayment (token, receipt){       
  // Clear the form items
  document.getElementById("Amount").innerHTML = "Please wait ...";
  var OrderNumber = sessionStorage.getItem("OrderNumber");
  sessionStorage.setItem('OrderNumber', OrderNumber);
  UpdateInvoiceOrder(receipt, token)
}
```
Here we put the order number in a session storage to get it when the checkout-complete page opens, then we call the function UpdateInvoiceOrder(receipt, token).

```
function UpdateInvoiceOrder(receipt, token) {
  var OrderId = sessionStorage.getItem("OrderId");
  var input ={};
  webapi.safeAjax({
    type: "POST",
    url:  "https://cartzilla-dev-cs.powerappsportals.com/_api/salesorders(" + OrderId + ")/Microsoft.Dynamics.CRM.clds_invoiceorder",
    contentType: "application/json",
    data: JSON.stringify(input),
    success: function (res, status, xhr) {
      console.log("Success");
      sessionStorage.setItem('Receipt', receipt);
      sessionStorage.setItem('Token', token);
      sessionStorage.setItem('Message', "Successful Transaction");
      all_is_done=true;
      $(form).submit();
    },
    error: function (xhr, textStatus, errorThrown) {
      console.log(xhr);
      sessionStorage.setItem('Message', "Problem with the order");
      all_is_done=true;
      $(form).submit();
    }
  });   
}
```
This call gets the **OrderId** and executes the Dynamics Action **clds_invoiceorder** which performs the following:
* Move custom tax value to actual tax field
* Create invoice based off order
* Update invoice status to Paid-complete
* Update order status to Invoiced

If the call fails, then it submits the form with session message “Problem with the order”. Otherwise, if the call succeeds, it sends with the session: the receipt, the token, and the message “Successful transaction”
**In checkout-complete page, it takes the messages sent in the session storage and displays the result accordingly**.

## Cartzilla Payment Testing


In Cartzilla payment integration with Stripe, we can simulate transactions without moving any money, using special values in test mode. Scenarios to simulate are:
* Successful payments by special card numbers
* Card errors due to declines or invalid data

## Valid cart numbers to simulate
To simulate a successful payment, we can test cards from the following list. 

### Simulate billing country to United States with different type of cards (Visa, Mastercard, American Express, Discover, Diners Club, JCB, UnionPay)


Brand |	Number |	CVC 	|Date
--------|-------------------| -----------------|-------------------|
Visa |	4242 4242 4242 4242 |	Any 3 digits| 	Any future date
Visa (debit) |	4000 0566 5566 5556 |	Any 3 digits |	Any future date|
Mastercard |	5555 5555 5555 4444 |	Any 3 digits |	Any future date|
Mastercard (2-series)	| 2223 0031 2200 3222	| Any 3 digits	| Any future date|
Mastercard (debit)	| 5200 8282 8282 8210	| Any 3 digits	| Any future date| 
Mastercard (prepaid)	| 5105 1051 0510 5100	| Any 3 digits	| Any future date|
American Express	| 3782 822463 10005	| Any 4 digits	| Any future date|
American Express	| 3714 496353 98431	| Any 4 digits	| Any future date|
Discover	| 6011 1111 1111 1117	| Any 3 digits	| Any future date|
Discover	| 6011 0009 9013 9424	| Any 3 digits	| Any future date| 
Diners Club	| 3056 9300 0902 0004	| Any 3 digits	| Any future date| 
Diners Club (14-digit card)	| 3622 720627 1667	| Any 3 digits	| Any future date|
JCB	| 3566 0020 2036 0505	| Any 3 digits	| Any future date|
UnionPay	| 6200 0000 0000 0005	| Any 3 digits	| Any future date|


### Simulate billing payments to North and South America

Country |	Number	|Brand|
--------------|-----------------------|----------------|
United States (US)	|4242 4242 4242 4242	|Visa|
Brazil (BR)	|4000 0007 6000 0002	|Visa|
Canada (CA)	|4000 0012 4000 0000	|Visa|
Mexico (MX)	|4000 0048 4000 8001	Visa|


### Simulate billing payments to Europe and Middle East

Country	| Number	| Brand |
---------------|--------------------------|-----------------|
United Arab Emirates (AE)	|4000 0078 4000 0001	|Visa|
United Arab Emirates (AE)	|5200 0078 4000 0022	|Mastercard|
Austria (AT)	|4000 0004 0000 0008	|Visa|
Belgium (BE)	|4000 0005 6000 0004	|Visa|
Bulgaria (BG)	|4000 0010 0000 0000	|Visa|
Croatia (HR)	|4000 0019 1000 0009	|Visa|
Cyprus (CY)	|4000 0019 6000 0008	|Visa|
Czech Republic (CZ)	|4000 0020 3000 0002	|Visa|
Denmark (DK)	|4000 0020 8000 0001	|Visa|
Estonia (EE)	|4000 0023 3000 0009	|Visa|
Finland (FI)	|4000 0024 6000 0001	|Visa|
France (FR)	|4000 0025 0000 0003	|Visa|
Germany (DE)	|4000 0027 6000 0016	|Visa|
Greece (GR)	|4000 0030 0000 0030	|Visa|
Hungary (HU)	|4000 0034 8000 0005	|Visa|
Ireland (IE)	|4000 0037 2000 0005	|Visa|
Italy (IT)	|4000 0038 0000 0008	|Visa|
Latvia (LV)	|4000 0042 8000 0005	|Visa|
Lithuania (LT)	|4000 0044 0000 0000	|Visa|
Luxembourg (LU)	|4000 0044 2000 0006	|Visa|
Malta (MT)	|4000 0047 0000 0007	|Visa|
Netherlands (NL)	|4000 0052 8000 0002	|Visa|
Norway (NO)	|4000 0057 8000 0007	|Visa|
Poland (PL)	|4000 0061 6000 0005	|Visa|
Portugal (PT)	|4000 0062 0000 0007	|Visa|
Romania (RO)	|4000 0064 2000 0001	|Visa|
Slovenia (SI)	|4000 0070 5000 0006	|Visa|
Slovakia (SK)	|4000 0070 3000 0001	|Visa|
Spain (ES)	|4000 0072 4000 0007	|Visa|
Sweden (SE)	|4000 0075 2000 0008	|Visa|
Switzerland (CH)	|4000 0075 6000 0009	|Visa|
United Kingdom (GB)	|4000 0082 6000 0000	|Visa|
United Kingdom (GB)	|4000 0582 6000 0005	|Visa (debit)|
United Kingdom (GB)	|5555 5582 6555 4449	|Mastercard|


### Simulate billing payments to Asia-Pacific

Country	|Number	|Brand|
-------------------|--------------------------|---------|
Australia (AU)	|4000 0003 6000 0006	|Visa|
China (Cn)	|4000 0015 6000 0002	|Visa|
Hong Kong (HK)	|4000 0034 4000 0004	|Visa|
India (IN)	|4000 0035 6000 0008	|Visa|
Japan (JP)	|4000 0039 2000 0003	|Visa|
Malaysia (my)	|4000 0045 8000 0002	|Visa|
New Zealand (NZ)	|4000 0055 4000 0008	|Visa|
Singapore (SG)	|4000 0070 2000 0003	|Visa|
Thailand (TH)	|4000 0076 4000 0003	|Visa (credit)|
Thailand (TH)	|4000 0576 4000 0008	|Visa (debit)|


## Simulate declined payments
To simulate payments that the issuer declines for various reasons, we can use these cards.
Description	|Number	Error |Code	|Decline Code|
------------------------|-----------------------|------------------|-----------------|
Generic decline	|4000 0000 0000 0002	|Card_declined	|Generic_decline|
Insufficient funds decline	|4000 0000 0000 9995	|Card_declined	|Insufficient_funds|
Lost card decline	|4000 0000 0000 9987	|Card_declined	|Lost_card|
Stolen card decline	|4000 0000 0000 9979	|Card_declined	|Stolen_card|
Expired card decline	|4000 0000 0000 0069	|Expired_card	|n/a|
Incorrect CVC decline	|4000 0000 0000 0127	|Incorrect_cvc	|n/a|
Processing error decline	|4000 0000 0000 0119	|Processing_error	|n/a|
Incorrect number decline	|4242 4242 4242 4241	|Incorrect_number 	|n/a|

## Fraud prevention
Stripe’s fraud prevention system, Radar, can block payments when they have a high risk level or fail verification checks. 

Description	|Number	|Details|
----------------|-------------------------------------------------|------------------|
Always blocked	|4100 0000 0000 0019	|The charge has a risk level of “highest”. <br/> Radar always blocks it|
Highest risk 	|4000 0000 0000 4954	|The charge has a risk level of “highest”. <br/> Radar might block it depending on your settings|
Elevated risk	|4000 0000 0000 9235	|The charge has a risk level of “elevated”. <br/>  If you use Radar for Fraud Teams, Radar might queue it for review|
CVC check fails|	4000 0000 0000 0101	|If you provide a CVC number, the CVC check fails. <br/> Radar might block it depending on your settings|
Postal code check fails	|4000 0000 0000 0036	|If you provide a postal code, the postal code check fails. <br/> Radar might block it depending on your settings|
Line1 check fails	|4000 0000 0000 0028	|The address line 1 fails. <br/> The payment succeeds unless you block it with a custom Radar rule|
Address checks fail	|4000 0000 0000 0010	|The address postal code check and address line 1 check fail. <br/> Radar might block it depending on you settings|
Address unavailable	|4000 0000 0000 0044	|The address postal code check and address line 1 check are both unavailable. <br/> The payment succeeds unless you block it with custom Radar rule.|


## Simulate Invalid data
To test errors resulting from invalid data, we don’t need a special test card for this. Any invalid value works. For example:
* Invalid_expiry_month: we can use invalid month, such as 13
* Invalid_expiry_year: we can use a year in the past, such as 19
* Invalid_cvc: we ca use two digit number, such as 99
* Incorrect_number: we can use any number that fails the “Luhn check algorithm”, such as 4242 4242 4242 4241


For more card numbers and options visit https://stripe.com/docs/testing 


