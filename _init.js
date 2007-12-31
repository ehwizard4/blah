/* _init.js executes once upon server startup (and also anytime you change it)
*/

core.user.auth();

/* Function allowed() is called on every request before processing for authentication purposes. 
   The default implementation below denies non-admin users access to anything under /admin/ on the 
   site, but keeps the site completely open otherwise.
*/
function allowed( req , res , uri ){
    if ( ! uri.match( /\/admin/ ) )
        return;
    
    user = Auth.getUser( req );
    if ( user == null )
        return Auth.reject( res );
	
    if ( ! user.isAdmin() )
        return Auth.reject( res );
}

