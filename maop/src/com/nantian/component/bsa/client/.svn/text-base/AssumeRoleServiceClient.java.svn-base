package com.nantian.component.bsa.client;

import org.apache.axis2.AxisFault;
import org.apache.axis2.databinding.ADBBean;

import com.nantian.component.bsa.webservice.assumeRole.AssumeRoleServiceStub;
import com.nantian.component.bsa.webservice.assumeRole.AssumeRoleServiceStub.AssumeRole;
import com.nantian.component.bsa.webservice.assumeRole.AssumeRoleServiceStub.AssumeRoleResponse;

/**
 * 设置用户角色
 * 在此操作之前, 必须要是通过{@link LoginServiceClient}登陆认证
 * @author <a href="mailto:fujunze@nantian.com.cn">LJay</a>
 *
 */
public class AssumeRoleServiceClient {
	
	private AssumeRoleServiceStub stub = null;
	private AssumeRoleServiceStub.SessionId session = null;
	private AssumeRoleServiceStub.TransactionId transaction = null;
	
	public AssumeRoleServiceClient(String sessionId, String transactionId) throws AxisFault{
		session = new AssumeRoleServiceStub.SessionId();
		session.setSessionId(sessionId);
		
		if(transaction != null){
			transaction = new AssumeRoleServiceStub.TransactionId();
			transaction.setTransactionId(transactionId);
		}
		stub = new AssumeRoleServiceStub();
	}

	/**
	 * 设置角色
	 * @return
	 * @throws Exception 
	 */
	public AssumeRoleResponse assumeRole(String assumeRole0) throws Exception {
		AssumeRole param = 
				(AssumeRole)getObject(AssumeRole.class);
		param.setRoleName(assumeRole0);
		
		return stub.assumeRole(param, session, transaction);
	}
	
	/**
	 * 获取对象实例
	 * @param type 类型
	 * @return
	 * @throws java.lang.Exception
	 */
	private ADBBean getObject(Class<?> type) throws Exception{
        return (ADBBean) type.newInstance();
     }
	
}///:~
