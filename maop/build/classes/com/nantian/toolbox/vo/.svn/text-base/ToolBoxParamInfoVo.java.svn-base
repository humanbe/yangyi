/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.toolbox.vo;

import java.io.Serializable;

/**
 * @author ky
 * 
 */
public class ToolBoxParamInfoVo implements Serializable {
	private static final long serialVersionUID = 1L;
	
	/**工具编号*/
	private String tool_code;
	/**应用系统*/
	private String appsys_code;
	/**参数名称*/
	private String param_name;
	/**参数类型*/
	private String param_type;

	/**参数长度*/
	private Long param_length;
	/**参数格式*/
	private String param_format;
	/**参数默认值*/
	private String param_default_value;
	/**参数描述*/
	private String param_desc;
	public String getTool_code() {
		return tool_code;
	}
	public void setTool_code(String tool_code) {
		this.tool_code = tool_code;
	}
	public String getAppsys_code() {
		return appsys_code;
	}
	public void setAppsys_code(String appsys_code) {
		this.appsys_code = appsys_code;
	}
	public String getParam_name() {
		return param_name;
	}
	public void setParam_name(String param_name) {
		this.param_name = param_name;
	}
	public String getParam_type() {
		return param_type;
	}
	public void setParam_type(String param_type) {
		this.param_type = param_type;
	}
	
	
	public Long getParam_length() {
		return param_length;
	}
	public void setParam_length(Long param_length) {
		this.param_length = param_length;
	}
	public String getParam_format() {
		return param_format;
	}
	public void setParam_format(String param_format) {
		this.param_format = param_format;
	}

	public String getParam_default_value() {
		return param_default_value;
	}
	public void setParam_default_value(String param_default_value) {
		this.param_default_value = param_default_value;
	}
	public String getParam_desc() {
		return param_desc;
	}
	public void setParam_desc(String param_desc) {
		this.param_desc = param_desc;
	}
	
	public boolean isValid(ToolBoxParamInfoVo vo){
		if((vo.getTool_code() == null || "".equals(vo.getTool_code()))
				&& (vo.getParam_name() == null || "".equals(vo.getParam_name()))
				&& (vo.getAppsys_code()== null || "".equals(vo.getAppsys_code()))
				
				
				){
			return false;
		}
		return true;
	}

}
