component {

	this.name       = hash( getCurrentTemplatePath() );
	this.datasource = "ufapp";

	function onRequestStart( required string targetPage ) {
		if ( !application.keyExists( "javaLoaderFactory" ) ) application.javaLoaderFactory = new JavaLoaderFactory();
		return true;
	}

}
