package com.nantian.common.exception;

import jp.co.nri.kinshasa.framework.message.MessageBundle;

import org.jboss.seam.Component;

public class Message {
	
	private String id;
	private String[] params;
	private String text;
	
	public Message(String id, String... params) {
		this.id = id;
		this.params = params;
	}

	public String getId() {
		return id;
	}

	public String[] getParams() {
		return params;
	}

	public String getText() {
	    if (text == null) {
    	    MessageBundle messageBundle = (MessageBundle) Component.getInstance("messageBundle");
            text = messageBundle.get(id, (Object[]) params);
	    }
		return text;
	}
	
	@Override
	public String toString() {
		return getText();
	}

}
