package com.nantian.check.vo;

import java.io.Serializable;

/**
 * 巡检模板信息bean
 * @author linawang
 *
 */
public class CheckTemplateInfoVo implements Serializable{

	private static final long serialVersionUID = 1L;

	private java.lang.String template_code;  //模板编号
	private java.lang.String template_path;  //模板路径
	private java.lang.String template_name;  //模板名称
	private java.lang.String template_desc;  //模板描述
	
	public java.lang.String getTemplate_code() {
		return template_code;
	}
	public void setTemplate_code(java.lang.String template_code) {
		this.template_code = template_code;
	}
	public java.lang.String getTemplate_path() {
		return template_path;
	}
	public void setTemplate_path(java.lang.String template_path) {
		this.template_path = template_path;
	}
	public java.lang.String getTemplate_name() {
		return template_name;
	}
	public void setTemplate_name(java.lang.String template_name) {
		this.template_name = template_name;
	}
	public java.lang.String getTemplate_desc() {
		return template_desc;
	}
	public void setTemplate_desc(java.lang.String template_desc) {
		this.template_desc = template_desc;
	}
	
	
	
}
