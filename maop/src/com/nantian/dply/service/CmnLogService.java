package com.nantian.dply.service;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.StringReader;
import java.net.URISyntaxException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import org.apache.tools.ant.types.CommandlineJava.SysProperties;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.input.SAXBuilder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.NoSuchMessageException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.xml.sax.InputSource;

import com.nantian.common.util.CommonConst;
import com.nantian.common.util.Constants;
import com.nantian.common.util.DateFunction;
import com.nantian.component.brpm.BrpmInvocationException;
import com.nantian.component.brpm.BrpmService;
import com.nantian.dply.DplyConstants;
import com.nantian.dply.DplyConstants.requestStateItem;
import com.nantian.dply.DplyConstants.stepStateItem;
import com.nantian.dply.vo.CmnDetailLogVo;
import com.nantian.dply.vo.CmnLogVo;
import com.nantian.dply.vo.DplyRequestInfoVo;
import com.nantian.jeda.security.util.SecurityUtils;
import com.nantian.toolbox.vo.ToolBoxDescInfoVo;

@Service
public class CmnLogService {
	
	@Autowired
	private CmnDetailLogService cmnDetailLogService;
	
    @Autowired
    private BrpmService brpmService;
    @Autowired
	 private SecurityUtils securityUtils; 
	/**
     * HIBERNATE Session Factory.
     */
    @Autowired
    private SessionFactory sessionFactory;
    
    public Session getSession() {
        return sessionFactory.getCurrentSession();
    }
    
    public Session getSessionByThread() {
    	return sessionFactory.openSession();
    }
    
    /**
     * 保存.
     * 
     * @param cmnLogVo
     */
    @Transactional
    public Long save(CmnLogVo cmnLogVo) {
        return (Long) getSession().save(cmnLogVo);
    }
    
    /**
	 * 修改日志信息
	 * @param cmnLogVo 日志记录对象
	 */
	@Transactional
	public void update(CmnLogVo cmnLogVo) {
		getSession().update(cmnLogVo);
	}
    
	/**
	 * 修改日志信息
	 * @param cmnLogVo 日志记录对象
	 */
	@Transactional
	public void updatecdlv(CmnDetailLogVo cdlv) {
		getSession().update(cdlv);
	}
	
	@Transactional
	public void updateCMNLOG(Timestamp endtime,Long logJnlNo) {
		getSession().createQuery("update  CmnLogVo cl set cl.execCompletedTime=? where cl.logJnlNo=?")
				.setTimestamp(0, endtime)
				.setLong(1, logJnlNo)
				.executeUpdate();
	}
	
	public void updateCMNLOGPaltForm(Long logJnlNo) {
		Timestamp endtime = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())) ;
		getSession().createQuery("update  CmnLogVo cl set cl.execCompletedTime=? where cl.logJnlNo=?")
				.setTimestamp(0, endtime)
				.setLong(1, logJnlNo)
				.executeUpdate();
	}
	
	@Transactional
	public void updateCMNLOGPaltFormSuccess(Long logJnlNo) {
		Timestamp endtime = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())) ;
		getSession().createQuery("update  CmnLogVo cl set cl.execStatus='0',cl.execCompletedTime=? where cl.logJnlNo=?")
				.setTimestamp(0, endtime)
				.setLong(1, logJnlNo)
				.executeUpdate();
	}
	
	
	@Transactional
	public void logReuqest(DplyRequestInfoVo dplyReqVo, requestStateItem state,
			Element root) throws NoSuchMessageException, IOException,
			BrpmInvocationException, URISyntaxException, JDOMException,
			ParseException {
		
    	CmnLogVo vo = new CmnLogVo();
    	switch(state){
    		case started:
    		case created:
    		case hold:
    		case cancelled:
    		case deleted:
    		case planned:
    			return;
			case complete:
				vo.setExecStatus("0");
				break;
			case problem:
				vo.setExecStatus("1");
				break;
    	}
    	
    	Date d = new Date(dplyReqVo.getRealStartDate().getTime());
    	Timestamp createdTime = null;
		Timestamp updatedTime = null;
		Timestamp startTime = null;
		Timestamp completedTime = null;
		String timeStr = "";
		long time = 0;
    	if(!root.getChildText("created-at").equals("")){
    		timeStr = root.getChildText("created-at");
    		timeStr = timeStr.substring(0, 19).replaceAll("T", " ").replaceAll("-", "");
    		time = DateFunction.convertStr2Date(timeStr, "yyyyMMdd HH:mm:ss").getTime();
			createdTime = new Timestamp(time);
		}
		
		if(!root.getChildText("updated-at").equals("")){
			timeStr = root.getChildText("updated-at");
			timeStr = timeStr.substring(0, 19).replaceAll("T", " ").replaceAll("-", "");
			time = DateFunction.convertStr2Date(timeStr, "yyyyMMdd HH:mm:ss").getTime();
			updatedTime = new Timestamp(time);
		}
		
		if(!root.getChildText("started-at").equals("")){
			timeStr = root.getChildText("created-at");
			timeStr = timeStr.substring(0, 19).replaceAll("T", " ").replaceAll("-", "");
			time = DateFunction.convertStr2Date(timeStr, "yyyyMMdd HH:mm:ss").getTime();
			startTime = new Timestamp(time);
		}
		
		if(!root.getChildText("completed-at").equals("")){
			timeStr = root.getChildText("updated-at");
			timeStr = timeStr.substring(0, 19).replaceAll("T", " ").replaceAll("-", "");
			time = DateFunction.convertStr2Date(timeStr, "yyyyMMdd HH:mm:ss").getTime();
			completedTime = new Timestamp(time);
		}
		String request_name=dplyReqVo.getRequestName()+CommonConst.MSG_CUT_UP+dplyReqVo.getEnvironment();
		//判断是否已存在数据---------------------------
		
				
				StringBuilder sql = new StringBuilder();
				sql.append("select count(*) from cmn_log t ")
					.append(" where t.REQUEST_NAME= :request_name ")
					.append(" and  t.EXEC_CREATED_TIME = :createdTime ")
					.append(" and t.EXEC_UPDATED_TIME = :updatedTime ");
				Query query=getSession().createSQLQuery(sql.toString()).setString("request_name", request_name)
				.setTimestamp("createdTime", createdTime).setTimestamp("updatedTime", updatedTime);
				
					Long l=Long.valueOf(query.uniqueResult().toString());
					
					if(l>0){
						return;
					}
					
	//判断是否已存在数据---------------------------
		
		
    	vo.setAppsysCode(dplyReqVo.getAppSysCode());
		vo.setExecDate(new SimpleDateFormat("yyyyMMdd").format(d));
    	vo.setLogResourceType("1");
    	vo.setLogType("1");
    	vo.setRequestName(dplyReqVo.getRequestName()+CommonConst.MSG_CUT_UP+dplyReqVo.getEnvironment());
    	vo.setExecStartTime(dplyReqVo.getRealStartDate());
    	vo.setExecCompletedTime(dplyReqVo.getRealEndDate());
		vo.setExecCreatedTime(createdTime);
		vo.setExecUpdatedTime(updatedTime);
		vo.setAuthorizedUser("Automatic");
		vo.setPlatformUser("Automatic");
		Long logseq = null;
		//获取连接
		Session session = getSessionByThread();
		//开启事物
		Transaction tran = session.getTransaction();
		tran.begin();
		try{
			logseq = (Long)session.save(vo);
			//提交事物
			tran.commit();
		}catch(Exception e){
			//回滚事物
			tran.rollback();
			//关闭连接
			if(session.isOpen()) session.close();
		}
		//关闭连接
		if(session.isOpen()) session.close();
    	
    	Integer logCount = 0;
    	List<Element> stepsRoot = root.getChild("steps").getChildren();
    	stepRoot : for(Element step: stepsRoot){
    		switch(DplyConstants.stepStateItem.getStepState(step.getChildText("aasm-state"))){
    		case problem :
    		case complete :
    			String result = brpmService.getMethodById("steps", step.getChildText("id"));
    			StringReader reader = new StringReader(result);
    			InputSource  source = new InputSource(reader);
    			SAXBuilder sb = new SAXBuilder();
    			Document stepDoc = null;
    			stepDoc = sb.build(source);
    			Element sroot = stepDoc.getRootElement();
    			
    			createdTime = null;
    			updatedTime = null;
    			startTime = null;
    			completedTime = null;
    			timeStr = "";
    			time = 0;
    			String execDt = "";
    			if(!sroot.getChildText("created-at").equals("")){
    				timeStr = sroot.getChildText("created-at");
    				timeStr = timeStr.substring(0, 19).replaceAll("T", " ").replaceAll("-", "");
    				time = DateFunction.convertStr2Date(timeStr, "yyyyMMdd HH:mm:ss").getTime();
    				createdTime = new Timestamp(time);
    			}
    			
    			if(!sroot.getChildText("updated-at").equals("")){
    				timeStr = sroot.getChildText("updated-at");
    				timeStr = timeStr.substring(0, 19).replaceAll("T", " ").replaceAll("-", "");
    				time = DateFunction.convertStr2Date(timeStr, "yyyyMMdd HH:mm:ss").getTime();
    				updatedTime = new Timestamp(time);
    			}
    			
    			if(!sroot.getChildText("work-started-at").equals("")){
    				timeStr = sroot.getChildText("work-started-at");
    				timeStr = timeStr.substring(0, 19).replaceAll("T", " ").replaceAll("-", "");
    				time = DateFunction.convertStr2Date(timeStr, "yyyyMMdd HH:mm:ss").getTime();
    				startTime = new Timestamp(time);
    				execDt = sroot.getChildText("work-started-at").substring(0, 10).replaceAll("-", "");
    			}
    			
    			if(!sroot.getChildText("work-finished-at").equals("")){
    				timeStr = sroot.getChildText("work-finished-at");
    				timeStr = timeStr.substring(0, 19).replaceAll("T", " ").replaceAll("-", "");
    				time = DateFunction.convertStr2Date(timeStr, "yyyyMMdd HH:mm:ss").getTime();
    				completedTime = new Timestamp(time);
    			}
    			
    			
    			String jobsResult = brpmService.getMethodByFilter("job_runs", "{\"filters\" : {\"step_id\" : " + step.getChildText("id") + "}}");
    			String resultsPath = null;
    			if(jobsResult != null){
    				StringReader jobsReader = new StringReader(jobsResult);
    				InputSource  jobsSource = new InputSource(jobsReader);
    				SAXBuilder jobsSb = new SAXBuilder();
    				Document jobsDoc = null;
    				jobsDoc = jobsSb.build(jobsSource);
    				Element jobsRoot = jobsDoc.getRootElement();
    				resultsPath = jobsRoot.getChildren().get(0).getChildText("results-path");
    				
    		       //读取文件获取路径		
    				if(resultsPath!=null&&!"".equals(resultsPath)){
    				InputStream in = null;
    				BufferedReader reader2 = null;
    				String line="";
    				File file=new File(resultsPath);
    			
    				in = new FileInputStream(file);
    				reader2 = new BufferedReader(new InputStreamReader(in,"gbk"));
    				while((line = reader2.readLine()) != null){
    			
    					if(	line.indexOf("$$SS_Pack_Response{job_log=>")!=-1){
    						resultsPath=line.substring(line.indexOf("/"), line.lastIndexOf("}"));
    					};
    			}
    			if(reader != null){
    				reader.close();
    			}
    			}
    			}
    			
    			CmnDetailLogVo stepVo = new CmnDetailLogVo();
    			stepVo.setLogJnlNo(logseq);
    			stepVo.setDetailLogSeq((++logCount).toString());
    			stepVo.setAppsysCode(dplyReqVo.getAppSysCode());
    			stepVo.setExecDate(execDt);
    			stepVo.setStepName(sroot.getChildText("name"));
    			switch(stepStateItem.getStepState(sroot.getChildText("aasm-state"))){
	        		case locked:
	        		case ready:
	        		case being_resolved:
	        		case blocked:
	        		case in_process:
	        			continue stepRoot;
	    			case complete:
	    				stepVo.setExecStatus("0");
	    				break;
	    			case problem:
	    				stepVo.setExecStatus("1");
	    				break;
	        	}
    			stepVo.setExecCreatedTime(createdTime);
    			stepVo.setExecCompletedTime(completedTime);
    			stepVo.setExecStartTime(startTime);
    			stepVo.setExecUpdatedTime(updatedTime);
    			stepVo.setJobName("--");
    			stepVo.setExecServerIp("--");
    			stepVo.setResultsPath(resultsPath);
//    			stepVo.setExecCmd(execCmd)
    			stepVo.setLogType("1");
    			//cmnDetailLogService.save(stepVo);
    			cmnDetailLogService.saveByThread(stepVo);
    		}
		}
    	
    }
	
	/**
	 * 修改日志信息
	 * @param type 日志记录对象
	 */
	@Transactional
	public  Long logPaltform(int type){
		Date startDate = new Date();
		String logState = "1" ; //执行状态（O:正常、1：平台异常、2：BRPM异常、3：BSA异常）
		String execdate = new SimpleDateFormat("yyyyMMdd").format(startDate) ;
		String starttime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate);
		CmnLogVo cmnLog = new CmnLogVo();
		
		switch(type){
		case 0: cmnLog.setRequestName("应用系统数据同步");
		         break;
		case 1: cmnLog.setRequestName("服务器信息数据同步");
	             break;
		case 2: cmnLog.setRequestName("操作用户数据同步");
	            break;
		}
		cmnLog.setAppsysCode("MAOP");
		cmnLog.setLogResourceType("1"); //1:自动化平台、2：BRPM、3 ：BSA
		
		cmnLog.setLogType("4"); //1:应用发布、2：工具箱、3：自动巡检、4：公共平台
		cmnLog.setExecStatus(logState);
		cmnLog.setExecDate(execdate);
		cmnLog.setExecStartTime(Timestamp.valueOf(starttime));
		Timestamp ts = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())) ;
		cmnLog.setExecCompletedTime(ts);
		cmnLog.setExecCreatedTime(ts);
		cmnLog.setExecUpdatedTime(ts);
		cmnLog.setPlatformUser(securityUtils.getUser().getUsername());
		Long logJnlNo = this.save(cmnLog);
		this.save(cmnLog);
		return logJnlNo;
	}
	
	/**
	 * 修改日志信息
	 * @param type 日志记录对象
	 * @param username 用户编号
	 */
	@Transactional
	public  Long logPaltformForAutoSyn(int type,String username){
		Date startDate = new Date();
		String logState = "1" ; //执行状态（O:正常、1：平台异常、2：BRPM异常、3：BSA异常）

		String execdate = new SimpleDateFormat("yyyyMMdd").format(startDate) ;
		String starttime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate);
		CmnLogVo cmnLog = new CmnLogVo();
		
		switch(type){
		case 0: cmnLog.setRequestName("应用系统数据同步");
		         break;
		case 1: cmnLog.setRequestName("服务器信息数据同步");
	             break;
		case 2: cmnLog.setRequestName("操作用户数据同步");
	            break;
		}
		cmnLog.setAppsysCode("MAOP");
		cmnLog.setLogResourceType("1"); //1:自动化平台、2：BRPM、3 ：BSA
		
		cmnLog.setLogType("4"); //1:应用发布、2：工具箱、3：自动巡检、4：公共平台

		cmnLog.setExecStatus(logState);
		cmnLog.setExecDate(execdate);
		cmnLog.setExecStartTime(Timestamp.valueOf(starttime));
		Timestamp ts = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())) ;
		cmnLog.setExecCompletedTime(ts);
		cmnLog.setExecCreatedTime(ts);
		cmnLog.setExecUpdatedTime(ts);
		cmnLog.setPlatformUser(username);
		Long logJnlNo = this.save(cmnLog);
		this.save(cmnLog);
		return logJnlNo;
	}
	
	
}
