package com.nantian.common.webservice.impl;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.output.XMLOutputter;
import org.springframework.beans.factory.annotation.Autowired;

import com.nantian.common.util.JDOMParserUtil;
import com.nantian.common.webservice.IToolWSService;
import com.nantian.toolbox.service.ToolBoxAlarmService;
import com.nantian.toolbox.vo.MonitorWarninginfoVo;

public class ToolWSService implements IToolWSService {
	@Autowired
	ToolBoxAlarmService toolBoxAlarmService ;

	@Override
	public String syncComponentType(String componentTypes) {
		return null;
	}

	@Override
	public String syncComponent(String components) {
		return null;
	}

	@Override
	public String syncSubComponent(String subComponents) {
		return null;
	}

	@Override
	public String syncEventGroup(String eventGroups) {
		return null;
	}

	
	@Override
	public String syncWarningMessage(String monitor_warning_info) {
		
		String xml = null;//返回值

		Document resultDocument = null;//文档对象
		Element rootElement = null;//根要素

		Element okElement = null;//成功要素
		Element errElement = null;//失败要素
		XMLOutputter outputter = null;
		List<String> okList = new ArrayList<String>();//正常列表
		List<String> errList = new ArrayList<String>();//异常列表
		MonitorWarninginfoVo mwVo ;
		
		try{
			//1.读xml
			Document doc = JDOMParserUtil.xmlParse(monitor_warning_info);
	        List<Element> warningMessages =doc.getRootElement().getChildren();//获得所有子要素集合
	        
	        for(Element warningMessage : warningMessages){
	        	try{
	        		mwVo = new MonitorWarninginfoVo();
		        	mwVo.setEvent_id(warningMessage.getChildTextTrim("eventId"));//事件ID（必填）
		      
		        	if(null != warningMessage.getChildText("customerSeverity")) mwVo.setCustomerseverity(Integer.parseInt(warningMessage.getChildText("customerSeverity")));//级别
		        	if(null != warningMessage.getChildText("deviceId")) mwVo.setDevice_id(warningMessage.getChildText("deviceId"));//设备
		        	if(null != warningMessage.getChildText("deviceIp")) mwVo.setDevice_ip(warningMessage.getChildText("deviceIp"));//IP
		        	if(null != warningMessage.getChildText("alarmObject")) mwVo.setAlarmobject(warningMessage.getChildText("alarmObject"));//告警对象
		        	if(null != warningMessage.getChildText("componentType")) mwVo.setComponenttype(warningMessage.getChildText("componentType"));//事件大类
		        	if(null != warningMessage.getChildText("component")) mwVo.setComponent(warningMessage.getChildText("component"));//事件子类
		        	if(null != warningMessage.getChildText("subcomponent")) mwVo.setSubcomponent(warningMessage.getChildText("subcomponent"));//事件细类
		        	if(null != warningMessage.getChildText("summarycn")) mwVo.setSummarycn(warningMessage.getChildText("summarycn"));//摘要
		        	if(null != warningMessage.getChildText("eventStatus")) mwVo.setEventstatus(Integer.parseInt(warningMessage.getChildText("eventStatus")));//事件状态
		        	if(null != warningMessage.getChildText("firstTime")) mwVo.setFirst_time(Timestamp.valueOf(warningMessage.getChildText("firstTime")));//首次发生时间
		        	if(null != warningMessage.getChildText("lastTime")) mwVo.setLast_time(Timestamp.valueOf(warningMessage.getChildText("lastTime")));//最后发生时间		        	
		        	if(null != warningMessage.getChildText("alarmInstance")) mwVo.setAlarminstance(warningMessage.getChildText("alarmInstance"));//告警实例
		        	if(null != warningMessage.getChildText("appName")) mwVo.setAppname(warningMessage.getChildText("appName"));//系统名称
		        	if(null != warningMessage.getChildText("manageByCenter")) mwVo.setManagebycenter(Integer.parseInt(warningMessage.getChildText("manageByCenter")));//接管状态
		        	if(null != warningMessage.getChildText("manageByUser")) mwVo.setManagebyuser(warningMessage.getChildText("manageByUser"));//接管人
		        	if(null != warningMessage.getChildText("manageTimeExceed")) mwVo.setManagetimeexceed(warningMessage.getChildText("manageTimeExceed"));//接管超时
		        	
		        	if(null != warningMessage.getChildText("manageTime")) mwVo.setManagetime(Timestamp.valueOf(warningMessage.getChildText("manageTime")));//接管时间
		        	
		        	if(null != warningMessage.getChildText("maintainStatus")) mwVo.setMaintainstatus(Integer.parseInt(warningMessage.getChildText("maintainStatus")));//维护期	
		        	if(null != warningMessage.getChildText("repeatNumber")) mwVo.setRepeat_number(Integer.parseInt(warningMessage.getChildText("repeatNumber")));//重复次数
		        	
		        	if(null != warningMessage.getChildText("mgtorg")) mwVo.setMgtorg(warningMessage.getChildText("mgtorg"));//管理机构
		        	if(null != warningMessage.getChildText("orgName")) mwVo.setOrgname(warningMessage.getChildText("orgName"));//所属机构
		        	if(null != warningMessage.getChildText("eventGroup")) mwVo.setEvent_group(warningMessage.getChildText("eventGroup"));//事件组
		        	if(null != warningMessage.getChildText("monitorTool")) mwVo.setMonitor_tool(warningMessage.getChildText("monitorTool"));//监控工具
		        	if(null != warningMessage.getChildText("isTicket")) mwVo.setIs_ticket(warningMessage.getChildText("isTicket"));//是否生成工单
		        	if(null != warningMessage.getChildText("nTicketid")) mwVo.setN_ticketid(warningMessage.getChildText("nTicketid"));//工单ID	
		        	if(null != warningMessage.getChildText("umpId")) mwVo.setUmp_id(warningMessage.getChildText("umpId"));//UMP现场数据关联ID
		        	if(null != warningMessage.getChildText("causeEffect")) mwVo.setCause_effect(warningMessage.getChildText("causeEffect"));//因果分类
		        	if(null != warningMessage.getChildText("parentEventId")) mwVo.setParent_event_id(warningMessage.getChildText("parentEventId"));//父类事件号
		        	mwVo.setHandle_status("1");
		        	
		        	toolBoxAlarmService.save(mwVo);
	        		okList.add(warningMessage.getChildTextTrim("eventId"));
	        	}catch(Exception e){
	        		System.out.println(e.getMessage());
	        		e.printStackTrace();
	        		errList.add(warningMessage.getChildTextTrim("eventId"));
	        	}
	        }
			//2.编辑XML并输出
			rootElement = new Element("results");//根要素
			resultDocument = new Document(rootElement);//文档对象
			
			okElement = new Element("result").setAttribute("returncode", "true");//成功要素
			rootElement.addContent(okElement);//添加成功要素
			
			errElement  = new Element("result").setAttribute("returncode", "false");//失败要素
			rootElement.addContent(errElement);//添加失败要素
			if(okList.size() ==0){
				okElement.addContent("");
			}else{
				for (String okId : okList) {//OK列表
					okElement.addContent(new Element("eventId").addContent(okId));
				}
			}
			
			if(errList.size() ==0){
				errElement.addContent("");
			}else{
				for (String errId : errList) {//ERR列表
					errElement.addContent(new Element("eventId").addContent(errId));
				}
			}
			outputter = new XMLOutputter();
		    outputter.output(resultDocument, System.out);
		    xml = outputter.outputString(resultDocument);
		}catch(Exception e){
			System.out.println(e.getMessage());
			e.printStackTrace();
		}
		
		return xml;
	}

}
