component extends="preside.system.base.AdminHandler" {

	property name="systemEmailTemplateService" inject="systemEmailTemplateService";
	property name="emailTemplateService"       inject="emailTemplateService";
	property name="messagebox"                 inject="coldbox:plugin:messagebox";

	public void function preHandler( event, action, eventArguments ) {
		super.preHandler( argumentCollection=arguments );

		if ( !hasCmsPermission( "emailcenter.systemTemplates.navigate" ) ) {
			event.adminAccessDenied();
		}

		event.addAdminBreadCrumb(
			  title = translateResource( "cms:emailcenter.systemTemplates.breadcrumb.title" )
			, link  = event.buildAdminLink( linkTo="emailcenter.systemTemplates" )
		);

		event.setValue( "pageIcon", "envelope", true );
	}

	public void function index( event, rc, prc ) {
		prc.pageTitle    = translateResource( "cms:emailcenter.systemTemplates.page.title"    );
		prc.pageSubTitle = translateResource( "cms:emailcenter.systemTemplates.page.subTitle" );

		prc.templates = systemEmailTemplateService.listTemplates();
	}

	public void function template( event, rc, prc ) {
		var templateId = rc.template ?: "";

		prc.template = emailTemplateService.getTemplate( id=templateId, allowDrafts=true );

		if ( !prc.template.count() || !systemEmailTemplateService.templateExists( templateId ) ) {
			event.adminNotFound();
		}

		prc.preview = emailTemplateService.previewTemplate( template=templateId, allowDrafts=true );

		prc.pageTitle    = translateResource( uri="cms:emailcenter.systemTemplates.template.page.title"   , data=[ prc.template.name ] );
		prc.pageSubTitle = translateResource( uri="cms:emailcenter.systemTemplates.template.page.subTitle", data=[ prc.template.name ] );

		event.addAdminBreadCrumb(
			  title = translateResource( uri="cms:emailcenter.systemTemplates.template.breadcrumb.title"  , data=[ prc.template.name ] )
			, link  = event.buildAdminLink( linkTo="emailcenter.systemTemplates.template", queryString="template=" & templateId )
		);
	}

	public void function edit( event, rc, prc ) {
		var templateId = rc.template ?: "";

		prc.template = emailTemplateService.getTemplate( id=templateId, allowDrafts=true );

		if ( !prc.template.count() || !systemEmailTemplateService.templateExists( templateId ) ) {
			event.adminNotFound();
		}

		prc.canSaveDraft = hasCmsPermission( "emailcenter.systemtemplates.savedraft" );
		prc.canPublish   = hasCmsPermission( "emailcenter.systemtemplates.publish"   );

		if ( !prc.canSaveDraft && !prc.canPublish ) {
			event.adminAccessDenied();
		}

		prc.formName           = "preside-objects.email_template.system.admin.edit";
		prc.editTemplateAction = event.buildAdminLink( linkto="emailcenter.systemtemplates.editaction" );
		prc.cancelAction       = event.buildAdminLink( linkto="emailcenter.systemtemplates.template", queryString="template=#templateId#" );

		prc.pageTitle    = translateResource( uri="cms:emailcenter.systemTemplates.edit.page.title"   , data=[ prc.template.name ] );
		prc.pageSubTitle = translateResource( uri="cms:emailcenter.systemTemplates.edit.page.subTitle", data=[ prc.template.name ] );

		event.addAdminBreadCrumb(
			  title = translateResource( uri="cms:emailcenter.systemTemplates.edit.breadcrumb.title"  , data=[ prc.template.name ] )
			, link  = event.buildAdminLink( linkTo="emailcenter.systemTemplates.edit", queryString="template=" & templateId )
		);
	}

	public void function editAction( event, rc, prc ) {
		var templateId = rc.template ?: "";
		var saveAction = ( rc._saveAction ?: "savedraft" ) == "publish" ? "publish" : "savedraft";

		if ( !hasCmsPermission( "emailcenter.systemtemplates.#saveAction#" ) ) {
			event.adminAccessDenied();
		}
		if ( !emailTemplateService.templateExists( templateId ) ) {
			event.notFound();
		}

		var formName         = "preside-objects.email_template.system.admin.edit";
		var formData         = event.getCollectionForForm( formName );
		var validationResult = validateForm( formName, formData );

		var missingHtmlParams = emailTemplateService.listMissingParams(
			  template = templateId
			, content  = ( formData.html_body ?: "" )
		);
		var missingTextParams = emailTemplateService.listMissingParams(
			  template = templateId
			, content  = ( formData.text_body ?: "" )
		);

		if ( missingHtmlParams.len() ) {
			validationResult.addError( "html_body", "cms:emailcenter.variables.missing.validation.error", [ missingHtmlParams.toList( ", " ) ] );
		}
		if ( missingTextParams.len() ) {
			validationResult.addError( "text_body", "cms:emailcenter.variables.missing.validation.error", [ missingTextParams.toList( ", " ) ] );
		}

		if ( validationResult.validated() ) {
			emailTemplateService.saveTemplate( id=templateId, template=formData, isDraft=( saveAction=="savedraft" ) );

			messagebox.info( "TODO: success message" );
			setNextEvent( url=event.buildAdminLink( linkTo="emailcenter.systemtemplates.template", queryString="template=#templateId#" ) );
		}

		formData.validationResult = validationResult;
		messagebox.error( "TODO: error message" );
		setNextEvent(
			  url           = event.buildAdminLink( linkTo="emailcenter.systemtemplates.edit", queryString="template=#templateId#" )
			, persistStruct = formData
		);
	}

}