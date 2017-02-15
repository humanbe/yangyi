package com.nantian.common.util;

import java.io.StringReader;

import org.jdom2.Document;
import org.jdom2.input.SAXBuilder;
import org.xml.sax.InputSource;

/**
 * XML工具类
 * @author <a href="mailto:donghui@nantian.com.cn">donghui</a>
 *
 */
public class JDOMParserUtil {

	public static Document xmlParse(String xmlDoc){
		//创建一个新的字符串
		StringReader read=new StringReader(xmlDoc);
		//创建新的输入源SAX，解析器使用InputSource 对象来确定如何读取xml输入
		InputSource  source=new InputSource(read);
		//创建一个SAXBUilder
		SAXBuilder sb=new SAXBuilder();
		//通过输入源构建一个Document  
        Document doc = null;
		try {
			doc = sb.build(source);
		} catch (Exception e) {
			e.printStackTrace();
		}
        return doc;
	}

	
}///:~