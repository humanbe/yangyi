/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.jeda.core.web;

import java.net.URLEncoder;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.ClientAnchor;
import org.apache.poi.ss.usermodel.CreationHelper;
import org.apache.poi.ss.usermodel.Drawing;
import org.apache.poi.ss.usermodel.Picture;
import org.springframework.web.servlet.view.document.AbstractExcelView;

import com.nantian.common.util.CommonConst;
import com.nantian.common.util.DateFunction;
import com.nantian.rept.ReptConstants;
import com.nantian.rept.vo.AplAnalyzeVo;

/**
 * @author <a href="mailto:donghui@nantian.com.cn">donghui</a>
 * 
 */
public class ExcelViewDayRptAll extends AbstractExcelView {

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
		//首页运行情况总结数据
		List<AplAnalyzeVo> runStateDataList = (List<AplAnalyzeVo>) model.get(ReptConstants.DEFAULT_RUN_STATE_SUMMARY);
		//下载文件名称
		response.setHeader("Content-Disposition", "attachment; filename=\"" + URLEncoder.encode("导出文件", "UTF-8") + ".xls\"");
		
		//sheet名称
		HSSFSheet sheet;
		HSSFCell cell;
		
		// 编辑运行情况总结
		if(runStateDataList != null && runStateDataList.size() != 0){
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
								.append("0".equals(runStateDataList.get(i).getStatus())?CommonConst.NORMAL:CommonConst.ABNORMAL_CH)
								.append(CommonConst.LINE_FEED)
								.append(CommonConst.QUANJIAO_SPACE)
								.append(runStateDataList.get(i).getExeAnaDesc())
								.append(CommonConst.LINE_FEED)
								.append(CommonConst.LINE_FEED);
			}
			cell.setCellValue(summaryMsg.toString());
		}
		
		for (String sheetName : chartDatBytesListMap.keySet()) {
			sheet = workbook.createSheet(sheetName);
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
				anchor.setCol1(0);//起始列
				anchor.setRow1(count*18);//起始行
				
				Picture pict = drawing.createPicture(anchor, pictureIdx);
				//auto-size picture relative to its top-left corner
				pict.resize();
				count++;
			}
		}
		
	}
	

}///:~
