package com.nantian.dply.service;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.dply.vo.CmnDetailLogVo;

@Service
public class CmnDetailLogService {
	/**
     * HIBERNATE Session Factory.
     */
    @Autowired
    private SessionFactory sessionFactory;
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
    public Session getSession() {
        return sessionFactory.getCurrentSession();
    }
    
    public Session getSessionByThread() {
    	return sessionFactory.openSession();
    }
    
    /**
     * 保存.
     * 
     * @param cmnDetailLogVo
     */
    @Transactional
    public void save(CmnDetailLogVo cmnDetailLogVo) {
        getSession().save(cmnDetailLogVo);
    }
    
    /**
     * 后台定时批量保存用.
     * 
     * @param cmnDetailLogVo
     */
    @Transactional
    public void saveByThread(CmnDetailLogVo cmnDetailLogVo) {
    	Session session = getSessionByThread();
    	Transaction tran = session.getTransaction();
    	tran.begin();
    	try{
    		session.save(cmnDetailLogVo);
    		tran.commit();
    	}catch(Exception e){
    		tran.rollback();
    		if(session.isOpen()) session.close();
    		e.printStackTrace();
    	}
    	if(session.isOpen()) session.close();
    }
    
    
    /**
     * 保存.
     * 
     * @param logJnlNo
     * @param type
     */
    @Transactional
    public void saveBydetailLog(Long logJnlNo,int type, String seq){
  
	//插入详细日志表
    Date startDate = new Date();
    String logState = "1" ; //执行状态（O:正常、1：平台异常、2：BRPM异常、3：BSA异常）
	String execdate = new SimpleDateFormat("yyyyMMdd").format(startDate) ;
	String starttime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate);
	CmnDetailLogVo cdlv = new CmnDetailLogVo();
	
	switch(type){
	case 0:     cdlv.setStepName("应用系统数据同步");
	            cdlv.setJobName("应用系统数据同步");
	         break;
	case 1:     cdlv.setStepName("服务器信息数据同步");
                cdlv.setJobName("服务器信息数据同步");
             break;
	case 2:     cdlv.setStepName("操作用户数据同步");
                cdlv.setJobName("操作用户数据同步");
            break;
	}
	cdlv.setLogJnlNo(logJnlNo);
	cdlv.setDetailLogSeq(seq);
	cdlv.setAppsysCode("MAOP");
	
	cdlv.setExecServerIp( messages.getMessage("systemServer.ip"));
	cdlv.setLogType("4"); //1:应用发布、2：工具箱、3：自动巡检4：公共平台
	cdlv.setExecStatus(logState);
	cdlv.setExecDate(execdate);
	cdlv.setExecStartTime(Timestamp.valueOf(starttime));
	Timestamp timestamp = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())) ;
	cdlv.setExecCompletedTime(timestamp);
	cdlv.setExecCreatedTime(timestamp);
	cdlv.setExecUpdatedTime(timestamp);
	this.save(cdlv);
    }
//    @Transactional
//    public void updateBydetailLog(Long logJnlNo ,int Seq,String logPath ){
//    	Timestamp endTime = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())) ;
//    	getSession().createQuery("update  CmnDetailLogVo cl set cl.execCompletedTime=:endTime, cl.execUpdatedTime=:endTime,cl.resultsPath=:logPath where cl.logJnlNo=:logJnlNo and cl.detailLogSeq=:Seq ")
//		.setTimestamp("endTime", endTime)
//		.setLong("logJnlNo", logJnlNo)
//		.setString("logPath",logPath)
//		.setInteger("Seq",Seq)
//		.executeUpdate();
//    }
    
    public void updateBydetailLog(Long logJnlNo ,int Seq,String logPath ){
    	Timestamp endTime = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())) ;
    	
    	getSession().createSQLQuery("update  CMN_DETAIL_LOG cl set cl.EXEC_COMPLETED_TIME=:endTime, cl.EXEC_UPDATED_TIME=:endTime,cl.RESULTS_PATH=:logPath where cl.LOG_JNL_NO=:logJnlNo and cl.DETAIL_LOG_SEQ=:Seq ")
		.setTimestamp("endTime", endTime)
		.setLong("logJnlNo", logJnlNo)
		.setString("logPath",logPath)
		.setInteger("Seq",Seq)
		.executeUpdate();
    }
    
    public void updateBydetailLogSucess(Long logJnlNo ,int Seq  ){
    	Timestamp endTime = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())) ;
    	getSession().createQuery("update  CmnDetailLogVo cl set cl.execCompletedTime=:endTime, cl.execUpdatedTime=:endTime,cl.execStatus='0' where cl.logJnlNo=:logJnlNo and cl.detailLogSeq=:Seq ")
		.setTimestamp("endTime", endTime)
		.setLong("logJnlNo", logJnlNo)
		.setInteger("Seq", Seq)
		.executeUpdate();
    }
    
}
