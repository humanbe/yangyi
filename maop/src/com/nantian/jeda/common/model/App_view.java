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
public class App_view implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	/* 关联序号*/
	private String aview_rel_id;
	/* 命名 */
	private String aview_name;
	/*描述*/
	private String aview_desc;
	/*发布人员*/
	private String aview_oper;
	/*发布时间*/
	private String aview_time;
	/**
	 * 
	 * @return aview_rel_id
	 */
	public String getAview_rel_id() {
		return aview_rel_id;
	}
	/**
	 * 
	 * @param aview_rel_id 
	 */
	public void setAview_rel_id(String aview_rel_id) {
		this.aview_rel_id = aview_rel_id;
	}
	/**
	 * 
	 * @return aview_name
	 */
	public String getAview_name() {
		return aview_name;
	}
	/**
	 * 
	 * @param aview_name
	 */
	public void setAview_name(String aview_name) {
		this.aview_name = aview_name;
	}
	/**
	 * 
	 * @return aview_desc
	 */
	public String getAview_desc() {
		return aview_desc;
	}
	/**
	 * 
	 * @param aview_desc
	 */
	public void setAview_desc(String aview_desc) {
		this.aview_desc = aview_desc;
	}
	/**
	 * 
	 * @return aview_oper
	 */
	public String getAview_oper() {
		return aview_oper;
	}
	/**
	 * 
	 * @param aview_oper
	 */
	public void setAview_oper(String aview_oper) {
		this.aview_oper = aview_oper;
	}
	/**
	 * 
	 * @return aview_time
	 */
	public String getAview_time() {
		return aview_time;
	}
	/**
	 * 
	 * @param aview_time
	 */
	public void setAview_time(String aview_time) {
		this.aview_time = aview_time;
	}
	
}
