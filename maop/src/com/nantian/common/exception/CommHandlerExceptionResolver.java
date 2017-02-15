package com.nantian.common.exception;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.servlet.HandlerExceptionResolver;
import org.springframework.web.servlet.ModelAndView;

public class CommHandlerExceptionResolver implements HandlerExceptionResolver {
	protected static Logger logger =null ; 
	protected static String className =null ;
	private String defaultErrorView;
	public String getDefaultErrorView() {
		return defaultErrorView;
	}
	public CommHandlerExceptionResolver() {
		super();
		className = getClass().getName();
	    logger=LoggerFactory.getLogger(className);
	}
	public void setDefaultErrorView(String defaultErrorView) {
		this.defaultErrorView = defaultErrorView;
	}
	public ModelAndView resolveException(HttpServletRequest request, HttpServletResponse response,
			Object handler, Exception ex) {
		logger.warn("Handle exception at Class: "+ex.getClass().getSimpleName()+" Cause:" + ex.toString());
		ex.printStackTrace();
		Map<String, Object> model = new HashMap<String, Object>();
		model.put("ex", ex.getClass().getSimpleName());
		model.put("error", ex.getMessage());
		return new ModelAndView(defaultErrorView, model);
	}
}