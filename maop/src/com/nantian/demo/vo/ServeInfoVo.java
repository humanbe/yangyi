package com.nantian.demo.vo;

import java.io.Serializable;

public class ServeInfoVo implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String serveid;
	private String appsystemcd;
	private String servecd;
	private String servename;
	private String servenum;
	private String queuenum;
	private String busimodule;
	private String higserviceid;
	private String isload;
	private String reserve;
	private String reserve1;
	public String getServeid() {
		return serveid;
	}
	public void setServeid(String serveid) {
		this.serveid = serveid;
	}
	public String getAppsystemcd() {
		return appsystemcd;
	}
	public void setAppsystemcd(String appsystemcd) {
		this.appsystemcd = appsystemcd;
	}
	public String getServecd() {
		return servecd;
	}
	public void setServecd(String servecd) {
		this.servecd = servecd;
	}
	public String getServename() {
		return servename;
	}
	public void setServename(String servename) {
		this.servename = servename;
	}
	public String getServenum() {
		return servenum;
	}
	public void setServenum(String servenum) {
		this.servenum = servenum;
	}
	public String getQueuenum() {
		return queuenum;
	}
	public void setQueuenum(String queuenum) {
		this.queuenum = queuenum;
	}
	public String getBusimodule() {
		return busimodule;
	}
	public void setBusimodule(String busimodule) {
		this.busimodule = busimodule;
	}
	public String getHigserviceid() {
		return higserviceid;
	}
	public void setHigserviceid(String higserviceid) {
		this.higserviceid = higserviceid;
	}
	public String getIsload() {
		return isload;
	}
	public void setIsload(String isload) {
		this.isload = isload;
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

}
