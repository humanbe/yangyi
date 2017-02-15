/**
 * 
 */
package com.nantian.jeda.security.web.editor;

import java.beans.PropertyEditorSupport;

import com.nantian.jeda.common.model.Function;
import com.nantian.jeda.security.service.FunctionService;

/**
 * @author daizhenzhong
 * 
 */
public class FunctionEditor extends PropertyEditorSupport {

	private FunctionService functionService;

	/**
	 * @param functionService
	 */
	public FunctionEditor(FunctionService functionService) {
		this.functionService = functionService;
	}

	/**
	 * @return
	 * @see java.beans.PropertyEditorSupport#getAsText()
	 */
	@Override
	public String getAsText() {
		if (getValue() instanceof Function) {
			return ((Function) getValue()).getId().toString();
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
		Object function = functionService.get(text);
		if (function != null) {
			setValue(function);
		} else {
			setValue(new Function(text));
		}
	}

}
