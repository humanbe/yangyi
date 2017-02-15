package com.nantian.component.bsa;

import java.net.InetAddress;
import java.net.SocketException;
import java.net.UnknownHostException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Service;

import com.nantian.component.log.Logger;

/**
 * BSA Service工具类 * @author <a href="mailto:donghui@nantian.com.cn">donghui</a>
 *
 */
@Service
public class BsaService {

	/** 日志输出 */
	final Logger logger = Logger.getLogger(BsaService.class);
	
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	
	/**
	 * 通过域名获取BSA的IP地址
	 * @throws SocketException
	 */
	public String getBsaWebServicesUrl(){
		String host = messages.getMessage("bsa.ipAddress");
		StringBuilder url = new StringBuilder();
		InetAddress[] address;
		try {
			address = InetAddress.getAllByName(host);
			if(null != address){
				url.append("https://").append(address[0].getHostAddress()).append(":9843/services/LoginService");
			}else{
				url.append("https://").append(host).append(":9843/services/LoginService").toString();
			}
		} catch (UnknownHostException e) {
			logger.log("Common0004", "getBsaWebServicesUrl=" + e.getMessage());
			url.append("https://").append(host).append(":9843/services/LoginService").toString();
		}
		return url.toString();
	}
	
	
}///:~
