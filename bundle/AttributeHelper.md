## Overview

The AttributeHelper is a utility that allows us to fetch Attributes which may contain JSON Strings as values (called object-values).

## Files

[bundle/AttributeHelper.md](AttributeHelper.md)  
README file containing information on configuring and using the attribute helper.

[bundle/AttributeHelper.jspf](AttributeHelper.jspf)  
Helper file containing definitions for the AttributeHelper.  More information can be found in
the [AttributeHelper Summary](#attributehelper-summary) section.

## Configuration

* Copy the files listed above into your bundle
* Initialize the AttributeHelper in your bundle/initialization.jspf file

### Initialize the AttributeHelper

**bundle/initialization.jspf**
```jsp
<%-- AttributeHelper --%>
<%@include file="AttributeHelper.jspf"%>
<%
    request.setAttribute("AttributeHelper", new AttributeHelper());
%>
```

## Example Usage

**Get Kapp Attribute Object-Values**
```jsp
<c:forEach var="objectValue" items="${AttributeHelper.getAttributeObjectValues(kapp, "Link")}">
    <%-- Sample 'Link' attribute value: {"URL":"/somewhere", "Name":"Somewhere"[, ...]} --%>
    <a href="${objectValue.URL}">${text.escape(objectValue.Name)}</a>
</c:forEach>

<c:forEach var="objectValue" items="${AttributeHelper.getAttributeObjectValues(kapp, "Link", AttributeHelper.kvp("Icon", true))}">
    <%-- Sample 'Link' attribute value: {"URL":"/somewhere", "Name":"Somewhere", "Icon":true, "Icon Class":"fa-exclamation"[, ...]} --%>
    <a href="${objectValue['URL']}"><i class="fa ${objectValue['Icon Class']}"></i>${text.escape(objectValue['Name'])}</a>
</c:forEach>
```

**Form Has Attribute Object-Values**
```jsp
<c:if test="${AttributeHelper.hasAttributeObjectValues(form, "Link")}">
    <%-- Sample 'Link' attribute value: {"Anything":"Anything"[, ...]} --%>
</c:if>

<c:if test="${AttributeHelper.hasAttributeObjectValues(form, "Link", AttributeHelper.kvp("Icon"))}">
    <%-- Sample 'Link' attribute value: {"Icon":"Any Value"[, ...]} --%>
</c:if>

<c:if test="${AttributeHelper.hasAttributeObjectValues(form, "Link", AttributeHelper.kvp("Icon Class", "fa-exclamation"))}">
    <%-- Sample 'Link' attribute value: {"Icon Class":"fa-exclamation"[, ...]} --%>
</c:if>
```

---

#### AttributeHelper Summary
Fetches attributes from any object that supports attributes, allowing for JSON String values.

`AttributeHelper()`  

`BundleAttribute getAttribute(ModelWithAttributes parent, String name)`  
`List<BundleAttribute> getAttributes(ModelWithAttributes parent)`    
`LinkedHashMap getAttributeObjectValue(ModelWithAttributes parent, String name)`  
`LinkedHashMap getAttributeObjectValue(ModelWithAttributes parent, String name, KeyValuePair... keyValuePairs)`  
`List<LinkedHashMap> getAttributeObjectValues(ModelWithAttributes parent, String name)`  
`List<LinkedHashMap> getAttributeObjectValues(ModelWithAttributes parent, String name, KeyValuePair... keyValuePairs)`  
`String getAttributeValue(ModelWithAttributes parent, String name)`  
`List<String> getAttributeValues(ModelWithAttributes parent, String name)`  
`boolean hasAttribute(ModelWithAttributes parent, String name)`  
`boolean hasAttributeObjectValues(ModelWithAttributes parent, String name)`  
`boolean hasAttributeObjectValues(ModelWithAttributes parent, String name, KeyValuePair... keyValuePairs)`  
`boolean hasAttributeValue(ModelWithAttributes parent, String name, String value)`  
`KeyValuePair kvp(String key)`  
`KeyValuePair kvp(String key, Object value)`  

---

#### KeyValuePair Summary
Custom model to store simple key-value pairs for using as parameters.

`KeyValuePair(String key, Object value)`  

`String getKey()`  
`String getValue()`  

---

#### BundleAttribute Summary
Custom model to wrap core Attribute object and decorate with extra methods.

`BundleAttribute(Attribute attribute)`  

`Attribute getAttribute()`  
`String getName()`  
`LinkedHashMap getObjectValue()`  
`LinkedHashMap getObjectValue(KeyValuePair... keyValuePairs)`  
`List<LinkedHashMap> getObjectValues()`  
`List<LinkedHashMap> getObjectValues(KeyValuePair... keyValuePairs)`  
`String getValue()`  
`List<String> getValues()`  
`boolean hasObjectValues()`  
`boolean hasObjectValues(KeyValuePair... keyValuePairs)`  
`boolean isMultiple()`  
`boolean isSingular()`  
