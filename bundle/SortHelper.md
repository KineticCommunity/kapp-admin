## Overview

The SortHelper is a utility that allows you to sort lists of Maps or Models.  
Implements sort of a List of Maps by one or more values.  
Implements sort of a List of Models by name. Model must have a name field.  
Implements sort of a List of Models by Attribute values. Valid for Space, Kapp, Form, Category, Identity, and User models.  

## Files

[bundle/SortHelper.md](SortHelper.md)  
README file containing information on configuring and using the sort helper.

[bundle/SortHelper.jspf](SortHelper.jspf)  
Helper file containing definitions for the SortHelper.  More information can be found in
the [SortHelper Summary](#sorthelper-summary) section.

## Configuration

* Copy the files listed above into your bundle
* Initialize the SortHelper in your bundle/initialization.jspf file

### Initialize the SortHelper

**bundle/initialization.jspf**
```jsp
<%-- SortHelper --%>
<%@include file="SortHelper.jspf"%>
<%
    request.setAttribute("SortHelper", new SortHelper());
%>
```

## Example Usage


**Sort Kapps by name in descending order**
```jsp
<c:set var="sortedKapps" value="${SortHelper.sortByName(space.kapps, true)}" />
```

**Sort Forms by attribute "Sort Order" in ascending order**
```jsp
<c:set var="sortedForms" value="${SortHelper.sortByAttribute(kapp.forms, SortHelper.sortBy('Sort Order'))}" />
```

**Sort Maps by "title" in ascending order**
```jsp
<c:set var="sortedMap" value="${SortHelper.sortMaps(listOfMaps, SortHelper.sortBy('title', false))}" />
<%-- Sample Sorted List of Maps: [{"title":"News"[, ...]},{"title":"Reports"[, ...]}] --%>
```

**Sort Maps by "weight" is descending order and then by "title" in ascending order**
```jsp
<c:set var="sortedMap" value="${SortHelper.sortMaps(listOfMaps, SortHelper.sortBy('weight', true), SortHelper.sortBy('title'))}" />
<%-- Sample Sorted List of Maps: [{"title":"News", "weight":10[, ...]},{"title":"Alerts", "weight":5[, ...]},{"title":"Reports", "weight":5[, ...]}] --%>
```

---

#### SortHelper Summary
There are placeholders in the below method definitions because mutliple types of objects are allowed.  
`A` can be any object which implements the ModelWithAttributes interface (Space, Kapp, Form, Category, Identity, User).  
`M` can be any object which extends the Model class. This object must have a `name` field in order for the sort to work.  
`V` is any object where that object or a parent of that object implements the Comparable interface.  [More info about Comparable](https://docs.oracle.com/javase/7/docs/api/java/lang/Comparable.html)  

`SortHelper()`  

`SortParam sortBy(String name)`  
`SortParam sortBy(String name, boolean descending)`  
`List<A> sortByAttribute( List<A> list, final SortParam... sortParams )`  
`List<M> sortByName(List<M> list)`  
`List<M> sortByName(List<M> list, final boolean descending)`  
`List<Map<String, V>> sortMaps(List<Map<String, V>> list, final SortParam... sortParams)`  

---

#### SortParam Summary
Custom model to store simple key-value pairs for using as parameters.

`SortParam(String name, boolean descending)`  

`String getName()`  
`String getDescending()`  
