package com.nantian.check.vo;

import java.io.Serializable;


/**
 * 合规巡检数据批量同步配置表
 * @author linaWang
 *
 */
public class CheckComplianceBatchConfigVo implements Serializable{

	private static final long serialVersionUID = 1L;

	/**最后同步时间*/
	private java.sql.Timestamp last_synchronize_time;
	public java.sql.Timestamp getLast_synchronize_time() {
		return last_synchronize_time;
	}
	public void setLast_synchronize_time(java.sql.Timestamp last_synchronize_time) {
		this.last_synchronize_time = last_synchronize_time;
	} 
	
}
