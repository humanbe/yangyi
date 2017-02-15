/**
 * 
 */
package com.nantian.jeda.security.web.editor;

import java.beans.PropertyEditorSupport;

import com.nantian.jeda.common.model.Position;
import com.nantian.jeda.security.service.PositionService;

/**
 * @author daizhenzhong
 * 
 */
public class PositionEditor extends PropertyEditorSupport {

	private PositionService positionService;

	/**
	 * @param positionService
	 */
	public PositionEditor(PositionService positionService) {
		this.positionService = positionService;
	}

	/**
	 * @return
	 * @see java.beans.PropertyEditorSupport#getAsText()
	 */
	@Override
	public String getAsText() {
		if (getValue() instanceof Position) {
			return ((Position) getValue()).getId().toString();
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
		Object position = positionService.get(Long.valueOf(text));
		if (position != null) {
			setValue(position);
		} else {
			setValue(new Position(Long.valueOf(text)));
		}
	}

}
