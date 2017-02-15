package com.nantian.component.bsa.client;

import javax.activation.DataHandler;

import org.apache.axis2.AxisFault;
import org.apache.axis2.databinding.ADBBean;

import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub;
import com.nantian.component.bsa.webservice.cliTunel.CommandLoadException;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ClientPayLoad;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamList;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamListAndAttachment;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamListAndAttachmentResponse;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamListResponse;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamString;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamStringResponse;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandUsingAttachments;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandUsingAttachmentsResponse;

/**
 * 通过CLI管道调用BSA命令
 * 在此操作之前, 必须要是通过{@link LoginServiceClient}登陆认证
 * @author <a href="mailto:fujunze@nantian.com.cn">LJay</a>
 *
 */
public class CLITunnelServiceClient {
	
	private CLITunnelServiceStub stub = null;
	private CLITunnelServiceStub.SessionId session = null;
	private CLITunnelServiceStub.TransactionId transaction = null;
	private static CLITunnelServiceClient client = null;
	
	public CLITunnelServiceClient(String sessionId, String transactionId) throws AxisFault{
		session = new CLITunnelServiceStub.SessionId();
		session.setSessionId(sessionId);
		if(transaction != null){
			transaction = new CLITunnelServiceStub.TransactionId();
			transaction.setTransactionId(transactionId);
		}
		stub = new CLITunnelServiceStub();
	}
	
	/**
	 * 获取管道客户端实例
	 * @param session
	 * @param transactionId
	 * @return
	 * @throws AxisFault
	 */
	public synchronized static CLITunnelServiceClient getInstance(
			String session, String transactionId) throws AxisFault{
		if(client == null){
			client = new CLITunnelServiceClient(session, transactionId);
		}
		return client;
	}

	/**
	 * 执行命令
	 * @param nameSpace 命令的命名空间
	 * @param commandName 命令名称
	 * @return
	 * @throws Exception 
	 */
	public ExecuteCommandByParamStringResponse executeCommandByParamString(
			String nameSpace, String commandName) throws Exception {
		ExecuteCommandByParamString param = 
				(ExecuteCommandByParamString)getObject(ExecuteCommandByParamString.class);
		param.setNameSpace(nameSpace);
		param.setCommandName(commandName);
		return stub.executeCommandByParamString(param, session, transaction);
	}
	
	/**
	 * 执行带参数的命令
	 * @param nameSpace 命令的命名空间
	 * @param commandName 命令名称
	 * @param commandArguments 命令参数数组
	 * @return
	 * @throws Exception 
	 */
	public ExecuteCommandByParamListResponse executeCommandByParamList(
			String nameSpace, String commandName, String[] commandArguments)
			throws Exception {
		ExecuteCommandByParamList param = 
				(ExecuteCommandByParamList)getObject(ExecuteCommandByParamList.class);
		param.setNameSpace(nameSpace);
		param.setCommandName(commandName);
		param.setCommandArguments(commandArguments);
		return stub.executeCommandByParamList(param, session, transaction);
	}
	
	/**
	 * 执行带参数和附件的命令
	 * @param nameSpace 命令的命名空间
	 * @param commandName 命令名称
	 * @param commandArguments 命令参数数组
	 * @param clientPayLoad 附件
	 * @return
	 * @throws Exception 
	 */
	public ExecuteCommandUsingAttachmentsResponse executeCommandUsingAttachments(
			String nameSpace, String commandName, String[] commandArguments,
			ClientPayLoad clientPayLoad) throws Exception {
		ExecuteCommandUsingAttachments param = 
				(ExecuteCommandUsingAttachments)getObject(ExecuteCommandUsingAttachments.class);
		param.setNameSpace(nameSpace);
		param.setCommandName(commandName);
		param.setCommandArguments(commandArguments);
		param.setPayload(clientPayLoad);
		return stub.executeCommandUsingAttachments(param, session, transaction);
	}
	
	/**
	 * 执行带参数和附件的命令
	 * @param nameSpace 命令的命名空间
	 * @param commandName 命令名称
	 * @param commandArguments 命令参数数组
	 * @param dataHandler 数据处理器
	 * @return
	 * @throws Exception 
	 */
	public ExecuteCommandByParamListAndAttachmentResponse executeCommandByParamListAndAttachment(
			String nameSpace, String commandName, String[] commandArguments,
			DataHandler dataHandler) throws Exception {
		ExecuteCommandByParamListAndAttachment param = 
				(ExecuteCommandByParamListAndAttachment)getObject(ExecuteCommandByParamListAndAttachment.class);
		param.setNameSpace(nameSpace);
		param.setCommandName(commandName);
		param.setCommandArguments(commandArguments);
		param.setDh(dataHandler);
		return stub.executeCommandByParamListAndAttachment(param, session, transaction);
	}
	
	/**
	 * 判断CLI命令执行结果是否异常
	 * @param response CLI命令执行返回对象
	 * @return
	 * @throws CommandLoadException
	 */
	public void ResponseCheck4ExecuteCommand(ExecuteCommandByParamStringResponse response) throws Exception{
		if(!response.get_return().getSuccess()){
			throw new CommandLoadException(response.get_return().getError().toString());
		}
	}
	/**
	 * 判断CLI命令执行结果是否异常
	 * @param response CLI命令执行返回对象
	 * @return
	 * @throws CommandLoadException
	 */
	public void ResponseCheck4ExecuteCommand(ExecuteCommandByParamListResponse response) throws Exception{
		if(!response.get_return().getSuccess()){
			throw new CommandLoadException(response.get_return().getError().toString());
		}
	}
	/**
	 * 判断CLI命令执行结果是否异常
	 * @param response CLI命令执行返回对象
	 * @return
	 * @throws CommandLoadException
	 */
	public void ResponseCheck4ExecuteCommand(ExecuteCommandUsingAttachmentsResponse response) throws Exception{
		if(!response.get_return().getSuccess()){
			throw new CommandLoadException(response.get_return().getError().toString());
		}
	}
	/**
	 * 判断CLI命令执行结果是否异常
	 * @param response CLI命令执行返回对象
	 * @return
	 * @throws CommandLoadException
	 */
	public void ResponseCheck4ExecuteCommand(ExecuteCommandByParamListAndAttachmentResponse response) throws Exception{
		if(!response.get_return().getSuccess()){
			throw new CommandLoadException(response.get_return().getError().toString());
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
}
