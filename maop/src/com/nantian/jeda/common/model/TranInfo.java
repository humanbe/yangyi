package com.nantian.jeda.common.model;

public class TranInfo {
	/**
	 * 交易ID.主键
	 */
	private String tranid;
	/**
	 * 系统代码.主键
	 */
	private String appsystemid;
	/**
	 * 渠道号.主键
	 */
	private String chnlno;
	/**
	 * 外部交易码.主键
	 */
	private String outtrancode;
	/**
	 * 内部交易码.主键
	 */
	private String trancode;
	/**
	 * 交易名称.主键
	 */
	private String tranname;
	/**
	 * 交易超时时间（秒）.主键
	 */
	private String trantime;
	/**
	 * 内部服务代码.主键
	 */
	private String serviceid;
	/**
	 * 所属模块名称
	 */
	private String busimoduelname;
	/**
	 * 所属模块代码
	 */
	private String busimoduelcode;
	/**
	 * 上级交易代码
	 */
	private String higouttrancode;
	/**
	 * 调用方式
	 */
	private String callway;
	/**
	 * 调用序号
	 */
	private String callnum;
	/**
	 * 条件描述（当调用方式选择T时填写）
	 */
	private String condition;
	/**
	 * 交易派生标识
	 */
	private String Deriveflag;
	/**
	 * 备用字段
	 */
	private String reserve;
	/**
	 * 备用字段1
	 */
	private String reserve1;
	/**
	 * 备用字段2
	 */
	private String reserve2;
	/**
	 * 备用字段3
	 */
	private String reserve3;

	public String getTranid() {
		return tranid;
	}

	public void setTranid(String tranid) {
		this.tranid = tranid;
	}

	public String getAppsystemid() {
		return appsystemid;
	}

	public void setAppsystemid(String appsystemid) {
		this.appsystemid = appsystemid;
	}

	public String getChnlno() {
		return chnlno;
	}

	public void setChnlno(String chnlno) {
		this.chnlno = chnlno;
	}

	public String getOuttrancode() {
		return outtrancode;
	}

	public void setOuttrancode(String outtrancode) {
		this.outtrancode = outtrancode;
	}

	public String getTrancode() {
		return trancode;
	}

	public void setTrancode(String trancode) {
		this.trancode = trancode;
	}

	public String getTranname() {
		return tranname;
	}

	public void setTranname(String tranname) {
		this.tranname = tranname;
	}

	public String getTrantime() {
		return trantime;
	}

	public void setTrantime(String trantime) {
		this.trantime = trantime;
	}

	public String getServiceid() {
		return serviceid;
	}

	public void setServiceid(String serviceid) {
		this.serviceid = serviceid;
	}

	public String getBusimoduelname() {
		return busimoduelname;
	}

	public void setBusimoduelname(String busimoduelname) {
		this.busimoduelname = busimoduelname;
	}

	public String getBusimoduelcode() {
		return busimoduelcode;
	}

	public void setBusimoduelcode(String busimoduelcode) {
		this.busimoduelcode = busimoduelcode;
	}

	public String getHigouttrancode() {
		return higouttrancode;
	}

	public void setHigouttrancode(String higouttrancode) {
		this.higouttrancode = higouttrancode;
	}

	public String getCallway() {
		return callway;
	}

	public void setCallway(String callway) {
		this.callway = callway;
	}

	public String getCallnum() {
		return callnum;
	}

	public void setCallnum(String callnum) {
		this.callnum = callnum;
	}

	public String getCondition() {
		return condition;
	}

	public void setCondition(String condition) {
		this.condition = condition;
	}

	public String getDeriveflag() {
		return Deriveflag;
	}

	public void setDeriveflag(String deriveflag) {
		Deriveflag = deriveflag;
	}

	public String getReserve() {
		return reserve;
	}

	public void setReserve(String reserve) {
		this.reserve = reserve;
	}

	public String getReserve1() {
		return reserve1;
	}

	public void setReserve1(String reserve1) {
		this.reserve1 = reserve1;
	}

	public String getReserve2() {
		return reserve2;
	}

	public void setReserve2(String reserve2) {
		this.reserve2 = reserve2;
	}

	public String getReserve3() {
		return reserve3;
	}

	public void setReserve3(String reserve3) {
		this.reserve3 = reserve3;
	}
}
