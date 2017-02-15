package com.nantian.jeda.config.vo;

import java.io.Serializable;
import java.sql.Timestamp;

public class sboxInfoVo implements Serializable {
	private static final long serialVersionUID = 1L;
	
	/**建议编号*/
	private Integer sbox_id;
	/**建议内容*/
	private String sbox_value;
	/**建议发起人*/
	private String sbox_initiator;
	/**建议提出时间*/
	private Timestamp sbox_time;
	/**建议状态编号*/
	private String sbox_statenum;
	/**建议确认人*/
	private String sbox_confirm_user;
	/**建议确认时间*/
	private Timestamp sbox_confirm_time;
	/**建议驳回人*/
	private String sbox_reject_user;
	/**建议驳回时间*/
	private Timestamp sbox_reject_time;
	
	
	public Integer getSbox_id() {
		return sbox_id;
	}
	public void setSbox_id(Integer sbox_id) {
		this.sbox_id = sbox_id;
	}
	public String getSbox_value() {
		return sbox_value;
	}
	public void setSbox_value(String sbox_value) {
		this.sbox_value = sbox_value;
	}
	public String getSbox_initiator() {
		return sbox_initiator;
	}
	public void setSbox_initiator(String sbox_initiator) {
		this.sbox_initiator = sbox_initiator;
	}
	public Timestamp getSbox_time() {
		return sbox_time;
	}
	public void setSbox_time(Timestamp sbox_time) {
		this.sbox_time = sbox_time;
	}
	public String getSbox_confirm_user() {
		return sbox_confirm_user;
	}
	public void setSbox_confirm_user(String sbox_confirm_user) {
		this.sbox_confirm_user = sbox_confirm_user;
	}
	public Timestamp getSbox_confirm_time() {
		return sbox_confirm_time;
	}
	public void setSbox_confirm_time(Timestamp sbox_confirm_time) {
		this.sbox_confirm_time = sbox_confirm_time;
	}
	public String getSbox_reject_user() {
		return sbox_reject_user;
	}
	public void setSbox_reject_user(String sbox_reject_user) {
		this.sbox_reject_user = sbox_reject_user;
	}
	public Timestamp getSbox_reject_time() {
		return sbox_reject_time;
	}
	public void setSbox_reject_time(Timestamp sbox_reject_time) {
		this.sbox_reject_time = sbox_reject_time;
	}
	public String getSbox_statenum() {
		return sbox_statenum;
	}
	public void setSbox_statenum(String sbox_statenum) {
		this.sbox_statenum = sbox_statenum;
	}
	
}
