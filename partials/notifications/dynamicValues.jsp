<%@page pageEncoding="UTF-8" contentType="text/html" trimDirectiveWhitespaces="true"%>

<div class="col-xs-12 alert alert-info" role="alert" style="margin-bottom: 15px">

    <div style="margin-bottom:15px;">
        <h4>Dynamic Replacements</h4>
        <p>Use the dropdown to insert dynamic elements within the subject and body of your templates. Just put your cursor into one of those fields where you want the element to appear and choose an option from the dropdown list.
        <p>Selecting a Kapp and Form will populate the dropdown menu with available options.
        <p><strong>Caution</strong>: Email templates can be used by any process. Since not all Kapps have the same attributes and not all forms have the same attributes or fields, relying on attributes or fields that may not exist will yield unexpected results. <strong><em>Test your email templates!</em></strong>
    </div>

    <div style="float:left; margin-right:10px;">
        <label class="field-label" for="kappSelectionList" style="width:100%">Select a Kapp</label>
        <select id="kappSelectionList" data-element-type="field"></select>
    </div>
    
    <div style="float:left; margin-right:10px;">
        <label class="field-label" for="kappFormSelectionList" style="width:100%">Select a Form</label>
        <select id="kappFormSelectionList" data-element-type="field"></select>
    </div>

    <div style="float:left; margin-top:15px;">
        <div class="dropdown">
            <a id="dynamicDropdownMenu" role="button" data-toggle="dropdown" class="btn btn-primary">
                Insert Dynamic Replacement Value <span class="caret"></span>
            </a>
            <ul class="dropdown-menu multi-level" role="menu" aria-labelledby="dropdownMenu">
                <li class="dropdown-submenu">
                    <a tabindex="-1" href="#">Snippits</a>
                    <ul class="dropdown-menu" data-menu-name="Snippits">
                        <li>
                            <a class="dynamic-replacement dynamic-snippits" tabindex="-1" href="#">..Replaced on Page Ready..</a>
                        </li>
                    </ul>
                </li>
                <li class="dropdown-submenu">
                    <a tabindex="-1" href="#">Submission</a>
                    <ul class="dropdown-menu">
                        <li>
                            <a class="dynamic-replacement" tabindex="-1" href="#">submission('id')</a>
                        </li>
                    </ul>
                </li>
                <li class="dropdown-submenu">
                    <a tabindex="-1" href="#">Form</a>
                    <ul class="dropdown-menu">
                        <li>
                            <a class="dynamic-replacement" tabindex="-1" href="#">form('Form Description')</a></li>
                        <li>
                            <a class="dynamic-replacement" href="#">form('Form Name')</a>
                        </li>
                        <li>
                            <a class="dynamic-replacement" href="#">form('Form Notes')</a>
                        </li>
                        <li>
                            <a class="dynamic-replacement" href="#">form('Form Slug')</a>
                        </li>
                        <li>
                            <a class="dynamic-replacement" href="#">form('Form Status')</a>
                        </li>
                    </ul>
                </li>
                <li class="dropdown-submenu">
                    <a tabindex="-1" href="#">Kapp</a>
                    <ul class="dropdown-menu">
                        <li>
                            <a class="dynamic-replacement" tabindex="-1" href="#">kapp('Kapp Name')</a>
                        </li>
                        <li>
                            <a class="dynamic-replacement" href="#">kapp('Kapp Slug')</a>
                        </li>
                    </ul>
                </li>
                <li class="dropdown-submenu">
                    <a tabindex="-1" href="#">Space</a>
                    <ul class="dropdown-menu">
                        <li>
                            <a class="dynamic-replacement" tabindex="-1" href="#">space('Space Slug')</a>
                        </li>
                    </ul>
                </li>
                <li class="dropdown-submenu">
                    <a tabindex="-1" href="#">Submission Values</a>
                    <ul class="dropdown-menu" data-menu-name="Submission Values">
                        <li>
                            <a class="dynamic-replacement" tabindex="-1" href="#">values('##Replace with form field name##')</a>
                        </li>
                    </ul>
                </li>
                <li class="dropdown-submenu">
                    <a tabindex="-1" href="#">Form Attributes</a>
                    <ul class="dropdown-menu"  data-menu-name="Form Attributes">
                        <li>
                            <a class="dynamic-replacement" tabindex="-1" href="#">formAttributes('##Replace with form attribute name##')</a>
                        </li>
                    </ul>
                </li>
                <li class="dropdown-submenu">
                    <a tabindex="-1" href="#">Kapp Attributes</a>
                    <ul class="dropdown-menu" data-menu-name="Kapp Attributes">
                        <li>
                            <a class="dynamic-replacement" tabindex="-1" href="#">kappAttributes('##Replace with attribute name##')</a>
                        </li>
                    </ul>
                </li>
                <li class="dropdown-submenu">
                    <a tabindex="-1" href="#">Space Attributes</a>
                    <ul class="dropdown-menu" data-menu-name="Space Attributes">
                        <li>
                            <a class="dynamic-replacement" tabindex="-1" href="#">spaceAttributes('##Replace with attribute name##')</a>
                        </li>
                    </ul>
                </li>
                <li class="dropdown-submenu">
                    <a tabindex="-1" href="#">Other Variables<br>(provided at run-time in the Task engine)</a>
                    <ul class="dropdown-menu">
                        <li>
                            <a class="dynamic-replacement" tabindex="-1" href="#">vars('##Replace with variable name##')</a>
                        </li>
                    </ul>
                </li>
                <li class="dropdown-submenu">
                    <a tabindex="-1" href="#">Appearance Wrapper for selected date field</a>
                    <ul class="dropdown-menu" data-menu-name="Appearance Attributes">
                        <li>
                            <a class="dynamic-replacement dynamic-appearance" tabindex="-1" href="#">..Replaced on Page Ready..</a>
                        </li>
                    </ul>
                </li>
            </ul>
        </div>
    </div>
    <div class="col-xs-12 appearance-alert alert alert-warning" style="display:none;">
        <span class="appearance-alert-message"></span>
    </div>
</div>