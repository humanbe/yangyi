/**
 * 
 */
package com.nantian.jeda.security.web.editor;

import java.beans.PropertyEditorSupport;

import com.nantian.jeda.common.model.SubItem;
import com.nantian.jeda.config.service.SubItemService;

/**
 * 数据项Editor
 * 
 * @author <a href="mailto:daizhenzhong@nantian.com.cn">daizhenzhong</a>
 * 
 */
public class SubItemEditor extends PropertyEditorSupport {

	private SubItemService subitemService;

	/**
	 * @param itemService
	 */
	public SubItemEditor(SubItemService subitemService) {
		this.subitemService = subitemService;
	}

	/**
	 * @return
	 * @see java.beans.PropertyEditorSupport#getAsText()
	 */
	@Override
	public String getAsText() {
		if (getValue() instanceof SubItem) {
			return ((SubItem) getValue()).getId().toString();
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
		Object subitem = subitemService.get(Long.valueOf(text));
		if (subitem != null && subitem instanceof SubItem) {
			setValue(subitem);
		} else {
			setValue(new SubItem(Long.valueOf(text)));
		}
	}

}
