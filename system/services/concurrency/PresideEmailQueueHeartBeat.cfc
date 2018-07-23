/**
 * @presideService true
 * @singleton      true
 *
 */
component extends="AbstractHeartBeat" {

	/**
	 * @emailMassSendingService.inject emailMassSendingService
	 *
	 */
	public function init(
		  required any     emailMassSendingService
		,          numeric instanceNumber = 1
		,          string  threadName     = "Preside Email Queue Heartbeat #arguments.instanceNumber#"
	){
		super.init(
			  threadName   = arguments.threadName
			, intervalInMs = 5000
		);

		_setInstanceNumber( arguments.instanceNumber );
		_setEmailMassSendingService( arguments.emailMassSendingService );

		return this;
	}

	// PUBLIC API METHODS
	public void function run() {
		try {
			if ( _getInstanceNumber() == 1 ) {
				_getEmailMassSendingService().autoQueueScheduledSendouts();
			}
			_getEmailMassSendingService().processQueue();
		} catch( any e ) {
			$raiseError( e );
		}
	}

	public void function startInNewRequest() {
		var startUrl = $getRequestContext().buildLink( linkTo="taskmanager.runtasks.startEmailQueueHeartbeat" );

		thread name=CreateUUId() startUrl=startUrl {
			try {
				sleep( 5000 + ( 100 * _getInstanceNumber() ) );
				http method="post" url=startUrl timeout=2 throwonerror=true {
					httpparam type="formfield" name="instanceNumber" value=_getInstanceNumber();
				}
			} catch( any e ) {
				$raiseError( e );
			}
		}
	}

// GETTERS AND SETTERS
	private any function _getEmailMassSendingService() {
		return _taskmanagerService;
	}
	private void function _setEmailMassSendingService( required any emailMassSendingService ) {
		_taskmanagerService = arguments.emailMassSendingService;
	}

	private any function _getInstanceNumber() {
		return _instanceNumber;
	}
	private void function _setInstanceNumber( required any instanceNumber ) {
		_instanceNumber = arguments.instanceNumber;
	}
}