
/**
 * SessionRejectedException.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis2 version: 1.6.2  Built on : Apr 17, 2012 (05:33:49 IST)
 */

package com.nantian.component.bsa.webservice.assumeRole;

public class SessionRejectedException extends java.lang.Exception{

    private static final long serialVersionUID = 1383903239093L;
    
    private com.nantian.component.bsa.webservice.assumeRole.AssumeRoleServiceStub.SessionRejectedExceptionE faultMessage;

    
        public SessionRejectedException() {
            super("SessionRejectedException");
        }

        public SessionRejectedException(java.lang.String s) {
           super(s);
        }

        public SessionRejectedException(java.lang.String s, java.lang.Throwable ex) {
          super(s, ex);
        }

        public SessionRejectedException(java.lang.Throwable cause) {
            super(cause);
        }
    

    public void setFaultMessage(com.nantian.component.bsa.webservice.assumeRole.AssumeRoleServiceStub.SessionRejectedExceptionE msg){
       faultMessage = msg;
    }
    
    public com.nantian.component.bsa.webservice.assumeRole.AssumeRoleServiceStub.SessionRejectedExceptionE getFaultMessage(){
       return faultMessage;
    }
}
    