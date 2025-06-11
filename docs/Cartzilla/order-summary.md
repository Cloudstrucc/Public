# Order Summary Values Update

Add this code in order-summary web template to update any combination of changes of Total Amount, Shipping Fee, and Discount in the order summary table.

```
$(document).ready(function(){
      
  var CurrencySym = "{{CurrencySymbol}}"
  var TotalAmountString = "{{dollars}}{{decimal}}{{cents}}";
  var TotalAmount = parseFloat(TotalAmountString);

  // update Total Amount with Shipping Fee and Discount
  var ShippingFeeString = $('#ShippingFee').get(0).innerHTML;
  ShippingFeeString = ShippingFeeString.trim().substring(1);
  var DiscountString = $('#Discount').get(0).innerHTML;
  DiscountString = DiscountString.trim()substring(1);

  var NewTotalAmount = TotalAmount;

  if ((DiscountString != "") && ShippingFeeString != "") {
          
     var Discount = parseFloat(DiscountString);
     var ShippingFee = parseFloat(ShippingFeeString);

     NewTotalAmount = TotalAmount - Discount;
     NewTotalAmount = parseFloat(NewTotalAmount).toFixed(2);

     var NewTotalAmountString = CurrencySym.concat(NewTotalAmount);
     $('#TotalAmount').html(NewTotalAmountString);

     // select the target node: ShippingFee and Discount
     var target1 = document.getElementById('ShippingFee');
     var target2 = document.getElementById('Discount');

     // create an observer instance
     var observer = new MutationObserver(function(mutations) {

         mutations.forEach(function(mutation) {

            var ShippingFeeStringT = $('#ShippingFee').get(0).innerHTML;
            ShippingFeeStringT = ShippingFeeStringT.trim()substring(1);

            var DiscountStringT = $('#Discount').get(0).innerHTML;
            DiscountStringT = DiscountStringT.substring(1);

            var ShippingFeeT = parseFloat(ShippingFeeStringT);
            var DiscountT = parseFloat(DiscountStringT);
            var NewTotalAmountT = TotalAmount;

            NewTotalAmountT = NewTotalAmountT - DiscountT;
            NewTotalAmountT = parseFloat(NewTotalAmountT).toFixed(2);

            var NewTotalAmountStringT = CurrencySym.concat(NewTotalAmountT);
            $('#TotalAmount').html(NewTotalAmountStringT);

         });    
     });

     // configuration of the observer:
     var config = { attributes: true, childList: true, characterData: true };

     // pass in the ShippingFee node, as well as the observer options
     observer.observe(target1, config);

     // pass in the Discount node, as well as the observer options
     observer.observe(target2, config);
  }

});

```