package com.nantian.check.utils;

import java.io.ByteArrayOutputStream;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import net.sf.jasperreports.engine.JRException;
import net.sf.jasperreports.engine.JRExporterParameter;
import net.sf.jasperreports.engine.JasperCompileManager;
import net.sf.jasperreports.engine.JasperExportManager;
import net.sf.jasperreports.engine.JasperFillManager;
import net.sf.jasperreports.engine.JasperPrint;
import net.sf.jasperreports.engine.JasperReport;
import net.sf.jasperreports.engine.data.JRBeanCollectionDataSource;
import net.sf.jasperreports.engine.export.JRHtmlExporter;
import net.sf.jasperreports.engine.export.JRHtmlExporterParameter;
import net.sf.jasperreports.engine.export.JRRtfExporter;
import net.sf.jasperreports.engine.export.JRXlsExporter;
import net.sf.jasperreports.engine.export.JRXlsExporterParameter;
import net.sf.jasperreports.engine.util.JRLoader;
import net.sf.jasperreports.j2ee.servlets.ImageServlet;

import org.springframework.stereotype.Controller;

/**
 * 报表导出工具类
 * @author linaWang
 *
 */
@Controller
public class JasperReportUtil {
	
	/*
	 * @ param reportFilePath：ireport模板路径
	 * @ param reportDataList：数据源列表
	 * @ param type：导出类型
	 */
	public void generateUtils(HttpServletRequest request,String reportFilePath,List reportDataList,String type) throws Exception {
		if(type.equals("html")){
			generateHtml(request,reportFilePath,reportDataList);
		}else if(type.equals("excel")){
			generateExcel(request,reportFilePath,reportDataList);
		}else if(type.equals("word")){
			generateWordOrRtf(reportFilePath,reportDataList);
		}else{ //pdf
			generatePDF(reportFilePath,reportDataList);
		}
	}
	
	/*
	 * 导出单个报表为HTML
	 * @ param JasperPrint,OutputStream,reportDataList
	 * @ 页面设置response.setContentType("text/html");
	 * @ 页面设置response.setHeader("Content-disposition","attachment;filename=fileName.html");
	 * @ 页面设置response.setContentLength(bytes.length);
	 */
	public byte[] generateHtml(HttpServletRequest request,String reportFilePath,List reportDataList) throws Exception {
		JRHtmlExporter exporter = new JRHtmlExporter();
		ByteArrayOutputStream oStream = new ByteArrayOutputStream();
		Map<String,Object> parameters = new HashMap<String,Object>();
		//装载数据
		JRBeanCollectionDataSource ds = new JRBeanCollectionDataSource(reportDataList);
		JasperReport jasperReport = null;
		if("jrxml".equals(reportFilePath.substring(reportFilePath.lastIndexOf(".")+1,reportFilePath.length()))){
			jasperReport = JasperCompileManager.compileReport(reportFilePath); //jrxml文件
		}else{
			jasperReport = (JasperReport)JRLoader.loadObject(reportFilePath); //jasper文件
		}
		JasperPrint jasperPrint = JasperFillManager.fillReport(jasperReport, parameters, ds);
		
		/*int pageIndex = 0 ;
		int lastPageIndex = 0 ;
		if(jasperPrint.getPages()!=null){
			lastPageIndex = jasperPrint.getPages().size()-1;
		}
	    if( pageNum != null)
	        pageIndex = Integer.parseInt(pageNum);
		if (pageIndex < 0){
		    pageIndex = 0;
		}
		if (pageIndex > lastPageIndex){
		    pageIndex = lastPageIndex;
		}
		exporter.setParameter(JRExporterParameter.PAGE_INDEX, new Integer(pageIndex));*/
		exporter.setParameter(JRExporterParameter.JASPER_PRINT, jasperPrint);
		exporter.setParameter(JRExporterParameter.CHARACTER_ENCODING, "UTF-8");
		exporter.setParameter(JRExporterParameter.OUTPUT_STREAM, oStream);
		//图片显示处理
		request.getSession().setAttribute(ImageServlet.DEFAULT_JASPER_PRINT_SESSION_ATTRIBUTE, jasperPrint); 
		exporter.setParameter(JRHtmlExporterParameter.IS_USING_IMAGES_TO_ALIGN,Boolean.TRUE);
		exporter.setParameter(JRHtmlExporterParameter.IS_OUTPUT_IMAGES_TO_DIR,Boolean.TRUE);
		exporter.setParameter(JRHtmlExporterParameter.IMAGES_URI, "image?image="); //控制html线条显示为红叉
		//导出
		exporter.exportReport();
		byte[] bytes = oStream.toByteArray();
		return bytes;
	}
	
	
	/*
	 * 导出单个报表为PDF
	 * @ param JasperPrint,OutputStream,reportDataList
	 * @ 页面设置response.setContentType("application/pdf");
	 * @ 页面设置response.setHeader("Content-disposition","attachment;filename=fileName.pdf");
	 * @ 页面设置response.setContentLength(bytes.length);
	 */
	public byte[] generatePDF(String reportFilePath,List reportDataList) throws Exception {
		Map<String,Object> parameters = new HashMap();
		JRBeanCollectionDataSource ds = new JRBeanCollectionDataSource(reportDataList);
		JasperPrint jasperPrint = JasperFillManager.fillReport(reportFilePath, parameters, ds);
		return JasperExportManager.exportReportToPdf(jasperPrint);
	}
	
	/*
	 * 导出单个报表为XLS(Excel)
	 * @ param JasperPrint,OutputStream,reportDataList
	 * @ 页面设置response.setContentType("application/vnd.ms-excel");
	 * @ 页面设置response.setHeader("Content-disposition","attachment;filename=fileName.xls");
	 * @ 页面设置response.setContentLength(bytes.length);
	 */
	public byte[] generateExcel(HttpServletRequest request,String reportFilePath,List reportDataList) throws Exception {
		Map parameters = new HashMap();
		JRXlsExporter exporter = new JRXlsExporter(); 
		ByteArrayOutputStream oStream = new ByteArrayOutputStream();
		JRBeanCollectionDataSource ds = new JRBeanCollectionDataSource(reportDataList);
		JasperPrint jasperPrint = JasperFillManager.fillReport(reportFilePath, parameters, ds);
		exporter.setParameter(JRExporterParameter.JASPER_PRINT, jasperPrint);
		exporter.setParameter(JRExporterParameter.OUTPUT_STREAM, oStream);
		exporter.setParameter(JRXlsExporterParameter.IS_REMOVE_EMPTY_SPACE_BETWEEN_ROWS,Boolean.TRUE);
		exporter.setParameter(JRXlsExporterParameter.IS_ONE_PAGE_PER_SHEET,Boolean.FALSE);
		exporter.setParameter(JRXlsExporterParameter.IS_WHITE_PAGE_BACKGROUND,Boolean.FALSE);
		//图片显示处理
		request.getSession().setAttribute(ImageServlet.DEFAULT_JASPER_PRINT_SESSION_ATTRIBUTE, jasperPrint); 
		exporter.setParameter(JRHtmlExporterParameter.IS_USING_IMAGES_TO_ALIGN,Boolean.TRUE);
		exporter.setParameter(JRHtmlExporterParameter.IS_OUTPUT_IMAGES_TO_DIR,Boolean.TRUE);
		exporter.setParameter(JRHtmlExporterParameter.IMAGES_URI, "image?image="); //控制html线条显示为红叉
		exporter.exportReport();
		byte[] bytes = oStream.toByteArray();
		return bytes;
	}
	
	/*
	 * 导出单个报表为rtf或word
	 * @ param JasperPrint,OutputStream,reportDataList
	 * @ 页面设置response.setContentType("application/msword");
	 * @ 页面设置response.setHeader("Content-disposition","attachment;filename=fileName.doc");
	 * @ 页面设置response.setContentLength(bytes.length);
	 */
	public byte[] generateWordOrRtf(String reportFilePath,List reportDataList) throws Exception {
		Map parameters = new HashMap();
		JRRtfExporter rtfExporter = new JRRtfExporter();
		ByteArrayOutputStream oStream = new ByteArrayOutputStream();
		try {
			JRBeanCollectionDataSource ds = new JRBeanCollectionDataSource(reportDataList);
			JasperPrint jasperPrint = JasperFillManager.fillReport(reportFilePath, parameters, ds);
			rtfExporter.setParameter(JRExporterParameter.JASPER_PRINT, jasperPrint);
			rtfExporter.setParameter(JRExporterParameter.OUTPUT_STREAM, oStream);
			rtfExporter.exportReport();
			byte[] bytes = oStream.toByteArray();
			return bytes;
		} catch (JRException e) {
			throw new Exception("Report Export Failed.");
		}
	}
	
	
}
