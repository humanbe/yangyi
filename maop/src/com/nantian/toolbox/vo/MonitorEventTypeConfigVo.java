/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.toolbox.vo;

import java.io.Serializable;

/**
 * @author ky
 * 
 */
public class MonitorEventTypeConfigVo implements Serializable {
	
	private static final long serialVersionUID = 1L;
	/**事件大类*/
	private String componentType;
	/**事件小类*/
	private String component;
	/**事件细类*/
	private String subComponent;
	
	public String getComponentType() {
		return componentType;
	}
	public void setComponentType(String componentType) {
		this.componentType = componentType;
	}
	public String getComponent() {
		return component;
	}
	public void setComponent(String component) {
		this.component = component;
	}
	public String getSubComponent() {
		return subComponent;
	}
	public void setSubComponent(String subComponent) {
		this.subComponent = subComponent;
	}
	

}
