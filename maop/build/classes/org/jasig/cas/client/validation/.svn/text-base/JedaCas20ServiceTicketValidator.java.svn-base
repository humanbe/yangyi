package org.jasig.cas.client.validation;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.jasig.cas.client.authentication.AttributePrincipal;
import org.jasig.cas.client.authentication.AttributePrincipalImpl;
import org.jasig.cas.client.proxy.Cas20ProxyRetriever;
import org.jasig.cas.client.proxy.ProxyGrantingTicketStorage;
import org.jasig.cas.client.proxy.ProxyRetriever;
import org.jasig.cas.client.util.CommonUtils;
import org.jasig.cas.client.util.XmlUtils;
import org.springframework.beans.factory.annotation.Autowired;

import com.nantian.common.util.MyApplicationContextUtil;
import com.nantian.jeda.common.model.SubItem;
import com.nantian.jeda.security.util.ItemProvider;

/**
 * 重写CAS认证的类，修改CAS SERVER HOST地址从数据库获取
 * 
 * @author <a href="mailto:donghui@nantian.com.cn">donghui</a>
 */
public class JedaCas20ServiceTicketValidator extends
		JedaAbstractCasProtocolUrlBasedTicketValidator {
	private String proxyCallbackUrl;
	private ProxyGrantingTicketStorage proxyGrantingTicketStorage;
	private ProxyRetriever proxyRetriever;
	@Autowired
	private ItemProvider itemProvider;

	public JedaCas20ServiceTicketValidator(String casServerUrlPrefix) {
		super(casServerUrlPrefix);

		// add by donghui start 20141010
		if(null == itemProvider){
			itemProvider = (ItemProvider) MyApplicationContextUtil.springContext
					.getBean("itemProvider");
		}
		List<SubItem> subItemList = itemProvider.getSubItemEntity("CAS_SERVER");
		for (SubItem subItem : subItemList) {
			if ("HOST".equalsIgnoreCase(subItem.getName().trim())) {
//				System.out
//						.println("$$$$$$$$$$$$$$$$$$$$$$$$$$ JedaCas20ServiceTicketValidator ============"
//								+ subItem.getValue());
				casServerUrlPrefix = subItem.getValue();
//				System.out
//						.println("$$$$$$$$$$$$$$$$$$$$$$$$$$ casServerUrlPrefix ============"
//								+ casServerUrlPrefix);
			}
		}
		// add by donghui end 20141010

		this.proxyRetriever = new Cas20ProxyRetriever(casServerUrlPrefix);
	}

	protected final void populateUrlAttributeMap(Map urlParameters) {
		urlParameters.put("pgtUrl", encodeUrl(this.
		proxyCallbackUrl));
	}

	protected String getUrlSuffix() {
		return "serviceValidate";
	}

	protected final Assertion parseResponseFromServer(String response)
			throws TicketValidationException {
		String error = XmlUtils.getTextForElement(response,
				"authenticationFailure");

		if (CommonUtils.isNotBlank(error)) {
			throw new TicketValidationException(error);
		}

		String principal = XmlUtils.getTextForElement(response, "user");
		String proxyGrantingTicketIou = XmlUtils.getTextForElement(response,
				"proxyGrantingTicket");

		String proxyGrantingTicket = this.proxyGrantingTicketStorage != null ? this.proxyGrantingTicketStorage
				.retrieve(proxyGrantingTicketIou) : null;

		if (CommonUtils.isEmpty(principal)) {
			throw new TicketValidationException(
					"No principal was found in the response from the CAS server.");
		}

		Map attributes = extractCustomAttributes(response);
		Assertion assertion;
		if (CommonUtils.isNotBlank(proxyGrantingTicket)) {
			AttributePrincipal attributePrincipal = new AttributePrincipalImpl(
					principal, attributes, proxyGrantingTicket,
					this.proxyRetriever);
			assertion = new AssertionImpl(attributePrincipal);
		} else {
			assertion = new AssertionImpl(new AttributePrincipalImpl(principal,
					attributes));
		}

		customParseResponse(response, assertion);

		return assertion;
	}

	protected Map extractCustomAttributes(String xml) {
		int pos1 = xml.indexOf("<cas:attributes>");
		int pos2 = xml.indexOf("</cas:attributes>");

		if (pos1 == -1) {
			return Collections.EMPTY_MAP;
		}

		String attributesText = xml.substring(pos1 + 16, pos2);

		Map attributes = new HashMap();
		BufferedReader br = new BufferedReader(new StringReader(attributesText));

		List attributeNames = new ArrayList();
		try {
			String line;
			while ((line = br.readLine()) != null) {
				String trimmedLine = line.trim();
				if (trimmedLine.length() > 0) {
					int leftPos = trimmedLine.indexOf(":");
					int rightPos = trimmedLine.indexOf(">");
					attributeNames.add(trimmedLine.substring(leftPos + 1,
							rightPos));
				}
			}
			br.close();
		} catch (IOException e) {
		}
		for (Iterator iter = attributeNames.iterator(); iter.hasNext();) {
			String name = (String) iter.next();
			attributes.put(name, XmlUtils.getTextForElement(xml, name));
		}

		return attributes;
	}

	protected void customParseResponse(String response, Assertion assertion)
			throws TicketValidationException {
	}

	public final void setProxyCallbackUrl(String proxyCallbackUrl) {
		this.proxyCallbackUrl = proxyCallbackUrl;
	}

	public final void setProxyGrantingTicketStorage(
			ProxyGrantingTicketStorage proxyGrantingTicketStorage) {
		this.proxyGrantingTicketStorage = proxyGrantingTicketStorage;
	}

	public final void setProxyRetriever(ProxyRetriever proxyRetriever) {
		this.proxyRetriever = proxyRetriever;
	}
}