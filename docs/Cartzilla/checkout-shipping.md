# Checkout Shipping for Payment

___


## Update Discount Method
The method UpdateDiscount calculates the discounts and rewards points when the page loads. It first checks if there is nothing in the discount element, in this case the discount element is replaced by zero currency. Otherwise, if there is a discount it calculates the price.

```
function UpdateDiscount(){
  var PreviousDiscountString = $('#Discount').get(0).innerHTML;
  PreviousDiscountString = PreviousDiscountString.trim().substring(1);
  if (PreviousDiscountString == "") {
     $('#Discount').html(currency + "0.00");
  }
  else {
     FirstCalculateRewardsPoints();
  }
}

function FirstCalculateRewardsPoints(){
  var rPoints = parseInt($('#RewardsPoints').get(0).innerHTML);
  var DiscountString = $('#Discount').get(0).innerHTML;
  DiscountString = DiscountString.trim().substring(1);
  var PreviousPoints = parseInt(parseFloat(DiscountString) * 10);
  if (PreviousPoints < rPoints)
  {
    rPoints = rPoints - PreviousPoints
  }
  else {
    rPoints = 0;
  }
  $('#RewardsPoints').html(rPoints);
  $("#use_points").attr("checked","checked");
}

```

## Update Total Amount with New Taxes Method
The UpdateTotalAmountWithNewTaxes function updates the taxes and total amount when the order items values changes.

```
function UpdateTotalAmountWithNewTaxes(){

  var SubTotalString = $('#SubTotal').get(0).innerHTML;
  SubTotalString = SubTotalString.replace("&lt;small&gt;", "");
  SubTotalString = SubTotalString.replace("&lt;small&gt;", "");
  SubTotalString = SubTotalString.substring(1);

  var SubTotalAmount = parseFloat(SubTotalString);
  var ShippingFeeString = $('#ShippingFee').get(0).innerHTML;
  ShippingFeeString = ShippingFeeString.trim().substring(1);
  var DiscountString = $('#Discount').get(0).innerHTML;
  DiscountString = DiscountString.substring(1);  

  if ((DiscountString != "") && (ShippingFeeString != "")) {      
    var Discount = parseFloat(DiscountString);
    var ShippingFee = parseFloat(ShippingFeeString);
    var NewTaxes = (SubTotalAmount + ShippingFee - Discount) * 0.13;
    var NewTotalAmount = SubTotalAmount + ShippingFee - Discount + NewTaxes
    NewTaxes = parseFloat(NewTaxes).toFixed(2);
    var NewTaxesString = NewTaxes.toString();
    NewTaxesString = currency + NewTaxesString;
    $('#Taxes').html(NewTaxesString);
    NewTotalAmount = parseFloat(NewTotalAmount).toFixed(2);
    var NewTotalAmountString = NewTotalAmount.toString();
    NewTotalAmountString = currency + NewTotalAmountString;
   $('#TotalAmount').html(NewTotalAmountString);
  }
}

```
## Select Fee Event
Select Fee Event triggers when the user selects new shipping method.

```
var rad = document.getElementsByClassName("form-check-input");
for (var i = 0; i < rad.length; i++) {
  if (rad[i].getAttribute("type") == 'radio'){
    if (rad[i].checked){
      ShippingLookup = rad[i].getAttribute("data-shippingid");
    }

    rad[i].addEventListener('change', function (e) {
      var target = e.target;
      if (target.checked == true)
      {  
        PreviousShippingFeeString  = $('#ShippingFee').get(0).innerHTML;
        PreviousShippingFeeString = PreviousShippingFeeString.trim().substring(1);
        PreviousShippingFee = parseFloat(PreviousShippingFeeString).toFixed(2);
        var val = parseFloat(target.value).toFixed(2);
        var sval = val.toString();
        var shippingvalue = currency + sval;
        $('#ShippingFee').html(shippingvalue);
        ShippingLookup = target.getAttribute("data-shippingid");
        UpdateTotalAmountWithNewTaxes();
     }  
    });
  }
}

```
## Proceed to Payment Event
Proceed to Payment Event saves the necessary values in Dynamics via API calls when procced to payment.

```
var pay = document.getElementById("ProceedToPayment");
pay.addEventListener('click', function (e) {

  if(all_is_done==false){
    // prevent the page from submitting by default
    e.preventDefault();
    var shippingFee = $('#ShippingFee').get(0).innerHTML; 
    shippingFee = shippingFee.substring(1);
    var sValue = parseFloat(shippingFee);
    var shippingValue = parseFloat(sValue / rate).toFixed(2); 

    //Get the shipping method infos
    var id = $("input[name=shippingMethod]:checked").attr('id');
    var shippingMethod = id.split("-")[0];
    var shippingCode =  parseInt(id.split("-")[1]);
    var shippingMethodCode = parseInt(id.split("-")[1]) + 137879000;

    // get the current user
    var userid = "{{user.id}}";

    // Update the Order table with the shipping choice and discount
    var Discount = $('#Discount').get(0).innerHTML; 
    Discount = Discount.substring(1);
    var record = {};
    record["crc98_ShippingChoice@odata.bind"] = "/crc98_shippingmethods(" + ShippingLookup + ")"; // Lookup
    record.discountamount = Number(parseFloat(Discount).toFixed(4));
    var urlOrder = "/_api/salesorders(" + OrderId + ")";

    webapi.safeAjax({
      type: "PATCH",
      contentType: "application/json",
      url: urlOrder,
      data: JSON.stringify(record),
      success: function (data, textStatus, xhr) {
        console.log("Record updated");
        UpdateShippingFee();
      },
      error: function (xhr, textStatus, errorThrown) {
        console.log(xhr);
      }
    }); 

    function UpdateShippingFee(){
      var input ={};
      var urlAddress = "https://cartzilla-dev-cs.powerappsportals.com/_api/salesorders(" + OrderId + ")/Microsoft.Dynamics.CRM.clds_updateordershippingfee"

      webapi.safeAjax({
        type: "POST",
        url: urlAddress,
        contentType: "application/json",
        data: JSON.stringify(input),
        success: function (res, status, xhr) {
          console.log("Success");
          all_is_done=true;
          $('#ProceedToPayment span').trigger('click');
        },
        error: function (xhr, textStatus, errorThrown) {
          console.log(xhr);
          all_is_done=true;
          $('#ProceedToPayment span').trigger('click');
       }
     });
    }

```


