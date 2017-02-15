package com.nantian.component.com;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

import com.nantian.common.util.ComUtil;
import com.nantian.component.log.Logger;


/**
 * 获取资源文件信息
 * @author dong
 * 
 */
public class ComponentObject {
	
	/**
	 * Logger
	 */
	private static Logger logger =  Logger.getLogger(ComponentObject.class);
	/**
	 * 构造函数
	 */
	private ComponentObject(){}
	
	/**
	 * 读取资源文件
	 * <P>
	 * @param arg
	 * @return Properties 对象
	 */
	 public static Object getInstance(String arg) {
			// 输出开始日志
			if (logger.isEnableFor("Component0001")) {
				logger.log("Component0001", ComUtil.getCurrentMethodName());
			}
			Properties props = new Properties();
			InputStream is = ComponentObject.class.getResourceAsStream("/resources/" + arg);
			try {
				
				props.load(is);
				
			} catch (IOException e) {
				logger.log("Component0015", "Load properties configuration failed", arg);
			}
			
			// 输出结束日志
			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", ComUtil.getCurrentMethodName());
			}
			
			return props;
	 }
}
