package com.nantian.check.vo;

import java.io.Serializable;

/**
* 巡检作业信息表
* @author linaWang
* 
*/
public class CheckJobInfoVo implements Serializable{

		private static final long serialVersionUID = 1L;

		/**应用系统编号*/
		private java.lang.String appsys_code ; 
		/**作业编号*/
		private java.lang.Integer job_code;  
		/**巡检类型*/
		private java.lang.String check_type;  
		/**授权级别分类-巡检方式*/
		private java.lang.String authorize_lever_type;  
		/**专业领域分类*/
		private java.lang.String field_type;  
		/**作业名称*/
		private java.lang.String job_name;  
		/**作业路径*/
		private java.lang.String job_path; 
		/**作业类型*/
		private java.lang.String job_type; 
		/**作业描述*/
		private java.lang.String job_desc;  
		/**作业状态*/
		private java.lang.String tool_status;  
		/**一线使用可否*/
		private java.lang.String frontline_flag;  
		/**是否需要授权*/
		private java.lang.String authorize_flag;  
		/**删除标示*/
		private java.lang.String delete_flag;  
		/**创建人*/
		private java.lang.String tool_creator; 
		
		/**脚本名称*/
		private java.lang.String script_name; 
		/**脚本执行路径*/
		private java.lang.String exec_path; 
		/**脚本执行用户*/
		private java.lang.String exec_user; 
		/**脚本执行用户组*/
		private java.lang.String exec_user_group; 
		/**脚本编码*/
		private java.lang.String language_type; 
		/**巡检目标*/
		private java.lang.String server_target_type; 
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
		public java.lang.String getCheck_type() {
			return check_type;
		}
		public void setCheck_type(java.lang.String check_type) {
			this.check_type = check_type;
		}
		public java.lang.String getAuthorize_lever_type() {
			return authorize_lever_type;
		}
		public void setAuthorize_lever_type(java.lang.String authorize_lever_type) {
			this.authorize_lever_type = authorize_lever_type;
		}
		public java.lang.String getField_type() {
			return field_type;
		}
		public void setField_type(java.lang.String field_type) {
			this.field_type = field_type;
		}
		public java.lang.String getJob_name() {
			return job_name;
		}
		public void setJob_name(java.lang.String job_name) {
			this.job_name = job_name;
		}
		public java.lang.String getJob_path() {
			return job_path;
		}
		public void setJob_path(java.lang.String job_path) {
			this.job_path = job_path;
		}
		public java.lang.String getJob_type() {
			return job_type;
		}
		public void setJob_type(java.lang.String job_type) {
			this.job_type = job_type;
		}
		public java.lang.String getJob_desc() {
			return job_desc;
		}
		public void setJob_desc(java.lang.String job_desc) {
			this.job_desc = job_desc;
		}
		public java.lang.String getTool_status() {
			return tool_status;
		}
		public void setTool_status(java.lang.String tool_status) {
			this.tool_status = tool_status;
		}
		public java.lang.String getFrontline_flag() {
			return frontline_flag;
		}
		public void setFrontline_flag(java.lang.String frontline_flag) {
			this.frontline_flag = frontline_flag;
		}
		public java.lang.String getAuthorize_flag() {
			return authorize_flag;
		}
		public void setAuthorize_flag(java.lang.String authorize_flag) {
			this.authorize_flag = authorize_flag;
		}
		public java.lang.String getDelete_flag() {
			return delete_flag;
		}
		public void setDelete_flag(java.lang.String delete_flag) {
			this.delete_flag = delete_flag;
		}
		public java.lang.String getTool_creator() {
			return tool_creator;
		}
		public void setTool_creator(java.lang.String tool_creator) {
			this.tool_creator = tool_creator;
		}
		public java.lang.String getScript_name() {
			return script_name;
		}
		public void setScript_name(java.lang.String script_name) {
			this.script_name = script_name;
		}
		public java.lang.String getExec_path() {
			return exec_path;
		}
		public void setExec_path(java.lang.String exec_path) {
			this.exec_path = exec_path;
		}
		public java.lang.String getExec_user() {
			return exec_user;
		}
		public void setExec_user(java.lang.String exec_user) {
			this.exec_user = exec_user;
		}
		public java.lang.String getExec_user_group() {
			return exec_user_group;
		}
		public void setExec_user_group(java.lang.String exec_user_group) {
			this.exec_user_group = exec_user_group;
		}
		public java.lang.String getLanguage_type() {
			return language_type;
		}
		public void setLanguage_type(java.lang.String language_type) {
			this.language_type = language_type;
		}
		public java.lang.String getServer_target_type() {
			return server_target_type;
		}
		public void setServer_target_type(java.lang.String server_target_type) {
			this.server_target_type = server_target_type;
		}
		
}
