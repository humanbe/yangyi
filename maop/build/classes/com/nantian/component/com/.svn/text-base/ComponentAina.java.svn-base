package com.nantian.component.com;

import jp.co.nri.kinshasa.aplcommons.model.Aina;
import jp.co.nri.kinshasa.aplcommons.model.Mina;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.support.MessageSourceAccessor;

/**
 * Aina类
 * @author dong
 *
 */
@org.springframework.stereotype.Component
public class ComponentAina extends Aina {

	/**
	 * serialVersionUID
	 */
	private static final long serialVersionUID = -365770101348002431L;
	
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	
	/**
	 *指定的信息设置到aina中
	 * @param msgId 信息id
	 * @param param 可变参数
	 * @throws Throwable 抛出异常
	 */
	public void addMessage(String msgId, String ... param) throws Throwable {

//		MessageBundle messageBundle = (MessageBundle) Component.getInstance("messageBundle");
//		String msg = messageBundle.get(msgId, (Object[]) param);
		String msg = messages.getMessage(msgId, (Object[]) param);

		if (msg != null) {
			Mina mina = new Mina();
			mina.setMSG_TEXT_SUMMARY(msg);
			super.addMESSAGES(mina);
		}
	}
}
