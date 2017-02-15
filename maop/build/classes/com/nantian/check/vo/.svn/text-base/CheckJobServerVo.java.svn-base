package com.nantian.check.vo;

import java.io.Serializable;


/**
 * 作业服务器关系表
 * @author linaWang
 *
 */
public class CheckJobServerVo implements Serializable{

	private static final long serialVersionUID = 1L;

	/**应用系统编号*/
	private java.lang.String appsys_code;  
	/**作业编号*/
	private java.lang.Integer job_code; 
	/**智能组路径*/
	private java.lang.String server_path;  
	/**智能组名称*/
	private java.lang.String server_name;  
	
	public java.lang.String getServer_path() {
		return server_path;
	}
	public void setServer_path(java.lang.String server_path) {
		this.server_path = server_path;
	}
	public java.lang.String getServer_name() {
		return server_name;
	}
	public void setServer_name(java.lang.String server_name) {
		this.server_name = server_name;
	}
	public java.lang.String getAppsys_code() {
		return appsys_code;
	}
	public void setAppsys_code(java.lang.String appsys_code) {
		this.appsys_code = appsys_code;
	}
	public java.lang.Integer getJob_code() {
		return job_code;
	}
	public void setJob_code(java.lang.Integer job_code) {
		this.job_code = job_code;
	}
	
	public boolean isValid(CheckJobServerVo vo){
		if( (vo.getAppsys_code() == null || "".equals(vo.getAppsys_code()))
				&& (vo.getJob_code() == null || "".equals(vo.getJob_code()))
				&& (vo.getServer_path() == null || "".equals(vo.getServer_path()))
				&& (vo.getServer_name() == null || "".equals(vo.getServer_name()))
				){
			return false;
		}
		return true;
	}
	
}
