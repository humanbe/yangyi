package com.nantian.jeda.core.web;

import java.net.URLEncoder;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.math.NumberUtils;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFFont;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.hssf.util.HSSFColor;
import org.springframework.web.servlet.view.document.AbstractExcelView;

//import com.nantian.demo.common.ComUtil;
import com.nantian.common.util.ComUtil;
import com.nantian.jeda.Constants;
import com.nantian.jeda.JEDAException;
import com.nantian.rept.ReptConstants;

public class ExcelView4Request extends AbstractExcelView{

	private String tempName;
	@SuppressWarnings("unchecked")
	@Override
	protected void buildExcelDocument(Map<String, Object> model,
			HSSFWorkbook workbook, HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		String changeMonth = (String) model.get("month");
		tempName = "request_templet.xls";//ReptConstants.APP_CHANGE_FILE_NAME_PREFIX + ComUtil.checkNull(changeMonth) + ".xls";
		response.setHeader("Content-Disposition", "attachment; filename=\"" + URLEncoder.encode(tempName, "UTF-8") + "\"");
		Map<String, String> requestNum = (Map<String, String>) model.get("requestNum");
		Map<String, String> columns = (Map<String, String>) model.get("stepColumns");
		int sheetIndex = workbook.getSheetIndex("request");
		String[] sheetName = null;
		
		//普通数据样式：无背景色+边框样式实线
		HSSFCellStyle normalStyle = workbook.createCellStyle();
		normalStyle.setBorderTop((short)1);
		normalStyle.setBorderRight((short)1);
		normalStyle.setBorderBottom((short)1);
		normalStyle.setBorderLeft((short)1);
		
		if(requestNum != null && columns != null){
			String count[] = requestNum.toString().split("=")[1].split(",");
			sheetName = new String[count.length];
			sheetName[0] = "request";
			for(int i=1;i<count.length;i++){
				HSSFSheet sheet = workbook.cloneSheet(sheetIndex);
				sheetName[i] = sheet.getSheetName();
			}
			HSSFSheet sheet = null;
			List<Map<String, String>> data = null;
			List<Map<String, String>> requestData = null;
			for(int i=0;i<count.length;i++){
				data = (List<Map<String, String>>) model.get("stepData"+i);
				requestData = (List<Map<String, String>>) model.get("requestData"+i);

				for(int j=0;j<workbook.getNumberOfSheets();j++){
					sheet = workbook.getSheetAt(j);
					if(sheet.getSheetName().equals(sheetName[i])){
						if(data != null && columns != null){
							writeSheetByName(workbook, sheet, data, columns, requestData, normalStyle);
						}
						
					}
				}
			}
			columns = (Map<String, String>) model.get("riskEvalColumns");
			data = (List<Map<String, String>>) model.get("riskEvalData");
			sheet = workbook.getSheet(ReptConstants.APP_CHANGE_RISK_EVAL_SHEET);
			if(data != null && columns != null){
				writeSheetByName(workbook, sheet, data, columns, requestData, normalStyle);
			}
			
			columns = (Map<String, String>) model.get("summaryColumns");
			data = (List<Map<String, String>>) model.get("summaryData");
			sheet = workbook.getSheet(ReptConstants.APP_CHANGE_SUMMARY_SHEET);
			if(data != null && columns != null){
				writeSheetByName(workbook, sheet, data, columns, requestData, normalStyle);
			}
			
			columns = (Map<String, String>) model.get("monitorWarnColumns");
			data = (List<Map<String, String>>) model.get("monitorWarnData");
			sheet = workbook.getSheet(ReptConstants.MONITOR_WARN_SHEET);
			if(data != null && columns != null){
				writeSheetByName(workbook, sheet, data, columns, requestData, normalStyle);
			}
		}
		
		
			
		/*List<Map<String, String>> data = (List<Map<String, String>>) model.get("stepData");
		List<Map<String, String>> requestData = (List<Map<String, String>>) model.get("requestData");

		HSSFSheet sheet = workbook.getSheetAt(0);//workbook.getSheet(ReptConstants.APP_CHANGE_SHEET)
		if(data != null && columns != null){
			writeSheetByName(workbook, sheet, data, columns ,requestData);
		}
		
		columns = (Map<String, String>) model.get("riskEvalColumns");
		data = (List<Map<String, String>>) model.get("riskEvalData");
		sheet = workbook.getSheet(ReptConstants.APP_CHANGE_RISK_EVAL_SHEET);
		if(data != null && columns != null){
			writeSheetByName(workbook, sheet, data, columns,requestData);
		}
		
		columns = (Map<String, String>) model.get("summaryColumns");
		data = (List<Map<String, String>>) model.get("summaryData");
		sheet = workbook.getSheet(ReptConstants.APP_CHANGE_SUMMARY_SHEET);
		if(data != null && columns != null){
			writeSheetByName(workbook, sheet, data, columns,requestData);
		}
		
		columns = (Map<String, String>) model.get("monitorWarnColumns");
		data = (List<Map<String, String>>) model.get("monitorWarnData");
		sheet = workbook.getSheet(ReptConstants.MONITOR_WARN_SHEET);
		if(data != null && columns != null){
			writeSheetByName(workbook, sheet, data, columns,requestData);
		}*/
	}
	
	/**
	 * 将对应的列和数据写入报表
	 * @param book 工作簿
	 * @param sheet 工作报表
	 * @param data 数据
	 * @param columns 列
	 */
	private void writeSheetByName(HSSFWorkbook book, HSSFSheet sheet,
			List<Map<String, String>> data, Map<String, String> columns, List<Map<String, String>> requestData ,HSSFCellStyle normalStyle) {
		/*book.setActiveSheet(book.getSheetIndex(sheet));
		HSSFRow titleRow = sheet.getRow(0);
		
		
		HSSFFont statisticalFont = book.createFont();
		statisticalFont.setFontName("宋体");
		statisticalFont.setFontHeightInPoints((short)10);
		
		HSSFCellStyle statisticalStyle = book.createCellStyle();
		statisticalStyle.setBorderTop((short)1);
		statisticalStyle.setBorderRight((short)1);
		statisticalStyle.setBorderBottom((short)1);
		statisticalStyle.setBorderLeft((short)1);
		statisticalStyle.setAlignment(HSSFCellStyle.ALIGN_CENTER);
		statisticalStyle.setVerticalAlignment(HSSFCellStyle.VERTICAL_CENTER);
		statisticalStyle.setWrapText(true);//自动换行
		statisticalStyle.setFillForegroundColor(HSSFColor.WHITE.index);
		statisticalStyle.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);
		statisticalStyle.setFont(statisticalFont);
		
		int titleCol = 0;
		for(String key : columns.keySet()){
			if(titleRow.getLastCellNum() > titleCol){
				HSSFCell cell = titleRow.getCell(titleCol);
				if(cell == null) cell = titleRow.createCell(titleCol);
				setText(cell, columns.get(key));
				titleCol ++;
			}
		}
		
		HSSFCell cell;
		int col = 0;
		
		for (int rowCount = 0; rowCount < data.size(); rowCount++) {
			Map<String, String> map = data.get(rowCount);
			col = 0;
			for (Iterator<String> i = columns.keySet().iterator(); i.hasNext();) {
				Object columnKey = i.next();
				if(columnKey.toString().equalsIgnoreCase("sequence")){
					cell = getCell(sheet, rowCount + 1, col ++);
					cell.setCellType(HSSFCell.CELL_TYPE_FORMULA);
					cell.setCellStyle(statisticalStyle);
					cell.setCellFormula("ROW()-1");
					continue;
				}
				
				if(columnKey.toString().equalsIgnoreCase("primaryChangeRiskLink")){
					cell = getCell(sheet, rowCount + 1, col ++);
					cell.setCellStyle(statisticalStyle);
					if(map.get(columnKey) != null){
						cell.setCellType(HSSFCell.CELL_TYPE_FORMULA);
						String formula = "HYPERLINK(CONCATENATE(\"[" + tempName+"]" + 
								ReptConstants.APP_CHANGE_RISK_EVAL_SHEET + "!H\", A" +  
								(Integer.parseInt(map.get(columnKey)) + 1) + "+1),\"" + 
								ReptConstants.APP_CHANGE_RISK_EVAL_LINK +"\")";
						cell.setCellFormula(formula);
					}
					continue;
				}
				
				for (Iterator<String> iterator = map.keySet().iterator(); iterator.hasNext();) {
					String dataKey = iterator.next();
					if (columnKey.toString().equalsIgnoreCase(dataKey)) {
						String value = map.get(dataKey);
						cell = getCell(sheet, rowCount + 1, col ++);
						//设置格式
						cell.setCellStyle(statisticalStyle);
						if(NumberUtils.isNumber(value)){
							cell.setCellValue(NumberUtils.toDouble(value));
						}else{
							setText(cell, value);
						}
					}
				}
			}
		}*/
		
		
		
		HSSFCell cell;
		int col = 0;

		/*for (Iterator<String> iterator = columns.keySet().iterator(); iterator.hasNext();) {
			cell = getCell(sheet, 0, col);
			setText(cell, columns.get(iterator.next()));
			col++;
		}*/
		String app = requestData.get(0).get("app").toString();
		String environment = requestData.get(0).get("environment").toString();
		String name = requestData.get(0).get("name").toString();
		cell = getCell(sheet, 0, 1);
		setText(cell, name == null ? "" : name.toString());
		cell = getCell(sheet, 1, 1);
		setText(cell, app == null ? "" : app.toString());
		cell = getCell(sheet, 2, 1);
		setText(cell, environment == null ? "" : environment.toString());
		int row = 0;
		for (; row < data.size(); row++) {
			Map<String, String> map = data.get(row);

			col = 0;
			for (Iterator<String> i = columns.keySet().iterator(); i.hasNext();) {
				Object columnKey = i.next();
				for (Iterator<String> iterator = map.keySet().iterator(); iterator.hasNext();) {
					String dataKey = iterator.next();
					if (columnKey.toString().equalsIgnoreCase(dataKey)) {
						Object value = map.get(dataKey);
						cell = getCell(sheet, row + 5, col);
						setText(cell, value == null ? "" : value.toString());
						cell.setCellStyle(normalStyle);
						col++;
					}
				}
			}
		}
		
	}
}
