package com.nantian.common.util;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.LineNumberReader;
import java.io.UnsupportedEncodingException;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Type;
import java.net.Inet4Address;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.sql.Time;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import net.sf.json.JSONNull;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.support.MessageSourceAccessor;

import com.nantian.common.exception.ErrorException;
import com.nantian.component.log.Logger;
import com.nantian.jeda.FieldType;

/**
 * @author <a href="mailto:donghui@nantian.com.cn">donghui</a>
 * 
 */
public class ComUtil {
	
	/**
	 * Logger
	 */
	private static Logger logger =  Logger.getLogger(ComUtil.class);
	
	/** 类名*/
	private static final String className = "ComUtil";
	
	/** 国际化资源 */
	@Autowired
	private static MessageSourceAccessor messages;
	
	public static String osName = null;
	public static String charset = null;
	public static boolean isWindows = false;
	public static String systemStartTime = null;	//系统资源开始时间

	public static String systemEndTime = null;		//系统资源结束时间
	public static String weblogicStartTime = null;	//weblogic资源开始时间

	public static String weblogicEndTime = null;	//weblogic资源结束时间
	public static String netResrcStartTime = null;	//网络资源开始时间

	public static String netResrcEndTime = null;	//网络资源结束时间
	public static String hoursStartTime = null; 	//七天分小时小时开始时间
	public static String hoursEndTime = null;//七天分小时小时结束时间

	
	public static String hoursStartTimeRealTime = null;//实时分小时累计交易情况

	public static String hoursEndTimeRealTime = null;//实时分小时累计交易情况

	public static List<String> systemTimeList = new ArrayList<String>();//系统资源时间列表
	public static List<String> weblogicTimeList = new ArrayList<String>();//weblogic资源时间列表
	public static List<String> netResrcTimeList = new ArrayList<String>();//网络资源时间列表
	public static List<String> hoursList = new ArrayList<String>();//七天分小时小时列表

	public static List<String> hoursListRealTime = new ArrayList<String>();//实时分小时累计交易情况小时列表
	
	static {
		try{
			osName = System.getProperty("os.name");
			charset = System.getProperty("sun.jnu.encoding");
			if(osName.toUpperCase().startsWith("WINDOWS")){
				isWindows = true;
			}
			
			long lStartDate = 0;
			long systemEndlDate = 0;
			long weblogicEndlDate = 0;
			long netResrcEndlDate = 0;
			String strStartHour = null;
			String strDate = null;
			Date tempDate = null;
			messages = (MessageSourceAccessor)MyApplicationContextUtil.springContext.getBean("message");
			// 获取系统资源、weblogic资源、网络资源五分钟（开始、结束）时间
			systemStartTime = messages.getMessage("systemStartTime");
			systemEndTime = messages.getMessage("systemEndTime");
			weblogicStartTime = messages.getMessage("weblogicStartTime");
			weblogicEndTime = messages.getMessage("weblogicEndTime");
			netResrcStartTime = messages.getMessage("netResrcStartTime");
			netResrcEndTime = messages.getMessage("netResrcEndTime");
			hoursStartTime = messages.getMessage("hoursStartTime");
			hoursEndTime = messages.getMessage("hoursEndTime");
			hoursStartTimeRealTime = messages.getMessage("hoursStartTimeRealTime");
			hoursEndTimeRealTime = messages.getMessage("hoursEndTimeRealTime");
			

			SimpleDateFormat sf = new SimpleDateFormat("HH:mm:ss"); 	//定义时间格式
			//系统资源（07:06当日-07:01隔日）

			Date systemStartDT = Time.valueOf(systemStartTime);
			Date systemEndDT = Time.valueOf(systemEndTime);
			//当日weblogic资源（00:01当日-23:56当日）

			Date weblogicStartDT = Time.valueOf(weblogicStartTime);	
			Date weblogicEndDT = Time.valueOf(weblogicEndTime);
			//当日网络资源（00:01当日-23:56当日）

			Date netResrcStartDT = Time.valueOf(netResrcStartTime);
			Date netResrcEndDT = Time.valueOf(netResrcEndTime);
			
			// 系统资源时间取得07:06 ~ 07:01
			lStartDate = systemStartDT.getTime();
			systemEndlDate = systemEndDT.getTime();
			while (lStartDate <= systemEndlDate) {
				strDate = sf.format(new Date(lStartDate));
				systemTimeList.add(strDate.substring(0, 5));
				tempDate = Time.valueOf(strDate);
				lStartDate = tempDate.getTime() + (1000L * 60L * 5L);
			}
			
			// 当日weblogic资源时间取得00:01当日-23:56当日
			lStartDate = weblogicStartDT.getTime();
			weblogicEndlDate = weblogicEndDT.getTime();
			while (lStartDate <= weblogicEndlDate) {
				strDate = sf.format(new Date(lStartDate));
				weblogicTimeList.add(strDate.substring(0, 5));
				tempDate = Time.valueOf(strDate);
				lStartDate = tempDate.getTime() + (1000L * 60L * 5L);
			}

			// 当日网络资源时间的取得00:01当日-23:56当日
			lStartDate = netResrcStartDT.getTime();
			netResrcEndlDate = netResrcEndDT.getTime();
			while (lStartDate <=netResrcEndlDate) {
				strDate = sf.format(new Date(lStartDate));
				netResrcTimeList.add(strDate.substring(0, 5));
				tempDate = Time.valueOf(strDate);
				lStartDate = tempDate.getTime() + (1000L * 60L * 5L);
			}
			
			strStartHour = hoursStartTime;
			while(Integer.parseInt(strStartHour) <= Integer.parseInt(hoursEndTime)){
				if(strStartHour.length() == 1){
					hoursList.add("0".concat(strStartHour));
				}else{
					hoursList.add(strStartHour);
				}
				strStartHour = String.valueOf(Integer.parseInt(strStartHour)+1);
			}
			
			strStartHour = hoursStartTimeRealTime;
			while(Integer.parseInt(strStartHour) <= Integer.parseInt(hoursEndTimeRealTime)){
				if(strStartHour.length() == 1){
					hoursListRealTime.add("0".concat(strStartHour));
				}else{
					hoursListRealTime.add(strStartHour);
				}
				strStartHour = String.valueOf(Integer.parseInt(strStartHour)+1);
			}
		}catch(Exception e){
			e.printStackTrace();
		}
	}
	
	/**
	 * 返回当前正在执行的方法名
	 * 
	 * @return 方法名	 */
	public static String getCurrentMethodName() {
		if(osName.startsWith("Windows") || osName.startsWith("Linux")){
			return Thread.currentThread().getStackTrace().clone()[2].getMethodName();
		}else{
			return Thread.currentThread().getStackTrace().clone()[3].getMethodName();
		}
	}
	
	/**
	 * 判断字符串是否为空并返回char类型数据
	 * @param str
	 * @return
	 */
	public static Character changeToChar(String str){
		if(str == null|| str.equals("")){
			return null;
		}
		return str.charAt(0);
	}
	
	/**
	 * 判断是否NULL为	 * @param obj
	 * @return
	 */
	public static String checkNull(Object obj){
		return (null == obj || ""== obj) ? "" : obj.toString().trim();
	}

	/**
	 *判断对象是否JSONNull
	 * @param obj
	 * @return
	 */
	public static String checkJSONNull(Object obj){
		return obj instanceof JSONNull ? "" : obj.toString().trim();
	}


	/**
	 * 读取文件总行数	 * @param file
	 * @return totalLines 总行数	 * @throws IOException
	 */
	public static int getFileTotalLines(String file) throws IOException{
		int totalLines = 0;
		FileReader in = new FileReader(file);
        LineNumberReader reader = new LineNumberReader(in);
        
        while(reader.readLine() != null){
        	totalLines ++;
        }
        
        reader.close();
        in.close();
        return totalLines;
	}
	
	/**
	 * 删除临时文件
	 * @param filePath 文件目录
	 */
	public static void deleteFile(String filePath){
		File file = new File(filePath);
		//删除
		if(file.exists()){
			file.delete();
		}
	}
	
	/**
	 * 替换回车换行
	 * @param inputStr 待替换字符串
	 * @param repStr 替换后的字符
	 */
	public static String replaceCrLf(String inputStr,String repStr){
    	if (inputStr==null){
    		return "";
    	}
    	String rtnSt = inputStr.replace("\r\n", repStr);
    	
    	return rtnSt;
	}
	
	/**
	 * 中文url加密
	 * @param str 要加密的字符串
	 * @param charset 编码
	 * @return 加密后的字符串
	 * @throws UnsupportedEncodingException
	 */
	public static String encodeCNString(String str, String charset) throws UnsupportedEncodingException{
		str = URLEncoder.encode(str, charset);
		//把空格替换回来		str = str.replaceAll("\\+", "%20");
		return str;
	}
	
	/**
	 * 中文url解密
	 * @param str 要解密的字符串

	 * @param charset 编码
	 * @return 解密后的字符串

	 * @throws UnsupportedEncodingException
	 */
	public static String decodeCNString(String str, String charset) throws UnsupportedEncodingException{
		str = URLDecoder.decode(str, charset);
		
		return str;
	}
	
	/**
	 * 组合路径
	 * @param 组合的路径参数
	 * @return 以[/]连接的路径
	 */
	public static String join(String...paths) {
			
		// 初始化		StringBuilder result = new StringBuilder();
		int pathLen = 0;
		
		// 若参数为空，则返回空
		if (paths == null || (pathLen=paths.length) == 0) {
			return "";
		}
		
		// 输出日志
		if (logger.isDebugEnable()) {
			logger.debug(LogConst.DEBUG_LOOP_NUM_VAL, className, getCurrentMethodName(), 0, paths[0]);
		}
		
		// 连接路径
		if (!StringUtil.isEmpty(paths[0])){
			result.append(paths[0]);
		}
		boolean appendSeparator = (!StringUtil.isEmpty(paths[0]) && !CommonConst.SLASH.equals(paths[0]));
		for (int i=1; i<pathLen; i++){
			// 输出日志
			if (logger.isDebugEnable()) {
				logger.debug(LogConst.DEBUG_LOOP_NUM_VAL, className, getCurrentMethodName(), i, paths[i]);
			}
			
			// 若参数为空，则处理下一个			if (StringUtil.isEmpty(paths[i]) || CommonConst.SLASH.equals(paths[i])){
				continue;
			}
			
			// 第一个参数不为【/】，则连接CommonConst.SLASH
			if (appendSeparator) {
				result.append(CommonConst.SLASH);
			}
			
			result.append(paths[i]);
			
			appendSeparator = !CommonConst.SLASH.equals(paths[i]);
		}
			
		return result.toString();
	}
	
	
    /**
     * 执行操作系统命令
     * @param funcId 功能ID
     * @param cmd 命令
     * @param workPath 工作目录
     * @param stdOut 标准输出
     * @param stdErr 标准异常输出
     * @return res 实行结果(正常：0  异常：0以外)
     * @throws Throwable Throwable
     */
    public static int doOsbtCmdExec(String funcId, String cmd, String workPath,
            StringBuffer stdOut, StringBuffer stdErr) throws Throwable {
    	
    	String CMD = "命令";
    	String WORK_PATH = "工作目录";
    	
        String STD_OUT = "标准输出";

        String STD_ERR = "标准异常输出";

        // 输出开始日志        if (logger.isDebugEnable()) {
            logger.debug(LogConst.DEBUG015, "funcId", funcId, "cmd", cmd, "workPath", workPath,
                    "stdOut", stdOut, "stdErr", stdErr);
        }
        // 参数检查 
        ErrorException errorException = new ErrorException();
        // DebugLog
        if (logger.isDebugEnable()) {
            logger.debug(LogConst.DEBUG001, "cmd", cmd);
        }
        // 命令cmd isEmpty()则ErrorException中添加异常信息
        if (StringUtil.isEmpty(cmd)) {
            errorException.addMessage(funcId + MessageConst.M_5008, CMD);
        }
        // DebugLog
        if (logger.isDebugEnable()) {
            logger.debug(LogConst.DEBUG001, "workPath", workPath);
        }
        // 工作目录 isEmpty()则ErrorException中添加异常信息
        if (StringUtil.isEmpty(workPath)) {
            errorException.addMessage(funcId + MessageConst.M_5008, WORK_PATH);
        }
        // DebugLog
        if (logger.isDebugEnable()) {
            logger.debug(LogConst.DEBUG001, "stdOut", stdOut);
        }
        // 标准输出 = NULL则ErrorException中添加异常信息
        if (stdOut == null) {
            errorException.addMessage(funcId + MessageConst.M_5008, STD_OUT);
        }
        // DebugLog
        if (logger.isDebugEnable()) {
            logger.debug(LogConst.DEBUG001, "stdErr", stdErr);
        }
        // 标准异常输出 = NULL则ErrorException中添加异常信息
        if (stdErr == null) {
            errorException.addMessage(funcId + MessageConst.M_5008, STD_ERR);
        }
        // DebugLog
        if (logger.isDebugEnable()) {
            logger.debug(LogConst.DEBUG001, "errorException.hasHappened()", errorException
                    .hasHappened());
        }
        // 若存在异常则设定异常值"21"
        if (errorException.hasHappened()) {

            errorException.setErrorCode(CommonConst.ERR_CD_PARAMETER);
            // 抛出异常
            throw errorException;
        }

        // 空格分割命令
        String[] cmdArrays = cmd.split(CommonConst.SPACE);
        // process对象
        Process process = null;
        // 返回值
        int res = 0;

        InputStreamReader inputStreamReader = null;
        BufferedReader br1 = null;
        InputStreamReader errorStreamReader = null;
        BufferedReader br2 = null;
        
        
        try {
            // new ProcessBuilder
            ProcessBuilder builder = new ProcessBuilder(cmdArrays);
            // 创建目录
            builder.directory(new File(workPath));
            // 启动
            process = builder.start();
            // DebugLog
            if (logger.isDebugEnable()) {
                logger.debug(LogConst.DEBUG001, "process", process);
            }
            // process对象已经存在
            if (process != null) {
                // 获取InputStream
                InputStream inputStream = process.getInputStream();
                // 获取InputStreamReader
                inputStreamReader = new InputStreamReader(inputStream);
                // 获取BufferedReader
                br1 = new BufferedReader(inputStreamReader);
                String inputLine = CommonConst.EMPTY;
                // br1 readLine != NULL
                if (logger.isDebugEnable()) {
                    logger.debug(LogConst.DEBUG_LOOP_START);
                }
                while ((inputLine = br1.readLine()) != null) {
                    if (logger.isDebugEnable()) {
                        logger.debug(LogConst.DEBUG_LOOP_ITER_01, "inputLine", inputLine);
                    }
                    // DebugLog
                    if (logger.isDebugEnable()) {
                        logger.debug(LogConst.DEBUG001, "stdOut.toString()", stdOut.toString());
                    }
                    if (!StringUtil.isEmpty(stdOut.toString())) {
                        // 换行信息
                        stdOut.append(CommonConst.LINE_FEED);
                    }
                    // 输出到标准输出
                    stdOut.append(inputLine);
                }
                if (logger.isDebugEnable()) {
                    logger.debug(LogConst.DEBUG_LOOP_END);
                }

                // 调用process 的getErrorStream获取异常流信息
                InputStream errorStream = process.getErrorStream();
                // 获取InputStreamReader
                errorStreamReader = new InputStreamReader(errorStream);
                // 获取BufferedReader
                br2 = new BufferedReader(errorStreamReader);
                String errorLine = CommonConst.EMPTY;
                if (logger.isDebugEnable()) {
                    logger.debug(LogConst.DEBUG_LOOP_START);
                }
                // br2 readLine != NULL
                while ((errorLine = br2.readLine()) != null) {
                    if (logger.isDebugEnable()) {
                        logger.debug(LogConst.DEBUG_LOOP_ITER_01, "errorLine", errorLine);
                    }
                    // DebugLog
                    if (logger.isDebugEnable()) {
                        logger.debug(LogConst.DEBUG001, "stdErr.toString()", stdErr.toString());
                    }
                    if (!StringUtil.isEmpty(stdErr.toString())) {
                        // 换行信息
                        stdErr.append(CommonConst.LINE_FEED);
                    }
                    // 添加标准异常输出
                    stdErr.append(errorLine);
                }
                if (logger.isDebugEnable()) {
                    logger.debug(LogConst.DEBUG_LOOP_END);
                }
                // 执行process waitFor
                process.waitFor();
            }
        } finally {
            // DebugLog
            if (logger.isDebugEnable()) {
                logger.debug(LogConst.DEBUG001, "process", process);
            }
            // process对象存在
            if (process != null) {
                // 调用process的exitValue获取执行结果
                res = process.exitValue();
            }
            if (br1 != null) {
            	br1.close();
            } 
            if (br2 != null) {
            	br2.close();
            }
            if (inputStreamReader != null) {
            	inputStreamReader.close();
            }
            if (errorStreamReader != null) {
            	errorStreamReader.close();
            } 
        }
        // 输出结束日志
        if (logger.isDebugEnable()) {
            logger.debug(LogConst.DEBUG021, "res", res);
        }

        return res;
    }
    
    /**
     * 获取目录下所有文件
     * @param 指定目录
     * @param 文件保存列表
     * @param 需要从文件保存列表中过滤掉的文件，可以为NULL
     * @throws Throwable Throwable
     */
	public static void printFNByFolder(File file, List<File> fileNames, String filterFile){
		
		// 目录则递归处理
		if(file.isDirectory()){
			File[] arrFile = file.listFiles();
			for (File f : arrFile) {
				printFNByFolder(f,fileNames,filterFile);
			}
		}
		
		// 文件则输出		if(file.isFile() && !file.getName().equals(filterFile)){
			fileNames.add(file);
		}
		
	}
	
	/**
	 * 通过接口的路径来取得一个接口实现类的对象	 * @param key 接口的路径字符串
	 * @param objects 可变长对象	 * @return
	 */
	public static  Object getObject(String key, Object ... objects){
		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getObject");
		}

		Class<?> [] clazzArray = new Class[objects.length];
		
		for(int i = 0; i < objects.length; i++){
			clazzArray[i] = objects[i].getClass();
		}
		
		Class<?> clazz;
		Object obj = null;
		String className = key;
		
		try {
			clazz = Class.forName(className);
			obj = clazz.getConstructor(clazzArray).newInstance(objects);
		} catch (Exception e) {
			e.printStackTrace();
			// 输出异常结束日志
			if (logger.isEnableFor("Component0099")) {
				logger.log("Component0099", "doProcess");
			}
		}
		
		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doProcess");
		}
		return obj;
	}

	/**
	 * 把QueryParamsVo中设值的字段值保存到paramsMap中	 * @param Ojbect vo
	 * @throws UNCAUGHT_EXCEPTION
	 */
	public static Map<String, Object> getQueryMap(Object vo) throws Exception{
		
		Map<String, Object> map = new HashMap<String, Object>();
		try {
			Field[] fields = vo.getClass().getDeclaredFields();
			for (Field field : fields) {
				String fieldName = field.getName();
				String firstLetter= fieldName.substring(0,1).toUpperCase();
				String getMethodName="get"+firstLetter+fieldName.substring(1);
				Method getMethod = vo.getClass().getMethod(getMethodName, new Class[]{});
				Object value = getMethod.invoke(vo);
				if(null != value){
					Type rerutnType = getMethod.getReturnType();
					if (rerutnType.toString().indexOf("String") != -1) {
						if(!fieldName.equalsIgnoreCase("startDate") && !fieldName.equalsIgnoreCase("endDate")){
							map.put(fieldName, "%" + value.toString() + "%");
						}else{
							map.put(fieldName, value.toString());
						}
					} else if (rerutnType.toString().indexOf(FieldType.INTEGER) != -1) {
						map.put(fieldName, Integer.valueOf(value.toString()));
					} else if (rerutnType.toString().indexOf(FieldType.LONG) != -1) {
						map.put(fieldName, Long.valueOf(value.toString()));
					} else if (rerutnType.toString().indexOf(FieldType.DOUBLE) != -1) {
						map.put(fieldName, Double.valueOf(value.toString()));
					} else if (rerutnType.toString().indexOf(FieldType.DATE) != -1) {
						SimpleDateFormat format = new SimpleDateFormat("yyyyMMdd");
						map.put(fieldName, format.parse(value.toString()));
					} else if (rerutnType.toString().indexOf(FieldType.TIME) != -1) {
						SimpleDateFormat format = new SimpleDateFormat("HH:mm:ss");
						map.put(fieldName, format.parse(value.toString()));
					} else if (rerutnType.toString().indexOf(FieldType.TIMESTAMP) != -1) {
						SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
						map.put(fieldName, format.parse(value.toString()));
					}
				}
			}
		} catch (ParseException e) {
			e.printStackTrace();
			throw e;
		}
		return map;
	}
	
    /**
     * 获取无数据信息     * @param 科目名     */
	public static String getMessage(String msg){
		return "无".concat(msg).concat("数据");
	}
	
	/**
	 * 获取本机IP(linux下方法，但多IP时取出的ip不固定)
	 * @throws SocketException
	 */
	@SuppressWarnings("rawtypes")
	public static String getLocalHostIp() throws SocketException{
		Enumeration allNetInterfaces = NetworkInterface.getNetworkInterfaces();
		InetAddress ip = null;
		String hostIp = null;
		boolean breakFlag = false;
		while (allNetInterfaces.hasMoreElements())
		{
			NetworkInterface netInterface = (NetworkInterface) allNetInterfaces.nextElement();
			if(netInterface.isLoopback() || netInterface.isVirtual()){
				continue;
			}
			Enumeration addresses = netInterface.getInetAddresses();
			while (addresses.hasMoreElements())
			{
				ip = (InetAddress) addresses.nextElement();
				if (ip != null && ip instanceof Inet4Address)
				{
					hostIp = ip.getHostAddress();
					breakFlag = true;
					break;
				} 
			}
			if(breakFlag) break;
		}
		return hostIp;
	}
	 /**
     * 获取服务器iP
     * @param request
     */
	public static String getServerIp(HttpServletRequest request){
		if(null==request.getHeader("x-forwarder-for")&&("").equals(request.getHeader("x-forwarder-for"))){
			return null;
		}else{
			return request.getHeader("x-forwarder-for");
		}
	}
	
	 /**
     * 生成日志文件
     * @param 错误日志信息errMsg
     * @param 日志路径 pathType 
     *         0 :应用系统同步错误日志路径      1 :服务器信息同步错误日志路径        2 :操作用户信息同步错误日志路径 
	 * @throws IOException 
     */
	public  static String  writeLogFile(String errMsg,int pathType) throws IOException{
		String logday=new SimpleDateFormat("yyyyMMdd").format(new Date());
		String time=new SimpleDateFormat("HHmmss").format(new Date());
		String logname="";
		String  logPath = "";
		switch(pathType){
		case 0: logname="appsysCodeError_"+time+".txt";
		         break;
		case 1: logname="serverError_"+time+".txt";
                 break;
		case 2: logname="osUserError_"+time+".txt";
                break;
		}
		
		if(isWindows){
			
			switch(pathType){
			case 0: logPath=messages.getMessage("platform.appsysLogPathForWindow").concat(File.separator).concat(logday);
			         break;
			case 1: logPath=messages.getMessage("platform.serverLogPathForWindow").concat(File.separator).concat(logday);
	                 break;
			case 2: logPath=messages.getMessage("platform.osuserLogPathForWindow").concat(File.separator).concat(logday);
	                break;
			}
			 
		    
		}else{
			
			switch(pathType){
			case 0: logPath=messages.getMessage("platform.appsysLogPathForLinux").concat(File.separator).concat(logday);
			         break;
			case 1: logPath=messages.getMessage("platform.serverLogPathForLinux").concat(File.separator).concat(logday);
	                 break;
			case 2: logPath=messages.getMessage("platform.osuserLogPathForLinux").concat(File.separator).concat(logday);
	                break;
			}
			 
		}
		
		File outDir = new File(logPath);
		if (!outDir.exists()) {
			outDir.mkdirs(); 
		}
		logPath =logPath.concat(File.separator).concat(logname);
		
		FileWriter writer =new FileWriter(logPath);
		BufferedWriter bw =new BufferedWriter(writer);
		errMsg.replaceAll("<br>", "\n");
		bw.write(errMsg.toString());
		bw.close();
		writer.close();
		return logPath;
	}
	
	
	/**
	 * 比较两个实例所有字段的值是否相同
	 * @param Ojbect voFirst
	 * @param Ojbect voSecond
	 * @throws NoSuchMethodException 
	 * @throws SecurityException 
	 * @throws InvocationTargetException 
	 * @throws IllegalAccessException 
	 * @throws IllegalArgumentException 
	 * @return 两个实例所有字段值相等时，返回true , 否则，返回false 
	 */
	public static Boolean compareTwoObjects(Object voFirst,Object voSecond) 
			throws SecurityException, NoSuchMethodException, IllegalArgumentException, IllegalAccessException, InvocationTargetException{
		Field[] fieldsFirst = voFirst.getClass().getDeclaredFields();
		int t = 0 ;
		for (Field field : fieldsFirst) {
			String fieldName = field.getName();
			String firstLetter= fieldName.substring(0,1).toUpperCase();
			String getMethodName="get"+firstLetter+fieldName.substring(1);
			Method getMethod = voFirst.getClass().getMethod(getMethodName, new Class[]{});
			Object valueFirst = getMethod.invoke(voFirst);
			Object valueSecond = getMethod.invoke(voSecond);
			if((null==valueFirst && null==valueSecond)
					|| (null!=valueFirst && null!=valueSecond && valueFirst.equals(valueSecond))){
				t++;
			}
		}
		if(t == fieldsFirst.length){
			return true ;
		}else return false;
	}
	
	
	
}///~:
