package com.nantian.rept.service;

import java.util.List;
import java.util.Map;

import org.springframework.ui.ModelMap;

public interface BaseService<E, C> {
	
	public void getColumns(List<E> elist, ModelMap modelMap, Object...options );
	
	public Map<String, Object> getRptData(List<E> elist, String sheetName,
			String aplCode, String startDate, String endDate, Object... options)
			throws Exception;
	
	public Map<String, String> getChart(List<E> elist, List<C> clist,
			List<Map<String, Object>> metedataMapList, Object...options) throws Exception;
	
	public Map<String, String> getConfigurableXlsColumns(List<E> elist, Object... options);
	
}
