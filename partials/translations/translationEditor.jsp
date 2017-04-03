<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>
<%@include file="../../bundle/initialization.jspf" %>
<div class="row translation-editor collapse">
    <div class="col-xs-12">
        <h4>Edit Translation</h4>
    </div>
    <div class="col-xs-12 overflow-auto">
        <table class="table"> 
            <thead>
                <tr>
                    <th>Context</th>
                    <th>Locale</th>
                    <th>Language</th>
                    <th class="collapse" data-entry-dependency-count-header>Dependencies</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><span class="btn-xs btn-subtle" disabled data-entry-context></span></td>
                    <td><span class="btn-xs btn-subtle" disabled data-entry-locale></span></td>
                    <td data-entry-language></td>
                    <td class="collapse" data-entry-dependency-count><span class="badge"></span></td>
                </tr>
            </tbody>
        </table>
    </div>
    <div class="col-xs-12 overflow-auto">
        <table class="table">
            <thead>
                <tr>
                    <th>Key</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td data-entry-key></td>
                </tr>
            </tbody>
        </table>
    </div>
    <div class="col-xs-12 overflow-auto">
        <table class="table">
            <thead>
                <tr>
                    <th>
                        <span>Translation</span>
                        <small class="btn-xs btn-info collapse" disabled data-entry-dependency>
                            <span>Affects</span>
                            <span data-entry-dependency-count></span>
                            <span>Translations</span>
                        </small>
                        <small class="btn-xs btn-warning collapse pull-right" disabled data-entry-missing>Missing</small>
                        <small class="btn-xs btn-subtle collapse pull-right" disabled data-entry-inherited>
                            <span>Inherited from:</span>
                            <span data-entry-source-context></span>
                            <span>|</span>
                            <span data-entry-source-locale></span>
                        </small>
                    </th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>
                        <textarea data-entry-translation></textarea>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
    <div class="col-xs-12">
        <div class="text-right">
            <button class="btn btn-success" data-entry-save>
                <span class="fa fa-check"></span>
                <span>Save Translation</span>
            </button>
            <button class="btn btn-link" data-entry-cancel>
                <span>Cancel</span>
            </button>
        </div>
    </div>
</div>