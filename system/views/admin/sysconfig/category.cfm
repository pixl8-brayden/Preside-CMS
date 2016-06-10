<cfscript>
	param name="prc.category"  type="ConfigCategory";
	param name="prc.savedData" type="struct";

	formId     = "edit-system-config-" & ( rc.id ?: "" );
	sites      = prc.sites ?: QueryNew('');
	categoryId = Trim( rc.id   ?: "" );
	site       = Trim( rc.site ?: "" );
</cfscript>

<cfoutput>
	<cfif sites.recordcount gt 1>
		<div class="tabbable tabs-left">
			<ul class="nav nav-tabs">
				<li<cfif site eq ""> class="active"</cfif>>
					<cfset link = event.buildAdminLink( linkTo="sysconfig.category", queryString="id=#categoryId#" ) />
					<a href="#link#">
						<i class="fa fa-fw fa-cogs"></i>
						#translateResource( "cms:sysConfig.global.settings")#
					</a>
				</li>
				<cfloop query="sites">
					<li<cfif site eq sites.id> class="active"</cfif>>
						<cfset link = event.buildAdminLink( linkTo="sysconfig.category", queryString="id=#categoryId#&site=#sites.id#" ) />
						<a href="#link#">
							<i class="fa fa-fw fa-globe"></i>
							#sites.name# (#sites.domain##sites.path#)
						</a>
					</li>
				</cfloop>
			</ul>

			<div class="tab-content">
	</cfif>

	<form id="#formId#" method="post" action="#event.buildAdminLink( linkTo='sysConfig.saveCategoryAction' )#" data-auto-focus-form="true" data-dirty-form="protect" class="form-horizontal">
		<input type="hidden" name="id" value="#( rc.id ?: '' )#">

		#renderForm(
			  formName          = prc.category.getForm()
			, context           = "admin"
			, formId            = formId
			, savedData         = prc.savedData
			, validationResult  = rc.validationResult ?: ""
		)#

		<div class="form-actions row">
			<div class="col-md-offset-2">
				<button class="btn btn-info" type="submit" tabindex="#getNextTabIndex()#">
					<i class="fa fa-check bigger-110"></i>
					#translateResource( "cms:sysConfig.save.button" )#
				</button>
			</div>
		</div>
	</form>

	<cfif sites.recordcount gt 1>
		</div>
	</cfif>
</cfoutput>