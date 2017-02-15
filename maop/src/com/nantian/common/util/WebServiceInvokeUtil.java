package com.nantian.common.util;

import javax.xml.namespace.QName;

import org.apache.axis2.AxisFault;
import org.apache.axis2.addressing.EndpointReference;
import org.apache.axis2.client.Options;
import org.apache.axis2.rpc.client.RPCServiceClient;

public class WebServiceInvokeUtil {
	/**
	 * 通过jaxws方式调用websevice接口
	 * @param address webservice地址
	 * @param params 参数
	 * @param returnType 返回值
	 * @param qName 限定名, 格式为 (命名空间):(本地部分)
	 * @return
	 * @throws AxisFault
	 */
	public static Object[] invokeWebServiceInterface(String address, Object[] params,
			Class<?>[] returnType, QName qName) throws AxisFault {
		Object[] returnVal = null;  
        // 建立一个远程连接客户端  
        RPCServiceClient serviceClient = new RPCServiceClient();
        // 设置参数  
        Options options = serviceClient.getOptions();
        //连接超时时间
        options.setTimeOutInMilliSeconds(CommonConst.WEBSERVICE_TIME_OUT);
        
        EndpointReference targetEPR = new EndpointReference(address);
        options.setTo(targetEPR);
        serviceClient.setTargetEPR(targetEPR);
        
        if(returnType != null){
        	returnVal = serviceClient.invokeBlocking(qName, params, returnType);
        }else{
        	serviceClient.invokeRobust(qName, params);
        }
		
        serviceClient.cleanupTransport();
		
       return returnVal;
	}
}
