/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.toolbox.vo;

import java.io.Serializable;
import java.util.Date;

/**
 * @author ky
 * 
 */
public class ToolBoxInfoVo implements Serializable {
	private static final long serialVersionUID = 1L;
	/**工具编号*/
	private String tool_code;
	/**应用系统*/
	private String appsys_code;
	/**工具描述*/
	private String tool_desc;
	/**授权级别分类*/
	private String authorize_level_type;
	/**专业领域分类一级*/
	private String field_type_one;
	/**专业领域分类二级*/
	private String field_type_two;
	/**专业领域分类三级*/
	private String field_type_three;
	/**授权级别*/
	private String tool_authorize_flag;
	/**工具创建人*/
	private String tool_creator;
	/**工具名称*/
	private String tool_name;
	/**删除标示*/
	private String delete_flag;
	/**参数*/
	private String paramValue;
	/**服务器*/
	private String serverValue;
	
	/**工具修改人*/
	private String tool_modifier;
	/**工具创建时间*/
	private Date tool_created_time;
	/**工具修改时间*/
	private Date tool_updated_time;
	/**工具类型*/
	private String tool_type;
	
	/**一级工具描述*/
	private String front_tool_desc;

	public String getFront_tool_desc() {
		return front_tool_desc;
	}

	public void setFront_tool_desc(String front_tool_desc) {
		this.front_tool_desc = front_tool_desc;
	}

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

	

	public String getTool_desc() {
		return tool_desc;
	}

	public void setTool_desc(String tool_desc) {
		this.tool_desc = tool_desc;
	}

	

	public String getAuthorize_level_type() {
		return authorize_level_type;
	}

	public void setAuthorize_level_type(String authorize_level_type) {
		this.authorize_level_type = authorize_level_type;
	}

	public String getField_type_one() {
		return field_type_one;
	}

	public void setField_type_one(String field_type_one) {
		this.field_type_one = field_type_one;
	}

	public String getField_type_two() {
		return field_type_two;
	}

	public void setField_type_two(String field_type_two) {
		this.field_type_two = field_type_two;
	}

	public String getField_type_three() {
		return field_type_three;
	}

	public void setField_type_three(String field_type_three) {
		this.field_type_three = field_type_three;
	}

	


	public String getTool_authorize_flag() {
		return tool_authorize_flag;
	}

	public void setTool_authorize_flag(String tool_authorize_flag) {
		this.tool_authorize_flag = tool_authorize_flag;
	}

	public String getTool_creator() {
		return tool_creator;
	}

	public void setTool_creator(String tool_creator) {
		this.tool_creator = tool_creator;
	}


	public String getTool_name() {
		return tool_name;
	}

	public void setTool_name(String tool_name) {
		this.tool_name = tool_name;
	}

	public String getDelete_flag() {
		return delete_flag;
	}

	public void setDelete_flag(String delete_flag) {
		this.delete_flag = delete_flag;
	}

	public String getParamValue() {
		return paramValue;
	}

	public void setParamValue(String paramValue) {
		this.paramValue = paramValue;
	}


	public String getServerValue() {
		return serverValue;
	}

	public void setServerValue(String serverValue) {
		this.serverValue = serverValue;
	}


	public String getTool_modifier() {
		return tool_modifier;
	}

	public void setTool_modifier(String tool_modifier) {
		this.tool_modifier = tool_modifier;
	}

	public Date getTool_created_time() {
		return tool_created_time;
	}

	public void setTool_created_time(Date tool_created_time) {
		this.tool_created_time = tool_created_time;
	}

	public Date getTool_updated_time() {
		return tool_updated_time;
	}

	public void setTool_updated_time(Date tool_updated_time) {
		this.tool_updated_time = tool_updated_time;
	}

	public String getTool_type() {
		return tool_type;
	}

	public void setTool_type(String tool_type) {
		this.tool_type = tool_type;
	}



}
