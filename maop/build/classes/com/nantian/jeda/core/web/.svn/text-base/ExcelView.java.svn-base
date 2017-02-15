/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.jeda.core.web;

import java.net.URLEncoder;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.springframework.web.servlet.view.document.AbstractExcelView;

import com.nantian.jeda.Constants;
import com.nantian.jeda.JEDAException;

/**
 * @author <a href="mailto:daizhenzhong@nantian.com.cn">daizhenzhong</a>
 * 
 */
public class ExcelView extends AbstractExcelView {

	/**
	 * @param model
	 * @param workbook
	 * @param request
	 * @param response
	 * @throws Exception
	 * @see org.springframework.web.servlet.view.document.AbstractExcelView#buildExcelDocument(java.util.Map,
	 *      org.apache.poi.hssf.usermodel.HSSFWorkbook, javax.servlet.http.HttpServletRequest,
	 *      javax.servlet.http.HttpServletResponse)
	 */
	@SuppressWarnings("unchecked")
	@Override
	protected void buildExcelDocument(Map<String, Object> model, HSSFWorkbook workbook, HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		List<Map<String, String>> data = (List<Map<String, String>>) model.get(Constants.DEFAULT_RECORD_MODEL_KEY);
		// 列定义:有序的字段和名称映射表
		Map<String, String> columns = (Map<String, String>) model.get(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY);
		if (columns == null) {
			// 若列定义没有设置
			throw new JEDAException();
		}
		response.setHeader("Content-Disposition", "attachment; filename=\"" + URLEncoder.encode("导出文件", "UTF-8") + ".xls\"");
		HSSFSheet sheet = workbook.getSheetAt(0);
		HSSFCell cell;
		int col = 0;

		for (Iterator<String> iterator = columns.keySet().iterator(); iterator.hasNext();) {
			cell = getCell(sheet, 0, col);
			setText(cell, columns.get(iterator.next()));
			col++;
		}

		for (int row = 0; row < data.size(); row++) {
			Map<String, String> map = data.get(row);

			col = 0;
			for (Iterator<String> i = columns.keySet().iterator(); i.hasNext();) {
				Object columnKey = i.next();
				for (Iterator<String> iterator = map.keySet().iterator(); iterator.hasNext();) {
					String dataKey = iterator.next();
					if (columnKey.toString().equalsIgnoreCase(dataKey)) {
						Object value = map.get(dataKey);
						cell = getCell(sheet, row + 1, col);
						setText(cell, value == null ? "" : value.toString());
						col++;
					}
				}
			}

		}

	}

}
