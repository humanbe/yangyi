package org.jasig.cas.client.validation;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

/**
 * 重写CAS认证的类，修改CAS SERVER HOST地址从数据库获取
 * @author <a href="mailto:donghui@nantian.com.cn">donghui</a>
 */
public abstract class JedaAbstractCasProtocolUrlBasedTicketValidator extends
		JedaAbstractUrlBasedTicketValidator {
	protected JedaAbstractCasProtocolUrlBasedTicketValidator(
			String casServerUrlPrefix) {
		super(casServerUrlPrefix);
	}

	protected final String retrieveResponseFromServer(URL validationUrl,
			String ticket) {
		HttpURLConnection connection = null;
		try {
			String line = null;
			connection = (HttpURLConnection) validationUrl.openConnection();
			BufferedReader in = new BufferedReader(new InputStreamReader(
					connection.getInputStream()));

			StringBuffer stringBuffer = new StringBuffer(255);

			synchronized (stringBuffer) {
				while ((line = in.readLine()) != null) {
					stringBuffer.append(line);
					stringBuffer.append("\n");
				}
				String str1 = stringBuffer.toString();

				if (connection != null)
					connection.disconnect();
				return str1;
			}
		} catch (IOException e) {
			this.log.error(e, e);
			String line = null;
			return line;
		} finally {
			if (connection != null)
				connection.disconnect();
		}
	}
}