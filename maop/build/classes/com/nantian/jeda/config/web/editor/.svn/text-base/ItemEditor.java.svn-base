/**
 * 
 */
package com.nantian.jeda.config.web.editor;

import java.beans.PropertyEditorSupport;

import com.nantian.jeda.common.model.Item;
import com.nantian.jeda.config.service.ItemService;

/**
 * 数据项Editor
 * 
 * @author <a href="mailto:daizhenzhong@nantian.com.cn">daizhenzhong</a>
 * 
 */
public class ItemEditor extends PropertyEditorSupport {

	private ItemService itemService;

	/**
	 * @param itemService
	 */
	public ItemEditor(ItemService itemService) {
		this.itemService = itemService;
	}

	/**
	 * @return
	 * @see java.beans.PropertyEditorSupport#getAsText()
	 */
	@Override
	public String getAsText() {
		if (getValue() instanceof Item) {
			return ((Item) getValue()).getId().toString();
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
		Object item = itemService.get(text);
		if (item != null && item instanceof Item) {
			setValue(item);
		} else {
			setValue(new Item(text));
		}
	}

}
