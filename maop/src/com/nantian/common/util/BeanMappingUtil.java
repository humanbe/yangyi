package com.nantian.common.util;

import net.sf.dozer.util.mapping.DozerBeanMapper;
import net.sf.dozer.util.mapping.MapperIF;

public class BeanMappingUtil {
	  private static MapperIF instance = new DozerBeanMapper();

	  public static MapperIF getInstance()
	  {
	    return instance;
	  }
}
