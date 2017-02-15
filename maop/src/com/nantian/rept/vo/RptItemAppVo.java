package com.nantian.rept.vo;

import java.io.Serializable;
import java.sql.Timestamp;


/**
 * @author <a href="mailto:donghui@nantian.com.cn">daijinyu</a>
 * 
 */
public class RptItemAppVo implements Serializable{

		private static final long serialVersionUID = 1L;
		
		/** 应用系统编号 */
		private String apl_code;
		
		/** 巡检指标编码 */
		private String item_cd_app;
		
		/** 一级指标编码 */
		private String item_cd_lvl1;
		
		/** 二级指标编码 */
		private String item_cd_lvl2;
		
		/** 巡检指标名称 */
		private String item_app_name;
	
		/** 巡检指标阀值是否统计峰值标识 */
		private String item_app_ststcs_peak_flag;
		/** 巡检指标计算表达式,不能包含本巡检指标 */
		private String expression;
		
		
		/** 创建人 */
		private String item_creator;
		
		/** 创建时间 */
		private Timestamp item_created;
		
		/** 修改人 */
		private String item_modifier;
		
		/** 修改时间 */
		private Timestamp item_modified;

		

		public String getApl_code() {
			return apl_code;
		}

		public void setApl_code(String apl_code) {
			this.apl_code = apl_code;
		}

		public String getItem_cd_app() {
			return item_cd_app;
		}

		public void setItem_cd_app(String item_cd_app) {
			this.item_cd_app = item_cd_app;
		}

		public String getItem_cd_lvl1() {
			return item_cd_lvl1;
		}

		public void setItem_cd_lvl1(String item_cd_lvl1) {
			this.item_cd_lvl1 = item_cd_lvl1;
		}

		public String getItem_cd_lvl2() {
			return item_cd_lvl2;
		}

		public void setItem_cd_lvl2(String item_cd_lvl2) {
			this.item_cd_lvl2 = item_cd_lvl2;
		}

		public String getItem_app_name() {
			return item_app_name;
		}

		public void setItem_app_name(String item_app_name) {
			this.item_app_name = item_app_name;
		}


		public String getItem_app_ststcs_peak_flag() {
			return item_app_ststcs_peak_flag;
		}

		public void setItem_app_ststcs_peak_flag(String item_app_ststcs_peak_flag) {
			this.item_app_ststcs_peak_flag = item_app_ststcs_peak_flag;
		}

		public String getExpression() {
			return expression;
		}

		public void setExpression(String expression) {
			this.expression = expression;
		}

		public String getItem_creator() {
			return item_creator;
		}

		public void setItem_creator(String item_creator) {
			this.item_creator = item_creator;
		}

		public Timestamp getItem_created() {
			return item_created;
		}

		public void setItem_created(java.sql.Timestamp item_created) {
			this.item_created = item_created;
		}

		public String getItem_modifier() {
			return item_modifier;
		}

		public void setItem_modifier(String item_modifier) {
			this.item_modifier = item_modifier;
		}

		public Timestamp getItem_modified() {
			return item_modified;
		}

		public void setItem_modified(Timestamp item_modified) {
			this.item_modified = item_modified;
		}

	



}