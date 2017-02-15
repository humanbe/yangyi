package com.nantian.check.vo;

import java.io.Serializable;

/**
* JEDA作业信息表
* @author linaWang
* 
*/
public class CheckJobJedaInfoVo implements Serializable{

		private static final long serialVersionUID = 1L;

		/**应用系统编号*/
		private java.lang.String appsys_code ; 
		/**作业编号*/
		private java.lang.Integer job_code_jeda;  
		/**巡检类型*/
		private java.lang.String check_type;  
		/**授权级别分类*/
		private java.lang.String authorize_lever_type;  
		/**专业领域分类*/
		private java.lang.String field_type;  
		/**作业名称*/
		private java.lang.String job_name;  
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
		
		public java.lang.String getAppsys_code() {
			return appsys_code;
		}
		public void setAppsys_code(java.lang.String appsys_code) {
			this.appsys_code = appsys_code;
		}
		public java.lang.Integer getJob_code_jeda() {
			return job_code_jeda;
		}
		public void setJob_code_jeda(java.lang.Integer job_code_jeda) {
			this.job_code_jeda = job_code_jeda;
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
		
}
