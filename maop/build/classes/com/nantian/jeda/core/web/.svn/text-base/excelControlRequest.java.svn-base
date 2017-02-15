package com.nantian.jeda.core.web;

import java.net.URLEncoder;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.lang.String;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.springframework.web.servlet.view.document.AbstractExcelView;

import com.nantian.rept.ReptConstants;

public class excelControlRequest extends AbstractExcelView{

	private String tempName;
	@SuppressWarnings("unchecked")
	@Override
	protected void buildExcelDocument(Map<String, Object> model,
			HSSFWorkbook workbook, HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		String appsys_code = (String) request.getAttribute("appsys_code");
		tempName = appsys_code+"投产变更实施控制表.xls";//ReptConstants.APP_CHANGE_FILE_NAME_PREFIX + ComUtil.checkNull(changeMonth) + ".xls";
		response.setHeader("Content-Disposition", "attachment; filename=\"" + URLEncoder.encode(tempName, "UTF-8") + "\"");
		Map<String, String> requestNum = (Map<String, String>) model.get("requestNum");
		Map<String, String> columns = (Map<String, String>) model.get("stepColumns");
		
		Map<String, String> requestcodes=  (Map<String, String>)  model.get("requestcodes");
		 String []rcds=null;
		
		int sheetIndex = workbook.getSheetIndex("request");
		String[] sheetName = null;
		
		//普通数据样式：无背景色+边框样式实线
		HSSFCellStyle normalStyle = workbook.createCellStyle();
		normalStyle.setBorderTop((short)1);
		normalStyle.setBorderRight((short)1);
		normalStyle.setBorderBottom((short)1);
		normalStyle.setBorderLeft((short)1);
		
		
		
		if(requestNum != null && columns != null){
			 rcds=requestcodes.get("requestcodes").split(",");
			
			 HSSFSheet sheet1 = workbook.getSheetAt(0);
				replaceSheet(workbook,sheet1,rcds);
			 
			 
			sheetName = new String[rcds.length+2];
			sheetName[2] = "request";
			for(int i=1;i<rcds.length;i++){
				HSSFSheet sheet = workbook.cloneSheet(sheetIndex);
				sheetName[i+2] = sheet.getSheetName();
			}
			HSSFSheet sheet = null;
			List<Map<String, String>> data = null;
			List<Map<String, String>> requestData = null;
			for(int i=0;i<rcds.length;i++){
				data = (List<Map<String, String>>) model.get("stepData"+i);
				requestData = (List<Map<String, String>>) model.get("requestData"+i);

				for(int j=0;j<workbook.getNumberOfSheets();j++){
					sheet = workbook.getSheetAt(j);
					if(sheet.getSheetName().equals(sheetName[i+2])){
						if(data != null && columns != null){
							writeSheetByName(workbook, sheet, data, columns, requestData, normalStyle);
							
						}
						
					}
				}
				workbook.setSheetName(i+2, rcds[i].toString());
				
			}
			
		}
		

	}
	
	private void replaceSheet(HSSFWorkbook book, HSSFSheet sheet,String []rcds) {
		// TODO Auto-generated method stub
		String req ="";
		String reqrst ="";
		
		for (String rcd : rcds){
			if(rcd.indexOf("REQRST")!=-1){
				reqrst=reqrst+rcd+"  ";
			}else{
				req=req+rcd+"  ";
			}
			
		}
		
		HSSFCell cell1 = getCell(sheet, 5, 7);
		
		String t1=cell1.getStringCellValue().replaceAll("@REQRST@", reqrst).replaceAll("@REQ@", req);
		cell1.setCellValue(t1);
		
		HSSFCell cell2 = getCell(sheet, 8, 7);
		HSSFCell cell3 = getCell(sheet, 9, 7);
		HSSFCell cell4 = getCell(sheet, 10, 7);
		
		HSSFCell cell5 = getCell(sheet, 13, 7);
		HSSFCell cell6 = getCell(sheet, 14, 7);
		HSSFCell cell7 = getCell(sheet, 15, 7);
	
		
		String t2=cell2.getStringCellValue().replaceAll("@REQ@", req);
		cell2.setCellValue(t2);
		
		String t3=cell3.getStringCellValue().replaceAll("@REQ@", req);
		cell3.setCellValue(t3);
		
		String t4=cell4.getStringCellValue().replaceAll("@REQ@", req);
		cell4.setCellValue(t4);
		
		String t5=cell5.getStringCellValue().replaceAll("@REQRST@", reqrst);
		cell5.setCellValue(t5);
		
		String t6=cell6.getStringCellValue().replaceAll("@REQRST@", reqrst);
		cell6.setCellValue(t6);
		
		String t7=cell7.getStringCellValue().replaceAll("@REQRST@", reqrst);
		cell7.setCellValue(t7);
		
		
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
		
		HSSFCell cell;
		int col = 0;

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
