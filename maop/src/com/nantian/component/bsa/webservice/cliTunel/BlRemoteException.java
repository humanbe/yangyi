
/**
 * BlRemoteException.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis2 version: 1.6.2  Built on : Apr 17, 2012 (05:33:49 IST)
 */

package com.nantian.component.bsa.webservice.cliTunel;

public class BlRemoteException extends java.lang.Exception{

    private static final long serialVersionUID = 1383879505187L;
    
    private com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.BlRemoteExceptionE faultMessage;

    
        public BlRemoteException() {
            super("BlRemoteException");
        }

        public BlRemoteException(java.lang.String s) {
           super(s);
        }

        public BlRemoteException(java.lang.String s, java.lang.Throwable ex) {
          super(s, ex);
        }

        public BlRemoteException(java.lang.Throwable cause) {
            super(cause);
        }
    

    public void setFaultMessage(com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.BlRemoteExceptionE msg){
       faultMessage = msg;
    }
    
    public com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.BlRemoteExceptionE getFaultMessage(){
       return faultMessage;
    }
}
    