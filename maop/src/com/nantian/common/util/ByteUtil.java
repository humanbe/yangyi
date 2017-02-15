package com.nantian.common.util;

/**
 * @author <a href="mailto:donghui@nantian.com.cn">donghui</a>
 * 
 */
public class ByteUtil {
	
	public static boolean compare(byte[] b1, byte[] b2)
	  {
	    if (b1.length != b2.length) {
	      return false;
	    }
	    for (int i = 0; i < b1.length; i++) {
	      if (b1[i] != b2[i]) {
	        return false;
	      }
	    }
	    return true;
	  }
	
}
