package com.nantian.common.filter;

import org.aopalliance.intercept.MethodInterceptor;
import org.aopalliance.intercept.MethodInvocation;

import com.nantian.component.log.Logger;

public class AroundAdvisor implements MethodInterceptor {
	/** 日志输出 */
	private static Logger logger = Logger.getLogger(AroundAdvisor.class);
	@Override
	public Object invoke(MethodInvocation invocation) throws Throwable {
		if (logger.isEnableFor("LogAdvisor0001")) {
			logger.log("LogAdvisor0001", invocation.getThis().getClass(), invocation.getMethod().getName());
		}
		
		Object returnVal = invocation.proceed();
		
		if (logger.isEnableFor("LogAdvisor0002")) {
			logger.log("LogAdvisor0002", invocation.getThis().getClass(), invocation.getMethod().getName());
		}
		
		return returnVal;
	}

}
