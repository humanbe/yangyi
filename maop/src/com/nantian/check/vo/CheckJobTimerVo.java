package com.nantian.check.vo;

import java.io.Serializable;

/**
* 巡检作业时间表
* @author linaWang
* 
*/
public class CheckJobTimerVo implements Serializable{

		private static final long serialVersionUID = 1L;

		/**应用系统编号*/
		private java.lang.String appsys_code ; 
		/**作业编号*/
		private java.lang.Integer job_code;  
		/**时间表编号*/
		private java.lang.Integer timer_code;
		/**执行频率类型*/
		private java.lang.String exec_freq_type ; 
		/**执行开始日期*/
		private java.lang.String exec_start_date ;
		/**执行开始时间*/
		private java.lang.String exec_start_time ;
		/**星期一*/
		private java.lang.String week1_flag ;
		/**星期二*/
		private java.lang.String week2_flag ;
		/**星期三*/
		private java.lang.String week3_flag ;
		/**星期四*/
		private java.lang.String week4_flag ;
		/**星期五*/
		private java.lang.String week5_flag ;
		/**星期六*/
		private java.lang.String week6_flag ;
		/**星期日*/
		private java.lang.String week7_flag ;
		/**间隔周数*/
		private java.lang.Integer interval_weeks;
		/**当月日期序号*/
		private java.lang.Integer month_day;
		/**间隔天数*/
		private java.lang.Integer interval_days;
		/**间隔小时数*/
		private java.lang.Integer interval_hours;
		/**间隔分钟数*/
		private java.lang.Integer interval_minutes;
		/**执行优先级*/
		private java.lang.String exec_priority ;
		/**作业运行通知邮件列表*/
		private java.lang.String exec_notice_mail_list ;
		/**邮件发送成功状态*/
		private java.lang.String mail_success_flag ;
		/**邮件发送失败状态*/
		private java.lang.String mail_failure_flag ;
		/**邮件发送已终止状态*/
		private java.lang.String mail_cancel_flag ;
		/**作业运行通知SNMP列表*/
		private java.lang.String exec_notice_snmp_list ;
		/**SNMP状态值*/
		private java.lang.Integer snmp_status_value;
		
		
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

		public java.lang.Integer getTimer_code() {
			return timer_code;
		}

		public void setTimer_code(java.lang.Integer timer_code) {
			this.timer_code = timer_code;
		}

		public java.lang.String getExec_freq_type() {
			return exec_freq_type;
		}

		public void setExec_freq_type(java.lang.String exec_freq_type) {
			this.exec_freq_type = exec_freq_type;
		}

		public java.lang.String getExec_start_date() {
			return exec_start_date;
		}

		public void setExec_start_date(java.lang.String exec_start_date) {
			this.exec_start_date = exec_start_date;
		}

		public java.lang.String getExec_start_time() {
			return exec_start_time;
		}

		public void setExec_start_time(java.lang.String exec_start_time) {
			this.exec_start_time = exec_start_time;
		}

		public java.lang.String getWeek1_flag() {
			return week1_flag;
		}

		public void setWeek1_flag(java.lang.String week1_flag) {
			this.week1_flag = week1_flag;
		}

		public java.lang.String getWeek2_flag() {
			return week2_flag;
		}

		public void setWeek2_flag(java.lang.String week2_flag) {
			this.week2_flag = week2_flag;
		}

		public java.lang.String getWeek3_flag() {
			return week3_flag;
		}

		public void setWeek3_flag(java.lang.String week3_flag) {
			this.week3_flag = week3_flag;
		}

		public java.lang.String getWeek4_flag() {
			return week4_flag;
		}

		public void setWeek4_flag(java.lang.String week4_flag) {
			this.week4_flag = week4_flag;
		}

		public java.lang.String getWeek5_flag() {
			return week5_flag;
		}

		public void setWeek5_flag(java.lang.String week5_flag) {
			this.week5_flag = week5_flag;
		}

		public java.lang.String getWeek6_flag() {
			return week6_flag;
		}

		public void setWeek6_flag(java.lang.String week6_flag) {
			this.week6_flag = week6_flag;
		}

		public java.lang.String getWeek7_flag() {
			return week7_flag;
		}

		public void setWeek7_flag(java.lang.String week7_flag) {
			this.week7_flag = week7_flag;
		}

		public java.lang.Integer getInterval_weeks() {
			return interval_weeks;
		}

		public void setInterval_weeks(java.lang.Integer interval_weeks) {
			this.interval_weeks = interval_weeks;
		}

		public java.lang.Integer getMonth_day() {
			return month_day;
		}

		public void setMonth_day(java.lang.Integer month_day) {
			this.month_day = month_day;
		}

		public java.lang.Integer getInterval_days() {
			return interval_days;
		}

		public void setInterval_days(java.lang.Integer interval_days) {
			this.interval_days = interval_days;
		}

		public java.lang.Integer getInterval_hours() {
			return interval_hours;
		}

		public void setInterval_hours(java.lang.Integer interval_hours) {
			this.interval_hours = interval_hours;
		}

		public java.lang.Integer getInterval_minutes() {
			return interval_minutes;
		}

		public void setInterval_minutes(java.lang.Integer interval_minutes) {
			this.interval_minutes = interval_minutes;
		}

		public java.lang.String getExec_priority() {
			return exec_priority;
		}

		public void setExec_priority(java.lang.String exec_priority) {
			this.exec_priority = exec_priority;
		}

		public java.lang.String getExec_notice_mail_list() {
			return exec_notice_mail_list;
		}

		public void setExec_notice_mail_list(java.lang.String exec_notice_mail_list) {
			this.exec_notice_mail_list = exec_notice_mail_list;
		}

		public java.lang.String getMail_success_flag() {
			return mail_success_flag;
		}

		public void setMail_success_flag(java.lang.String mail_success_flag) {
			this.mail_success_flag = mail_success_flag;
		}

		public java.lang.String getMail_failure_flag() {
			return mail_failure_flag;
		}

		public void setMail_failure_flag(java.lang.String mail_failure_flag) {
			this.mail_failure_flag = mail_failure_flag;
		}

		public java.lang.String getMail_cancel_flag() {
			return mail_cancel_flag;
		}

		public void setMail_cancel_flag(java.lang.String mail_cancel_flag) {
			this.mail_cancel_flag = mail_cancel_flag;
		}
		
		public java.lang.String getExec_notice_snmp_list() {
			return exec_notice_snmp_list;
		}

		public void setExec_notice_snmp_list(java.lang.String exec_notice_snmp_list) {
			this.exec_notice_snmp_list = exec_notice_snmp_list;
		}

		public java.lang.Integer getSnmp_status_value() {
			return snmp_status_value;
		}

		public void setSnmp_status_value(java.lang.Integer snmp_status_value) {
			this.snmp_status_value = snmp_status_value;
		}
		
}
