package com.nantian.rept.controller;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.http.HttpServletResponse;
import javax.xml.namespace.QName;

import net.sf.json.JSONArray;

import org.apache.axis2.AxisFault;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.common.util.WebServiceInvokeUtil;
import com.nantian.jeda.Constants;
import com.nantian.jeda.ErrorCode;
import com.nantian.jeda.JEDAException;
import com.nantian.rept.ReptConstants;
import com.nantian.rept.service.RptDataInterfaceService;
import com.nantian.rept.service.ServerConfService;
import com.nantian.rept.service.WeblogicConfService;

@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/rptdatainterface")
public class RptDataInterfaceController {
	
	/** 模板管理领域对象名称 */
	private static final String domain = "RptDataManage";
	
	/** 视图前缀 */
	private static final String viewPrefix = "rept/" + domain + "/" + domain;
	
	@Autowired
	private WeblogicConfService weblogicConfService;
	
	@Autowired
	private RptDataInterfaceService rptDataInterfaceService;
	
	@Autowired
	private ServerConfService serverConfService;
	
	
	
	/**
	 * 返回weblogic数据管理页面
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/weblogic", method = RequestMethod.GET)
	public String weblogic() throws JEDAException {
		return viewPrefix + "Weblogic";
	}
	
	/**
	 * 调用webservice接口获取weblogic数据
	 * @param startDate 起始日期
	 * @param endDate 结束日期
	 * @param jsonArray
	 * @param type weblogic取数类型, 十进制表示二进制,三个位置分别代表jdbc, 
	 * 		内存, 队列. 对应的位置为1表示取, 0为不取.例如 3(011)表示只取内存队列
	 * @param modelMap 相应对象
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/importWeblogic", method = RequestMethod.POST)
	public @ResponseBody ModelMap importWeblogic(
			@RequestParam(value = "startDate", required = true) String startDate,
			@RequestParam(value = "endDate", required = true) String endDate,
			@RequestParam(value = "sourceType", required = true) int sourceType,
			@RequestParam(value = "type", required = true) int type,
			@RequestParam(value = "jsonArray", required = true) String jsonArray,
			ModelMap modelMap) throws JEDAException{
			// 输出开始日志
		/*Object[] params = new Object[]{startDate, endDate, type, jsonArray};
		QName qName = null;
		if(sourceType == 1){
			qName = new QName("http://webservice.common.nantian.com/", "importWeblogicData");
		}else if(sourceType == 2){
			qName = new QName("http://webservice.common.nantian.com/", "importWlsmWeblogicData");
		}*/		
		try {
			//WebServiceInvokeUtil.invokeWebServiceInterface(ReptConstants.DATA_COLLECT_WSDL, params, null, qName);
			if(sourceType == 1){
				rptDataInterfaceService.importSysResource("WEBLOGIC", startDate, endDate, jsonArray, "");
			}else {
				rptDataInterfaceService.importSysResource("WLSM", startDate, endDate, jsonArray, "");
			}
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", e.getMessage());
		}
		return modelMap;
	}
	
	/**
	 * 返回月报数据管理页面
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/month", method = RequestMethod.GET)
	public String month() throws JEDAException {
		return viewPrefix + "Month";
	}
	
	/**
	 * 调用webservice接口获取月报数据
	 * @param startMonth 起始月份
	 * @param endMonth 结束月份
	 * @param monthType 月报数据类型. 1为交易量;2为系统资源;3为分钟和秒交易量
	 * @param timesTransType 分钟和秒交易量类型.1为分钟交易量;2为秒钟交易量
	 * @param systems 系统编号.多个以逗号隔开
	 * @param modelMap 响应对象
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/importMonth", method = RequestMethod.POST)
	public @ResponseBody ModelMap importMonth(
			@RequestParam(value = "startMonth", required = true) String startMonth,
			@RequestParam(value = "endMonth", required = true) String endMonth,
			@RequestParam(value = "monthType", required = true) int monthType,
			@RequestParam(value = "timesTransType", required = false) int timesTransType,
			@RequestParam(value = "aplCode", required = true) String aplCode,
			ModelMap modelMap) throws JEDAException{
			// 输出开始日志
		Object[] params = null;
		String methodName = null;
		switch(monthType){
			case 1 : 
				params = new Object[]{startMonth, endMonth, aplCode};
				methodName = "importMonthsTrans";
				break;
			case 2 : 
				params = new Object[]{startMonth, endMonth, aplCode};
				methodName = "importMonthsResource";
				break;
			case 3 : 
				params = new Object[]{startMonth, endMonth, timesTransType, aplCode};
				methodName = "importMonthsTimesTrans";
				break;
		}
		
		QName qName = new QName("http://webservice.common.nantian.com/", methodName);
		try {
			int rows = (Integer) WebServiceInvokeUtil.invokeWebServiceInterface(
					ReptConstants.DATA_COLLECT_WSDL, params,
					new Class[] { Integer.class }, qName)[0];
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("rows", rows);
		} catch (AxisFault e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		
		return modelMap;
	}
	
	/**
	 * 返回周报数据管理页面
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/week", method = RequestMethod.GET)
	public String weeklyData() throws JEDAException {
		return viewPrefix + "Week";
	}
	
	/**
	 * 调用webservice接口获取周报数据
	 * @param startDate 起始日期
	 * @param endDate 结束日期
	 * @param weekType 周报数据类型.1为交易量;2为系统资源
	 * @param aplCode 系统编号.多个以逗号隔开
	 * @param modelMap 响应对象
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/importWeek", method = RequestMethod.POST)
	public @ResponseBody ModelMap importWeek(
			@RequestParam(value = "startDate", required = true) String startDate,
			@RequestParam(value = "endDate", required = true) String endDate,
			@RequestParam(value = "weekType", required = true) int weekType,
			@RequestParam(value = "aplCode", required = true) String aplCode,
			ModelMap modelMap) throws JEDAException{
			// 输出开始日志
		Object[] params = new Object[]{startDate, endDate, aplCode};
		String methodName = null;
		switch(weekType){
			case 1 : 
				methodName = "importWeekTrans";
				break;
			case 2 : 
				methodName = "importWeekResource";
				break;
		}
		
		QName qName = new QName("http://webservice.common.nantian.com/", methodName);
		try {
			int rows = (Integer) WebServiceInvokeUtil.invokeWebServiceInterface(
					ReptConstants.DATA_COLLECT_WSDL, params,
					new Class[] { Integer.class }, qName)[0];
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("rows", rows);
		} catch (AxisFault e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		
		return modelMap;
	}
	
	/**
	 * 返回获取系统资源页面
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/sysResource", method = RequestMethod.GET)
	public String sysResource() throws JEDAException {
		return viewPrefix + "SysResource";
	}
	
	/**
	 * 调用webservice接口获取系统资源
	 * @param startDate 起始日期
	 * @param endDate 结束日期
	 * @param sysSrvJson 系统主机名json字符串
	 * @param modelMap 相应对象
	 * @return
	 * @throws Exception 
	 */
	@RequestMapping(value = "/importSysResource", method = RequestMethod.POST)
	public @ResponseBody ModelMap importSysResource(
			@RequestParam(value = "startDate", required = true) String startDate,
			@RequestParam(value = "endDate", required = true) String endDate,
			@RequestParam(value = "sysSrvJson", required = true) String sysSrvJson,
			//Json格式：[{\"aplCode\":\"NEXCH\"\,\"srvCode\":\"BL685-005\"},{\"aplCode\":\"NEXCH\"\,\"srvCode\":\"BL685-005\"}]
			ModelMap modelMap){
			// 输出开始日志
		/*Object[] params = new Object[]{startDate, endDate, sysSrvJson};
		QName qName = new QName("http://webservice.common.nantian.com/", "importSysResource");*/
		try {
			/*int rows = (Integer)WebServiceInvokeUtil.invokeWebServiceInterface(
					ReptConstants.DATA_COLLECT_WSDL, params, new Class[] { Integer.class }, qName)[0];*/
			rptDataInterfaceService.importSysResource("SYSRES", startDate, endDate, sysSrvJson, "");
			modelMap.addAttribute("success", Boolean.TRUE);
			//modelMap.addAttribute("rows", rows);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", e.getMessage());
		}
		
		return modelMap;
	}
	
	/**
	 * 查询系统与IP的对应列表
	 * @param response
	 * @throws JEDAException
	 */
	@RequestMapping(value = "queryConfigIps", method = RequestMethod.GET)
	public @ResponseBody void queryConfigIps(
			@RequestParam(value = "aplCode", required = false) String aplCode,
			HttpServletResponse response) throws JEDAException {
		PrintWriter out = null;
		try {
			Object ipList = weblogicConfService.queryConfigIps(aplCode);
			JSONArray json = JSONArray.fromObject(ipList);
			out = response.getWriter();
			out.print(json);
		} catch (IOException e) {
			e.printStackTrace();
		}finally{
			if(out != null){
				out.close();
			}
		}
		
	}
	
	/**
	 * 查询系统代码与系统全称对应的列表
	 * @param response
	 * @throws JEDAException
	 */
	@RequestMapping(value = "querySysAplNames", method = RequestMethod.GET)
	public @ResponseBody void querySysAplNames(HttpServletResponse response) throws JEDAException {
		PrintWriter out = null;
		try {
			Object sysAplNameList = weblogicConfService.querySysAplNames();
			JSONArray json = JSONArray.fromObject(sysAplNameList);
			out = response.getWriter();
			out.print(json);
		} catch (IOException e) {
			e.printStackTrace();
		}finally{
			if(out != null){
				out.close();
			}
		}
		
	}
	
	/**
	 * 查询系统与主机名的对应列表
	 * @param response
	 * @throws JEDAException
	 */
	@RequestMapping(value = "queryServers", method = RequestMethod.GET)
	public @ResponseBody void queryServers(
			@RequestParam(value = "aplCode", required = false) String aplCode,
			HttpServletResponse response) throws JEDAException {
		PrintWriter out = null;
		try {
			Object srvCodeList = serverConfService.querySysSrvCode(aplCode);
			JSONArray json = JSONArray.fromObject(srvCodeList);
			out = response.getWriter();
			out.print(json);
		} catch (IOException e) {
			e.printStackTrace();
		}finally{
			if(out != null){
				out.close();
			}
		}
		
	}
	/**
	 * 返回阀值数据管理页面
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/datasource", method = RequestMethod.GET)
	public String datasource() throws JEDAException {
		return viewPrefix + "Datasource";
	}
	
	/**
	 * 调用webservice接口获取系统资源
	 * @param startDate 起始日期
	 * @param endDate 结束日期
	 * @param sysSrvJson 系统主机名json字符串

	 * @param modelMap 相应对象
	 * @return
	 * @throws Exception 
	 */
	@RequestMapping(value = "/importDatasource", method = RequestMethod.POST)
	public @ResponseBody ModelMap importDatasource(
			@RequestParam(value = "Date", required = true) String Date,
			@RequestParam(value = "aplCode", required = true) String aplCode,
			ModelMap modelMap){
		try {
			rptDataInterfaceService.Execute(aplCode,Date);
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", e.getMessage());
		}
		
		return modelMap;
	}
	
	/**
	 * 返回阀值数据管理页面
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/multtrans", method = RequestMethod.GET)
	public String multtrans() throws JEDAException {
		return viewPrefix + "MultTrans";
	}
	
	/**
	 * 调用webservice接口获取系统资源
	 * @param startDate 起始日期
	 * @param endDate 结束日期
	 * @param sysSrvJson 系统主机名json字符串

	 * @param modelMap 相应对象
	 * @return
	 * @throws Exception 
	 */
	@RequestMapping(value = "/importMultTrans", method = RequestMethod.POST)
	public @ResponseBody ModelMap importMultTrans(
			@RequestParam(value = "Date", required = true) String Date,
			@RequestParam(value = "aplCode", required = true) String aplCode,
			ModelMap modelMap){
			// 输出开始日志

		/*Object[] params = new Object[]{startDate, endDate, sysSrvJson};
		QName qName = new QName("http://webservice.common.nantian.com/", "importSysResource");*/
		try {
			/*int rows = (Integer)WebServiceInvokeUtil.invokeWebServiceInterface(
					ReptConstants.DATA_COLLECT_WSDL, params, new Class[] { Integer.class }, qName)[0];*/
			rptDataInterfaceService.importMultTrans(aplCode,Date);
			modelMap.addAttribute("success", Boolean.TRUE);
			//modelMap.addAttribute("rows", rows);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", e.getMessage());
		}
		
		return modelMap;
	}
	
	/**
	 * 返回阀值数据管理页面
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/systranspeak", method = RequestMethod.GET)
	public String systranspeak() throws JEDAException {
		return viewPrefix + "SysTransPeak";
	}
	
	/**
	 * 调用webservice接口获取系统资源
	 * @param startDate 起始日期
	 * @param endDate 结束日期
	 * @param sysSrvJson 系统主机名json字符串

	 * @param modelMap 相应对象
	 * @return
	 * @throws Exception 
	 */
	@RequestMapping(value = "/sysTransPeak", method = RequestMethod.POST)
	public @ResponseBody ModelMap sysTransPeak(
			@RequestParam(value = "Date", required = true) String Date,
			@RequestParam(value = "aplCode", required = true) String aplCode,
			ModelMap modelMap){
			// 输出开始日志

		/*Object[] params = new Object[]{startDate, endDate, sysSrvJson};
		QName qName = new QName("http://webservice.common.nantian.com/", "importSysResource");*/
		try {
			/*int rows = (Integer)WebServiceInvokeUtil.invokeWebServiceInterface(
					ReptConstants.DATA_COLLECT_WSDL, params, new Class[] { Integer.class }, qName)[0];*/
			rptDataInterfaceService.sysTransPeak(aplCode,Date);
			modelMap.addAttribute("success", Boolean.TRUE);
			//modelMap.addAttribute("rows", rows);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", e.getMessage());
		}
		
		return modelMap;
	}
	
	/**
	 * 返回阀值数据管理页面
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/exprstat", method = RequestMethod.GET)
	public String exprstat() throws JEDAException {
		return viewPrefix + "ExpRstat";
	}
	
	/**
	 * 调用webservice接口获取系统资源
	 * @param startDate 起始日期
	 * @param endDate 结束日期
	 * @param sysSrvJson 系统主机名json字符串

	 * @param modelMap 相应对象
	 * @return
	 * @throws Exception 
	 */
	@RequestMapping(value = "/expRstat", method = RequestMethod.POST)
	public @ResponseBody ModelMap expRstat(
			@RequestParam(value = "Date", required = true) String Date,
			@RequestParam(value = "aplCode", required = true) String aplCode,
			ModelMap modelMap){
			// 输出开始日志

		/*Object[] params = new Object[]{startDate, endDate, sysSrvJson};
		QName qName = new QName("http://webservice.common.nantian.com/", "importSysResource");*/
		try {
			/*int rows = (Integer)WebServiceInvokeUtil.invokeWebServiceInterface(
					ReptConstants.DATA_COLLECT_WSDL, params, new Class[] { Integer.class }, qName)[0];*/
			rptDataInterfaceService.expRstat(aplCode,Date);
			modelMap.addAttribute("success", Boolean.TRUE);
			//modelMap.addAttribute("rows", rows);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", e.getMessage());
		}
		
		return modelMap;
	}
}
