package org.jasig.cas.client.validation;

import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.jasig.cas.client.util.CommonUtils;
import org.springframework.beans.factory.annotation.Autowired;

import com.nantian.common.util.MyApplicationContextUtil;
import com.nantian.jeda.common.model.SubItem;
import com.nantian.jeda.security.util.ItemProvider;

/**
 * 重写CAS认证的类，修改CAS SERVER HOST地址从数据库获取
 * @author <a href="mailto:donghui@nantian.com.cn">donghui</a>
 */
public abstract class JedaAbstractUrlBasedTicketValidator implements
		TicketValidator {
	protected final Log log = LogFactory.getLog(getClass());
	private String casServerUrlPrefix;
	private boolean renew;
	private Map customParameters;

	@Autowired
	private ItemProvider itemProvider;

	protected JedaAbstractUrlBasedTicketValidator(String casServerUrlPrefix) {
		
		// add by donghui start 20141010
		if(null == itemProvider){
			itemProvider = (ItemProvider) MyApplicationContextUtil.springContext
					.getBean("itemProvider");
		}
		List<SubItem> subItemList = itemProvider.getSubItemEntity("CAS_SERVER");
		for (SubItem subItem : subItemList) {
			if ("HOST".equalsIgnoreCase(subItem.getName().trim())) {
				casServerUrlPrefix = subItem.getValue();
//				System.out
//						.println("$$$$$$$$$$$$$$$$$$$$$$$$$$ Father1 JedaAbstractUrlBasedTicketValidator ============"
//								+ casServerUrlPrefix);
			}
		}
		// add by donghui end 20141010
		
		this.casServerUrlPrefix = casServerUrlPrefix;
		CommonUtils.assertNotNull(this.casServerUrlPrefix,
				"casServerUrlPrefix cannot be null.");
	}

	protected void populateUrlAttributeMap(Map urlParameters) {
	}

	protected abstract String getUrlSuffix();

	protected final String constructValidationUrl(String ticket,
			String serviceUrl) {
		Map urlParameters = new HashMap();

		this.log.debug("Placing URL parameters in map.");
		urlParameters.put("ticket", ticket);
		urlParameters.put("service", encodeUrl(serviceUrl));

		if (this.renew) {
			urlParameters.put("renew", "true");
		}

		this.log.debug("Calling template URL attribute map.");
		populateUrlAttributeMap(urlParameters);

		this.log.debug("Loading custom parameters from configuration.");
		if (this.customParameters != null) {
			urlParameters.putAll(this.customParameters);
		}

		// add by donghui start 20141010
//		System.out
//		.println("$$$$$$$$$$$$$$$$$$$$$$$$$$ Father1 constructValidationUrl ============"
//				+ this.casServerUrlPrefix);
		if(null == itemProvider){
			itemProvider = (ItemProvider) MyApplicationContextUtil.springContext
					.getBean("itemProvider");
		}
		String casServerUrlPrefix = null;
		List<SubItem> subItemList = itemProvider.getSubItemEntity("CAS_SERVER");
		for (SubItem subItem : subItemList) {
			if ("HOST".equalsIgnoreCase(subItem.getName().trim())) {
				casServerUrlPrefix = subItem.getValue();
			}
		}
		if (null != casServerUrlPrefix){
			this.casServerUrlPrefix = casServerUrlPrefix;
		}
		// add by donghui end 20141010

		String suffix = getUrlSuffix();
		StringBuffer buffer = new StringBuffer(urlParameters.size() * 10
				+ this.casServerUrlPrefix.length() + suffix.length() + 1);

		int i = 0;
		synchronized (buffer) {
			buffer.append(this.casServerUrlPrefix);
			if (!this.casServerUrlPrefix.endsWith("/")) {
				buffer.append("/");
			}
			buffer.append(suffix);

			for (Iterator iter = urlParameters.entrySet().iterator(); iter
					.hasNext();) {
				buffer.append(i++ == 0 ? "?" : "&");
				Map.Entry entry = (Map.Entry) iter.next();
				String key = (String) entry.getKey();
				String value = (String) entry.getValue();

				if (value != null) {
					buffer.append(key);
					buffer.append("=");
					buffer.append(value);
				}
			}

			return buffer.toString();
		}
	}

	protected final String encodeUrl(String url) {
		if (url == null) {
			return null;
		}
		try {
			return URLEncoder.encode(url, "UTF-8");
		} catch (UnsupportedEncodingException e) {
		}
		return url;
	}

	protected abstract Assertion parseResponseFromServer(String paramString)
			throws TicketValidationException;

	protected abstract String retrieveResponseFromServer(URL paramURL,
			String paramString);

	public Assertion validate(String ticket, String service)
			throws TicketValidationException {
		String validationUrl = constructValidationUrl(ticket, service);
		if (this.log.isDebugEnabled()) {
			this.log.debug("Constructing validation url: " + validationUrl);
		}
		try {
			this.log.debug("Retrieving response from server.");
			String serverResponse = retrieveResponseFromServer(new URL(
					validationUrl), ticket);

			if (serverResponse == null) {
				throw new TicketValidationException(
						"The CAS server returned no response.");
			}

			if (this.log.isDebugEnabled()) {
				this.log.debug("Server response: " + serverResponse);
			}

			return parseResponseFromServer(serverResponse);
		} catch (MalformedURLException e) {
			throw new TicketValidationException(e);
		}
	}

	public void setRenew(boolean renew) {
		this.renew = renew;
	}

	public void setCustomParameters(Map customParameters) {
		this.customParameters = customParameters;
	}
}