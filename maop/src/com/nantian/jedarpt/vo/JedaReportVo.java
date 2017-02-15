package com.nantian.jedarpt.vo;

import java.io.Serializable;
import java.util.Date;

/**
* 报表定制  - 报表配置表
* @author linaWang
* 
*/
public class JedaReportVo implements Serializable{

		private static final long serialVersionUID = 1L;

		/**报表编号*/
		private int report_code ; 
		
		/**报表分类*/
		private String report_type;  
		
		/**报表名称*/
		private String report_name;  
		
		/**描述*/
		private String report_desc;  
		
		/**查询SQL语句*/
		private String report_sql;  
		
		/**创建人*/
		private String creator;
		
		/**创建时间*/
		private Date created;
		
		/**修改人*/
		private String modifier;
		
		/**修改时间*/
		private Date modified;
		
		/**删除标示*/
		private String delete_flag;

		public int getReport_code() {
			return report_code;
		}

		public void setReport_code(int report_code) {
			this.report_code = report_code;
		}

		public String getReport_type() {
			return report_type;
		}

		public void setReport_type(String report_type) {
			this.report_type = report_type;
		}

		public String getReport_name() {
			return report_name;
		}

		public void setReport_name(String report_name) {
			this.report_name = report_name;
		}

		public String getReport_desc() {
			return report_desc;
		}

		public void setReport_desc(String report_desc) {
			this.report_desc = report_desc;
		}

		public String getReport_sql() {
			return report_sql;
		}

		public void setReport_sql(String report_sql) {
			this.report_sql = report_sql;
		}

		public String getCreator() {
			return creator;
		}

		public void setCreator(String creator) {
			this.creator = creator;
		}

		public Date getCreated() {
			return created;
		}

		public void setCreated(Date created) {
			this.created = created;
		}

		public String getModifier() {
			return modifier;
		}

		public void setModifier(String modifier) {
			this.modifier = modifier;
		}

		public Date getModified() {
			return modified;
		}

		public void setModified(Date modified) {
			this.modified = modified;
		}

		public String getDelete_flag() {
			return delete_flag;
		}

		public void setDelete_flag(String delete_flag) {
			this.delete_flag = delete_flag;
		}
		
}
