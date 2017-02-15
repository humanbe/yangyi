/**
 * 
 */
package com.nantian.jeda.common.model;

import java.io.Serializable;

/**
 * 
 * @author gyc
 *
 */
public class App_view_detail implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	/*序号*/
	private String avd_id;
	/*关联序号*/
	private String avd_rel_id;
	/*功能概述*/
	private String avd_simpdesc;
	/*功能详述
	 * 数据库中的Clob字段在bean中用String
	 * */
	private String avd_descdetail;
	/*功能类型*/
	private String avd_type;
	public String getAvd_id() {
		return avd_id;
	}
	public void setAvd_id(String avd_id) {
		this.avd_id = avd_id;
	}
	public String getAvd_rel_id() {
		return avd_rel_id;
	}
	public void setAvd_rel_id(String avd_rel_id) {
		this.avd_rel_id = avd_rel_id;
	}
	public String getAvd_simpdesc() {
		return avd_simpdesc;
	}
	public void setAvd_simpdesc(String avd_simpdesc) {
		this.avd_simpdesc = avd_simpdesc;
	}
	public String getAvd_descdetail() {
		return avd_descdetail;
	}
	public void setAvd_descdetail(String avd_descdetail) {
		this.avd_descdetail = avd_descdetail;
	}
	public String getAvd_type() {
		return avd_type;
	}
	public void setAvd_type(String avd_type) {
		this.avd_type = avd_type;
	}
	
	
	
	
}