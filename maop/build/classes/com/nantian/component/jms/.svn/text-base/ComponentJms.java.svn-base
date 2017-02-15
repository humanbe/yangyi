package com.nantian.component.jms;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import java.util.UUID;

import javax.jms.JMSException;
import javax.jms.MapMessage;
import javax.jms.Queue;
import javax.jms.QueueConnection;
import javax.jms.QueueConnectionFactory;
import javax.jms.QueueSender;
import javax.jms.QueueSession;
import javax.jms.Session;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.nantian.component.com.ComponentConst;
import com.nantian.component.com.ComponentDateFunc;
import com.nantian.component.com.ComponentException;
import com.nantian.component.com.ComponentProperties;
import com.nantian.component.log.Logger;
import com.nantian.dply.service.ExecuteStatusInfoService;
import com.nantian.dply.vo.ExecuteStatusInfoVo;

/**
 * JMS类
 * @author dong
 */
@Component
public class ComponentJms {

	/** 日志输出 */
	final Logger logger = Logger.getLogger(ComponentJms.class);
	
	@Autowired
	private ExecuteStatusInfoService executeStatusInfoService;
	
	public ComponentJms() {
		super();
	}

	/**
	 * 依据指定的队列利用JMS发送消息	 *
	 * <UL><B>异常编码：异常原因</B>
	 * <LI>60000001：登录ID为NULL
	 * <LI>60000002：登录ID为空
	 * <LI>60000004：队列的JNDI名为NULL
	 * <LI>60000005：队列的JNDI名为空	 * <LI>60000006：队列的JNDI名不存在
	 * <LI>60009999：未知异常	 * </UL>
	 *
	 * @param entryid 登录ID
	 * @param queueName QUEUE名
	 */
	public final void sendJMS(final String entryid, final String queueName) {
		
		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "sendJMS");
		}

		// 输出参数
		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "entryid;queueName", entryid + ";" + queueName);
		}

		//确认参数(登录ID)
		if (entryid == null) {
			if (logger.isEnableFor("Component5001")) {
				logger.log("Component5001","");
			}
			throw new ComponentException("登录ID为NULL", ComponentJmsConst.ERROR_ENTRY_KEY_NULL);

		} else if ("".equals(entryid.trim())) {
			if (logger.isEnableFor("Component5002")) {
				logger.log("Component5002","");
			}
			throw new ComponentException("登录ID为空", ComponentJmsConst.ERROR_ENTRY_KEY_EMPTY);
		}

		// 确认队列名(QUEUE名)
		if (queueName == null) {
			if (logger.isEnableFor("Component5004")) {
				logger.log("Component5004","");
			}
			throw new ComponentException("QUEUE名为NULL",	ComponentJmsConst.ERROR_QUEUE_JNDI_NULL);

		} else if ("".equals(queueName.trim())) {
			if (logger.isEnableFor("Component5005")) {
				logger.log("Component5005","");
			}
			throw new ComponentException("QUEUE名为空", ComponentJmsConst.ERROR_QUEUE_JNDI_EMPTY);
		}

		Context jndiContext = null;
		QueueConnectionFactory queueConnectionFactory = null;
		QueueConnection queueConnection = null;
		QueueSession queueSession = null;
		Queue queue = null;
		QueueSender queueSender = null;
		String jmsQueueJndi = "";

		try {
			// 获取JNDI的上下文环境
			Properties pp = new Properties();
			pp.put(Context.INITIAL_CONTEXT_FACTORY, ComponentProperties.getJmsJavaNamingFactoryInitial());
			pp.put(Context.PROVIDER_URL, ComponentProperties.getJmsJavaNamingProviderUrl());
			pp.put(Context.SECURITY_PRINCIPAL, ComponentProperties.getJmsJavaNamingSecurityPrincipal());
			pp.put(Context.SECURITY_CREDENTIALS, ComponentProperties.getJmsJavaNamingSecurityCredentials());
			jndiContext = new InitialContext(pp);

			// 队列的连接工厂（JmsConnectionFactory）
			queueConnectionFactory =
					(QueueConnectionFactory) jndiContext.lookup(ComponentJmsConst.QUEUE_CONNECTION_FACTORY);
			
			// 从资源文件中获取设定的JNDI名
			jmsQueueJndi = ComponentProperties.getJmsQueueJndiName(queueName);
			
			queue = (Queue) jndiContext.lookup(jmsQueueJndi);

		} catch (NamingException e) {
			if (logger.isEnableFor("Component5006")) {
				logger.log("Component5006", queueName, jmsQueueJndi,  e.getMessage());
			}

			List<String> errorDetailList = new ArrayList<String>();
			errorDetailList.add("entryid=" + entryid);
			errorDetailList.add("queueName=" + queueName);

			throw new ComponentException("JNDI名不存在",
					ComponentJmsConst.ERROR_QUEUE_JNDI_NOT_FOUND, errorDetailList, e);
		}

		try {
			// 建立连接
			queueConnection = queueConnectionFactory.createQueueConnection();

			try{
				// 建立SESSION
				queueSession = queueConnection.createQueueSession(false, Session.AUTO_ACKNOWLEDGE);

				try{
					// 建立队列发送对象					queueSender = queueSession.createSender(queue);

					try{
						// 建立消息对象
						MapMessage message = queueSession.createMapMessage();

						// 在发送的消息中设定唯一的登录ID
						message.setString(ComponentConst.JMS_MESSAGE_ENTRY_ID, entryid);

						// 发送消息						queueSender.send(message);
					}
					finally{
						queueSender.close();
						queueSender = null;
					}
				}
				finally{
					queueSession.close();
					queueSession = null;
				}
				
			}
			finally{
				queueConnection.close();
				queueConnection = null;
			}

		} catch (JMSException e) {
			if (logger.isEnableFor("Component5999")) {
				logger.log("Component5999", e.getMessage(),
						"entryid;queueName", entryid + ";" + queueName);
			}

			List<String> errorDetailList = new ArrayList<String>();
			errorDetailList.add("entryid=" + entryid);
			errorDetailList.add("queueName=" + queueName);

			throw new ComponentException("JMS操作类中发生未知",
					ComponentJmsConst.ERROR_UNKNOWN, errorDetailList, e);

		} 
		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "sendJMS");
		}
	}

	/**
	 * 实行状态管理表中插入数据</BR>
	 * ExecuteStatusInfoVo的在服务器上存放的临时文件（uploadFileTmpName）存在</BR>
	 * 则作成上传文件处理后的空文件，信息存放在afterFilePath字段中。</BR>
	 *
	 * <UL><B>异常编码：异常原因</B>
	 * <LI>60000007：未指定用户名	 * <LI>60000007：未指定队列名	 * <LI>60000007：未指定执行的类名	 * <LI>60000008：上传后的文件作成失败（功能ID为设定）
	 * <LI>60009999：发生未知异常	 * </UL>
	 *
	 * @param dbVo dbVo
	 * @param isImmediate 立即执行&定时执行标识(true:立即执行 / false:定时执行)
	 * @throws Throwable 抛出发生的异常	 */
	public final void entryRecord(ExecuteStatusInfoVo dbVo, boolean isImmediate)
			throws Throwable {

		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "entryRecord");
		}
		// 输出参数
		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "isImmediate", String.valueOf(isImmediate));
		}

		if (dbVo == null) {
			if (logger.isEnableFor("Component5007")) {
				logger.log("Component5007", "DB Vo对象");
			}
			throw new ComponentException("未指定DB Vo对象", ComponentJmsConst.ERROR_INVALID_PARAMETER);
		}
		if (dbVo.getUserId() == null || dbVo.getUserId().trim().equals("")) {
			if (logger.isEnableFor("Component5007")) {
				logger.log("Component5007", "用户名");
			}
			throw new ComponentException("未指定用户名", ComponentJmsConst.ERROR_INVALID_PARAMETER);
		}

		if (dbVo.getQueueName() == null || dbVo.getQueueName().trim().equals("")) {
			if (logger.isEnableFor("Component5007")) {
				logger.log("Component5007", "QUEUE名");
			}
			throw new ComponentException("未指定QUEUE名", ComponentJmsConst.ERROR_INVALID_PARAMETER);
		}

		if (dbVo.getClassName() == null || dbVo.getClassName().trim().equals("")) {
			if (logger.isEnableFor("Component5007")) {
				logger.log("Component5007", "执行的类名");
			}
			throw new ComponentException("未指定执行的类名", ComponentJmsConst.ERROR_INVALID_PARAMETER);
		}

		// 执行计划时间
		if (!isImmediate) {
			if (dbVo.getExecutePlanTime() == null || dbVo.getExecutePlanTime().trim().equals("")) {
				if (logger.isEnableFor("Component5007")) {
					logger.log("Component5007", "执行计划时间");
				}
				throw new ComponentException("未指定执行计划时间", ComponentJmsConst.ERROR_INVALID_PARAMETER);
			}

			try {
				SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmssSSS");
				sdf.setLenient(false);
				sdf.parse(dbVo.getExecutePlanTime());

			} catch (java.text.ParseException e) {
				if (logger.isEnableFor("Component5008")) {
					logger.log("Component5008", dbVo.getExecutePlanTime());
				}
				throw new ComponentException("执行计划时间错误", ComponentJmsConst.ERROR_INVALID_PARAMETER, e);
			}
		}

		// 方法名		String method = "doProcess";

		// UUID
		String entryID = (UUID.randomUUID()).toString();

		if (logger.isDebugEnable()) {
			logger.debug("entry_id=" + entryID);
		}

		if (logger.isDebugEnable()) {
			logger.debug("DPLY_EXECUTE_STATUS insert start");
		}

		// 登录ID
		dbVo.setEntryId(entryID);

		// 若未指定方法名		if (dbVo.getMethod() == null || dbVo.getMethod().trim().equals("")) {
			// 设定方法名			dbVo.setMethod(method);
		}

		// 若是立即执行
		if (isImmediate) {
			// 设定JOB状态			dbVo.setJobStatus("02_WAIT");
			// 清除执行计划时间
			dbVo.setExecutePlanTime(null);
		} else {
			// 设定JOB状态			dbVo.setJobStatus("01_PLAN");
		}

		// 设定删除标示
		dbVo.setDeleteFlag("");
		
		// 若dbVo存在上传文件，则作成上传文件处理后的CSV空文件		String kibanUploadFileTmpName = dbVo.getUploadFileTmpName();
		if(kibanUploadFileTmpName != null && !kibanUploadFileTmpName.equals("")) {
			
			String functionId = dbVo.getFunctionId();
			if(functionId == null || functionId.equals("")) {
				// 若未登录功能ID则抛出异常
				if (logger.isEnableFor("Component5012")) {
					logger.log("Component5012","");
				}
				throw new ComponentException("作成处理后的上传文件异常。（未设定功能ID）",
						ComponentJmsConst.ERROR_AFTER_UPLOAD_FILE_ERROR_KINOUID_NOT_FOUND);
			}			
			String userId = dbVo.getUserId();
			
			// 功能ID不为空和NULL则作成处理后的上传文件
			// 文件的格式为
			// 1.资源文件中的【jms.result.file】+【YYYYMMDD】+【/OutputF_】+【功能ID_】+【用户名_】+【HHMMSSFFF】+【.csv】			// 2.用【1.】的规则作成的文件已经存在，则在文件最后加上通过Thread.currentThread().getId()取得的值			// 获取此格式的（YYYYMMDDHHMMSSFFF）的系统时间，然后分割YYYYMMDD和HHMMSSFFF
			String systemTimeMillsSec = ComponentDateFunc.getSystemTimeMillSec();
			String yyyymmdd = systemTimeMillsSec.substring(0, 8);
			String hhmmssfff = systemTimeMillsSec.substring(8,17);
			
			String suffix = ".csv";
			// 作成处理后的上传文件的路径			String afterFilePathDir = 
				ComponentProperties.getJmsResultFile() +
				"/" +
				yyyymmdd;
			
			File baseDir = new File(afterFilePathDir);
			if(!baseDir.exists()) {
				// 若路径不存在则创建目录				baseDir.mkdir();
			}
			
			// 处理后的上传文件的文件名
			String afterFileName = 
				"/OutputF_" +
				functionId +
				"_" +
				userId +
				"_" +
				hhmmssfff;
						
			// 检查文件是否存在			File afterFile = new File(afterFilePathDir + afterFileName + suffix);
			if(afterFile.exists()) {
				// 获取ThreadId
				long threadId = Thread.currentThread().getId();
				// 文件名中增加ThreadId
				afterFileName += new Long(threadId).toString();
				afterFile = new File(afterFilePathDir + afterFileName + suffix);
			}
			
			// 制作空文件			try {
				afterFile.createNewFile();
			} catch (IOException e) {
				if (logger.isEnableFor("Component5013")) {
					logger.log("Component5013", e, afterFile.getPath());
				}
				
				List<String> errorDetailList = new ArrayList<String>();
				errorDetailList.add("处理后的上传文件的路径=" + afterFile.getPath());
				throw new ComponentException("JMS操作发生未知异常",
						ComponentJmsConst.ERROR_UNKNOWN, errorDetailList, e);
			}
			
			String afterFilePath = afterFile.getPath(); 
			
			// 设定处理后的上传文件保存路径
			dbVo.setAfterFilePath(afterFilePath);
			
			// 输出保存路径
			if (logger.isEnableFor("Component5011")) {
				logger.log("Component5011", afterFilePath);
			}
		}
		
		// 获取系统时刻
		String systemTime = ComponentDateFunc.getSystemTime();
		// 设定登录时间
		dbVo.setLoginTime(systemTime);
		// 设定更新时间
		dbVo.setModifyTime(systemTime);

		// 执行状况管理表插入数据		executeStatusInfoService.save(dbVo);
		if (logger.isDebugEnable()) {
			logger.debug("DPLY_EXECUTE_STATUS insert end");
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "entryRecord");
		}
	}

	/**
	 * 删除执行状况管理表	 *
	 * <UL><B>异常编码：异常原因</B>
	 * <LI>60000007：未指定登录ID
	 * </UL>
	 *
	 * @param dbVo dbVo
	 * @return 更新记录数
	 * @throws Throwable 抛出异常
	 */
	public final int cancelRecord(ExecuteStatusInfoVo dbVo)
			throws Throwable {
		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "cancelRecord");
		}

		if (dbVo == null) {
			if (logger.isEnableFor("Component5007")) {
				logger.log("Component5007", "DB Vo对象");
			}
			throw new ComponentException("未指定DB Vo对象", ComponentJmsConst.ERROR_INVALID_PARAMETER);
		}
		if (dbVo.getEntryId() == null || dbVo.getEntryId().trim().equals("")) {
			if (logger.isEnableFor("Component5007")) {
				logger.log("Component5007", "登录ID");
			}
			throw new ComponentException("未指定登录ID", ComponentJmsConst.ERROR_INVALID_PARAMETER);
		}

		// 执行状况管理表查询		ExecuteStatusInfoVo getVo = (ExecuteStatusInfoVo) executeStatusInfoService.findById(dbVo.getEntryId());
		if (getVo == null) {
			if (logger.isEnableFor("Component5009")) {
				logger.log("Component5009", dbVo.getEntryId());
			}
			// 当前登录ID的数据不存在
			return 0;
		}

		// 设置删除标志
		getVo.setDeleteFlag("D");
		// 获取系统时间
		String systemTime = ComponentDateFunc.getSystemTime();
		// 设定更新时间
		getVo.setModifyTime(systemTime);
		// 更新执行状态管理表
		executeStatusInfoService.update(getVo);
		
		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "cancelRecord");
		}

		// 更新数据
		return 1;
	}
}
