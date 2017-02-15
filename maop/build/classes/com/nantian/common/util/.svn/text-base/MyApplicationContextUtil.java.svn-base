package com.nantian.common.util;

import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.stereotype.Component;

/**
 * @author <a href="mailto:donghui@nantian.com.cn">donghui</a>
 * 
 */
@Component
public class MyApplicationContextUtil implements ApplicationContextAware{
	
	//全局springcontext,解决异步反射类注入资源为NULL的问题
	// 同时设置为静态资源是为提高性能，因为都实现spring该接口会影响性能
	public static ApplicationContext springContext;

	@Override
	public void setApplicationContext(ApplicationContext context)
			throws BeansException {
		springContext = context;
	}


}
