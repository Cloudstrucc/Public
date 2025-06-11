# Order Review Display

___

## Order-review page template
If the user is sign in, then fetchxml contactShippingAddress will execute
<!-- Shipping Address -->
```
{% if user %}
  {% fetchxml contactShippingAddress %}
    <fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
      <entity name="contact">
        <attribute name="fullname" />
        <attribute name="contactid" />
        <attribute name="lastname" />
        <attribute name="firstname" />
        <attribute name="address1_postalcode" />
        <attribute name="address1_line1" />
        <attribute name="address1_country" />
        <attribute name="address1_city" />
        <order attribute="fullname" descending="false" />
        <filter type="and">
          <condition attribute="contactid" operator="eq" uitype="contact" value="{{user.id}}" />
        </filter>
      </entity>
    </fetch>
 {% endfetchxml %}
```

If the contactShippingAddress contains values, then display the shipping address.

```
 {% if contactShippingAddress.Results.Entities.size > 0  %}
    <div class="container">
        <div class="row row-review">
           <div class="col">
              <h2 class="h6 pb-3 mb-2">Shipping Address </h2>
              <dl class="row">
                <dd class="col-sm-12">{{ contactShippingAddress.Results.Entities[0].firstname }} {{ contactShippingAddress.Results.Entities[0].lastname }}</dd>
                <dd class="col-sm-12">{{ contactShippingAddress.Results.Entities[0].address1_line1 }} {{ contactShippingAddress.Results.Entities[0].address1_city }}</dd>
                <dd class="col-sm-12">{{ contactShippingAddress.Results.Entities[0].address1_postalcode }} {{ contactShippingAddress.Results.Entities[0].address1_country }}</dd>
              </dl>
           </div>
  {% endif %}

{% endif %}

{% include 'Current User Order ID' %}

{% include 'currency' %}
```
If there is an order, then find the shipping method info by executing the fetch xml shippingMethodInfo.

```
<!-- Delivery Method -->
{% if OrderID.size > 0 %}
  {% fetchxml shippingMethodInfo %}
    <fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="true">
      <entity name="crc98_shippingmethod">
        <attribute name="crc98_shippingmethodid" />
        <attribute name="crc98_shippingid" />
        <attribute name="crc98_shippingname" />
        <attribute name="crc98_shippingfee" />
        <attribute name="clds_deliverytime" />
        <order attribute="crc98_shippingid" descending="false" />
        <link-entity name="adx_contentsnippet" from="adx_contentsnippetid" to="clds_deliverytime" visible="false" link-type="outer" alias="shipping">
            <attribute name="adx_value" />
        </link-entity>
        <link-entity name="salesorder" from="crc98_shippingchoice" to="crc98_shippingmethodid" link-type="inner" alias="aa">
            <filter type="and">
               <condition attribute="salesorderid" operator="eq" value="{{ OrderID }}" />
            </filter>
        </link-entity>
      </entity>
    </fetch>
  {% endfetchxml %}

```

If the shippingMethodInfo contains data than display the info.

```

  {% if shippingMethodInfo.Results.Entities.size > 0  %}
     <div class="col"></div>
     <div class="col">
        <h2 class="h6 pb-3 mb-2">Shipping Method </h2>
        <dl class="row row-review">
           <dd class="col-sm-12">Delivery Time: {{ shippingMethodInfo.Results.Entities[0]["shipping.adx_value"] }}</dd>
              {% assign dollar =  shippingMethodInfo.Results.Entities[0].crc98_shippingfee | times: exchangeRate | round:2 | string  %}
           <dd class="col-sm-12">Shipping Fee: {{currencysymbol}}{{dollar}} </dd>
           <dd class="col-sm-12">Shipping Name: {{ shippingMethodInfo.Results.Entities[0].crc98_shippingname }}</dd>
        </dl>
    </div>
    </div>
    </div>

    {% endif %}

{% endif %}

```

