package com.nantian.dply.vo;

import java.io.Serializable;
import java.sql.Timestamp;

public class SysConfManageVo implements Serializable{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	
	/**系统配置ID*/
	private String sys_conf_id;
	/**系统配置编码*/
	private String sys_conf_code;
	/**系统配置名称*/
	private String sys_conf_name;
	/**系统配置值*/
	private String sys_conf_value;
	/**系统配置类型*/
	private String sys_conf_type;
	/**系统配置描述*/
	private String sys_conf_desc;
	
	/**创建人*/
	private String creator;
	/**修改人*/
	private String modifier;
	/**创建时间*/
	private Timestamp created_time;
	/**修改时间*/
	private Timestamp modifiled_time;
	
	
	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	public String getSys_conf_id() {
		return sys_conf_id;
	}
	public void setSys_conf_id(String sys_conf_id) {
		this.sys_conf_id = sys_conf_id;
	}
	public String getSys_conf_code() {
		return sys_conf_code;
	}
	public void setSys_conf_code(String sys_conf_code) {
		this.sys_conf_code = sys_conf_code;
	}
	public String getSys_conf_name() {
		return sys_conf_name;
	}
	public void setSys_conf_name(String sys_conf_name) {
		this.sys_conf_name = sys_conf_name;
	}
	public String getSys_conf_value() {
		return sys_conf_value;
	}
	public void setSys_conf_value(String sys_conf_value) {
		this.sys_conf_value = sys_conf_value;
	}
	public String getSys_conf_type() {
		return sys_conf_type;
	}
	public void setSys_conf_type(String sys_conf_type) {
		this.sys_conf_type = sys_conf_type;
	}
	public String getSys_conf_desc() {
		return sys_conf_desc;
	}
	public void setSys_conf_desc(String sys_conf_desc) {
		this.sys_conf_desc = sys_conf_desc;
	}
	public String getCreator() {
		return creator;
	}
	public void setCreator(String creator) {
		this.creator = creator;
	}
	public String getModifier() {
		return modifier;
	}
	public void setModifier(String modifier) {
		this.modifier = modifier;
	}
	public Timestamp getCreated_time() {
		return created_time;
	}
	public void setCreated_time(Timestamp created_time) {
		this.created_time = created_time;
	}
	public Timestamp getModifiled_time() {
		return modifiled_time;
	}
	public void setModifiled_time(Timestamp modifiled_time) {
		this.modifiled_time = modifiled_time;
	}
	
	
	
}
