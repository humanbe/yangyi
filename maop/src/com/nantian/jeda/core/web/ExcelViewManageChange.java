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
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.util.CellRangeAddress;
import org.springframework.web.servlet.view.document.AbstractExcelView;

import com.nantian.common.util.ComUtil;
import com.nantian.rept.ReptConstants;

public class ExcelViewManageChange extends AbstractExcelView{

	private String tempName;
	@SuppressWarnings("unchecked")
	@Override
	protected void buildExcelDocument(Map<String, Object> model,
			HSSFWorkbook workbook, HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		String changeMonth = (String) model.get("month");
		tempName = ReptConstants.APP_CHANGE_FILE_NAME_PREFIX + ComUtil.checkNull(changeMonth) + ".xls";
		response.setHeader("Content-Disposition", "attachment; filename=\"" + URLEncoder.encode(tempName, "UTF-8") + "\"");
		
		Map<String, String> columns = (Map<String, String>) model.get("appChangeColumns");
		List<Map<String, String>> data = (List<Map<String, String>>) model.get("appChangeData");
		HSSFSheet sheet = workbook.getSheet(ReptConstants.APP_CHANGE_SHEET);
		if(data != null && columns != null){
			writeSheetByName(workbook, sheet, data, columns);
		}
		
		columns = (Map<String, String>) model.get("riskEvalColumns");
		data = (List<Map<String, String>>) model.get("riskEvalData");
		sheet = workbook.getSheet(ReptConstants.APP_CHANGE_RISK_EVAL_SHEET);
		if(data != null && columns != null){
			writeSheetByName(workbook, sheet, data, columns);
		}
		
		columns = (Map<String, String>) model.get("summaryColumns");
		data = (List<Map<String, String>>) model.get("summaryData");
		sheet = workbook.getSheet(ReptConstants.APP_CHANGE_SUMMARY_SHEET);
		if(data != null && columns != null){
			writeSheetByName(workbook, sheet, data, columns);
		}
		
		columns = (Map<String, String>) model.get("monitorWarnColumns");
		data = (List<Map<String, String>>) model.get("monitorWarnData");
		sheet = workbook.getSheet(ReptConstants.MONITOR_WARN_SHEET);
		if(data != null && columns != null){
			writeSheetByName(workbook, sheet, data, columns);
		}
		
		columns = (Map<String, String>) model.get("umpMonitorWarnColumns");
		data = (List<Map<String, String>>) model.get("umpMonitorWarnData");
		sheet = workbook.getSheet(ReptConstants.MONITOR_WARN_UMP_SHEET);
		if(data != null && columns != null){
			writeSheetByName(workbook, sheet, data, columns);
		}
		
		columns = (Map<String, String>) model.get("changeCalendarColumns");
		data = (List<Map<String, String>>) model.get("changeCalendarData");
		sheet = workbook.getSheet(ReptConstants.CHANGE_CALENDAR_SHEET);
		if(data != null && columns != null){
			writeSheetByName(workbook, sheet, data, columns);
			mergedCellRange(sheet,1);
		}

	}
	
	/**
	 * 将对应的列和数据写入报表
	 * @param book 工作簿
	 * @param sheet 工作报表
	 * @param data 数据
	 * @param columns 列
	 */
	private void writeSheetByName(HSSFWorkbook book, HSSFSheet sheet,
			List<Map<String, String>> data, Map<String, String> columns) {
		book.setActiveSheet(book.getSheetIndex(sheet));
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
		}
	}
	
	/**
	 * 合并指定的四种单元格.容量分类相同/阀值类型相同/阀值名称相同/阀值名称与子名称相同
	 * @param sheet
	 * @param startRow
	 */
	private void mergedCellRange(HSSFSheet sheet, int startRow) {
		int rowNum = sheet.getPhysicalNumberOfRows() - startRow;
		
		int sysNameColIdx = 1;
		int eapsCodeColIdx = 4;
		int planStartTimeColIdx = 6;
		int planEndTimeColIdx = 7;
		int itemStartRow = startRow;
		
		StringBuilder cell = new StringBuilder();
		//处于容量分类列的单元格
		HSSFCell sysNameCell;
		HSSFCell eapsCodeCell;
		//处于阀值类型列的单元格
		HSSFCell planStartTimeCell;
		//阀值名称列的单元格
		HSSFCell planEndTimeCell;
		//被比较的单元格
		StringBuilder comparedCell = new StringBuilder();
		HSSFCell comparedSysNameCell;
		HSSFCell comparedEapsCodeCell;
		HSSFCell comparedPlanStartTimeCell;
		HSSFCell comparedPlanEndTimeCell;
		
		for(int i = 0; i < rowNum; i++){
			//合并阀值名称相同并
			cell.delete(0, cell.length());
			comparedCell.delete(0, comparedCell.length());
			
			sysNameCell = sheet.getRow(itemStartRow).getCell(sysNameColIdx);
			eapsCodeCell = sheet.getRow(itemStartRow).getCell(eapsCodeColIdx);
			planStartTimeCell = sheet.getRow(itemStartRow).getCell(planStartTimeColIdx);
			planEndTimeCell = sheet.getRow(itemStartRow).getCell(planEndTimeColIdx);
			
			sysNameCell.setCellType(Cell.CELL_TYPE_STRING);
			eapsCodeCell.setCellType(Cell.CELL_TYPE_STRING);
			planStartTimeCell.setCellType(Cell.CELL_TYPE_STRING);
			planEndTimeCell.setCellType(Cell.CELL_TYPE_STRING);
			
			cell.append(sysNameCell.getStringCellValue())
				.append(eapsCodeCell.getStringCellValue())
				.append(planStartTimeCell.getStringCellValue())
				.append(planEndTimeCell.getStringCellValue());
			
			comparedSysNameCell = sheet.getRow(startRow + i).getCell(sysNameColIdx);
			comparedEapsCodeCell = sheet.getRow(startRow + i).getCell(eapsCodeColIdx);
			comparedPlanStartTimeCell = sheet.getRow(startRow + i).getCell(planStartTimeColIdx);
			comparedPlanEndTimeCell = sheet.getRow(startRow + i).getCell(planEndTimeColIdx);
			
			comparedSysNameCell.setCellType(Cell.CELL_TYPE_STRING);
			comparedEapsCodeCell.setCellType(Cell.CELL_TYPE_STRING);
			comparedPlanStartTimeCell.setCellType(Cell.CELL_TYPE_STRING);
			comparedPlanEndTimeCell.setCellType(Cell.CELL_TYPE_STRING);
			
			comparedCell.append(comparedSysNameCell.getStringCellValue())
						.append(comparedEapsCodeCell.getStringCellValue())
						.append(comparedPlanStartTimeCell.getStringCellValue())
						.append(comparedPlanEndTimeCell.getStringCellValue());
			
			if(!comparedCell.toString().equals(cell.toString())){
				if(itemStartRow < startRow + i - 1){
					for(int j = 0; j < 9; j++){
						sheet.addMergedRegion(new CellRangeAddress(itemStartRow , startRow + i - 1, j, j));
					}
				}
				itemStartRow = startRow + i;
			}else if(comparedCell.toString().equals(cell.toString()) 
					&& itemStartRow < startRow + i && i == rowNum - 1){
				for(int j = 0; j < 9; j++){
					sheet.addMergedRegion(new CellRangeAddress(itemStartRow, startRow + i, j, j));
				}
			}					
		}
		
	}

}
