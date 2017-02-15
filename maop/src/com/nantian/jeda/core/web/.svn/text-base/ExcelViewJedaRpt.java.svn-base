package com.nantian.jeda.core.web;

import java.io.File;
import java.io.FileInputStream;
import java.net.URLEncoder;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFFont;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.hssf.util.HSSFColor;
import org.apache.poi.poifs.filesystem.POIFSFileSystem;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.LocalizedResourceHelper;
import org.springframework.web.servlet.support.RequestContextUtils;
import org.springframework.web.servlet.view.AbstractView;

import com.nantian.jeda.Constants;
import com.nantian.jeda.JEDAException;

/**
 * 报表展现Excel导出
 * @author linaWang
 *
 */
public class ExcelViewJedaRpt extends AbstractView {
	
	/** 日志输出 */
	final Logger logger = Logger.getLogger(ExcelViewJedaRpt.class);
	
	private static boolean isWindows = false;
	private static String osName = null;
	static {
		osName = System.getProperty("os.name");
		System.getProperty("sun.jnu.encoding");
		if (osName.toUpperCase().startsWith("WINDOWS")) {
			isWindows = true;
		}
	}
	@Autowired
	private MessageSourceAccessor messages;
	
	private static final String CONTENT_TYPE = "application/vnd.ms-excel";

	private static final String EXTENSION = ".xls";

	private String url;

	public ExcelViewJedaRpt() {
		setContentType(CONTENT_TYPE);
	}

	public void setUrl(String url) {
		this.url = url;
	}

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
	protected void buildExcelDocument(Map<String, Object> model, HSSFWorkbook workbook, HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		List<Map<String, String>> data = (List<Map<String, String>>) model.get(Constants.DEFAULT_RECORD_MODEL_KEY);
		// 列定义:有序的字段和名称映射表		Map<String, String> columns = (Map<String, String>) model.get(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY);
		if (columns == null) {
			// 若列定义没有设置
			throw new JEDAException();
		}
		HSSFWorkbook book = null ;
		
		//默认开始行号
		int startRow = 0 ;
		//默认开始列号
		int startCol = 0 ;
		//导出模板全路径
		String templatePath = "";
		//jedaRptTemplate数据格式：模板编号#模板名称#开始行号#开始列号
		String template = (String) request.getSession().getAttribute("jedaRptTemplate");
		logger.info("Export Template Info : "+template);
		//报表配置了相应的导出模板，使用上传的Excel模板
		if(template!=null && !template.equals("")){
			String[] params = template.split("#");
			String templateCode = params[0];
			String templateName = "";
			if(params.length>1){
				templateName = params[1];
			}
			if(params.length>2){
				startRow = Integer.valueOf(params[2]);
			}
			if(params.length>3){
				startCol = Integer.valueOf(params[3]);
			}
			if(startRow>0){
				startRow = startRow -1 ;
			}
			if(startCol>0){
				startCol = startCol -1 ;
			}
			
			String name = templateName.substring(0,templateName.indexOf("."));
			String type = templateName.substring(templateName.indexOf("."));
			//模板上传时已经重命名：上传文件名_模板编号
			//templateName = name.concat("_").concat(templateCode).concat(type);
			//模板上传时已经重命名：模板编号
			templateName = templateCode.concat(type);
			
			response.setHeader("Content-Disposition", "attachment; filename=\"" + URLEncoder.encode(name, "UTF-8") + ".xls\"");
			
			if(isWindows){
				templatePath=messages.getMessage("jedarpt.templatePathForWin").concat(File.separator);
			}else{
				templatePath=messages.getMessage("jedarpt.templatePathForLinux").concat(File.separator);
			}
			templatePath = templatePath.concat(templateName);
			logger.info("Export Template Path : "+templatePath);
			File fi = new File(templatePath); 
		    POIFSFileSystem fs = new POIFSFileSystem(new FileInputStream(fi));
	    	book = new HSSFWorkbook(fs);
	    	HSSFSheet sheet = (HSSFSheet) book.getSheetAt(0);
			HSSFCell cell ;
			int col = startCol;
			// 写标题
			for (Iterator<String> iterator = columns.keySet().iterator(); iterator.hasNext();) {
				cell = getCell(sheet, startRow, col);
				setText(cell, columns.get(iterator.next()));
				col++;
			}
			/*注释人：代金玉
			 * 注释原因： 当使用brpm、nsh命令重启服务时，导出excel报错
			// 自适应列宽
			for (int i = 0; i < columns.keySet().size(); i++) {
				sheet.autoSizeColumn(i);
			}
			*/
	        // 遍历数据
			for (int row = 0; row < data.size(); row++) {
				Map<String, String> map = data.get(row);
				col = startCol;
				for (Iterator<String> i = columns.keySet().iterator(); i.hasNext();) {
					Object columnKey = i.next();
					for (Iterator<String> iterator = map.keySet().iterator(); iterator.hasNext();) {
						String dataKey = iterator.next();
						if (columnKey.toString().equalsIgnoreCase(dataKey)) {
							Object value = map.get(dataKey);
							cell = getCell(sheet, row + 1 + startRow, col);
							setText(cell, value == null ? "" : value.toString());
							col++;
						}
					}
				}
			}
		}else{  //报表未配置导出模板，使用默认的Excel模板
			response.setHeader("Content-Disposition", "attachment; filename=\"" + URLEncoder.encode("导出文件", "UTF-8") + ".xls\"");
			book = workbook;
			HSSFSheet sheet = (HSSFSheet) book.getSheetAt(0);
			HSSFCell cell ;
			int col = startCol;
			//数据标题字体样式
			HSSFFont titleFont = (HSSFFont) book.createFont();
			titleFont.setFontName("宋体");
			titleFont.setFontHeightInPoints((short)11);
			titleFont.setBoldweight(HSSFFont.BOLDWEIGHT_BOLD);

			//数据标题样式：橙色背景色+边框样式实线+粗体12
			HSSFCellStyle titleStyle = (HSSFCellStyle) book.createCellStyle();
			titleStyle.setBorderTop((short)1);
			titleStyle.setBorderRight((short)1);
			titleStyle.setBorderBottom((short)1);
			titleStyle.setBorderLeft((short)1);
			titleStyle.setFont(titleFont);
			titleStyle.setFillForegroundColor(HSSFColor.GOLD.index);
			titleStyle.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);
			titleStyle.setAlignment(HSSFCellStyle.ALIGN_CENTER);
			titleStyle.setVerticalAlignment(HSSFCellStyle.VERTICAL_CENTER);
			
			// 写标题
			for (Iterator<String> iterator = columns.keySet().iterator(); iterator.hasNext();) {
				cell = getCell(sheet, startRow, col);
				cell.setCellStyle(titleStyle);
				setText(cell, columns.get(iterator.next()));
				col++;
			}
			/*注释人：代金玉
			 * 注释原因： 当使用brpm、nsh命令重启服务时，导出excel报错
			// 自适应列宽
			for (int i = 0; i < columns.keySet().size(); i++) {
				sheet.autoSizeColumn(i);
			}
			*/
	        // 遍历数据
			for (int row = 0; row < data.size(); row++) {
				Map<String, String> map = data.get(row);
				col = startCol;
				for (Iterator<String> i = columns.keySet().iterator(); i.hasNext();) {
					Object columnKey = i.next();
					for (Iterator<String> iterator = map.keySet().iterator(); iterator.hasNext();) {
						String dataKey = iterator.next();
						if (columnKey.toString().equalsIgnoreCase(dataKey)) {
							Object value = map.get(dataKey);
							cell = getCell(sheet, row + 1 + startRow, col);
							setText(cell, value == null ? "" : value.toString());
							col++;
						}
					}
				}
			}
		}
		response.setContentType(getContentType());
		ServletOutputStream out = response.getOutputStream();
		book.write(out);
		out.flush();
	}

	@SuppressWarnings("deprecation")
	protected HSSFCell getCell(HSSFSheet sheet, int row, int col) {
		HSSFRow sheetRow = sheet.getRow(row);
		if (sheetRow == null) {
			sheetRow = sheet.createRow(row);
		}
		HSSFCell cell = sheetRow.getCell((short) col);
		if (cell == null) {
			cell = sheetRow.createCell((short) col);
		}
		return cell;
	}

	protected void setText(HSSFCell cell, String text) {
		cell.setCellType(HSSFCell.CELL_TYPE_STRING);
		cell.setCellValue(text);
	}
	
	/**
	 * Creates the workbook from an existing XLS document.
	 */
	protected HSSFWorkbook getTemplateSource(String url, HttpServletRequest request) throws Exception {
		LocalizedResourceHelper helper = new LocalizedResourceHelper(getApplicationContext());
		Locale userLocale = RequestContextUtils.getLocale(request);
		Resource inputFile = helper.findLocalizedResource(url, EXTENSION, userLocale);
		POIFSFileSystem fs = new POIFSFileSystem(inputFile.getInputStream());
		return new HSSFWorkbook(fs);
	}
	
	@Override
	protected boolean generatesDownloadContent() {
		return true;
	}

	@Override
	protected void renderMergedOutputModel(Map<String, Object> model,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		HSSFWorkbook workbook;
		if (this.url != null) {
			workbook = getTemplateSource(this.url, request);
		}
		else {
			workbook = new HSSFWorkbook();
			logger.debug("Created Excel Workbook from scratch");
		}
		buildExcelDocument(model, workbook, request, response);
	}
	
	
}
