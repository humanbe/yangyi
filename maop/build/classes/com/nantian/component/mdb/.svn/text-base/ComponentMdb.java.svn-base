package com.nantian.component.mdb;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;

import javax.jms.JMSException;
import javax.jms.MapMessage;
import javax.jms.Message;
import javax.jms.MessageListener;

import net.sf.dozer.util.mapping.MapperIF;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.nantian.common.util.BeanMappingUtil;
import com.nantian.common.util.ComUtil;
import com.nantian.common.util.MyApplicationContextUtil;
import com.nantian.component.com.ComponentAina;
import com.nantian.component.com.ComponentConst;
import com.nantian.component.com.ComponentDateFunc;
import com.nantian.component.com.ComponentProperties;
import com.nantian.component.log.Logger;
import com.nantian.dply.service.ExecuteStatusInfoService;
import com.nantian.dply.vo.ExecuteStatusInfoVo;

/**
 * 消息驱动Bean
 * @author dong
 */
@Component
public class ComponentMdb implements MessageListener {

	/**
	 * Log
	 */
	static Logger logger = Logger.getLogger(ComponentMdb.class);
	
	@Autowired
	private ExecuteStatusInfoService executeStatusInfoService;
	
	/**
	 * 从JMS队列接收消息
	 * @param msg jms的Message实例
	 */
	@SuppressWarnings({ "unused", "unchecked" })
	public void onMessage(Message msg) {
		
		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "onMessage");
		}

		//变量定义
		String exceptionMessageId = "";
		String entryId = "";
		String componentId = "";
		String methodName = "";
		String queueName = "";
		String userID = "";
		String teamID = "";

		try {
			if (logger.isEnableFor("Component0003")) {
				logger.log("Component0003", "msg", msg);
			}

			//(1)执行状态表中用到的状态值			// delete_flag 表示删除的值			String DELETE_FLAG = ComponentProperties.getMdbDeleteFlag();

			// 执行状态管理表:job_status的状态值			// 开始			String JOB_STATUS_START = ComponentProperties.getMdbJobStatusStart();
			// 完成
			String JOB_STATUS_COMPLETE = ComponentProperties.getMdbJobStatusComplete();
			// 等待
			String JOB_STATUS_WAIT = ComponentProperties.getMdbJobStatusWait();
			// 异常
			String JOB_STATUS_ERROR = ComponentProperties.getMdbJobStatusError();
			
			//(2)从JMS的消息中获取唯一的登录ID
			MapMessage map = (MapMessage) msg;

			try {
				entryId = map.getString(ComponentConst.JMS_MESSAGE_ENTRY_ID);
			} catch (JMSException ex) {
				if (logger.isEnableFor("Component6013")) {
					logger.log("Component6013", ex.getMessage());
				}
			}
			if (entryId == null || entryId.trim().equals("")) {
				if (logger.isEnableFor("Component6001")) {
					logger.log("Component6001","");
				}
				//直接返回，不更新数据
				return;
			}

			// 输出唯一的登录ID
			if (logger.isEnableFor("Component6002")) {
				logger.log("Component6002", entryId);
			}
			
			//(3)AINA对象
			// 获取Spring容器管理的componentAina对象
			ComponentAina aina = (ComponentAina)MyApplicationContextUtil.springContext.getBean("componentAina");
			aina.setSTATUS_CODE(0);
			
			ExecuteStatusInfoVo executeStatusInfoVo = new ExecuteStatusInfoVo();
			Map<String,Object> exeStatusVoMap = new HashMap<String,Object>();

			try {
				//设置查询异常时的msgID
				exceptionMessageId = "Component6010";
				
				exeStatusVoMap =  (Map<String, Object>) executeStatusInfoService.findById(entryId);
				//VODATA对象设值
				executeStatusInfoVo.setEntryId(exeStatusVoMap.get("entryId")!=null?exeStatusVoMap.get("entryId").toString():null);
				executeStatusInfoVo.setUserId(exeStatusVoMap.get("userId")!=null?exeStatusVoMap.get("userId").toString():null);
				executeStatusInfoVo.setQueueName(exeStatusVoMap.get("queueName")!=null?exeStatusVoMap.get("queueName").toString():null);
				executeStatusInfoVo.setClassName(exeStatusVoMap.get("className")!=null?exeStatusVoMap.get("className").toString():null);
				executeStatusInfoVo.setMethod(exeStatusVoMap.get("method")!=null?exeStatusVoMap.get("method").toString():null);
				executeStatusInfoVo.setExecutePlanTime(exeStatusVoMap.get("executePlanTime")!=null?exeStatusVoMap.get("executePlanTime").toString():null);
				executeStatusInfoVo.setExecuteStartTime(exeStatusVoMap.get("executeStartTime")!=null?exeStatusVoMap.get("executeStartTime").toString():null);
				executeStatusInfoVo.setExecuteEndTime(exeStatusVoMap.get("executeEndTime")!=null?exeStatusVoMap.get("executeEndTime").toString():null);
				executeStatusInfoVo.setJobStatus(exeStatusVoMap.get("jobStatus")!=null?exeStatusVoMap.get("jobStatus").toString():null);
				executeStatusInfoVo.setAplStatus(exeStatusVoMap.get("aplStatus")!=null?exeStatusVoMap.get("aplStatus").toString():null);
				executeStatusInfoVo.setUploadFileClientName(exeStatusVoMap.get("uploadFileClientName")!=null?exeStatusVoMap.get("uploadFileClientName").toString():null);
				executeStatusInfoVo.setUploadFileTmpName(exeStatusVoMap.get("uploadFileTmpName")!=null?exeStatusVoMap.get("uploadFileTmpName").toString():null);
				executeStatusInfoVo.setUploadFileRecordCount(exeStatusVoMap.get("uploadFileRecordCount")!=null?Integer.valueOf(exeStatusVoMap.get("uploadFileRecordCount").toString()):null);
				executeStatusInfoVo.setLoginTime(exeStatusVoMap.get("loginTime")!=null?exeStatusVoMap.get("loginTime").toString():null);
				executeStatusInfoVo.setModifyTime(exeStatusVoMap.get("modifyTime")!=null?exeStatusVoMap.get("modifyTime").toString():null);
				executeStatusInfoVo.setFunctionId(exeStatusVoMap.get("functionId")!=null?exeStatusVoMap.get("functionId").toString():null);
				executeStatusInfoVo.setAfterFilePath(exeStatusVoMap.get("afterFilePath")!=null?exeStatusVoMap.get("afterFilePath").toString():null);
				executeStatusInfoVo.setReserve1(exeStatusVoMap.get("reserve1")!=null?exeStatusVoMap.get("reserve1").toString():null);
				executeStatusInfoVo.setReserve2(exeStatusVoMap.get("reserve2")!=null?exeStatusVoMap.get("reserve2").toString():null);
				executeStatusInfoVo.setReserve3(exeStatusVoMap.get("reserve3")!=null?exeStatusVoMap.get("reserve3").toString():null);
				executeStatusInfoVo.setReserve4(exeStatusVoMap.get("reserve4")!=null?exeStatusVoMap.get("reserve4").toString():null);
				executeStatusInfoVo.setReserve5(exeStatusVoMap.get("reserve5")!=null?exeStatusVoMap.get("reserve5").toString():null);
				executeStatusInfoVo.setDeleteFlag(exeStatusVoMap.get("deleteFlag")!=null?exeStatusVoMap.get("deleteFlag").toString():null);

				if (executeStatusInfoVo == null) {
					//entry_id不存在
					//输出日志
					if (logger.isEnableFor("Component6014")) {
						logger.log("Component6014", entryId);
					}
					// 直接返回，不更新数据
					return;
				}

				//(3)删除标志的检查				if (DELETE_FLAG.equals(executeStatusInfoVo.getDeleteFlag())) {
					/*
					 * 如果删除标志为已经删除，则终止后续处理，直接返回
					 */
					if (logger.isEnableFor("Component6012")) {
						logger.log("Component6012", entryId, executeStatusInfoVo.getJobStatus(), executeStatusInfoVo.getDeleteFlag());
					}
					//直接返回，不更新数据
					return;
				}

				//(4)JOB状态检查				if (!JOB_STATUS_WAIT.equals(executeStatusInfoVo.getJobStatus())) {
					/*
					 * JOB是否执行完成检查					 * 根据从JMS的消息中获取的唯一登录ID，从执行状态管理表中获取JOB的执行状态（job_status）					 * JOB状态为等待以外的所有状态，则终止后续的处理，直接返回					 */
					if (logger.isEnableFor("Component6011")) {
						logger.log("Component6011", entryId, executeStatusInfoVo.getJobStatus());
					}
					//直接返回，不更新数据
					return;
				}

				//从查询出的对象中获取要输出的一些信息				componentId = executeStatusInfoVo.getClassName();
				methodName = executeStatusInfoVo.getMethod();
				queueName = executeStatusInfoVo.getQueueName();
				userID = executeStatusInfoVo.getUserId();

				//INFO级别的输出				if (logger.isEnableFor("Component6021")) {
					logger.log("Component6021",
							"user_id;team_id;component_id;method;queue_name",
							userID + ";"
							+ teamID + ";"
							+ componentId + ";"
							+ methodName + ";"
							+ queueName);
				}

				//(5) 更新执行状态管理表
				//更新操作发生异常时的msgID
				exceptionMessageId = "Component6009";
				
				// JOB状态设为开始				executeStatusInfoVo.setJobStatus(JOB_STATUS_START);
				
				// 设置开始执行时间				executeStatusInfoVo.setExecuteStartTime(ComponentDateFunc.getSystemTimeMillSec());

				//update
				executeStatusInfoService.update(executeStatusInfoVo);

			} catch (Throwable ex) {
				//发生异常
				if (logger.isEnableFor(exceptionMessageId)) {
					logger.log(exceptionMessageId, ex, entryId, userID
							, teamID, componentId, methodName, queueName, ex.toString());
				}
				//直接返回，不更新数据
				return;
			}

			//服务类执行完成CODE
			Integer aplReturnCode = null;
			String job_status = "";
			String exceptionMessage = "";
			try {
				/*
				 * 开始准备执行类及方法
				 */
				// 克隆数据对象
				MapperIF mapper = BeanMappingUtil.getInstance();
				ExecuteStatusInfoVo asyncInDto  = (ExecuteStatusInfoVo) mapper.map(executeStatusInfoVo, ExecuteStatusInfoVo.class);
				
				// 执行类
				Class<?> serviceClass = null;
				// 执行类方法的参数
				Class<?>[] args = {ExecuteStatusInfoVo.class};
				// 执行类的方法
				Method serviceMethod = null;
				// 获取执行类对象
				Object serviceObject = ComUtil.getObject(componentId);
				// 获取执行类
				serviceClass = serviceObject.getClass();
				// 获取执行方法
				serviceMethod = serviceClass.getMethod(methodName, args);
				// 执行方法
				serviceMethod.invoke(serviceObject, new Object[]{asyncInDto});

				// 获取执行类的执行结果
				aplReturnCode  = aina.getSTATUS_CODE();

				//执行完成
				job_status = JOB_STATUS_COMPLETE;

			} catch (Throwable ex) {
				String exClassName = null;
				if(ex instanceof InvocationTargetException) {
					InvocationTargetException invEx = (InvocationTargetException)ex;
					exClassName = invEx.getTargetException().getClass().getName();
				} else {
					exClassName = ex.getClass().getName();
				}
				// 获取异常JOBMAP
				Map<String,String> jobstatusMap = ComponentProperties.getExceptionJobStatusMap();
				String hashJobStatus = jobstatusMap.get(exClassName);
				
				if(hashJobStatus!=null) {
					// 异常MAP可以取到
					job_status = hashJobStatus;
					//设置发生异常时的MSGID
					exceptionMessageId = "Component6996";
					exceptionMessage = exClassName;
					
				} else {
					//类执行发生异常					job_status = JOB_STATUS_ERROR;
					//设置发生异常时的MSGID
					exceptionMessageId = "Component6999";
					exceptionMessage = ex.toString();
				}
				// 输出日志
				if (logger.isEnableFor(exceptionMessageId)) {
					logger.log(exceptionMessageId, ex, entryId, userID
							, teamID, componentId, methodName, queueName, exceptionMessage);
				}
			}

			/*
			 * 更新执行状态管理表
			 */
			// 设置job状态			executeStatusInfoVo.setJobStatus(job_status);
			// 设置执行完成时间
			executeStatusInfoVo.setExecuteEndTime(ComponentDateFunc.getSystemTimeMillSec());
			// 设置后台APL执行状态			executeStatusInfoVo.setAplStatus(aplReturnCode!=null?String.valueOf(aplReturnCode):null);

			try {
				executeStatusInfoService.update(executeStatusInfoVo);

			} catch (Throwable ex) {
				if (logger.isEnableFor("Component6009")) {
					logger.log("Component6009", ex, entryId, userID
							, teamID, componentId, methodName, queueName, ex.toString());
				}
			}

		} catch (Throwable ex) {
			if (logger.isEnableFor("Component6998")) {
				logger.log("Component6998", ex, entryId, userID
						, teamID, componentId, methodName, queueName, ex.toString());
			}
		} finally {
			// 输出结束日志，因为中间有return，所以放到finally中			if (logger.isEnableFor("Component0002")) {
				logger.log("Component0002", "onMessage");
			}
		}
	}
}
