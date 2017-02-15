package com.nantian.jedarpt.vo;

import java.io.Serializable;

/**
* 报表定制 - 报表菜单关联表
* @author linaWang
* 
*/
public class JedaReportMenuVo implements Serializable{

		private static final long serialVersionUID = 1L;

		/**报表编号*/
		private int report_code ; 
		
		/**父级菜单编号*/
		private String parent_menu;

		public int getReport_code() {
			return report_code;
		}

		public void setReport_code(int report_code) {
			this.report_code = report_code;
		}

		public String getParent_menu() {
			return parent_menu;
		}

		public void setParent_menu(String parent_menu) {
			this.parent_menu = parent_menu;
		}
}
