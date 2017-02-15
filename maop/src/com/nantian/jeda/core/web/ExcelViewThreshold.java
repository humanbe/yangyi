package com.nantian.jeda.core.web;

import java.net.URLEncoder;
import java.util.HashSet;
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
import org.apache.poi.ss.util.CellRangeAddress;
import org.springframework.web.servlet.view.document.AbstractExcelView;

import com.nantian.jeda.Constants;
import com.nantian.rept.ReptConstants;

public class ExcelViewThreshold extends AbstractExcelView {

	@SuppressWarnings("unchecked")
	@Override
	protected void buildExcelDocument(Map<String, Object> model,
			HSSFWorkbook book, HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		List<Map<String, String>> data = (List<Map<String, String>>) model.get(Constants.DEFAULT_RECORD_MODEL_KEY);
		List<String> columns = (List<String>) model.get( Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY);
		HashSet<String> sheetSet = new HashSet<String>();
		HSSFSheet currSheet = null;
		HSSFRow currRow = null;
		HSSFCell cell = null;
		int startRow = 4;
		int col = 0;
		int modelSheetIndex = 0;
		
		response.setHeader("Content-Disposition", "attachment; filename=\"" + 
				URLEncoder.encode(ReptConstants.CAPACITY_THRESHOLD_FILE_NAME_PREFIX, "UTF-8") + ".xls\"");
		
		for(int i = 0; i < data.size(); i++){
			Map<String, String> map = data.get(i);
			String sysName = map.get("appsysName");
			if(sysName != null){
				sheetSet.add(sysName);
			}
		}
		//复制模板到新sheet并重命名
		for(String sheetName : sheetSet){
			currSheet = book.cloneSheet(modelSheetIndex);
			book.setSheetName(book.getSheetIndex(currSheet), sheetName);
		}
		
		HSSFFont cellFont = book.createFont();
		cellFont.setFontName("宋体");
		cellFont.setFontHeightInPoints((short)11);
		
		HSSFCellStyle cellStyle = book.createCellStyle();
		cellStyle.setBorderTop((short)1);
		cellStyle.setBorderRight((short)1);
		cellStyle.setBorderBottom((short)1);
		cellStyle.setBorderLeft((short)1);
		cellStyle.setAlignment(HSSFCellStyle.ALIGN_CENTER);
		cellStyle.setVerticalAlignment(HSSFCellStyle.VERTICAL_CENTER);
		cellStyle.setWrapText(true);//自动换行
		cellStyle.setFillForegroundColor(HSSFColor.WHITE.index);
		cellStyle.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);
		cellStyle.setFont(cellFont);
		
		for(int i = 0; i < data.size(); i++){
			Map<String, String> map = data.get(i);
			//这里的逻辑默认data的数据是按系统名排序的			//当记录的系统名变换时, 认为该工作表的数据已经写完			if(!currSheet.getSheetName().equals(map.get("appsysName"))){
				currSheet = book.getSheet(map.get("appsysName"));
				startRow = 4;
			}
			
			book.setActiveSheet(book.getSheetIndex(currSheet));
			currRow = currSheet.createRow(startRow++);
			col = 0;
			//保证映射对象取数据的顺序, 与excel的顺序相同			for(int j = 0; j < columns.size(); j++){
				String key = columns.get(j);
				if(!key.equals("appsysName")){
					cell = currRow.createCell(col++);
					cell.setCellStyle(cellStyle);
					String value = String.valueOf(map.get(key));
					if(value != null){
						if(NumberUtils.isNumber(value)){
							cell.setCellValue(NumberUtils.toDouble(value));
						}else{
							if(!"null".equals(value)){
								setText(cell, value);
							}
						}
					}
				}
			}
		}
		
		//合并每个sheet中指定的单元格
		for(String sheetName : sheetSet){
			currSheet = book.getSheet(sheetName);
			book.setActiveSheet(book.getSheetIndex(currSheet));
			mergedCellRange(currSheet, 4);
		}
		
		book.setActiveSheet(0);
		book.removeSheetAt(modelSheetIndex);
	}

	/**
	 * 合并指定的四种单元格.容量分类相同/阀值类型相同/阀值名称相同/阀值名称与子名称相同
	 * @param sheet
	 * @param startRow
	 */
	private void mergedCellRange(HSSFSheet sheet, int startRow) {
		int rowNum =	sheet.getPhysicalNumberOfRows() - startRow + 1;
		//excel中容量分类类型列索引
		int capColIdx = 0;
		//excel中阀值类型列索引
		int thresholdColIdx = 1;
		//excel中阀值名称列索引
		int itemCellColIdx = 2;
		int itemStartRow = startRow;
		int thresholdStartRow = startRow;
		int capStartRow = startRow;
		//处于容量分类列的单元格
		HSSFCell capCell;
		//处于阀值类型列的单元格
		HSSFCell thresholdCell;
		//阀值名称列的单元格
		HSSFCell itemCell;
		//被比较的单元格
		HSSFCell comparedCell;
		
		for(int i = 0; i < rowNum; i++){
			//合并阀值名称相同并
			itemCell = sheet.getRow(itemStartRow).getCell(itemCellColIdx);
			comparedCell = sheet.getRow(startRow + i).getCell(itemCellColIdx);
			if(!comparedCell.getStringCellValue().equals(itemCell.getStringCellValue())){
				if(itemStartRow < startRow + i - 1){
					sheet.addMergedRegion(new CellRangeAddress(itemStartRow , startRow + i - 1, itemCellColIdx, itemCellColIdx));
				}
				itemStartRow = startRow + i;
			}else if(comparedCell.getStringCellValue().equals(itemCell.getStringCellValue()) 
					&& itemStartRow < startRow + i && i == rowNum - 1){
				sheet.addMergedRegion(new CellRangeAddress(itemStartRow, startRow + i, itemCellColIdx, itemCellColIdx));
			}					
			
			//合并阀值类型相同的单元格			thresholdCell = sheet.getRow(thresholdStartRow).getCell(thresholdColIdx);
			comparedCell = sheet.getRow(startRow + i).getCell(thresholdColIdx);
			if(!comparedCell.getStringCellValue().equals(thresholdCell.getStringCellValue())){
				if(thresholdStartRow < startRow + i - 1){
					sheet.addMergedRegion(new CellRangeAddress(thresholdStartRow, startRow + i - 1, thresholdColIdx, thresholdColIdx));
				}
				thresholdStartRow = startRow + i;
			}else if(comparedCell.getStringCellValue().equals(thresholdCell.getStringCellValue()) 
					&& thresholdStartRow < startRow + i && i == rowNum - 1){
				sheet.addMergedRegion(new CellRangeAddress(thresholdStartRow, startRow + i, thresholdColIdx, thresholdColIdx));
			}
			//合并容量分类相同的单元格
			capCell = sheet.getRow(capStartRow).getCell(capColIdx);
			comparedCell = sheet.getRow(startRow + i).getCell(capColIdx);
			if(!comparedCell.getStringCellValue().equals(capCell.getStringCellValue())){
				if(capStartRow < startRow + i - 1){
					sheet.addMergedRegion(new CellRangeAddress(capStartRow, startRow + i - 1, capColIdx, capColIdx));
				}
				capStartRow = startRow + i;
			}else if(comparedCell.getStringCellValue().equals(capCell.getStringCellValue()) 
					&& capStartRow < startRow + i && i == rowNum - 1){
				sheet.addMergedRegion(new CellRangeAddress(capStartRow, startRow + i, capColIdx, capColIdx));
			}
		}
		
	}
}
