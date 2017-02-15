package com.nantian.common.util;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.nantian.common.exception.ErrorException;

public class ObjectPrinter {
	
	private static final String REGEX_GET_METHOD = "^get(\\S+)$";
	private static final String EQUAL = "=";
	
	public static String print(Object o) {	
	    /*
		final Pattern regex = Pattern.compile(REGEX_GET_METHOD);
		
		Class _class = o.getClass();
		
		Method[] methods = _class.getDeclaredMethods();
		ArrayList<String> methodList = new ArrayList<String>();
		ArrayList<Object> valueList = new ArrayList<Object>();
		
		for (Method method : methods) {
			String methodName = method.getName();
			Matcher matcher = regex.matcher(methodName);
			if (matcher.matches()) {
				String fieldName = matcher.group(1);
				char prefix = fieldName.charAt(0);
				if (prefix >= 65 && prefix <= 90) {
					fieldName = (char)(prefix + 32) + fieldName.substring(1);
				}
				methodList.add(fieldName);
				
				Object result = null;
				try {
				    result = method.invoke(o);
				} catch (IllegalAccessException e) {

				} catch (InvocationTargetException e) {

				}
				valueList.add(result);
			}
		}
		
		StringBuilder text = new StringBuilder(_class.getSimpleName());
		text.append(" = [");
		for (int i = 0; i < methodList.size(); i++) {
			text.append(methodList.get(i));
			text.append(EQUAL);
			text.append(valueList.get(i));
			if (i < methodList.size() - 1) {
				text.append(", ");
			}
		}
		text.append("]");
		
		return text.toString();
		*/
	    
	    if (o == null) {
	        return "null";
	    } else {
	        return o.toString();
	    }
	}
	
	public static String print(String name, Object o) {
	    StringBuilder text = new StringBuilder();
	    text.append(name);
	    text.append(EQUAL);
	    text.append(print(o));
	    
	    return text.toString();
	}
	
	public static String print(String[] names, Object[] objs) {
	    if (names.length < objs.length) {
//	        throw new ErrorException();
	    }
	    
	    StringBuilder text = new StringBuilder();
	    for (int i = 0; i < names.length; i++) {
	        text.append(names[i]);
	        text.append(EQUAL);
	        if (i < objs.length) {
	            text.append(print(objs[i]));
	        }
	        
	        if (i < names.length - 1) {
	            text.append(CommonConst.COMMA);
	        }
	    }
	    
	    return text.toString();
	}

}
