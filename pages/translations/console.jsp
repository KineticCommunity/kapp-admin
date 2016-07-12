<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<%@include file="../../bundle/router.jspf" %>
<c:set var="currentKapp" value="${space.getKapp(param.kapp)}" scope="request" />

<!-- Show page content only if Kapp exists. Otherwise redirect to valid page. -->
<c:choose>
    <c:when test="${empty currentKapp}">
        <script>window.location.replace("${bundle.kappLocation}");</script>
    </c:when>
    <c:otherwise>
    
        <bundle:layout page="${bundle.path}/layouts/layout.jsp">
            <!-- Sets title and imports js and css specific to this console. -->
            <bundle:variable name="head">
                <c:import url="${bundle.path}/partials/translations/head.jsp" charEncoding="UTF-8"/>
            </bundle:variable>

            <!-- PAGE CONTENT STARTS HERE ---------------------------------------------------------------->
            
            <ol class="breadcrumb">
                <li class="active">${space.name}</li>
            </ol>
            
            <div class="page-header">
                <h3>${form.name}</h3>
            </div>
        
            <div class="row">
                <div class="col-xs-12">
                    <div class="translation-navigation">
                        <ul class="nav nav-pills sub-nav" role="tablist">
                            <li role="presentation">
                                <a href="#config" aria-controls="home" role="tab" data-toggle="tab"><span class="fa fa-cog"></span></a>
                            </li>
                            <li role="presentation" class="active">
                                <a href="#translations" aria-controls="home" role="tab" data-toggle="tab">${space.name} Translations</a>
                            </li>
                            <li>
                                <a href="#children" aria-controls="home" role="tab" data-toggle="tab">Kapps</a>
                            </li>
                            <li class="pull-right">
                                <select name="" id="">
                                    <option value="en_US">English</option>
                                    <option value="es_SP">Spanish</option>
                                    <option value="de_DE">German</option>
                                </select>
                            </li>
                        </ul>
                    </div>
                    
                    <div class="tab-content translations-tab-content">
                    
                        <div role="tabpanel" class="tab-pane active" id="translations">
                            <table class="table table-hover datastore-list-table"> 
                                <thead>
                                    <tr>
                                        <th>Key</th>
                                        <th width="50%">Translation</th>
                                        <th width="6%"></th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td><a href="#">Key 1</a></td>
                                        <td><input type="text" value="Translation 1" /></td>
                                        <td>
                                            <div class="btn-group pull-right">
                                                <button class="btn btn-xs btn-danger">
                                                    <span class="fa fa-times fa-fw"></span>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><a href="#">Key 2</a></td>
                                        <td><input type="text" value="Translation 2" /></td>
                                        <td>
                                            <div class="btn-group pull-right">
                                                <button class="btn btn-xs btn-danger">
                                                    <span class="fa fa-times fa-fw"></span>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><a href="#">Key 3</a></td>
                                        <td><input type="text" value="Translation 3" /></td>
                                        <td>
                                            <div class="btn-group pull-right">
                                                <button class="btn btn-xs btn-danger">
                                                    <span class="fa fa-times fa-fw"></span>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                            <table class="table" id="add-translation-table"> 
                                <tbody>
                                    <tr>
                                        <td class="">
                                            <input class="input-sm form-control" placeholder="Key">
                                        </td>
                                        <td width="50%" class="">
                                            <input class="input-sm form-control" placeholder="Translation">
                                        </td>
                                        <td width="10%" class="qual-add-btn">
                                            <button class="btn btn-sm btn-success pull-right"><span class="fa fa-plus"></span> Add</button>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        <div role="tabpanel" class="tab-pane" id="children">
                            <table class="table table-hover datastore-list-table"> 
                                <thead>
                                    <tr>
                                        <th>Name</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach items="${space.kapps}" var="spaceKapp">
                                        <tr>
                                            <td><a href="${bundle.kappLocation}/${form.slug}?kapp=${param.kapp}&page=translations/kapp&slug=${spaceKapp.slug}">${spaceKapp.name}</a></td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                        
                    </div>
                </div>
            </div>
        
            <!-- PAGE CONTENT ENDS HERE ------------------------------------------------------------------>
            
        </bundle:layout>
        
    </c:otherwise>
</c:choose>