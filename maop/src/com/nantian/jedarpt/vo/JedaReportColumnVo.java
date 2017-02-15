package com.nantian.jedarpt.vo;

import java.io.Serializable;

/**
* 报表定制 - 报表字段关联表
* @author linaWang
* 
*/
public class JedaReportColumnVo implements Serializable{

		private static final long serialVersionUID = 1L;

		/**报表编号*/
		private int report_code ; 
		
		/**字段编号*/
		private int column_code;  
		
		/**字段是否可见*/
		private String is_visible;  
		
		/**字段默认值*/
		private String default_value;  
		
		/**字段宽度*/
		private String column_width;
		
		/**字段排序*/
		private String column_sort;

		public int getReport_code() {
			return report_code;
		}

		public void setReport_code(int report_code) {
			this.report_code = report_code;
		}

		public int getColumn_code() {
			return column_code;
		}

		public void setColumn_code(int column_code) {
			this.column_code = column_code;
		}

		public String getIs_visible() {
			return is_visible;
		}

		public void setIs_visible(String is_visible) {
			this.is_visible = is_visible;
		}

		public String getDefault_value() {
			return default_value;
		}

		public void setDefault_value(String default_value) {
			this.default_value = default_value;
		}

		public String getColumn_width() {
			return column_width;
		}

		public void setColumn_width(String column_width) {
			this.column_width = column_width;
		}
		
		public String getColumn_sort() {
			return column_sort;
		}

		public void setColumn_sort(String column_sort) {
			this.column_sort = column_sort;
		}

}
