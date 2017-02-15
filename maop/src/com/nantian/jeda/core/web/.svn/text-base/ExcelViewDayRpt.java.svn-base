/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.jeda.core.web;

import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.math.NumberUtils;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFFont;
import org.apache.poi.hssf.usermodel.HSSFPalette;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.hssf.util.HSSFColor;
import org.apache.poi.ss.usermodel.ClientAnchor;
import org.apache.poi.ss.usermodel.CreationHelper;
import org.apache.poi.ss.usermodel.Drawing;
import org.apache.poi.ss.usermodel.Picture;
import org.apache.poi.ss.util.CellRangeAddress;
import org.springframework.web.servlet.view.document.AbstractExcelView;

import com.nantian.common.util.CommonConst;
import com.nantian.common.util.DateFunction;
import com.nantian.jeda.Constants;
import com.nantian.jeda.JEDAException;
import com.nantian.rept.ReptConstants;
import com.nantian.rept.vo.AplAnalyzeVo;

/**
 * @author <a href="mailto:donghui@nantian.com.cn">donghui</a>
 * 
 */
public class ExcelViewDayRpt extends AbstractExcelView {

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
		//chart图表文件
		Map<String,List<byte[]>> chartDatBytesListMap = (Map<String, List<byte[]>>) model.get(ReptConstants.DEFAULT_CHART_DAT_KEY);
		//功能名称
		String sheetName = URLDecoder.decode((String) model.get(ReptConstants.DEFAULT_CHARTFILE_SHEETNAME), "UTF-8");
		// 数据
		List<Map<String, String>> data = (List<Map<String, String>>) model.get(Constants.DEFAULT_RECORD_MODEL_KEY);
		// 列定义:有序的字段和名称映射表		Map<String, String> columns = (Map<String, String>) model.get(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY);
		if (columns == null) {
			// 若列定义没有设置
			throw new JEDAException();
		}
		//首页运行情况总结数据
		List<AplAnalyzeVo> runStateDataList = (List<AplAnalyzeVo>) model.get(ReptConstants.DEFAULT_RUN_STATE_SUMMARY);
		//下载文件名称
		response.setHeader("Content-Disposition", "attachment; filename=\"" + URLEncoder.encode("导出文件", "UTF-8") + ".xls\"");
		//sheet名称
//		HSSFSheet sheet = workbook.createSheet("" == sheetName ? "未设定sheet名称" : URLDecoder.decode(sheetName, "UTF-8") + ("" == subSheetName ? "" : (URLDecoder.decode(sheetName, "UTF-8").indexOf(subSheetName) != -1?"":"(" + URLDecoder.decode(subSheetName, "UTF-8") + ")")));
		HSSFSheet sheet = workbook.createSheet("" == sheetName ? "Unknown Sheet" : sheetName);
		HSSFCell cell;
		int col = 0;
		int startRow = 1; // 写数据开始行
		boolean holidayFlag = false; // 节假日标识
		boolean statisticalFlag = false; // 统计值标识
		
		//数据标题字体样式
		HSSFFont titleFont = workbook.createFont();
		titleFont.setFontName("宋体");
		titleFont.setFontHeightInPoints((short)11);
		titleFont.setBoldweight(HSSFFont.BOLDWEIGHT_BOLD);
		//统计值数据字体样式
		HSSFFont statisticalFont = workbook.createFont();
		statisticalFont.setFontName("宋体");
		statisticalFont.setFontHeightInPoints((short)12);
		statisticalFont.setBoldweight(HSSFFont.BOLDWEIGHT_BOLD);
		
		//不使用POI提供的默认颜色，自定颜色索引
		 HSSFPalette hp=workbook.getCustomPalette();
	     hp.setColorAtIndex((short)63, (byte)60, (byte)179, (byte)113); //适中的海洋绿
	     hp.setColorAtIndex((short)62, (byte)255, (byte)165, (byte)0); //橙色
		
		//普通数据样式：无背景色+边框样式实线
		HSSFCellStyle normalStyle = workbook.createCellStyle();
		normalStyle.setBorderTop((short)1);
		normalStyle.setBorderRight((short)1);
		normalStyle.setBorderBottom((short)1);
		normalStyle.setBorderLeft((short)1);
		
		//数据标题样式：橙色背景色+边框样式实线+粗体12
		HSSFCellStyle titleStyle = workbook.createCellStyle();
		titleStyle.setBorderTop((short)1);
		titleStyle.setBorderRight((short)1);
		titleStyle.setBorderBottom((short)1);
		titleStyle.setBorderLeft((short)1);
		titleStyle.setFont(titleFont);
		titleStyle.setFillForegroundColor(HSSFColor.GOLD.index);
		titleStyle.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);
		titleStyle.setAlignment(HSSFCellStyle.ALIGN_CENTER);
		titleStyle.setVerticalAlignment(HSSFCellStyle.VERTICAL_CENTER);
		
		//休日的样式：橙色背景色+边框样式实线
		HSSFCellStyle holidayStyle = workbook.createCellStyle();
		holidayStyle.setBorderTop((short)1);
		holidayStyle.setBorderRight((short)1);
		holidayStyle.setBorderBottom((short)1);
		holidayStyle.setBorderLeft((short)1);
		holidayStyle.setFillForegroundColor(HSSFColor.GOLD.index);
		holidayStyle.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);
		
		//统计值的样式：绿色背景色+边框样式实线+粗体
		HSSFCellStyle statisticalStyle = workbook.createCellStyle();
		statisticalStyle.setBorderTop((short)1);
		statisticalStyle.setBorderRight((short)1);
		statisticalStyle.setBorderBottom((short)1);
		statisticalStyle.setBorderLeft((short)1);
		statisticalStyle.setFillForegroundColor((short)63);
		statisticalStyle.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);
		statisticalStyle.setFont(statisticalFont);
		
		if(runStateDataList != null && runStateDataList.size() != 0){
			// 编辑运行情况总结
			HSSFSheet summarySheet =  workbook.getSheet("运行情况总结");
			StringBuilder summaryMsg = new StringBuilder();
			cell = getCell(summarySheet, 4, 4);
			cell.setCellValue(cell.getStringCellValue().replaceAll("XXX", null!=runStateDataList.get(0).getAplCode()?runStateDataList.get(0).getAplCode():"Unknown System"));
			cell = getCell(summarySheet, 8, 6);
			cell.setCellValue(null!=runStateDataList.get(0).getAnaUser()?runStateDataList.get(0).getAnaUser():"Unknown AnaUser");
			cell = getCell(summarySheet, 10, 6);
			cell.setCellValue(null!=runStateDataList.get(0).getRevUser()?runStateDataList.get(0).getRevUser():"Unknown RevUser");
			cell = getCell(summarySheet, 12, 6);
			cell.setCellValue(DateFunction.getSystemTimeByFormat(0));
			
			cell = getCell(summarySheet, 14, 0);
			summaryMsg.append(cell.getStringCellValue()).append(CommonConst.LINE_FEED);
			for(int i = 0; i < runStateDataList.size(); i++){
				summaryMsg.append(i+1)
								.append(CommonConst.DOT_UNESCAPE)
								.append(runStateDataList.get(i).getAnaItem())
								.append(CommonConst.HALF_COLON)
								.append("2".equals(runStateDataList.get(i).getHandleState())?CommonConst.ABNORMAL_CH:CommonConst.NORMAL	)							
								.append(CommonConst.LINE_FEED)
								.append(CommonConst.QUANJIAO_SPACE)
								.append(null==runStateDataList.get(i).getExeAnaDesc()?"":runStateDataList.get(i).getExeAnaDesc())
								.append(CommonConst.LINE_FEED)
								.append(CommonConst.LINE_FEED);
			}
			cell.setCellValue(summaryMsg.toString());
		}
		
		// 根据图片数量计算数据写入起始行号
		if(null != chartDatBytesListMap){
			startRow = chartDatBytesListMap.get(sheetName).size()*18;
		}
		
		// 写标题		for (Iterator<String> iterator = columns.keySet().iterator(); iterator.hasNext();) {
			String key = iterator.next();
			//rows是代表合并行数的属性, 不必写入title
			if(key.equals("rows")) continue;
			cell = getCell(sheet, startRow, col);
			cell.setCellStyle(titleStyle);
			setText(cell, columns.get(key));
			col++;
		}
		
		// 合并标题单元格
		int rows2Merge = columns.get("rows") == null ? 1 : Integer.parseInt(columns.get("rows"));
		String columnMergeKey = null;
		String columnVal = null;
		String columnStr = null;
		Set<String> columnMergeKeyList = new HashSet<String>();
		Set<String> rowMergeKeyList = new HashSet<String>();
		List<Integer> columnMergeNums = new ArrayList<Integer>();
		for (Iterator<String> iterator = columns.keySet().iterator(); iterator.hasNext();) {
			columnStr = columns.get(iterator.next());
			if(columnStr.indexOf(CommonConst.UNDERLINE) != -1){
				columnMergeKeyList.add(columnStr.substring(0, columnStr.indexOf(CommonConst.UNDERLINE)));
			}else if(rows2Merge > 1){
				rowMergeKeyList.add(columnStr);
			}
		}
		
		for(String _rowMergeKey : rowMergeKeyList){
			for(int tCol = 0; tCol < columns.keySet().size(); tCol++){
				cell = getCell(sheet, startRow, tCol);
				if(cell.getStringCellValue().equals(_rowMergeKey)){
					sheet.addMergedRegion(new CellRangeAddress(startRow - 1, startRow - 1 + rows2Merge - 1, tCol, tCol));
					cell = getCell(sheet, startRow - 1, tCol);
					cell.setCellStyle(titleStyle);
					setText(cell, _rowMergeKey);
				}
			}
		}
		
		for (String _columnMergeKey : columnMergeKeyList) {
			for (int tCol = 0; tCol < columns.keySet().size(); tCol++) {
				cell = getCell(sheet, startRow, tCol);
				int firstPos = cell.getStringCellValue().indexOf(CommonConst.UNDERLINE);
				if(firstPos != -1){
					columnMergeKey = cell.getStringCellValue().substring(0,  firstPos);
					columnVal = cell.getStringCellValue().substring(firstPos + 1);
					if(columnMergeKey.equals(_columnMergeKey)){
						columnMergeNums.add(tCol);
						setText(cell, columnVal);
					}else{
						if(columnMergeNums.size() > 0)	break;
					}
				}
			}
			if(columnMergeNums.size() > 0){
				//Merging Cells
				sheet.addMergedRegion(new CellRangeAddress(startRow-1, startRow-1, columnMergeNums.get(0), columnMergeNums.get(columnMergeNums.size()-1)));
				for (Integer _col : columnMergeNums) {
					cell = getCell(sheet, startRow-1, _col);
					cell.setCellStyle(titleStyle);
				}
				cell = getCell(sheet, startRow-1, columnMergeNums.get(0));
				setText(cell, _columnMergeKey);
				columnMergeNums.clear();
			}
		}

		// 写数据		for (int row = 0; row < data.size(); row++) {
			Map<String, String> map = data.get(row);
			//循环初始化			holidayFlag = false;
			statisticalFlag = false;
			//取值			if(null != map.get("holidayFlag") && !"1".equals(map.get("holidayFlag"))) holidayFlag = true;
			if(null != map.get("statisticalFlag")) statisticalFlag = true;
			
			col = 0;
			boolean isEqual = false;
			for (Iterator<String> i = columns.keySet().iterator(); i.hasNext();) {
				isEqual = false;
				String columnKey = i.next();
				//rows是代表合并行数的属性, 不必写入数据
				if(columnKey.equals("rows")) continue;
				for (Iterator<String> iterator = map.keySet().iterator(); iterator.hasNext();) {
					String dataKey = iterator.next();
					if (columnKey.equalsIgnoreCase(dataKey)) {
						isEqual = true;
						Object value = map.get(dataKey);
						String cellVal = value == null ? "-" : value.toString();
						cell = getCell(sheet, startRow + 1, col);
						if(NumberUtils.isNumber(cellVal)){
							cell.setCellValue(NumberUtils.toDouble(cellVal));
						}else{
							setText(cell, cellVal);
						}
						col++;
						//设置格式
						if(holidayFlag != true && statisticalFlag != true){
							cell.setCellStyle(normalStyle);
							continue;
						}else if(holidayFlag == true){
							cell.setCellStyle(holidayStyle);
							continue;
						}else if(statisticalFlag == true){
							cell.setCellStyle(statisticalStyle);
							continue;
						}
					}
				}
				if(isEqual != true){
					cell = getCell(sheet, startRow + 1, col);
					setText(cell, "-");
					col++;
					//设置格式
					if(holidayFlag != true && statisticalFlag != true){
						cell.setCellStyle(normalStyle);
						continue;
					}else if(holidayFlag == true){
						cell.setCellStyle(holidayStyle);
						continue;
					}else if(statisticalFlag == true){
						cell.setCellStyle(statisticalStyle);
						continue;
					}
				}
				
			}
			startRow++;

		}
		
		// 自适应列宽
		/*for (int i = 0; i < columns.keySet().size(); i++) {
			sheet.autoSizeColumn(i);
		}
		*/
		// 写图片到导出的excel中此操作,放到调整自适应列宽后面，防止图片随列宽的变化而引起图片大小变大
		if(null != chartDatBytesListMap){
			//拆分多个文件，全部插入到excel
			int count = 0;
			for (byte[] datBytes : chartDatBytesListMap.get(sheetName)) {
				//获取文件在excel中的索引坐标
				int pictureIdx = workbook.addPicture(datBytes, HSSFWorkbook.PICTURE_TYPE_JPEG);
				
				CreationHelper helper = workbook.getCreationHelper();
				// create the drawing patriarch,this is the top level container for all shapes
				Drawing drawing = sheet.createDrawingPatriarch();
				//add a picture shape
				ClientAnchor anchor = helper.createClientAnchor();
				anchor.setAnchorType(ClientAnchor.DONT_MOVE_AND_RESIZE);//锁定位置和大小				
				// set top-left corner of the picture
				anchor.setCol1(0);//起始列				anchor.setRow1(count*18);//起始行				
				Picture pict = drawing.createPicture(anchor, pictureIdx);
				//auto-size picture relative to its top-left corner
				pict.resize();
				count++;
			}
		}

	}
	

}///:~
