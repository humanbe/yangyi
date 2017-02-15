/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.toolbox.vo;

import java.io.Serializable;

/**
 * @author ky
 * 
 */
public class BusinessKeyWordRelationVo implements Serializable {
	private static final long serialVersionUID = 1L;
	/**业务ID*/
	private Integer business_id;
	/**应用系统编号*/
	private String appsys_code;
	/**告警关键字*/
	private String alarm_key_word;
	public Integer getBusiness_id() {
		return business_id;
	}
	public void setBusiness_id(Integer business_id) {
		this.business_id = business_id;
	}
	public String getAppsys_code() {
		return appsys_code;
	}
	public void setAppsys_code(String appsys_code) {
		this.appsys_code = appsys_code;
	}
	public String getAlarm_key_word() {
		return alarm_key_word;
	}
	public void setAlarm_key_word(String alarm_key_word) {
		this.alarm_key_word = alarm_key_word;
	}
	
	
	

}
