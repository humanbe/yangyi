package com.nantian.common.filter;

import java.lang.reflect.Method;

import org.springframework.aop.ThrowsAdvice;

import com.nantian.component.log.Logger;

public class ExceptionAdvisor implements ThrowsAdvice {
	/** 日志输出 */
	private static Logger logger = Logger.getLogger(ExceptionAdvisor.class);
	
	public void afterThrowing(Method method, Object[] args, Object target, 
			Exception ex) throws Throwable{
		if (logger.isEnableFor("LogAdvisor0099")) {
			logger.log("LogAdvisor0099", ex, target.getClass().getName(), method.getName());
		}
		
	}
}
