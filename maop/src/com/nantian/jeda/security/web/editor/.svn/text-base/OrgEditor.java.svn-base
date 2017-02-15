/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.jeda.security.web.editor;

import java.beans.PropertyEditorSupport;

import com.nantian.jeda.common.model.Org;
import com.nantian.jeda.security.service.OrgService;

/**
 * 机构Editor
 * 
 * @author daizhenzhong
 * 
 */
public class OrgEditor extends PropertyEditorSupport {

	private OrgService orgService;

	/**
	 * @param orgService
	 */
	public OrgEditor(OrgService orgService) {
		this.orgService = orgService;
	}

	/**
	 * @return
	 * @see java.beans.PropertyEditorSupport#getAsText()
	 */
	@Override
	public String getAsText() {
		if (getValue() instanceof Org) {
			return ((Org) getValue()).getId().toString();
		}
		return null;
	}

	/**
	 * @param text
	 * @throws IllegalArgumentException
	 * @see java.beans.PropertyEditorSupport#setAsText(java.lang.String)
	 */
	@Override
	public void setAsText(String text) throws IllegalArgumentException {
		Object org = orgService.get(text);
		if (org != null) {
			setValue(org);
		} else {
			setValue(new Org(text));
		}
	}

}
