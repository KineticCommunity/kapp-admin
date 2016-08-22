## CategoryHelper.jspf

The Category Helper contains helper methods for fetching categories from a Kapp or Form, and returns them in a nested structure, using the BundleCategory wrapper class. The BundleCategory class is a decorative class which extends the functionality of the core Category model.

A category may specify its parent category by adding a _Parent_ Attribute with the name of the parent category.

Categories are returned sorted, first by their _Sort Order_ attribute, then by their _name_ field, and finally by their _slug_ field.

### Examples

**Instantiate the CategoryHelper in `initialization.jspf`:**
```java
request.setAttribute("CategoryHelper", new CategoryHelper());
```

**Use the CategoryHelper in pages or partials:**
```jsp
<c:forEach items="${CategoryHelper.getCategories(kapp)}" var="bundleCategory">
    <h3>${text.escape(bundleCategory.getName())}</h3>
    <c:forEach items="${bundleCategory.getForms()}" var="categoryForm">
        <span class="label label-default">${text.escape(categoryForm.name)}</span>
    </c:forEach>
</c:forEach>
```

**More Examples:** <http://community.kineticdata.com/10_Kinetic_Request/Kinetic_Request_Core_Edition/Resources/Bundle_Category_Helper>  

---

#### CategoryHelper Constructor Summary
| Signature                                              | Description                                                                                                                                       |
| :----------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------ |
| `CategoryHelper()`                                     | Constructs a newly allocated CategoryHelper object which can retrieve and decorate categories from Kapps and Forms.                               |

---

#### CategoryHelper Method Summary
| Signature                                              | Description                                                                                                                                       |
| :----------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------ |
| `List<BundleCategory> getCategories(Kapp kapp)`        | Gathers, maps, and sorts all of `kapp`'s categories/subcategories, and returns a list of the root categories.                                     |
| `List<BundleCategory> getCategories(Form form)`        | Returns categories that are set to `form`.                                                                                                        |
| `BundleCategory getCategory(String slug, Kapp kapp)`   | Returns a single category object from `kapp` based on the `slug`.                                                              |
| `BundleCategory getCategory(String slug, Form form)`   | Returns a single category object from the parent Kapp of the `form` based on the `slug`.                                       |

---

#### BundleCategory Constructor Summary
| Signature                                              | Description                                                                                                                                       |
| :----------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------ |
| `BundleCategory(Category category)`                    | Constructs a newly allocated BundleCategory object based on the `category` parameter, which extends the functionality of the core Category model. |

---

#### BundleCategory Decorative Method Summary
Decorative methods are additional methods created to extend the Category model.  

| Signature                                              | Description                                                                                                                                       |
| :----------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------ |
| `Category getCategory()`                               | Returns the original Category object.                                                                                                             |
| `String getParentCategory()`                           | Returns the parent BundleCategory object.                                                                                                         |
| `List<BundleCategory> getSubcategories()`              | Returns a list of all the subcategory objects.                                                                                                    |
| `List<BundleCategory> getTrail()`                      | Returns a list of parent category objects sorted from the root category to current category.                                                      |
| `Boolean hasForms()`                                   | Returns true if the current category has active forms.                                                                                            |
| `Boolean hasNonEmptySubcategories()`                   | Returns true if the current category has subcategories that have active forms.                                                                    |
| `Boolean hasSubcategories()`                           | Returns true if the current category has subcategories.                                                                                           |
| `Boolean isEmpty()`                                    | Returns true if the category and all subcategories do not have any active forms.                                                                  |

---

#### BundleCategory Delegate Method Summary
Delegate methods are methods that call the core Category model methods.  

| Signature                                              | Description                                                                                                                                       |
| :----------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------ |
| `Attribute getAttribute(String name)`                  | Returns the attribute object identified by the `name` parameter.                                                                                  |
| `List<Attribute> getAttributes()`                      | Returns a list of attributes for the category.                                                                                                    |
| `String getAttributeValue(String name)`                | Returns the attribute value identified by the `name` parameter if it exists and if the attribute only supports a single value.                    |
| `List<String> getAttributeValues(String name)`         | Returns a list of attribute values identified by the `name` parameter if it exists and if the attribute only supports multiple values.            |
| `List<Form> getForms()`                                | Returns a list of Form objects associated to the category.                                                                                        |
| `Kapp getKapp()`                                       | Returns the Kapp the category belongs to.                                                                                                         |
| `String getName()`                                     | Returns the name of the category.                                                                                                                 |
| `String getSlug()`                                     | Returns the slug of the category.                                                                                                                 |
| `Boolean hasAttribute(String name)`                    | Returns true if an attribute identified by the `name` parameter exists.                                                                           |
| `Boolean hasAttributeValue(String name, String value)` | Returns true if an attribute identified by the `name` parameter exists and has the value identified by the `value` parameter.                     |

---

**Last Updated:** 2016-03-10 16:00 CST
