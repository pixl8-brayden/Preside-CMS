/**
 * The page object represents the core data that is stored for all pages in the site tree, regardless of page type.
 */


component extends="preside.system.base.SystemPresideObject" labelfield="title" output=false displayname="Sitetree Page" {

<!--- properties --->
	property name="title"                     type="string"  dbtype="varchar"  maxLength="200" required="true" control="textinput";
	property name="main_content"              type="string"  dbtype="text"                     required="false";
	property name="teaser"                    type="string"  dbtype="varchar"  maxLength="500" required="false";
	property name="slug"                      type="string"  dbtype="varchar"  maxLength="50"  required="false" uniqueindexes="slug|3" format="slug";
	property name="page_type"                 type="string"  dbtype="varchar"  maxLength="100" required="true"                                             control="pageTypePicker";
	property name="layout"                    type="string"  dbtype="varchar"  maxLength="100" required="false"                                            control="pageLayoutPicker";

	property name="sort_order"                type="numeric" dbtype="int"                      required="true"                                             control="none";
	property name="active"                    type="boolean" dbtype="bool"                     required="false" default="0";
	property name="trashed"                   type="boolean" dbtype="bool"                     required="false" default="0" control="none";
	property name="old_slug"                  type="string"  dbtype="varchar" maxLength="50"   required="false";

	property name="main_image"  relationship="many-to-one" relatedTo="asset"                   required="false" allowedTypes="image";
	property name="site"        relationship="many-to-one" relatedTo="site"                    required="true"                      uniqueindexes="slug|1" control="none";
	property name="parent_page" relationship="many-to-one" relatedTo="page"                    required="false"                     uniqueindexes="slug|2" control="none";
	property name="created_by"  relationship="many-to-one" relatedTo="security_user"           required="true"                                             control="none" generator="loggedInUserId";
	property name="updated_by"  relationship="many-to-one" relatedTo="security_user"           required="true"                                             control="none" generator="loggedInUserId";

	property name="author"                    type="string"  dbtype="varchar" maxLength="100"  required="false";
	property name="browser_title"             type="string"  dbtype="varchar" maxLength="100"  required="false";
	property name="keywords"                  type="string"  dbtype="varchar" maxLength="255"  required="false";
	property name="description"               type="string"  dbtype="varchar" maxLength="255"  required="false";
	property name="embargo_date"              type="date"    dbtype="datetime"                 required="false"                                            control="datetimepicker";
	property name="expiry_date"               type="date"    dbtype="datetime"                 required="false"                                            control="datetimepicker";

	property name="exclude_from_navigation"   type="boolean" dbtype="boolean"                  required="false" default="false";
	property name="navigation_title"          type="string"  dbtype="varchar" maxLength="200"  required="false";

	property name="_hierarchy_id"             type="numeric" dbtype="int"     maxLength="0"    required="true"                                                            uniqueindexes="hierarchyId";
	property name="_hierarchy_sort_order"     type="string"  dbtype="varchar" maxLength="200"  required="true"                                             control="none" indexes="sortOrder";
	property name="_hierarchy_lineage"        type="string"  dbtype="varchar" maxLength="200"  required="true"                                             control="none" indexes="lineage";
	property name="_hierarchy_child_selector" type="string"  dbtype="varchar" maxLength="200"  required="true"                                             control="none";
	property name="_hierarchy_depth"          type="numeric" dbtype="int"                      required="true"                                             control="none" indexes="depth";
	property name="_hierarchy_slug"           type="string"  dbtype="varchar" maxLength="2000" required="true"                                             control="none";


	/**
	 * This method is used internally by the Sitetree Service to ensure
	 * that all child nodes of a page have the most up to date helper fields when the parent node
	 * changes.
	 *
	 * This is implemented using some funky SQL that was beyond the capabilities of the standard
	 * Preside Object Service CRUD methods.
	 *
	 * @oldData.hint Query record of the old parent node data
	 * @newData.hint Struct containing the changed fields on the parent node
	 */
	public void function updateChildHierarchyHelpers( required query oldData, required struct newData ) autodoc=true output=false {
		var q      = new query();
		var sql    = "update #getTableName()# set datemodified = ?";

		q.setDatasource( getDsn() );
		q.addParam( value=Now(), type="timestamp" );

		for( var field in [ "_hierarchy_lineage", "_hierarchy_slug", "_hierarchy_depth", "_hierarchy_sort_order", "trashed" ] ) {
			switch( field ) {
				case "_hierarchy_lineage":
					sql &= ', _hierarchy_child_selector = Concat( ?, Right( _hierarchy_child_selector, Length( _hierarchy_child_selector ) - ? ) )';
					q.addParam( value=arguments.newData[ field ]          , type="varchar" );
					q.addParam( value=Len( arguments.oldData[ field ][1] ), type="integer" );
					// deliberate no break!

				case "_hierarchy_slug":
				case "_hierarchy_sort_order":
					sql &= ', #field# = Concat( ?, Right( #field#, Length( #field# ) - ? ) )';
					q.addParam( value=arguments.newData[ field ]   , type="varchar" );
					q.addParam( value=arguments.oldData[ field ][1], type="varchar" );
					break;


				case "_hierarchy_depth":
					sql &= ', #field# = #field# - ?';
					q.addParam( value=arguments.oldData[ field ][1] - arguments.newData[ field ], type="integer" );
					break;

				case "trashed":
					sql &= ', #field# = ?';
					q.addParam( value=( arguments.newData.trashed ? 1 : 0 ), type="bit" );
					break;

			}
		}

		sql &= "where  _hierarchy_lineage like ?";
		q.addParam( lue=arguments.oldData._hierarchy_child_selector, type="varchar" );

		q.setSQL( sql );
		q.execute();
	}
}