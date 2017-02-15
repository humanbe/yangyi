package com.nantian.dply.service;

import java.io.IOException;
import java.io.StringReader;
import java.net.URISyntaxException;
import java.sql.Timestamp;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.input.SAXBuilder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.NoSuchMessageException;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import org.xml.sax.InputSource;

import com.nantian.common.util.DateFunction;
import com.nantian.component.brpm.BrpmConstants;
import com.nantian.component.brpm.BrpmInvocationException;
import com.nantian.component.brpm.BrpmService;
import com.nantian.component.log.Logger;
import com.nantian.dply.DplyConstants;
import com.nantian.dply.vo.DplyRequestInfoVo;

@Component
public class PetrolService {
	
	/** 日志输出 */
	final Logger logger = Logger.getLogger(PetrolService.class);
	
	@Autowired
    private CmnLogService cmnLogService;
	
	@Autowired
    private BrpmService brpmService;
	
	 /**
     * HIBERNATE Session Factory.
     */
    @Autowired
    private SessionFactory sessionFactory;
    
    private Map<String, String> reqNameIdMap = new HashMap<String, String>();
    
    private Session getSession(){
    	return sessionFactory.openSession();
    }
    
	/**
	 * 巡检日志登记
	 */
    @Transactional
	protected void patrolLogging() {
    	//获取连接
    	Session session = getSession();
		List<DplyRequestInfoVo> unfinishedList = queryUnfinishedRequests(session);
		//开启事物
		Transaction tran = session.getTransaction();
		tran.begin();
		if(unfinishedList.size() > 0){
			try {
				getRequestMapping();
				label : for(DplyRequestInfoVo vo : unfinishedList) {
					String result = brpmService.getMethodById("requests", reqNameIdMap.get(vo.getRequestCode()));
					if(result != null){
							StringReader reader = new StringReader(result);
							InputSource  source = new InputSource(reader);
							SAXBuilder sb = new SAXBuilder();
							Document doc = sb.build(source);
							Element root = doc.getRootElement();
							String status = root.getChildText("aasm-state");
							Timestamp startTimeStamp = null;
							Timestamp endTimeStamp = null;
							switch(DplyConstants.requestStateItem.getRequestState(status)){
							case started:
							case hold:
								status = "3";
								break;
							case complete :
								status = "4";
								break;
							case problem :
								status = "5";
								break;
							default :
								continue label;
							}
							
							if(!root.getChildText("started-at").equals("")){
								String startDateTime = root.getChildText("started-at");
								startDateTime = startDateTime.substring(0, 19).replaceAll("T", " ").replaceAll("-", "");
								long startTime = DateFunction.convertStr2Date(startDateTime, "yyyyMMdd HH:mm:ss").getTime();
								startTimeStamp = new Timestamp(startTime);
							}
							
							if(!root.getChildText("completed-at").equals("")){
								String endDateTime = root.getChildText("completed-at");
								endDateTime = endDateTime.substring(0, 19).replaceAll("T", " ").replaceAll("-", "");
								long endTime = DateFunction.convertStr2Date(endDateTime, "yyyyMMdd HH:mm:ss").getTime();
								endTimeStamp = new Timestamp(endTime);
							}
							
							if(!status.equals(vo.getExecStatus())){
								vo.setExecStatus(status);
								vo.setRealStartDate(startTimeStamp);
								vo.setRealEndDate(endTimeStamp);
								session.saveOrUpdate(vo);
								cmnLogService.logReuqest( vo, 
										DplyConstants.requestStateItem.getRequestState(
												root.getChildText("aasm-state")), root);
							}
					}
				}
				//提交事物
				tran.commit();
			} catch (Exception e) {
				//回滚事物
				tran.rollback();
				//关闭连接
				if(session.isOpen()) session.close();
				
				e.printStackTrace();
			}
		}
		//关闭连接
		if(session.isOpen()) session.close();
	}

	/**
	 * @return 请求列表
	 */
	@SuppressWarnings("unchecked")
	private List<DplyRequestInfoVo> queryUnfinishedRequests(Session session) {
		Calendar cal = Calendar.getInstance();
		cal.set(Calendar.DAY_OF_MONTH, 1);
		//当月第一天
		String startedStartDate = DateFunction.getFormatDateStr(cal.getTime(), "yyyyMMdd");
		cal.add(Calendar.MONDAY, 1);
		cal.add(Calendar.DATE, -1);
		//当月最后一天
		String startedEndDate = DateFunction.getFormatDateStr(cal.getTime(), "yyyyMMdd");
		StringBuilder hql = new StringBuilder();
		hql.append("from DplyRequestInfoVo t ")
			.append("where t.execStatus in ('2', '3', '5') ")
			.append("and t.planDeployDate between :startDate and :endDate ")
			.append("and t.trunSwitch = 1 ");
		
		return session.createQuery(hql.toString())
									.setString("startDate", startedStartDate)
									.setString("endDate", startedEndDate)
									.list();
	}
	
	/**
	 * 获取当月的所有发布请求
	 * @throws BrpmInvocationException
	 * @throws IOException
	 * @throws JDOMException
	 * @throws NoSuchMessageException
	 * @throws URISyntaxException
	 */
	private void getRequestMapping() throws BrpmInvocationException, IOException,
			JDOMException, NoSuchMessageException, URISyntaxException {
		Calendar cal = Calendar.getInstance();
		cal.set(Calendar.DAY_OF_MONTH, 1);
		//当月第一天
		String startedStartDate = DateFunction.getFormatDateStr(cal.getTime(), "MM/dd/yyyy");
		cal.add(Calendar.MONDAY, 1);
		cal.add(Calendar.DATE, -1);
		//当月最后一天
		String startedEndDate = DateFunction.getFormatDateStr(cal.getTime(), "MM/dd/yyyy");
		//请求的时间段过滤器, 已经启动的请求的日期范围
		//这里取的范围是本月内
		String filter = "{\"filters\":{\"started_start_date\":\""
				+ startedStartDate + "\", \"started_end_date\":\""
				+ startedEndDate + "\"}}";
		String responseXml = brpmService.getMethodByFilter("requests", filter);
		StringReader reader = new StringReader(responseXml);
		InputSource  source = new InputSource(reader);
		SAXBuilder sb = new SAXBuilder();
		Document doc = null;
		doc = sb.build(source);
		
		Element root = doc.getRootElement();
		for(Element child: root.getChildren()){
			reqNameIdMap.put(child.getChildText("name"), child.getChildText("id"));
		}
	}
	
	/**
	 * BRPM keep live方案（每小时定时调用BRPM环境获取API）
	 */
	protected void patrolBrpmReq() throws BrpmInvocationException, IOException,
	JDOMException, NoSuchMessageException, URISyntaxException {
		// 输出开始日志.
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "patrolBrpmReq");
		}
		String responseXml = brpmService.getMethod(BrpmConstants.KEYWORD_ENVIRONMENTS);
		// debug返回值.
		if (logger.isDebugEnable()) {
			logger.log("BRPM0002", responseXml);
		}
		// 输出结束日志.
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "patrolBrpmReq");
		}
    }
	
	
}
