package com.nantian.common.util;

import java.io.BufferedReader;
import java.io.StringReader;
import java.io.StringWriter;
import java.sql.Clob;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.dom4j.Document;
import org.dom4j.io.OutputFormat;
import org.dom4j.io.SAXReader;
import org.dom4j.io.XMLWriter;

import com.nantian.jeda.JEDAException;

/**
 * @author <a href="mailto:donghui@nantian.com.cn">donghui</a>
 * 
 */
public class StringUtil {
	
	private static char[] hexChars = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };

	
	  public static boolean isEmpty(String s)
	  {
	    return (s == null) || (s.equals(""));
	  }

	  
	  public static String toHex(byte[] data)
	  {
	    char[] oHex = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };

	    char[] hex = new char[oHex.length];
	    for (int i = 0; i < oHex.length; i++) {
	      hex[i] = oHex[i];
	    }

	    char[] buf = new char[data.length * 2];

	    int i = 0;
	    int j = 0;
	    for (; i < data.length; i++) {
	      byte k = data[i];
	      buf[(j++)] = hex[(k >>> 4 & 0xF)];
	      buf[(j++)] = hex[(k & 0xF)];
	    }
	    return new String(buf);
	  }

	  
	  public static byte[] hexToBytes(String str) {
	    byte[] bytes = new byte[(str.length() + 1) / 2];
	    if (str.length() == 0) {
	      return bytes;
	    }
	    bytes[0] = 0;
	    int nibbleIdx = str.length() % 2;
	    for (int i = 0; i < str.length(); i++) {
	      char c = str.charAt(i);
	      if (!isHex(c)) {
	        throw new IllegalArgumentException("string contains non-hex chars");
	      }

	      if (nibbleIdx % 2 == 0) {
	        bytes[(nibbleIdx >> 1)] = (byte)(hexValue(c) << 4);
	      }
	      else
	      {
	        int tmp92_91 = (nibbleIdx >> 1);
	        byte[] tmp92_88 = bytes; tmp92_88[tmp92_91] = (byte)(tmp92_88[tmp92_91] + (byte)hexValue(c));
	      }
	      nibbleIdx++;
	    }
	    return bytes;
	  }
	  

	  private static int hexValue(char c) {
	    if ((c >= '0') && (c <= '9'))
	      return c - '0';
	    if ((c >= 'a') && (c <= 'f')) {
	      return c - 'a' + 10;
	    }
	    return c - 'A' + 10;
	  }
	  

	  public static String bytesToHexString(byte[] bytes)
	  {
	    return bytesToHexString(bytes, null);
	  }
	  

	  public static String bytesToHexString(byte[] bytes, Character delimiter)
	  {
	    StringBuffer hex = new StringBuffer(bytes.length * (delimiter == null ? 2 : 3));

	    for (int i = 0; i < bytes.length; i++) {
	      int nibble1 = bytes[i] >>> 4 & 0xF;
	      int nibble2 = bytes[i] & 0xF;
	      if ((i > 0) && (delimiter != null))
	        hex.append(delimiter.charValue());
	      hex.append(hexChars[nibble1]);
	      hex.append(hexChars[nibble2]);
	    }
	    return hex.toString();
	  }
	  

	  public static boolean isHex(char c)
	  {
	    return ((c >= '0') && (c <= '9')) || ((c >= 'a') && (c <= 'f')) || ((c >= 'A') && (c <= 'F'));
	  }
	  

	  public static boolean isHex(String string)
	  {
	    if (string == null) {
	      return false;
	    }
	    for (int i = 0; i < string.length(); i++) {
	      char c = string.charAt(i);
	      if (!isHex(c)) {
	        return false;
	      }
	    }
	    return true;
	  }
	  

	  public static boolean isHex(String string, int length)
	  {
	    if (isEmpty(string)) {
	      return false;
	    }

	    if (string.length() != length) {
	      return false;
	    }

	    return isHex(string);
	  }
	  

	  public static String replaceWithEscape(String src, String target, String replace)
	  {
	    String replaced = src.replace("\\" + target, "@ESCAPE@");
	    replaced = replaced.replace(target, replace);
	    replaced = replaced.replace("@ESCAPE@", target);
	    return replaced;
	  }
	  

		/**
		 *Clob数据转换String
		 * 
		 * @throws JEDAException
		 */  
	  public static String clobToString(Clob dataValue){
		  StringBuffer valueString=new StringBuffer();
		  BufferedReader reader=null;
		  
		  try {
			reader=new BufferedReader(dataValue.getCharacterStream());
			String temp=null;
			while((temp=reader.readLine())!=null){
				valueString.append(temp);
			}
		} catch (Exception e) {
			
			e.printStackTrace();
		} 
		  
		return valueString.toString();
		  
	  }
	  /**
		 *ip验证
		 * 
		 * @throws JEDAException
		 */  
	  public static boolean checkIp(String ip){
			Pattern pattern = Pattern.compile("\\b((?!\\d\\d\\d)\\d+|1\\d\\d|2[0-4]\\d|25[0-5])\\.((?!\\d\\d\\d)\\d+|1\\d\\d|2[0-4]\\d|25[0-5])\\.((?!\\d\\d\\d)\\d+|1\\d\\d|2[0-4]\\d|25[0-5])\\.((?!\\d\\d\\d)\\d+|1\\d\\d|2[0-4]\\d|25[0-5])\\b");

			Matcher matcher = pattern.matcher(ip); //以验证127.400.600.2为例

			return matcher.matches();
	  }
	  
	public static String formatXML_cdata(String inputXML) throws Exception {
		SAXReader reader = new SAXReader();
		Document document = reader.read(new StringReader(inputXML));
		String requestXML = null;
		XMLWriter xw = null;
		if (document != null) {
			try {
				OutputFormat format = OutputFormat.createPrettyPrint();
				format.setEncoding("UTF-8");
				StringWriter sw = new StringWriter();
				xw = new XMLWriter(sw, format);
				xw.setEscapeText(false);
				xw.write(document);
				requestXML = sw.toString();
				xw.flush();
			} finally {
				if (xw != null) {
					xw.close();
				}
			}
		}
		return requestXML;
	}
}///:~
