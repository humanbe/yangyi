/**
 * 
 */
package com.nantian.jeda.security.web.editor;

import java.beans.PropertyEditorSupport;

import com.nantian.jeda.common.model.Module;
import com.nantian.jeda.security.service.ModuleService;

/**
 * @author daizhenzhong
 * 
 */
public class ModuleEditor extends PropertyEditorSupport {

	private ModuleService moduleService;

	/**
	 * @param moduleService
	 */
	public ModuleEditor(ModuleService moduleService) {
		this.moduleService = moduleService;
	}

	/**
	 * @return
	 * @see java.beans.PropertyEditorSupport#getAsText()
	 */
	@Override
	public String getAsText() {
		if (getValue() instanceof Module) {
			return ((Module) getValue()).getId().toString();
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
		Object module = moduleService.get(text);
		if (module != null) {
			setValue(module);
		} else {
			setValue(new Module(text));
		}
	}

}
