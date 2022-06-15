component {

	this.name = hash( getCurrentTemplatePath() );

	function onRequestStart( required string targetPage ) {
		if ( !application.keyExists( "javaLoaderFactory" ) ) application.javaLoaderFactory = new JavaLoaderFactory();
		return true;
	}

}
