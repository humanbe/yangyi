/**
 * 
 */
package com.nantian.jeda.util;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.springframework.web.bind.ServletRequestBindingException;
import org.springframework.web.bind.ServletRequestUtils;

import com.nantian.jeda.FieldType;

/**
 * @author daizhenzhong
 * 
 */
public class RequestUtil {

	public static Map<String, Object> getQueryMap(HttpServletRequest request, Map<String, String> fields) {
		Map<String, Object> map = new HashMap<String, Object>();
		try {
			for (String field : fields.keySet()) {
				String value = ServletRequestUtils.getStringParameter(request, field);
				if (null != value && !value.isEmpty()) {
					if (fields.get(field).equals(FieldType.STRING)) {
						map.put(field, "%" + value + "%");
					} else if (fields.get(field).equals(FieldType.INTEGER)) {
						map.put(field, Integer.valueOf(value));
					} else if (fields.get(field).equals(FieldType.LONG)) {
						map.put(field, Long.valueOf(value));
					} else if (fields.get(field).equals(FieldType.DOUBLE)) {
						map.put(field, Double.valueOf(value));
					} else if (fields.get(field).equals(FieldType.DATE)) {
						SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");
						map.put(field, format.parse(value));
					} else if (fields.get(field).equals(FieldType.TIME)) {
						SimpleDateFormat format = new SimpleDateFormat("HH:mm:ss");
						map.put(field, format.parse(value));
					} else if (fields.get(field).equals(FieldType.TIMESTAMP)) {
						SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
						map.put(field, format.parse(value));
					}
				}
			}

		} catch (ServletRequestBindingException e) {
			e.printStackTrace();
		} catch (ParseException e) {
			e.printStackTrace();
		}
		return map;
	}
}
