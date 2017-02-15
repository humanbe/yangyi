package com.nantian.component.bsa.client;

import java.io.File;

import org.apache.axis2.AxisFault;
import org.apache.axis2.databinding.ADBBean;

import com.nantian.component.bsa.webservice.login.LoginServiceStub;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingSessionCredential;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingSessionCredentialResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingUserCredential;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingUserCredentialResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.WS_SSOSessionCredential;
import com.nantian.component.bsa.webservice.login.SessionCredentialExpiredException;
import com.nantian.component.bsa.webservice.login.SessionRejectedException;
import com.nantian.component.com.ComponentProperties;

/**
 * 用户认证登陆BSA
 * @author <a href="mailto:fujunze@nantian.com.cn">LJay</a>
 *
 */
public class LoginServiceClient {
	//信任证书路径
	private String trueStorePath = System.getProperty("maop.root") + File.separator + ComponentProperties.getBsaTruststoreFile();
	//信任证书密码
	private String trueStorePassword = ComponentProperties.getBsaTruststoreFilePassword();
	//登陆BSA的用户名
	private String userName = ComponentProperties.getBsaUserName();
	//登陆BSA的密码	private String password = ComponentProperties.getBsaUserPassword();
	//登陆BSA的认证类型	private String authenticationType = ComponentProperties.getBsaAuthenticationType();
	//BSA transactionId
	private String transactionId = null;
	//BSA认证客户端	private LoginServiceStub stub = null;
	//session认证凭据
	private static WS_SSOSessionCredential sessionCred = null;
	
	private static LoginServiceClient client = null;
	
	public LoginServiceClient() throws AxisFault{
		stub = new LoginServiceStub();
	}
	
	/**
	 * 指定用户名、密码、认证类型和transactionId创建实例
	 * @param userName 用户名	 * @param password 密码
	 * @param authenticationType 认证类型
	 * @param transactionId 
	 * @throws AxisFault
	 */
	public LoginServiceClient(String userName, String password,
			String authenticationType, String transactionId) throws AxisFault {
		this();
		this.userName = userName;
		this.password = password;
		this.authenticationType = authenticationType;
		this.transactionId = transactionId;
	}
	
	/**
	 * 指定用户名、密码、认证类型、transactionId、可信任证书路径和证书密码创建实例.
	 * @param userName 用户名	 * @param password 密码
	 * @param authenticationType 认证类型
	 * @param transactionId
	 * @param trueStorePath 可信任证书路径	 * @param trueStorePassword 证书密码
	 * @throws AxisFault
	 */
	public LoginServiceClient(String userName, String password,
			String authenticationType, String transactionId,
			String trueStorePath, String trueStorePassword) throws AxisFault {
		this(userName, password, authenticationType, transactionId);
		this.trueStorePath = trueStorePath;
		this.trueStorePassword = trueStorePassword;
	}

	/**
	 * 用户认证登陆
	 * @return LoginUsingUserCredentialResponse
	 * @throws Exception
	 */
	public LoginUsingUserCredentialResponse loginUsingUserCredential() throws Exception{
		System.setProperty("javax.xml.stream.XMLInputFactory", "com.ctc.wstx.stax.WstxInputFactory");
		System.setProperty("javax.xml.stream.XMLOutputFactory", "com.ctc.wstx.stax.WstxOutputFactory");
		System.setProperty("javax.xml.stream.XMLEventFactory", "com.ctc.wstx.stax.WstxEventFactory");
		if(null == System.getProperty("javax.net.ssl.trustStore") 
				|| null == System.getProperty("javax.net.ssl.trustStorePassword")){
			System.setProperty("javax.net.ssl.trustStore", trueStorePath);
			System.setProperty("javax.net.ssl.trustStorePassword", trueStorePassword);
		}
		LoginUsingUserCredential credential = (LoginUsingUserCredential) getObject(LoginUsingUserCredential.class);
		credential.setUserName(userName);
		credential.setPassword(password);
		credential.setAuthenticationType(authenticationType);
		LoginServiceStub.TransactionId transId = null;
		if(transactionId != null){
			transId = new LoginServiceStub.TransactionId();
			transId.setTransactionId(transactionId);
		}
		
		return stub.loginUsingUserCredential(credential , transId);
	}
	
	/**
	 * 用户认证Session
	 * @return
	 * @throws Exception
	 */
	public LoginUsingSessionCredentialResponse getBsaCredential() throws Exception{
		if(sessionCred == null){
			LoginUsingUserCredentialResponse loginResponse = loginUsingUserCredential();
			sessionCred = loginResponse.get_return();
		}
		LoginUsingSessionCredential sessionCredential = (LoginUsingSessionCredential) getObject(LoginUsingSessionCredential.class);
		sessionCredential.setWs_sessionCredential(sessionCred);
		try {
			return stub.loginUsingSessionCredential(sessionCredential , null);
		} catch(Exception e){
			if(e instanceof SessionCredentialExpiredException || e instanceof SessionRejectedException){
				LoginUsingUserCredentialResponse loginResponse = loginUsingUserCredential();
				sessionCred = loginResponse.get_return();
				return getBsaCredential();
			}
			throw e;
		}
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
	
	/**
	 * 获取登陆客户端实例	 * @return
	 * @throws AxisFault
	 */
	public static LoginServiceClient getInstance() throws AxisFault{
		if(client == null){
			client = new LoginServiceClient();
		}
		return client;
	} 
	
}
