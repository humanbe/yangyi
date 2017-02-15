package com.nantian.common.filter;

import javax.servlet.http.HttpServletResponse;

import org.aopalliance.intercept.MethodInterceptor;
import org.aopalliance.intercept.MethodInvocation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.NoSuchMessageException;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.ui.ModelMap;

import com.nantian.component.log.Logger;

public class ExceptionInterceptor implements MethodInterceptor {

	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	
	@Override
	public Object invoke(MethodInvocation invocation) throws Throwable {
		final Logger logger = Logger.getLogger(invocation.getThis().getClass());
		Object returnVal = null;
		try {
			returnVal = invocation.proceed();
		} catch (Exception e) {
			if (logger.isEnableFor("Component1031")) {
				logger.log("Component1031", e.getMessage());
			}
			
			Object[] args = invocation.getArguments();
			
			for(int i = 0 ; i < args.length ; i ++ ){
				if(args[i] != null && (args[i].getClass().getName().indexOf("ModelMap") != -1 
						|| args[i].getClass().getName().indexOf("Response") != -1)){
					String errMessage =  e.toString();
					//根据取的的异常，到配置文件ExceptionMessage.properties找其对应的描述信息					String ExceptionMessage = null;
					String  OtherExceptionMessage = null;
					try {
						if(null != e.getCause() && null != e.getCause().getCause()){
							ExceptionMessage = messages.getMessage(e.getCause().getCause().getClass().getSimpleName());
							if(ExceptionMessage.indexOf("{0}") != -1){
								//有参数的异常类信息
								ExceptionMessage = messages.getMessage(e.getCause().getCause().getClass().getSimpleName(), new Object[]{e.getCause().getCause().getLocalizedMessage()});
							}
						}else{
							ExceptionMessage = messages.getMessage(e.getClass().getSimpleName());
							if(ExceptionMessage.indexOf("{0}") != -1){
								//有参数的异常类信息								ExceptionMessage = messages.getMessage(e.getClass().getSimpleName(), new Object[]{e.getLocalizedMessage()});
							}
						}
					} catch (NoSuchMessageException ne) {
						OtherExceptionMessage = messages.getMessage("Exception"); 
					}
					//如果异常在配置文件中无定义则返回指定的Exception所对应的描述信息					errMessage = (String)(ExceptionMessage != null ? ExceptionMessage : OtherExceptionMessage);
					
					if(args[i].getClass().getName().indexOf("ModelMap") != -1){
						ModelMap modelMap = (ModelMap)args[i];
						modelMap.addAttribute("success", Boolean.FALSE);
						modelMap.addAttribute("error", errMessage);
						return modelMap;
					}else{
						HttpServletResponse response = (HttpServletResponse)args[i];
						response.setHeader("error", errMessage);
						return null;
					}
				}
			}
		}
		return returnVal;
	}

}
