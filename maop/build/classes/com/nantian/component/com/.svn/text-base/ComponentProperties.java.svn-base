package com.nantian.component.com;

import java.io.File;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Properties;

import com.nantian.component.log.Logger;

/**
 * 共通属性资源类
 * <P>共通属性资源定义 * @author dong
 */
public class ComponentProperties {
	/**
	 * Logger
	 */
	private static Logger logger =  Logger.getLogger(ComponentProperties.class);

	/**
	 * 共通资源定义	 */
	private static Properties componentConfProperties;

	/**
	 * 存放资源属性值的Map
	 */
	private static HashMap<String, String> propertiesMap = new HashMap<String, String>();

	/**
	 * 文件upload：文件upload的临时文件目录KEY名	 * 默认：%TEMP%
	 */
	private static final String FILE_TEMP_FILE_DIR_KEY = "file.tempFileDir";

	/**
	 * SSH字符集设置KEY名	 */
	private static final String SSH_CHARSET_NAME_KEY = "ssh.charsetName";

	/**
	 * SSH默认字符集	 */
	private static final String SSH_CHARSET_NAME_DEF = "UTF-8";

	/**
	 * SSH用户名称设置KEY名	 */
	private static final String SSH_LOCAL_USER_KEY = "ssh.localUser";

	/**
	 * SSH密码设置KEY名	 */
	private static final String SSH_LOCAL_PASSWORD_KEY = "ssh.localPassword";

	/**
	 * MDB执行状态表：删除标示的KEY
	 */
	private static final String MDB_DELETE_FLAG_KEY = "mdb.deleteFlag";

	/**
	 * MDB执行状态表：删除标示的默认值	 */
	private static final String MDB_DELETE_FLAG_DEF = "1";

	/**
	 * MDB执行状态表：job_status（等待）key
	 */
	private static final String MDB_JOB_STATUS_WAIT_KEY = "mdb.statusWait";

	/**
	 * MDB执行状态表：job_status（等待）默认值	 */
	private static final String MDB_JOB_STATUS_WAIT_DEF = "02_WAIT";

	/**
	 * MDB执行状态表：job_status（开始）key
	 */
	private static final String MDB_JOB_STATUS_START_KEY = "mdb.statusStart";

	/**
	 * MDB执行状态表：job_status（开始）默认值	 */
	private static final String MDB_JOB_STATUS_START_DEF = "03_START";

	/**
	 * MDB执行状态表：job_status（完成）key
	 */
	private static final String MDB_JOB_STATUS_COMPLETE_KEY = "mdb.statusComplete";

	/**
	 * MDB执行状态表：job_status（完成）默认值	 */
	private static final String MDB_JOB_STATUS_COMPLETE_DEF = "04_COMPLETE";

	/**
	 * MDB执行状态表：job_status（异常）key
	 */
	private static final String MDB_JOB_STATUS_ERROR_KEY = "mdb.statusError";

	/**
	 * MDB执行状态表：job_status（异常）默认值	 */
	private static final String MDB_JOB_STATUS_ERROR_DEF = "99_ERROR";
		
	/**
	 * MDB调用的服务类发生异常时，异常类状态设定的bese key
	 */
	private static final String MDB_SERVICE_EXCEPTION_BASE_KEY = "mdb.service.exception";
	
	/**
	 * MDB调用的服务类发生异常时，异常类状态设定值的key
	 */
	private static final String MDB_SERVICE_EXCEPTION_NUM_KEY = MDB_SERVICE_EXCEPTION_BASE_KEY+".num";
	
	/**
	 * MDB调用的服务类发生异常时，异常类状态设定的异常类名（最后部分）
	 */
	private static final String MDB_SERVICE_EXCEPTION_CLASS_NAME_KEY = ".class";
	
	/**
	 * MDB调用的服务类发生异常时，异常类状态设定的异常类名（最后部分）
	 */
	private static final String MDB_SERVICE_EXCEPTION_JOB_STATUS_KEY = ".jobstatus";

	/**
	 * MDB调用的服务类发生异常时，异常类的状态MAP（key：异常类名、value：类状态）
	 */
	private static Map<String, String> exceptionJobStatusMap = new HashMap<String, String>();
	
	/**
	 * MDB调用的服务类发生异常时，异常类的状态MAP（key：异常类名、value：异常类登录资源文件KEY名）
	 * 仅在输出LOG时候用
	 */
	private static Map<String, String> exceptionClassKeyMap = new HashMap<String, String>();
	
	/**
	 * MDB调用的服务类发生异常时，异常类的状态MAP（key：异常类名、value：异常类登录资源文件KEY名）
	 * 仅在输出LOG时候用
	 */
	private static Map<String, String> exceptionJobStatusKeyMap = new HashMap<String, String>();

	/**
	 * SVNROOT目录key
	 */
	private static final String SVN_ROOT_KEY = "svn.root";

	/**
	 * SVNROOT目录默认值	 */
	private static final String SVN_ROOT_DEF = "/autodeploy/svn_data/zzsample";
	
	/**
	 * SVNURL目录key
	 */
	private static final String SVN_URL_KEY = "svn.url";

	/**
	 * SVNURL目录默认值
	 */
	private static final String SVN_URL_DEF = "svn://localhost/zzsample/";

	/**
	 * SVN连接用户名KEY
	 */
	private static final String SVN_USERNAME_KEY = "svn.userName";

	/**
	 * SVN连接密码KEY
	 */
	private static final String SVN_PASSWORD_KEY = "svn.passWord";
	
	/**
	 * 生产用SVNLIB的设定路径	 */
	private static final String SVN_HONBAN_PATH_KEY = "svn.honban.path";
	
	/**
	 * SVN文件DIFF后的比较结果文件存放路径
	 */
	private static final String SVN_RESULT_FILE_DIFF_KEY = "svn.result.file.diff";
	
	/**
	 * upload文件处理后存放的目录
	 * jms#enrtyRecord
	 */
	private static final String JMS_RESULT_FILE_KEY = "jms.result.file";
	
	/**
	 * weblogic提供JNDI的初始化工厂
	 */
	private static final String JAVA_NAMING_FACTORY_INITIAL_KEY="java.naming.factory.initial";
	private static final String JAVA_NAMING_FACTORY_INITIAL_DEF="weblogic.jndi.WLInitialContextFactory";
	
	/**
	 * weblogic提供JNDI的URL
	 */
	private static final String JAVA_NAMING_PROVIDER_URL_KEY="java.naming.provider.url";
	private static final String JAVA_NAMING_PROVIDER_URL_DEF="t3://127.0.0.1:7001";
	
	/**
	 * weblogic提供JNDI的安全认证的用户名	 */
	private static final String JAVA_NAMING_SECURITY_PRINCIPAL_KEY="java.naming.security.principal";
	private static final String JAVA_NAMING_SECURITY_PRINCIPAL_DEF="weblogic";
	
	/**
	 * weblogic提供JNDI的安全认证的密码
	 */
	private static final String JAVA_NAMING_SECURITY_CREDENTIALS_KEY="java.naming.security.credentials";
	private static final String JAVA_NAMING_SECURITY_CREDENTIALS_DEF="weblogic10";
	
	/**
	 * brpm
	 */
	private static final String BRPM_ACCESS_ADDRESS_KEY = "brpm.accessAddress";
	private static final String BRPM_USER_NAME_KEY = "brpm.userName";
	private static final String BRPM_USER_PASSWORD_KEY = "brpm.userPassword";
	private static final String BRPM_USER_TOKEN_KEY = "brpm.userToken";
	
	/**
	 * bsa
	 */
	private static final String BSA_IPADDRESS_KEY = "bsa.ipAddress";
	private static final String BSA_ACCESS_ADDRESS_KEY = "bsa.accessAddress";
	private static final String BSA_TRUSTSTORE_FILE_KEY = "bsa.truststoreFile";
	private static final String BSA_TRUSTSTORE_FILE_PASSWORD_KEY = "bsa.truststoreFilePassword";
	private static final String BSA_USER_NAME_KEY = "bsa.userName";
	private static final String BSA_USER_PASSWORD_KEY = "bsa.userPassword";
	private static final String BSA_AUTHENTICATION_TYPE_KEY = "bsa.authenticationType";
	
	/** 异常值:JMS送信队列的JNDI名获取失败 */
	public static final int ERROR_QUEUE_JNDI_NOT_FOUND = 10000001;

	/** 异常值:队列的参数错误 */
	public static final int ERROR_INVALID_QUEUE_NAME_PARAMETER = 10000002;
	
	/** 异常值:未设定upload文件处理后存放的目录 */
	public static final int ERROR_JMS_RESULT_FILE_KEY_NOT_FOUND = 10000003;
	
	/** 异常值:upload文件处理后存放的目录设定错误 */
	public static final int ERROR_INVALID_JMS_RESULT_FILE = 10000004;
	
	/** 异常值:属性值设定错误 */
	public static final int ERROR_INVALID_PROPERTIES_VALUE = 10000005;
	
	/** 异常值:未设定未设定SVN比较结果文件存放的目录 */
	public static final int ERROR_SVN_RESULT_FILE_DIFF_KEY_NOT_FOUND = 10000006;
	
	/** 异常值:SVN比较结果文件存放的目录设定错误 */
	public static final int ERROR_INVALID_SVN_RESULT_DIFF_FILE = 10000007;

	static {
		componentConfProperties = (Properties) ComponentObject.getInstance(ComponentConst.Component_PROPERTIES_FILE_NAME);

		// 获取资源文件中设定的临时目录
		String fileTempFileDir = componentConfProperties.getProperty(FILE_TEMP_FILE_DIR_KEY);
		if (fileTempFileDir == null || fileTempFileDir.trim().equals("")) {
			if (logger.isEnableFor("Component0004")) {
				logger.log("Component0004",
						ComponentConst.Component_PROPERTIES_FILE_NAME,
						FILE_TEMP_FILE_DIR_KEY,
						"%TEMP%");
			}
			// 若没有设定临时目录，则null
			fileTempFileDir = null;
		}
		propertiesMap.put(FILE_TEMP_FILE_DIR_KEY, fileTempFileDir);

		// 获取SSH字符集		String sshCharsetName = componentConfProperties.getProperty(SSH_CHARSET_NAME_KEY);
		if (sshCharsetName == null || sshCharsetName.trim().equals("")) {
			if (logger.isEnableFor("Component0004")) {
				logger.log("Component0004",
						ComponentConst.Component_PROPERTIES_FILE_NAME,
						SSH_CHARSET_NAME_KEY,
						SSH_CHARSET_NAME_DEF);
			}
			sshCharsetName = SSH_CHARSET_NAME_DEF;
		}
		propertiesMap.put(SSH_CHARSET_NAME_KEY, sshCharsetName);

		// 获取SSH本地用户
		String sshLocalUser = componentConfProperties.getProperty(SSH_LOCAL_USER_KEY);
		propertiesMap.put(SSH_LOCAL_USER_KEY, sshLocalUser);

		// 获取SSH本地用户密码
		String sshLocalPassword = componentConfProperties.getProperty(SSH_LOCAL_PASSWORD_KEY);
		propertiesMap.put(SSH_LOCAL_PASSWORD_KEY, sshLocalPassword);

		// MDB执行状态表：获取删除标示		String mdbDeleteFlag = componentConfProperties.getProperty(MDB_DELETE_FLAG_KEY);
		if (mdbDeleteFlag == null || mdbDeleteFlag.trim().equals("")) {
			if (logger.isEnableFor("Component0004")) {
				logger.log("Component0004",
						ComponentConst.Component_PROPERTIES_FILE_NAME,
						MDB_DELETE_FLAG_KEY,
						MDB_DELETE_FLAG_DEF);
			}
			mdbDeleteFlag = MDB_DELETE_FLAG_DEF;
		}
		propertiesMap.put(MDB_DELETE_FLAG_KEY, mdbDeleteFlag);

		// MDB执行状态表：获取job_status（等待）
		String mdbJobStatusWait = componentConfProperties.getProperty(MDB_JOB_STATUS_WAIT_KEY);
		if (mdbJobStatusWait == null || mdbJobStatusWait.trim().equals("")) {
			if (logger.isEnableFor("Component0004")) {
				logger.log("Component0004",
						ComponentConst.Component_PROPERTIES_FILE_NAME,
						MDB_JOB_STATUS_WAIT_KEY,
						MDB_JOB_STATUS_WAIT_DEF);
			}
			mdbJobStatusWait = MDB_JOB_STATUS_WAIT_DEF;
		}
		propertiesMap.put(MDB_JOB_STATUS_WAIT_KEY, mdbJobStatusWait);

		// MDB执行状态表：获取job_status（开始）
		String mdbJobStatusKaishi = componentConfProperties.getProperty(MDB_JOB_STATUS_START_KEY);
		if (mdbJobStatusKaishi == null || mdbJobStatusKaishi.trim().equals("")) {
			if (logger.isEnableFor("Component0004")) {
				logger.log("Component0004",
						ComponentConst.Component_PROPERTIES_FILE_NAME,
						MDB_JOB_STATUS_START_KEY,
						MDB_JOB_STATUS_START_DEF);
			}
			mdbJobStatusKaishi = MDB_JOB_STATUS_START_DEF;
		}
		propertiesMap.put(MDB_JOB_STATUS_START_KEY, mdbJobStatusKaishi);

		// MDB执行状态表：获取job_status（完成）
		String mdbJobStatusSyuryo = componentConfProperties.getProperty(MDB_JOB_STATUS_COMPLETE_KEY);
		if (mdbJobStatusSyuryo == null || mdbJobStatusSyuryo.trim().equals("")) {
			if (logger.isEnableFor("Component0004")) {
				logger.log("Component0004",
						ComponentConst.Component_PROPERTIES_FILE_NAME,
						MDB_JOB_STATUS_COMPLETE_KEY,
						MDB_JOB_STATUS_COMPLETE_DEF);
			}
			mdbJobStatusSyuryo = MDB_JOB_STATUS_COMPLETE_DEF;
		}
		propertiesMap.put(MDB_JOB_STATUS_COMPLETE_KEY, mdbJobStatusSyuryo);

		// MDB执行状态表：获取job_status（异常）
		String mdbJobStatusError = componentConfProperties.getProperty(MDB_JOB_STATUS_ERROR_KEY);
		if (mdbJobStatusError == null || mdbJobStatusError.trim().equals("")) {
			if (logger.isEnableFor("Component0004")) {
				logger.log("Component0004",
						ComponentConst.Component_PROPERTIES_FILE_NAME,
						MDB_JOB_STATUS_ERROR_KEY,
						MDB_JOB_STATUS_ERROR_DEF);
			}
			mdbJobStatusError = MDB_JOB_STATUS_ERROR_DEF;
		}
		propertiesMap.put(MDB_JOB_STATUS_ERROR_KEY, mdbJobStatusError);
		
		// 获取SVN项目文件库根目录
		String svnRoot = componentConfProperties.getProperty(SVN_ROOT_KEY);
		if (svnRoot == null || svnRoot.trim().equals("")) {
			if (logger.isEnableFor("Component0004")) {
				logger.log("Component0004",
						ComponentConst.Component_PROPERTIES_FILE_NAME,
						SVN_ROOT_KEY,
						SVN_ROOT_DEF);
			}
			svnRoot = SVN_ROOT_DEF;
		}
		propertiesMap.put(SVN_ROOT_KEY, svnRoot);
		
		// 获取SVN项目文件库url
		String svnUrl = componentConfProperties.getProperty(SVN_URL_KEY);
		if (svnUrl == null || svnUrl.trim().equals("")) {
			if (logger.isEnableFor("Component0004")) {
				logger.log("Component0004",
						ComponentConst.Component_PROPERTIES_FILE_NAME,
						SVN_URL_KEY,
						SVN_URL_KEY);
			}
			svnRoot = SVN_URL_DEF;
		}
		propertiesMap.put(SVN_URL_KEY, svnUrl);

		// 获取SVN连接用户名		String svnUsername = componentConfProperties.getProperty(SVN_USERNAME_KEY);
		propertiesMap.put(SVN_USERNAME_KEY, svnUsername);

		// 获取SVN连接密码
		String svnPassword = componentConfProperties.getProperty(SVN_PASSWORD_KEY);
		propertiesMap.put(SVN_PASSWORD_KEY, svnPassword);
		
		// 获取生产SVN项目文件库路径		String svnHonbanPath = componentConfProperties.getProperty(SVN_HONBAN_PATH_KEY);
		if (svnHonbanPath == null || svnHonbanPath.trim().equals("")) {
			if (logger.isEnableFor("Component0014")) {
				logger.log("Component0014",
						SVN_ROOT_KEY,
						propertiesMap.get(SVN_ROOT_KEY),
						ComponentConst.Component_PROPERTIES_FILE_NAME,
						SVN_HONBAN_PATH_KEY);
			}
			svnHonbanPath = "";
		}
		propertiesMap.put(SVN_HONBAN_PATH_KEY, svnHonbanPath);
		
		// SVN比较结果文件存放的目录
		String svnDiffResultFile = componentConfProperties.getProperty(SVN_RESULT_FILE_DIFF_KEY);
		if (svnDiffResultFile == null || svnDiffResultFile.trim().equals("")) {
			// 若值未设定则异常

			if (logger.isEnableFor("Component0005")) {
				logger.log("Component0005",
						ComponentConst.Component_PROPERTIES_FILE_NAME,
						SVN_RESULT_FILE_DIFF_KEY);
			}
			throw new ComponentException("未设定SVN比较结果文件存放的目录的KEY", 
					ERROR_SVN_RESULT_FILE_DIFF_KEY_NOT_FOUND);
		}
		
		File diffDir = new File(svnDiffResultFile);
		
		if(!diffDir.exists()) {
			// 若目录不存在，则创建目录
			diffDir.mkdirs();
		}
		
		if(!diffDir.isDirectory()) {
			// 若指定的路径不是目录
			if (logger.isEnableFor("Component0011")) {
				logger.log("Component0011",
						ComponentConst.Component_PROPERTIES_FILE_NAME,
						SVN_RESULT_FILE_DIFF_KEY,
						svnDiffResultFile);
			}
			throw new ComponentException("SVN比较结果文件存放的目录设定错误", 
					ERROR_INVALID_SVN_RESULT_DIFF_FILE);
		}
		propertiesMap.put(SVN_RESULT_FILE_DIFF_KEY, svnDiffResultFile);
		
		
		// upload文件处理后存放的目录
		String jmsResultFile = componentConfProperties.getProperty(JMS_RESULT_FILE_KEY);
		if (jmsResultFile == null || jmsResultFile.trim().equals("")) {
			// 若值未设定则异常
			if (logger.isEnableFor("Component0005")) {
				logger.log("Component0005",
						ComponentConst.Component_PROPERTIES_FILE_NAME,
						JMS_RESULT_FILE_KEY);
			}
			throw new ComponentException("未设定upload文件处理后存放的目录的KEY", 
					ERROR_JMS_RESULT_FILE_KEY_NOT_FOUND);
		}
		
		File dir = new File(jmsResultFile);
		
		if(!dir.exists()) {
			// 若目录不存在，则创建目录
			dir.mkdirs();
		}
		
		if(!dir.isDirectory()) {
			// 若指定的路径不是目录
			if (logger.isEnableFor("Component0011")) {
				logger.log("Component0011",
						ComponentConst.Component_PROPERTIES_FILE_NAME,
						JMS_RESULT_FILE_KEY,
						jmsResultFile);
			}
			throw new ComponentException("upload文件处理后存放的目录设定错误", 
					ERROR_INVALID_JMS_RESULT_FILE);			
		}
		propertiesMap.put(JMS_RESULT_FILE_KEY, jmsResultFile);

		/*
		 * MDB调用的服务类发生异常时，做成异常类状态MAP(key:异常类名、value：类状态)
		 */
		String exNumStr = componentConfProperties.getProperty(MDB_SERVICE_EXCEPTION_NUM_KEY);
		int exNum = 0;
		if(exNumStr == null || exNumStr.trim().equals("")) {
			exNumStr = "";
			
		} else {
			try {
				exNum = Integer.parseInt(exNumStr);
				
			} catch(NumberFormatException e) {
				if (logger.isEnableFor("Component0012")) {
					logger.log("Component0012",
							ComponentConst.Component_PROPERTIES_FILE_NAME,
							MDB_SERVICE_EXCEPTION_NUM_KEY,
							exNumStr);
				}
				throw new ComponentException("资源文件设定的值错误", ERROR_INVALID_PROPERTIES_VALUE);
			}
			
			for(int i=0; i<exNum; i++) {
				String exClassNameKey = MDB_SERVICE_EXCEPTION_BASE_KEY+"."+(i+1)+MDB_SERVICE_EXCEPTION_CLASS_NAME_KEY;
				String exJobStatusKey = MDB_SERVICE_EXCEPTION_BASE_KEY+"."+(i+1)+MDB_SERVICE_EXCEPTION_JOB_STATUS_KEY;
				
				String exClassName = componentConfProperties.getProperty(exClassNameKey);
				String exJobStatus = componentConfProperties.getProperty(exJobStatusKey);
				
				if(exClassName == null || exClassName.trim().equals("")) {
					if (logger.isEnableFor("Component0012")) {
						logger.log("Component0012",
								ComponentConst.Component_PROPERTIES_FILE_NAME,
								exClassNameKey,
								exClassName);
					}
					throw new ComponentException("资源文件的设定值错误", ERROR_INVALID_PROPERTIES_VALUE);					
				}
				if(exJobStatus == null || exJobStatus.trim().equals("")) {
					if (logger.isEnableFor("Component0012")) {
						logger.log("Component0012",
								ComponentConst.Component_PROPERTIES_FILE_NAME,
								exJobStatusKey,
								exJobStatus);
					}
					throw new ComponentException("资源文件的设定值错误", ERROR_INVALID_PROPERTIES_VALUE);										
				}
				exceptionClassKeyMap.put(exClassName, exClassNameKey);
				exceptionJobStatusKeyMap.put(exJobStatus, exJobStatusKey);
				
				exceptionJobStatusMap.put(exClassName, exJobStatus);
			}
		}

		 // 从资源文件中获取weblogic提供JNDI的初始化工厂信息
		String javaNamingFactoryInitial = componentConfProperties.getProperty(JAVA_NAMING_FACTORY_INITIAL_KEY);
		if (javaNamingFactoryInitial == null || javaNamingFactoryInitial.trim().equals("")) {
			if (logger.isEnableFor("Component0004")) {
				logger.log("Component0004",
						ComponentConst.Component_PROPERTIES_FILE_NAME,
						JAVA_NAMING_FACTORY_INITIAL_KEY,
						JAVA_NAMING_FACTORY_INITIAL_DEF);
			}
			javaNamingFactoryInitial = JAVA_NAMING_FACTORY_INITIAL_DEF;
		}
		propertiesMap.put(JAVA_NAMING_FACTORY_INITIAL_KEY, javaNamingFactoryInitial);
		
		 // 从资源文件中获取weblogic提供JNDI的URL
		String javaNamingProviderUrl = componentConfProperties.getProperty(JAVA_NAMING_PROVIDER_URL_KEY);
		if (javaNamingProviderUrl == null || javaNamingProviderUrl.trim().equals("")) {
			if (logger.isEnableFor("Component0004")) {
				logger.log("Component0004",
						ComponentConst.Component_PROPERTIES_FILE_NAME,
						JAVA_NAMING_PROVIDER_URL_KEY,
						JAVA_NAMING_PROVIDER_URL_DEF);
			}
			javaNamingProviderUrl = JAVA_NAMING_PROVIDER_URL_DEF;
		}
		propertiesMap.put(JAVA_NAMING_PROVIDER_URL_KEY, javaNamingProviderUrl);
		
		 // 从资源文件中获取weblogic提供JNDI的安全认证的用户名		String javaNamingSecurityPrincipal = componentConfProperties.getProperty(JAVA_NAMING_SECURITY_PRINCIPAL_KEY);
		if (javaNamingSecurityPrincipal == null || javaNamingSecurityPrincipal.trim().equals("")) {
			if (logger.isEnableFor("Component0004")) {
				logger.log("Component0004",
						ComponentConst.Component_PROPERTIES_FILE_NAME,
						JAVA_NAMING_SECURITY_PRINCIPAL_KEY,
						JAVA_NAMING_SECURITY_PRINCIPAL_DEF);
			}
			javaNamingSecurityPrincipal = JAVA_NAMING_SECURITY_PRINCIPAL_DEF;
		}
		propertiesMap.put(JAVA_NAMING_SECURITY_PRINCIPAL_KEY, javaNamingSecurityPrincipal);
		
		 // 从资源文件中获取weblogic提供JNDI的安全认证的密码
		String javaNamingSecurityCredentials = componentConfProperties.getProperty(JAVA_NAMING_SECURITY_CREDENTIALS_KEY);
		if (javaNamingSecurityCredentials == null || javaNamingSecurityCredentials.trim().equals("")) {
			if (logger.isEnableFor("Component0004")) {
				logger.log("Component0004",
						ComponentConst.Component_PROPERTIES_FILE_NAME,
						JAVA_NAMING_SECURITY_CREDENTIALS_KEY,
						JAVA_NAMING_SECURITY_CREDENTIALS_DEF);
			}
			javaNamingSecurityCredentials = JAVA_NAMING_SECURITY_CREDENTIALS_DEF;
		}
		propertiesMap.put(JAVA_NAMING_SECURITY_CREDENTIALS_KEY, javaNamingSecurityCredentials);
		
		 // 从资源文件中获取BRPM访问地址
		String brpmAccessAddress = componentConfProperties.getProperty(BRPM_ACCESS_ADDRESS_KEY);
		if (brpmAccessAddress == null || brpmAccessAddress.trim().equals("")) {
			if (logger.isEnableFor("Component0004")) {
				logger.log("Component0004",
						ComponentConst.Component_PROPERTIES_FILE_NAME,
						BRPM_ACCESS_ADDRESS_KEY,
						null);
			}
		}
		propertiesMap.put(BRPM_ACCESS_ADDRESS_KEY, brpmAccessAddress);
		
		 // 从资源文件中获取BRPM默认机器人账号		String brpmUserName = componentConfProperties.getProperty(BRPM_USER_NAME_KEY);
		if (brpmUserName == null || brpmUserName.trim().equals("")) {
			if (logger.isEnableFor("Component0004")) {
				logger.log("Component0004",
						ComponentConst.Component_PROPERTIES_FILE_NAME,
						BRPM_USER_NAME_KEY,
						null);
			}
		}
		propertiesMap.put(BRPM_USER_NAME_KEY, brpmUserName);
		
		 // 从资源文件中获取BRPM默认机器人账号密码		String brpmUserPassword = componentConfProperties.getProperty(BRPM_USER_PASSWORD_KEY);
		if (brpmUserPassword == null || brpmUserPassword.trim().equals("")) {
			if (logger.isEnableFor("Component0004")) {
				logger.log("Component0004",
						ComponentConst.Component_PROPERTIES_FILE_NAME,
						BRPM_USER_PASSWORD_KEY,
						null);
			}
		}
		propertiesMap.put(BRPM_USER_PASSWORD_KEY, brpmUserPassword);
		
		 //  从资源文件中获取BRPM默认机器人账号token
		String brpmUserToken = componentConfProperties.getProperty(BRPM_USER_TOKEN_KEY);
		if (brpmUserToken == null || brpmUserToken.trim().equals("")) {
			if (logger.isEnableFor("Component0004")) {
				logger.log("Component0004",
						ComponentConst.Component_PROPERTIES_FILE_NAME,
						BRPM_USER_TOKEN_KEY,
						null);
			}
		}
		propertiesMap.put(BRPM_USER_TOKEN_KEY, brpmUserToken);
		
		 // 从资源文件中获取bsaIp地址
		String bsaIpAddress = componentConfProperties.getProperty(BSA_IPADDRESS_KEY);
		if (bsaIpAddress == null || bsaIpAddress.trim().equals("")) {
			if (logger.isEnableFor("Component0004")) {
				logger.log("Component0004",
						ComponentConst.Component_PROPERTIES_FILE_NAME,
						BSA_IPADDRESS_KEY ,
						null);
			}
		}
		propertiesMap.put(BSA_IPADDRESS_KEY, bsaIpAddress);
		
		 // 从资源文件中获取bsa http访问地址
		String bsaAccessAddress = componentConfProperties.getProperty(BSA_ACCESS_ADDRESS_KEY);
		if (bsaAccessAddress == null || bsaAccessAddress.trim().equals("")) {
			if (logger.isEnableFor("Component0004")) {
				logger.log("Component0004",
						ComponentConst.Component_PROPERTIES_FILE_NAME,
						BSA_ACCESS_ADDRESS_KEY,
						null);
			}
		}
		propertiesMap.put(BSA_ACCESS_ADDRESS_KEY, bsaAccessAddress);
		
		 // 从资源文件中获取称为 bladelogic 的用于客户机的 TrustStore 文件, 包含服务器的证书
		String bsaTruststoreFile = componentConfProperties.getProperty(BSA_TRUSTSTORE_FILE_KEY);
		if (bsaTruststoreFile == null || bsaTruststoreFile.trim().equals("")) {
			if (logger.isEnableFor("Component0004")) {
				logger.log("Component0004",
						ComponentConst.Component_PROPERTIES_FILE_NAME,
						BSA_TRUSTSTORE_FILE_KEY,
						null);
			}
		}
		propertiesMap.put(BSA_TRUSTSTORE_FILE_KEY, bsaTruststoreFile);
		
		 // 从资源文件中获取bsa默认公钥密码.
		String bsaTruststorePassword = componentConfProperties.getProperty(BSA_TRUSTSTORE_FILE_PASSWORD_KEY);
		if (bsaTruststorePassword == null || bsaTruststorePassword.trim().equals("")) {
			if (logger.isEnableFor("Component0004")) {
				logger.log("Component0004",
						ComponentConst.Component_PROPERTIES_FILE_NAME,
						BSA_TRUSTSTORE_FILE_PASSWORD_KEY,
						null);
			}
		}
		propertiesMap.put(BSA_TRUSTSTORE_FILE_PASSWORD_KEY, bsaTruststorePassword);
		
		 // 从资源文件中获取bsa机器人默认账号.		String bsaUserName = componentConfProperties.getProperty(BSA_USER_NAME_KEY);
		if (bsaUserName == null || bsaUserName.trim().equals("")) {
			if (logger.isEnableFor("Component0004")) {
				logger.log("Component0004",
						ComponentConst.Component_PROPERTIES_FILE_NAME,
						BSA_USER_NAME_KEY,
						null);
			}
		}
		propertiesMap.put(BSA_USER_NAME_KEY, bsaUserName);
		
		 // 从资源文件中获取bsa机器人账号默认密码.		String basUserPassword = componentConfProperties.getProperty(BSA_USER_PASSWORD_KEY);
		if (basUserPassword == null || basUserPassword.trim().equals("")) {
			if (logger.isEnableFor("Component0004")) {
				logger.log("Component0004",
						ComponentConst.Component_PROPERTIES_FILE_NAME,
						BSA_USER_PASSWORD_KEY,
						null);
			}
		}
		propertiesMap.put(BSA_USER_PASSWORD_KEY, basUserPassword);
		
		 // 从资源文件中获取bsa api连接认证类型.
		String bsaAuthenticationType = componentConfProperties.getProperty(BSA_AUTHENTICATION_TYPE_KEY);
		if (bsaAuthenticationType == null || bsaAuthenticationType.trim().equals("")) {
			if (logger.isEnableFor("Component0004")) {
				logger.log("Component0004",
						ComponentConst.Component_PROPERTIES_FILE_NAME,
						BSA_AUTHENTICATION_TYPE_KEY,
						null);
			}
		}
		propertiesMap.put(BSA_AUTHENTICATION_TYPE_KEY, bsaAuthenticationType);
		
		if (logger.isEnableFor("Component0006")) {
			// 输出设定的值			logger.log("Component0006", FILE_TEMP_FILE_DIR_KEY, propertiesMap.get(FILE_TEMP_FILE_DIR_KEY) );
			logger.log("Component0006", SSH_CHARSET_NAME_KEY, propertiesMap.get(SSH_CHARSET_NAME_KEY) );
			logger.log("Component0006", MDB_DELETE_FLAG_KEY, propertiesMap.get(MDB_DELETE_FLAG_KEY) );
			logger.log("Component0006", MDB_JOB_STATUS_WAIT_KEY, propertiesMap.get(MDB_JOB_STATUS_WAIT_KEY) );
			logger.log("Component0006", MDB_JOB_STATUS_START_KEY, propertiesMap.get(MDB_JOB_STATUS_START_KEY) );
			logger.log("Component0006", MDB_JOB_STATUS_COMPLETE_KEY, propertiesMap.get(MDB_JOB_STATUS_COMPLETE_KEY) );
			logger.log("Component0006", MDB_JOB_STATUS_ERROR_KEY, propertiesMap.get(MDB_JOB_STATUS_ERROR_KEY) );
			logger.log("Component0006", MDB_SERVICE_EXCEPTION_NUM_KEY, exNumStr );
			Iterator<String> it = exceptionJobStatusMap.keySet().iterator();
			while(it.hasNext()) {
				String className = it.next();
				String jobStatus = exceptionJobStatusMap.get(className);
				logger.log("Component0006", exceptionClassKeyMap.get(className), className);
				logger.log("Component0006", exceptionJobStatusKeyMap.get(jobStatus), jobStatus);
			}
			logger.log("Component0006", SVN_ROOT_KEY, propertiesMap.get(SVN_ROOT_KEY) );
			logger.log("Component0006", SVN_USERNAME_KEY, propertiesMap.get(SVN_USERNAME_KEY) );
			logger.log("Component0006", SVN_PASSWORD_KEY, propertiesMap.get(SVN_PASSWORD_KEY) );
			logger.log("Component0006", SVN_HONBAN_PATH_KEY, propertiesMap.get(SVN_HONBAN_PATH_KEY) );
			logger.log("Component0006", JMS_RESULT_FILE_KEY, propertiesMap.get(JMS_RESULT_FILE_KEY) );			
		}
	}

	/**
	 * 获取Temp文件目录
	 * @return Temp文件目录
	 */
	public static File getFileTempDir() {
		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getFileTempDir");
		}
		try {
			String fileTempFileDir = propertiesMap.get(FILE_TEMP_FILE_DIR_KEY);

			File tmpFileDir = null;
			if (fileTempFileDir != null) {
				fileTempFileDir += "/" + ComponentDateFunc.getSystemDate();
				tmpFileDir = new File(fileTempFileDir);
				if (!tmpFileDir.exists()) {
					// 若临时目录不存在则创建该目录
					Boolean retMkdirs = tmpFileDir.mkdirs();
					if (!retMkdirs) {
						if (logger.isDebugEnable()) {
							logger.debug("未作成临时文件目录");
						}
					}
					if (logger.isEnableFor("Component8003")) {
						logger.log("Component8003", fileTempFileDir);
					}
				}
			}

			return tmpFileDir;
		} finally {
			// 输出结束日志
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", "getFileTempDir");
			}
		}
	}

	/**
	 * 获取资源文件中设定的SSH字符集	 * @return SSH字符集	 */
	public static String getSshCharsetName() {
		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getSshCharsetName");
		}
		try {
			return propertiesMap.get(SSH_CHARSET_NAME_KEY);

		} finally {
			// 输出结束日志
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", "getSshCharsetName");
			}
		}
	}

	/**
	 * 获取资源文件中设定的SSH本地用户
	 * @return SSH本地用户
	 */
	public static String getSshLocalUser() {
		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getSshLocalUser");
		}
		try {
			return propertiesMap.get(SSH_LOCAL_USER_KEY);

		} finally {
			// 输出结束日志
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", "getSshLocalUser");
			}
		}
	}

	/**
	 * 获取资源文件中设定的SSH本地用户密码
	 * @return SSH本地用户密码
	 */
	public static String getSshLocalPassword() {
		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getSshLocalPassword");
		}
		try {
			return propertiesMap.get(SSH_LOCAL_PASSWORD_KEY);

		} finally {
			// 输出结束日志
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", "getSshLocalPassword");
			}
		}
	}

	/**
	 * MDB执行状态管理表：取得资源文件中设定的删除标志	 * @return MDB执行状态管理表：删除标志	 */
	public static String getMdbDeleteFlag() {
		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getMdbDeleteFlag");
		}
		try {
			return propertiesMap.get(MDB_DELETE_FLAG_KEY);

		} finally {
			// 输出结束日志
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", "getMdbDeleteFlag");
			}
		}
	}

	/**
	 * MDB执行状态管理表：取得资源文件中设定的job_status（等待）
	 * @return MDB执行状态管理表：job_status（等待）
	 */
	public static String getMdbJobStatusWait() {
		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getMdbJobStatusWait");
		}
		try {
			return propertiesMap.get(MDB_JOB_STATUS_WAIT_KEY);
		} finally {
			// 输出结束日志
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", "getMdbJobStatusWait");
			}
		}
	}

	/**
	 * 从资源文件中获取MDB执行状态管理表：job_status（开始）的值
	 * @return MDB执行状态管理表：job_status（开始）的值
	 */
	public static String getMdbJobStatusStart() {
		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getMdbJobStatusStart");
		}
		try {
			return propertiesMap.get(MDB_JOB_STATUS_START_KEY);
		} finally {
			// 输出结束日志
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", "getMdbJobStatusStart");
			}
		}
	}

	/**
	 * 从资源文件中获取MDB执行状态管理表：job_status（完成）的值	 * @return MDB执行状态管理表：job_status（完成）的值	 */
	public static String getMdbJobStatusComplete() {
		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getMdbJobStatusComplete");
		}
		try {
			return propertiesMap.get(MDB_JOB_STATUS_COMPLETE_KEY);
		} finally {
			// 输出结束日志
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", "getMdbJobStatusComplete");
			}
		}
	}

	/**
	 * 从资源文件中获取MDB执行状态管理表：job_status（异常）的值	 * @return MDB执行状态管理表：job_status（异常）的值	 */
	public static String getMdbJobStatusError() {
		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getMdbJobStatusError");
		}
		try {
			return propertiesMap.get(MDB_JOB_STATUS_ERROR_KEY);
		} finally {
			// 输出结束日志
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", "getMdbJobStatusError");
			}
		}
	}
		
	/**
	 * MDB调用服务类发生异常时，从资源文件中获取异常类的状态MAP
	 * @return 异常类的状态MAP（key:异常类名、value:状态)
	 */
	public static Map<String, String> getExceptionJobStatusMap() {
		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getExceptionJobStatusMap");
		}
		try {
			return exceptionJobStatusMap;
		} finally {
			// 输出结束日志
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", "getExceptionJobStatusMap");
			}			
		}
	}
	
	/**
	 * 从资源文件中获取SVN的根目录
	 * @return SVN根目录	 */
	public static String getSvnUrl() {
		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getSvnUrl");
		}
		try {
			return propertiesMap.get(SVN_URL_KEY);
		} finally {
			// 输出结束日志
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", "getSvnUrl");
			}
		}
	}

	/**
	 * 从资源文件中获取SVN项目文件库的根目录.
	 * @return SVN根目录	 */
	public static String getSvnRoot() {
		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getSvnRoot");
		}
		try {
			return propertiesMap.get(SVN_ROOT_KEY);
		} finally {
			// 输出结束日志
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", "getSvnRoot");
			}
		}
	}

	/**
	 * 获取SVN用户名.
	 * @return SVN用户名.
	 */
	public static String getSvnUsername() {
		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getSvnUsername");
		}
		try {
			return propertiesMap.get(SVN_USERNAME_KEY);

		} finally {
			// 输出结束日志
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", "getSvnUsername");
			}
		}
	}

	/**
	 * 获取SVN密码
	 * @return SVN密码
	 */
	public static String getSvnPassword() {

		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getSvnPassword");
		}

		try {
			return propertiesMap.get(SVN_PASSWORD_KEY);

		} finally {
			// 输出结束日志
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", "getSvnPassword");
			}
		}
	}
	
	/**
	 * 获取生产SVN项目资源文件库目录
	 * @return 生产SVN项目资源文件库目录
	 */
	public static String getSvnHonbanPath() {
		
		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getSvnHonbanPath");
		}

		try {
			return propertiesMap.get(SVN_HONBAN_PATH_KEY);

		} finally {
			// 输出结束日志
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", "getSvnHonbanPath");
			}
		}
	}
	
	/**
	 * 获取SVN文件比较后的比较结果文件存放路径
	 * @return SVN比较结果文件存放路径
	 */
	public static String getSvnResultFileDiff() {
		
		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getSvnResultFileDiff");
		}
		try {
			return propertiesMap.get(SVN_RESULT_FILE_DIFF_KEY);
			
		} finally {
			// 输出结束日志
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", "getSvnResultFileDiff");
			}
		}
	}
	
	/**
	 * 获取JMS队列的JNDI名	 * <UL><B>异常编号：异常内容</B>
	 * <LI>10000001：JMS消息发送的队列名获取失败	 * <LI>10000002：参数错误	 * </UL>
	 * @param queueName 队列名	 * @return JMS队列的JNDI名	 */
	public static String getJmsQueueJndiName(String queueName) {

		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getJmsQueueJndiName");
		}
		
		if(queueName == null) {
			if (logger.isEnableFor("Component0010")) {
				logger.log("Component0010", "null");
			}
			throw new ComponentException("JMS发送消息的消息队列名称错误", ERROR_INVALID_QUEUE_NAME_PARAMETER);				
		}

		if(!propertiesMap.containsKey(queueName)) { 
			String jmsQueueJndiName = componentConfProperties.getProperty(queueName);
			if(jmsQueueJndiName == null) {
				if (logger.isEnableFor("Component0009")) {
					logger.log("Component0009", queueName);
				}
				throw new ComponentException("获取JMS发送消息的消息队列名称失败", ERROR_QUEUE_JNDI_NOT_FOUND);
			}
			
			propertiesMap.put(queueName, jmsQueueJndiName);
			
			if (logger.isEnableFor("Component0006")) {
				logger.log("Component0006", queueName, jmsQueueJndiName);
			}			
		}
		
		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "getJmsQueueJndiName");
		}
		return propertiesMap.get(queueName);		
	}
	
	/**
	 * 获取upload文件处理后存放的目录
	 * @return upload文件处理后存放的目录
	 */
	public static String getJmsResultFile() {
		
		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getJmsResultFile");
		}
		try {
			return propertiesMap.get(JMS_RESULT_FILE_KEY);
			
		} finally {
			// 输出结束日志
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", "getJmsResultFile");
			}
		}
	}
	
	/**
	 * 获取weblogic提供JNDI的初始化工厂信息
	 * @return weblogic提供JNDI的初始化工厂信息
	 */
	public static String getJmsJavaNamingFactoryInitial() {
		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getJmsJavaNamingFactoryInitial");
		}
		try {
			return propertiesMap.get(JAVA_NAMING_FACTORY_INITIAL_KEY);
			
		} finally {
			// 输出结束日志
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", "getJmsJavaNamingFactoryInitial");
			}
		}
	}
	
	/**
	 * 获取weblogic提供JNDI的URL
	 * @return weblogic提供JNDI的URL
	 */
	public static String getJmsJavaNamingProviderUrl() {
		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getJmsJavaNamingProviderUrl");
		}
		try {
			return propertiesMap.get(JAVA_NAMING_PROVIDER_URL_KEY);
			
		} finally {
			// 输出结束日志
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", "getJmsJavaNamingProviderUrl");
			}
		}
	}
	
	/**
	 * 获取weblogic提供JNDI的安全认证的用户名
	 * @return weblogic提供JNDI的安全认证的用户名
	 */
	public static String getJmsJavaNamingSecurityPrincipal() {
		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getJmsJavaNamingSecurityPrincipal");
		}
		try {
			return propertiesMap.get(JAVA_NAMING_SECURITY_PRINCIPAL_KEY);
			
		} finally {
			// 输出结束日志
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", "getJmsJavaNamingSecurityPrincipal");
			}
		}
	}
	
	/**
	 * 获取weblogic提供JNDI的安全认证的密码
	 * @return weblogic提供JNDI的安全认证的密码
	 */
	public static String getJmsJavaNamingSecurityCredentials() {
		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getJmsJavaNamingSecurityCredentials");
		}
		try {
			return propertiesMap.get(JAVA_NAMING_SECURITY_CREDENTIALS_KEY);
			
		} finally {
			// 输出结束日志
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", "getJmsJavaNamingSecurityCredentials");
			}
		}
	}
	
	/**
	 * 获取BRPM 访问地址.
	 * @return IP地址
	 */
	public static String getBrpmAccessAddress() {
		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getBrpmAccessAddress");
		}
		try {
			return propertiesMap.get(BSA_ACCESS_ADDRESS_KEY);
		} finally {
			// 输出结束日志
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", "getBrpmAccessAddress");
			}
		}
	}
	
	/**
	 * 获取BRPM 机器人账号.
	 * @return 账号
	 */
	public static String getBrpmUserName() {
		// 输出开始日志.		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getBrpmUserName");
		}
		try {
			return propertiesMap.get(BRPM_USER_NAME_KEY);
		} finally {
			// 输出结束日志.
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", "getBrpmUserName");
			}
		}
	}
	
	/**
	 * 获取BRPM 机器人账号默认密码.
	 * @return 密码
	 */
	public static String getBrpmUserPassword() {
		// 输出开始日志.		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getBrpmUserPassword");
		}
		try {
			return propertiesMap.get(BRPM_USER_PASSWORD_KEY);
		} finally {
			// 输出结束日志
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", "getBrpmUserPassword");
			}
		}
	}
	
	/**
	 * 获取BRPM token.
	 * @return token
	 */
	public static String getBrpmUserToken() {
		// 输出开始日志.		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getBrpmUserToken");
		}
		try {
			return propertiesMap.get(BRPM_USER_TOKEN_KEY);
		} finally {
			// 输出结束日志
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", "getBrpmUserToken");
			}
		}
	}
	
	/**
	 * 获取bsa IP地址.
	 * @return 地址
	 */
	public static String getBsaIpAddress() {
		// 输出开始日志.		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getBsaIpAddress");
		}
		try {
			return propertiesMap.get(BSA_IPADDRESS_KEY);
		} finally {
			// 输出结束日志
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", "getBsaIpAddress");
			}
		}
	}
	/**
	 * 获取bsa访问地址.
	 * @return 地址
	 */
	public static String getBsaAccessAddress() {
		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getBsaAccessAddress");
		}
		try {
			return propertiesMap.get(BSA_ACCESS_ADDRESS_KEY);
		} finally {
			// 输出结束日志
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", "getBsaAccessAddress");
			}
		}
	}
	/**
	 * 获取bsa称为 bladelogic 的用于客户机的 TrustStore 文件, 包含服务器的证书.
	 * @return 服务器的证书
	 */
	public static String getBsaTruststoreFile() {
		// 输出开始日志.		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getBsaDefaultTruststoreFile");
		}
		try {
			return propertiesMap.get(BSA_TRUSTSTORE_FILE_KEY);
		} finally {
			// 输出结束日志
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", "getBsaDefaultTruststoreFile");
			}
		}
	}
	/**
	 * 获取bsa默认公钥密码.
	 * @return 默认公钥密码
	 */
	public static String getBsaTruststoreFilePassword() {
		// 输出开始日志.		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getBsaTruststoreFilePassword");
		}
		try {
			return propertiesMap.get(BSA_TRUSTSTORE_FILE_PASSWORD_KEY);
		} finally {
			// 输出结束日志
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", "getBsaTruststoreFilePassword");
			}
		}
	}
	/**
	 * 获取bsa机器人账号.
	 * @return 账号
	 */
	public static String getBsaUserName() {
		// 输出开始日志.		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getBsaUserName");
		}
		try {
			return propertiesMap.get(BSA_USER_NAME_KEY);
		} finally {
			// 输出结束日志
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", "getBsaUserName");
			}
		}
	}
	/**
	 * 获取bsa机器人账号默认密码.
	 * @return password
	 */
	public static String getBsaUserPassword() {
		// 输出开始日志.		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getBsaUserPassword");
		}
		try {
			return propertiesMap.get(BSA_USER_PASSWORD_KEY);
		} finally {
			// 输出结束日志
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", "getBsaUserPassword");
			}
		}
	}
	/**
	 * 获取BSA连接方式.
	 * @return 方式
	 */
	public static String getBsaAuthenticationType() {
		// 输出开始日志.		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getBsaAuthenticationType");
		}
		try {
			return propertiesMap.get(BSA_AUTHENTICATION_TYPE_KEY);
		} finally {
			// 输出结束日志
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", "getBsaAuthenticationType");
			}
		}
	}
	
	
}///:~
