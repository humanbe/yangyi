package com.nantian.check.service;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import net.sf.json.JSONArray;

import org.apache.axis2.AxisFault;
import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.type.StringType;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.NoSuchMessageException;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.check.CheckConstants;
import com.nantian.check.vo.CheckItemInfoVo;
import com.nantian.check.vo.CheckItemNshInfoVo;
import com.nantian.check.vo.CheckItemScriptInfoVo;
import com.nantian.common.system.service.AppInfoService;
import com.nantian.common.util.ComUtil;
import com.nantian.component.brpm.BrpmService;
import com.nantian.component.bsa.client.AssumeRoleServiceClient;
import com.nantian.component.bsa.client.CLITunnelServiceClient;
import com.nantian.component.bsa.client.LoginServiceClient;
import com.nantian.component.bsa.webservice.cliTunel.CLITunnelServiceStub.ExecuteCommandByParamListResponse;
import com.nantian.component.bsa.webservice.login.LoginServiceStub.LoginUsingUserCredentialResponse;
import com.nantian.dply.vo.AppGroupVo;
import com.nantian.dply.vo.CmnEnvironmentVo;
import com.nantian.dply.vo.DplyJobInfoVo;
import com.nantian.jeda.Constants;
import com.nantian.jeda.FieldType;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.security.util.SecurityUtils;
import com.nantian.toolbox.service.ToolBoxService;

/**
 * 应用系统环境管理
 * 
 * @author <a href="mailto:zhengwenjie@nantian.com.cn">zhengwenjie</a>
 * 
 */
@Service
@Repository
@Transactional
public class ScriptUploadService {

	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();

	/** BRPM调用接口 */
	@Autowired
	private BrpmService brpmService;
	/** HIBERNATE Session Factory */
	@Autowired
	private SessionFactory sessionFactory;

	@Autowired
	private AppInfoService appInfoService;
	@Autowired
	 private SecurityUtils securityUtils; 
	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}

	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;

	/**
	 * 构造方法
	 */
	public ScriptUploadService() {
		fields.put("osType", FieldType.STRING);
		fields.put("checkItemCode", FieldType.STRING);
		fields.put("fieldType", FieldType.STRING);
		fields.put("scriptName", FieldType.STRING);
	}

	/**
	 * 保存分组数据
	 * 
	 * @param AppGroupVo
	 *            应用系统资源
	 */

	@Transactional
	public void saveGroup(AppGroupVo appGroupVo) {
		appGroupVo.setDeleteFlage("0");
		getSession().save(appGroupVo);

	}

	/**
	 * 删除.
	 * 
	 * @param cmnEnvironmentVo
	 */
	@Transactional
	public void delete(CmnEnvironmentVo cmnEnvironmentVo) {
		getSession().delete(cmnEnvironmentVo);
	}

	/**
	 * 查询作业表数据
	 * 
	 * 
	 * 
	 * 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 */
	@SuppressWarnings({ "unchecked" })
	@Transactional(readOnly = true)
	public List<Map<String, String>> queryAll(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params)
			throws SQLException {
		StringBuilder sql = new StringBuilder();
		sql.append("select  m.osType as \"osType\",")
				.append(" m.checkItemCode as \"checkItemCode\", ")
				.append("m.fieldType as \"fieldType\", ")
				.append("m.checkItemName as \"checkItemName\", ")
				.append("m.scriptType as \"scriptType\", ")
				.append("m.scriptName as \"scriptName\" ")
				.append(" from (  ")
				.append(" select t.os_type as osType, t.check_item_code as checkItemCode, ")
				.append(" t.field_type as fieldType,  ")
				.append(" t.check_item_name as checkItemName, ")
				.append(" o.script_type as scriptType, ")
				.append(" o.script_name  as scriptName")
				.append(" from check_item_info t, check_item_script_info o  ")
				.append(" where t.check_item_code = o.check_item_code   order by t.check_item_code) m where 1=1 ");
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					sql.append(" and " + key + " like :" + key);
				} else {
					sql.append(" and " + key + " = :" + key);
				}
			}
		}
		
		Query query = (Query) getSession().createSQLQuery(sql.toString())
				.addScalar("osType", StringType.INSTANCE)
				.addScalar("checkItemCode", StringType.INSTANCE)
				.addScalar("fieldType", StringType.INSTANCE)
				.addScalar("checkItemName", StringType.INSTANCE)
				.addScalar("scriptType", StringType.INSTANCE)
				.addScalar("scriptName", StringType.INSTANCE)
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		List<HashMap<String,String>> list=query.list();
		HashMap<String,String> map=new HashMap<String,String>();
		List<Map<String, String>> param = new ArrayList<Map<String, String>>();
		String oldCole = null;
		for(int i=0;i<list.size();i++){
			if(i == 0) {
				oldCole= list.get(0).get("checkItemCode");
				map.put("osType", list.get(i).get("osType"));
				map.put("fieldType", list.get(i).get("fieldType"));
				map.put("checkItemName", list.get(i).get("checkItemName"));
				if(list.get(i).get("scriptType").equals("BIN")){
					map.put("binScriptName", list.get(i).get("scriptName"));
				}
				if(list.get(i).get("scriptType").equals("SET")){
					map.put("setScriptName", list.get(i).get("scriptName"));
				}
				if(list.get(i).get("scriptType").equals("INIT")){
					map.put("initScriptName", list.get(i).get("scriptName"));
				}
				param.add(map);
			}else{
				if(oldCole.equals(list.get(i).get("checkItemCode"))){
					map.put("osType", list.get(i).get("osType"));
					map.put("fieldType", list.get(i).get("fieldType"));
					map.put("checkItemName", list.get(i).get("checkItemName"));
					if(list.get(i).get("scriptType").equals("BIN")){
						map.put("binScriptName", list.get(i).get("scriptName"));
					}
					if(list.get(i).get("scriptType").equals("SET")){
						map.put("setScriptName", list.get(i).get("scriptName"));
					}
					if(list.get(i).get("scriptType").equals("INIT")){
						map.put("initScriptName", list.get(i).get("scriptName"));
					}
				}else{
					map=new HashMap<String,String>();
					oldCole= list.get(i).get("checkItemCode");
					map.put("osType", list.get(i).get("osType"));
					map.put("fieldType", list.get(i).get("fieldType"));
					map.put("checkItemName", list.get(i).get("checkItemName"));
					if(list.get(i).get("scriptType").equals("BIN")){
						map.put("binScriptName", list.get(i).get("scriptName"));
					}
					if(list.get(i).get("scriptType").equals("SET")){
						map.put("setScriptName", list.get(i).get("scriptName"));
					}
					if(list.get(i).get("scriptType").equals("INIT")){
						map.put("initScriptName", list.get(i).get("scriptName"));
					}
					param.add(map);
				}
			}
		}
	
		return param;
	}

	/**
	 * 查询数据总数
	 * 
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long count(Map<String, Object> params) throws SQLException {

		StringBuilder sql = new StringBuilder();
		sql.append("select count(*)  from ( select  m.osType as \"osType\",")
				.append(" m.checkItemCode as \"checkItemCode\", ")
				.append("m.fieldType as \"fieldType\", ")
				.append("m.checkItemName as \"checkItemName\", ")
				.append("m.scriptType as \"scriptType\", ")
				.append("m.scriptName as \"scriptName\" ")
				.append(" from (  ")
				.append(" select t.os_type as osType, t.check_item_code as checkItemCode, ")
				.append(" t.field_type as fieldType,  ")
				.append(" t.check_item_name as checkItemName, ")
				.append(" o.script_type as scriptType, ")
				.append(" o.script_name  as scriptName")
				.append(" from check_item_info t, check_item_script_info o  ")
				.append(" where t.check_item_code = o.check_item_code and o.script_type='BIN') m where 1=1 ");
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					sql.append(" and " + key + " like :" + key);
				} else {
					sql.append(" and " + key + " = :" + key );
				}
			}
		}
		sql.append(" )");
		Query query = (Query) getSession().createSQLQuery(sql.toString());
		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return Long.valueOf(query.uniqueResult().toString());
	}

	
	/**
	 * 获取专业分级
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> getFieldTypeone(String fieldType)throws SQLException {
		
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct ");
		sql.append(" f.field_type_two as \"field_type_two\"");
		sql.append(" from  FIELD_TYPE_INFO f where f.FIELD_TYPE_DIRECTION ='巡检专业领域' and f.field_type_one='"+fieldType+"' ");

		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		return query.list();
	}
	
	/**
	 * 将上传的脚本添加到BSA中
	 * @param checkItemInfoVo 
	 * @throws Exception 
	 */
	public void addShScriptToBsa(CheckItemInfoVo checkItemInfoVo, String fileTxt,String shPath) throws Exception {
		
		
		String osType=checkItemInfoVo.getOsType();
		String fieldType=checkItemInfoVo.getFieldType();
		String crlf=System.getProperty("line.separator");
		String jobGroup=(String) jobGroupExists(CheckConstants.ChenkGroupName);
		if(jobGroup.equals("false")){
			createJobGroup(CheckConstants.ChenkGroupName, "");
			jobGroupApplyAclPolicy(CheckConstants.ChenkGroupName, CheckConstants.celv);
			jobGroupApplyAclPolicy(CheckConstants.ChenkGroupName, CheckConstants.allRootCelv);
		}
		//CHECH_INIT文件夹     createJobGroup jobGroupExists
		String isExist=(String) groupExists(CheckConstants.ChenkGroupName);
		if(isExist.equals("false")){
			createGroup(CheckConstants.ChenkGroupName,"");
			groupApplyAclPolicy(CheckConstants.ChenkGroupName, CheckConstants.celv);
			groupApplyAclPolicy(CheckConstants.ChenkGroupName, CheckConstants.allRootCelv);
		}
		//创建ALLINIT文件夹
		String allinitGroup=CheckConstants.ChenkGroupName+"/"+CheckConstants.AllinitGroupName;
		String allinitGroupGroupIsExist=(String) groupExists(allinitGroup);
		if(allinitGroupGroupIsExist.equals("false")){
			createGroup(CheckConstants.AllinitGroupName,CheckConstants.ChenkGroupName);
			groupApplyAclPolicy(allinitGroup, CheckConstants.celv);
		}
		String allinitJobGroup=(String) jobGroupExists(allinitGroup);
		if(allinitJobGroup.equals("false")){
			createJobGroup(CheckConstants.AllinitGroupName, CheckConstants.ChenkGroupName);
			jobGroupApplyAclPolicy(allinitGroup, CheckConstants.celv);
		}
		//创建操作系统文件夹
		String osTypeGroup=CheckConstants.ChenkGroupName+"/"+osType;
		String osTypeGroupIsExist=(String) groupExists(osTypeGroup);
		if(osTypeGroupIsExist.equals("false")){
			createGroup(osType,CheckConstants.ChenkGroupName);
			groupApplyAclPolicy(osTypeGroup, CheckConstants.celv);
			groupApplyAclPolicy(osTypeGroup, CheckConstants.celv);
			groupApplyAclPolicy(osTypeGroup, CheckConstants.allSysadminCelv);
		}
		String osTypeJobGroup=(String) jobGroupExists(osTypeGroup);
		if(osTypeJobGroup.equals("false")){
			createJobGroup(osType,CheckConstants.ChenkGroupName);
			jobGroupApplyAclPolicy(osTypeGroup, CheckConstants.celv);
			jobGroupApplyAclPolicy(osTypeGroup, CheckConstants.allSysadminCelv);
		}
		//创建专业领域分类文件夹
		String fieldTypeGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType;
		String fieldTypeGroupIsExist=(String) groupExists(fieldTypeGroup);
		if(fieldTypeGroupIsExist.equals("false")){
			createGroup(fieldType,osTypeGroup);
			groupApplyAclPolicy(fieldTypeGroup, CheckConstants.celv);
			groupApplyAclPolicy(fieldTypeGroup, CheckConstants.allSysadminCelv);
		}
		//创建ITEM文件夹
		String itemGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"ITEM";
		String itemGroupIsExist=(String) groupExists(itemGroup);
		if(itemGroupIsExist.equals("false")){
			createGroup("ITEM",fieldTypeGroup);
			groupApplyAclPolicy(itemGroup, CheckConstants.celv);
			groupApplyAclPolicy(itemGroup, CheckConstants.allSysadminCelv);
		}
		//创建BIN文件夹
		String binGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"BIN";
		String binGroupIsExist=(String) groupExists(binGroup);
		if(binGroupIsExist.equals("false")){
			createGroup("BIN",fieldTypeGroup);
			groupApplyAclPolicy(binGroup, CheckConstants.celv);
			groupApplyAclPolicy(binGroup, CheckConstants.allSysadminCelv);
		}
		//创建SET文件夹
		String setGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"SET";
		String setGroupExist=(String) groupExists(setGroup);
		if(setGroupExist.equals("false")){
			createGroup("SET",fieldTypeGroup);
			groupApplyAclPolicy(setGroup, CheckConstants.celv);
			groupApplyAclPolicy(setGroup, CheckConstants.allSysadminCelv);
		}
		//创建INIT文件夹
		String initGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"INIT";
		String initGroupIsExist=(String) groupExists(initGroup);
		if(initGroupIsExist.equals("false")){
			createGroup("INIT",fieldTypeGroup);
			groupApplyAclPolicy(initGroup, CheckConstants.celv);
			groupApplyAclPolicy(initGroup, CheckConstants.allSysadminCelv);
		}
		//创建binNSH文件夹
		String binNshGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"BIN"+"/"+"NSH";
		String binNshGroupIsExist=(String) groupExists(binNshGroup);
		if(binNshGroupIsExist.equals("false")){
			createGroup("NSH",binGroup);
			groupApplyAclPolicy(binNshGroup, CheckConstants.celv);
			groupApplyAclPolicy(binNshGroup, CheckConstants.allSysadminCelv);
		}
		//创建binSHELL文件夹
		String binShellGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"BIN"+"/"+"SHELL";
		String binShellGroupIsExist=(String) groupExists(binShellGroup);
		if(binShellGroupIsExist.equals("false")){
			createGroup("SHELL",binGroup);
			groupApplyAclPolicy(binShellGroup, CheckConstants.celv);
			groupApplyAclPolicy(binShellGroup, CheckConstants.allSysadminCelv);
		}
		//创建binNSHELL文件夹
		String nshellGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"BIN"+"/"+"NSHELL";
		String nshellGroupIsExist=(String) groupExists(nshellGroup);
		if(nshellGroupIsExist.equals("false")){
			createGroup("NSHELL",binGroup);
			groupApplyAclPolicy(nshellGroup, CheckConstants.celv);
			groupApplyAclPolicy(nshellGroup, CheckConstants.allSysadminCelv);
		}
		//创建initNSH文件夹
		String initNshGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"INIT"+"/"+"NSH";
		String initNshGroupIsExist=(String) groupExists(initNshGroup);
		if(initNshGroupIsExist.equals("false")){
			createGroup("NSH",initGroup);
			groupApplyAclPolicy(initNshGroup, CheckConstants.celv);
			groupApplyAclPolicy(initNshGroup, CheckConstants.allSysadminCelv);
		}
		//创建initSHELL文件夹
		String initShellGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"INIT"+"/"+"SHELL";
		String initShellGroupIsExist=(String) groupExists(initShellGroup);
		if(initShellGroupIsExist.equals("false")){
			createGroup("SHELL",initGroup);
			groupApplyAclPolicy(initShellGroup, CheckConstants.celv);
			groupApplyAclPolicy(initShellGroup, CheckConstants.allSysadminCelv);
		}
		//创建setNSH文件夹
		String setNshGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"SET"+"/"+"NSH";
		String setNshGroupIsExist=(String) groupExists(setNshGroup);
		if(setNshGroupIsExist.equals("false")){
			createGroup("NSH",setGroup);
			groupApplyAclPolicy(setNshGroup, CheckConstants.celv);
			groupApplyAclPolicy(setNshGroup, CheckConstants.allSysadminCelv);
		}
		//创建setSHELL文件夹
		String setShellGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"SET"+"/"+"SHELL";
		String setShellGroupIsExist=(String) groupExists(setShellGroup);
		if(setShellGroupIsExist.equals("false")){
			createGroup("SHELL",setGroup);
			groupApplyAclPolicy(setShellGroup, CheckConstants.celv);
			groupApplyAclPolicy(setShellGroup, CheckConstants.allSysadminCelv);
		}
		//取服务器的ip
		String ip=messages.getMessage("systemServer.ip");
		String Path="";
		if(ComUtil.isWindows){
			Path=shPath.replace(":", "").replace("\\", "/");
		}else{
			Path=shPath.substring(1);
		}
		//BIN脚本的上传
		if(fileTxt.substring(fileTxt.lastIndexOf("_")+1, fileTxt.indexOf(".")).equals("check")){
			String fileLocation="//"+ip+"/"+Path+"/"+fileTxt;
			addFileToDepot(binShellGroup, fileLocation, fileTxt);
			String shDbKey=(String) getFileDbKey(CheckConstants.fileType, binShellGroup, fileTxt);
			applyAclPolicy(shDbKey, CheckConstants.celv);
			String shDbKey1=(String) getFileDbKey(CheckConstants.fileType, binShellGroup, fileTxt);
			applyAclPolicy(shDbKey1, CheckConstants.allSysadminCelv);
			
			String binNshName=fileTxt.substring(0,fileTxt.indexOf(".")).concat(".nsh");
			String logName=fileTxt.substring(fileTxt.indexOf("_")+1, fileTxt.indexOf("."));
			Object nshNeiRong = binNshFile(fileTxt,logName);
			File file = new File(shPath);
			if(!file.exists()){
				file.mkdirs();
			}
			PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(shPath.concat(File.separator).concat(binNshName)),"utf-8"));
			out.println(nshNeiRong);
			out.flush();
			out.close();
			String nshFileLocation="//"+ip+"/"+Path+"/"+binNshName;
			addFileToDepot(nshellGroup, nshFileLocation, binNshName);
			String nshFielDbKey=(String) getFileDbKey(CheckConstants.fileType, nshellGroup, binNshName);
			applyAclPolicy(nshFielDbKey, CheckConstants.celv);
			String nshFielDbKey1=(String) getFileDbKey(CheckConstants.fileType, nshellGroup, binNshName);
			applyAclPolicy(nshFielDbKey1, CheckConstants.allSysadminCelv);
			
			Object nshFileNeiRong=binNshText(binShellGroup, fileTxt);
			PrintWriter out1 = new PrintWriter(new OutputStreamWriter(new FileOutputStream(shPath.concat(File.separator).concat(binNshName)),"utf-8"));
			out1.println(nshFileNeiRong);
			out1.flush();
			out1.close();
			addNshToDepot(binNshGroup, nshFileLocation, binNshName);
			String nshDbKey=(String) getFileDbKey(CheckConstants.nshFileType, binNshGroup, binNshName);
			applyAclPolicy(nshDbKey, CheckConstants.celv);
			String nshDbKey1=(String) getFileDbKey(CheckConstants.nshFileType, binNshGroup, binNshName);
			applyAclPolicy(nshDbKey1, CheckConstants.allSysadminCelv);
			addParamToBinNshScript(binNshGroup,binNshName);
			//创建blpackage包
			String blpackageName="ALLFILES_"+osType;
			String blpackagefileexist=(String)getFileDbKey(CheckConstants.blpackageFileType, allinitGroup, blpackageName);
			if(blpackagefileexist.equals("void")){
				String groupId=(String) groupNameToId(allinitGroup);
				createBlpackage(blpackageName,groupId);
				String blpackageDbkey=(String)getFileDbKey(CheckConstants.blpackageFileType, allinitGroup, blpackageName);
				applyAclPolicy(blpackageDbkey, CheckConstants.celv);
			}
			importDepotObjectToPackage(allinitGroup,blpackageName,binShellGroup,fileTxt,CheckConstants.fileType,osType,"SHELL");
			importDepotObjectToPackage(allinitGroup,blpackageName,nshellGroup,binNshName,CheckConstants.fileType,osType,"NSH");
		}
		//INIT脚本的上传
		if(fileTxt.substring(fileTxt.lastIndexOf("_")+1, fileTxt.indexOf(".")).equals("init")){
			String fileLocation="//"+ip+"/"+Path+"/"+fileTxt;
			addFileToDepot(initShellGroup, fileLocation, fileTxt);
			String shDbKey=(String) getFileDbKey(CheckConstants.fileType, initShellGroup, fileTxt);
			applyAclPolicy(shDbKey, CheckConstants.celv);
			String shDbKey1=(String) getFileDbKey(CheckConstants.fileType, initShellGroup, fileTxt);
			applyAclPolicy(shDbKey1, CheckConstants.allSysadminCelv);
			String nshName=fileTxt.substring(0,fileTxt.indexOf(".")).concat(".nsh");
			Object nshNeiRong = nshText(initShellGroup, fileTxt, "init");
			File file = new File(shPath);
			if(!file.exists()){
				file.mkdirs();
			}
			PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(shPath.concat(File.separator).concat(nshName)),"utf-8"));
			out.println(nshNeiRong);
			out.flush();
			out.close();
			String nshFileLocation="//"+ip+"/"+Path+"/"+nshName;
			addNshToDepot(initNshGroup, nshFileLocation, nshName);
			String nshDbKey=(String) getFileDbKey(CheckConstants.nshFileType, initNshGroup, nshName);
			applyAclPolicy(nshDbKey, CheckConstants.celv);
			String nshDbKey1=(String) getFileDbKey(CheckConstants.nshFileType, initNshGroup, nshName);
			applyAclPolicy(nshDbKey1, CheckConstants.allSysadminCelv);
			addParamToNshScript(initNshGroup,nshName);
		}
		//SET脚本的上传
		if(fileTxt.substring(fileTxt.lastIndexOf("_")+1, fileTxt.indexOf(".")).equals("set")){
			String fileLocation="//"+ip+"/"+Path+"/"+fileTxt;
			addFileToDepot(setShellGroup, fileLocation, fileTxt);
			String shDbKey=(String) getFileDbKey(CheckConstants.fileType, setShellGroup, fileTxt);
			applyAclPolicy(shDbKey, CheckConstants.celv);
			String shDbKey1=(String) getFileDbKey(CheckConstants.fileType, setShellGroup, fileTxt);
			applyAclPolicy(shDbKey1, CheckConstants.allSysadminCelv);
			String nshName=fileTxt.substring(0,fileTxt.indexOf(".")).concat(".nsh");
			Object nshNeiRong = nshText(setShellGroup, fileTxt, "set");
			File file = new File(shPath);
			if(!file.exists()){
				file.mkdirs();
			}
			PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(shPath.concat(File.separator).concat(nshName)),"utf-8"));
			out.println(nshNeiRong);
			out.flush();
			out.close();
			String nshFileLocation="//"+ip+"/"+Path+"/"+nshName;
			addNshToDepot(setNshGroup, nshFileLocation, nshName);
			String nshDbKey=(String) getFileDbKey(CheckConstants.nshFileType, setNshGroup, nshName);
			applyAclPolicy(nshDbKey, CheckConstants.celv);
			String nshDbKey1=(String) getFileDbKey(CheckConstants.nshFileType, setNshGroup, nshName);
			applyAclPolicy(nshDbKey1, CheckConstants.allSysadminCelv);
			addParamToNshScript(setNshGroup,nshName);
		}
	}
	
	/**
	 * 上传ITEM脚本到BSA中
	 * @param checkItemInfoVo 
	 * 
	 * @throws Exception 
	 * 
	 */
	public Object addItemScriptToBsa(CheckItemInfoVo checkItemInfoVo, List<String> scriptNameList,String shPath) throws Exception {
		String osType=checkItemInfoVo.getOsType();
		String fieldType=checkItemInfoVo.getFieldType();
		String NshGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"ITEM";
		String crlf=System.getProperty("line.separator");
		String bin = "";
		String set = "";
		String init = "";
		String itemNshName=null;
		//取服务器的ip
		String ip=messages.getMessage("systemServer.ip");
		String Path="";
		if(ComUtil.isWindows){
			Path=shPath.replace(":", "").replace("\\", "/");
		}else{
			Path=shPath.substring(1);
		}
		for(int i=0;i<scriptNameList.size();i++){
			if(scriptNameList.get(i).substring(scriptNameList.get(i).lastIndexOf("_")+1, scriptNameList.get(i).indexOf(".")).equals("check")){
					String nshName=scriptNameList.get(i).substring(0,scriptNameList.get(i).indexOf(".")).concat(".nsh");
					bin="if [ $Bin = y ]; "+crlf+"then"+crlf+"nsh -c \"$ExecuteCommonInitnsh\" /CHECK_INIT/"+osType+"/"+fieldType+"/BIN/NSH"+" "+nshName+" "+"$TargetIP $PushFile $Syspath"+crlf+"fi";
				   	itemNshName=scriptNameList.get(i).substring(0,scriptNameList.get(i).indexOf(".")).concat("_item.nsh");
			}
			if(scriptNameList.get(i).substring(scriptNameList.get(i).lastIndexOf("_")+1, scriptNameList.get(i).indexOf(".")).equals("set")){
					String nshName=scriptNameList.get(i).substring(0,scriptNameList.get(i).indexOf(".")).concat(".nsh");
					set="if [ $Set = y ]; "+crlf+"then"+crlf+"nsh -c \"$ExecuteCommonInitnsh\" /CHECK_INIT/"+osType+"/"+fieldType+"/SET/NSH"+" "+nshName+" "+"$TargetIP $PushFile $Syspath $Script $Execute"+crlf+"fi";
				}
			if(scriptNameList.get(i).substring(scriptNameList.get(i).lastIndexOf("_")+1, scriptNameList.get(i).indexOf(".")).equals("init")){
				 	String nshName=scriptNameList.get(i).substring(0,scriptNameList.get(i).indexOf(".")).concat(".nsh"); 
					init="if [ $Init = y ]; "+crlf+"then"+crlf+"nsh -c \"$ExecuteCommonInitnsh\" /CHECK_INIT/"+osType+"/"+fieldType+"/INIT/NSH"+" "+nshName+" "+"$TargetIP $PushFile $Syspath $Script $Execute"+crlf+"fi";
				}
		}
		StringBuilder itemNshFile = new StringBuilder();
		itemNshFile.append("TargetIP=$1").append(crlf);
		itemNshFile.append("PushFile=$2").append(crlf);
		itemNshFile.append("Syspath=$3").append(crlf);
		itemNshFile.append("Script=$4").append(crlf);
		itemNshFile.append("Execute=$5").append(crlf);
		itemNshFile.append("ExecuteCommonInitnsh=$6").append(crlf);
		itemNshFile.append("Set=$7").append(crlf);
		itemNshFile.append("Init=$8").append(crlf);
		itemNshFile.append("Bin=$9").append(crlf);
		itemNshFile.append(bin).append(crlf);
		if(""!=set){
		itemNshFile.append(set).append(crlf);
		}
		if(""!=init){
		itemNshFile.append(init).append(crlf);
		}
		itemNshFile.append("if [ $? != 0 ];").append(crlf);
		itemNshFile.append("then").append(crlf);
		itemNshFile.append("exit 151").append(crlf);
		itemNshFile.append("fi").append(crlf);
		File file = new File(shPath);
		if(!file.exists()){
			file.mkdirs();
		}
		PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(shPath.concat(File.separator).concat(itemNshName)),"utf-8"));
		out.println(itemNshFile);
		out.flush();
		out.close();
		String nshFileLocation="//"+ip+"/"+Path+"/"+itemNshName;
		addNshToDepot(NshGroup, nshFileLocation, itemNshName);
		String nshDbKey=(String) getFileDbKey(CheckConstants.nshFileType, NshGroup, itemNshName);
		applyAclPolicy(nshDbKey, CheckConstants.celv);
		String nshDbKey1=(String) getFileDbKey(CheckConstants.nshFileType, NshGroup, itemNshName);
		applyAclPolicy(nshDbKey1, CheckConstants.allSysadminCelv);
		addParamToItemNshScript(NshGroup,itemNshName);
		return itemNshName;
	}
	/**
	 * 将AllInit脚本上传到BSA
	 * @param scriptNameList 
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	@Transactional(rollbackFor=Exception.class)
	public void addAllInitScriptToBsa(CheckItemInfoVo checkItemInfoVo,
			String itemNshName,String shPath, List<String> scriptNameList) throws Exception {
		String itemNshGroup="/"+CheckConstants.ChenkGroupName+"/"+checkItemInfoVo.getOsType()+"/"+checkItemInfoVo.getFieldType()+"/"+"ITEM";
		String allInitNshGroup=CheckConstants.ChenkGroupName+"/"+CheckConstants.AllinitGroupName;
		String crlf=System.getProperty("line.separator");
		String allInitName="ALLINIT_"+checkItemInfoVo.getOsType()+".nsh";
		//取服务器的ip
		String ip=messages.getMessage("systemServer.ip");
		String Path="";
		if(ComUtil.isWindows){
			Path=shPath.replace(":", "").replace("\\", "/");
		}else{
			Path=shPath.substring(1);
		}
		String binScriptName="";
		for(int i=0;i<scriptNameList.size();i++){
			if(scriptNameList.get(i).substring(scriptNameList.get(i).lastIndexOf("_")+1, scriptNameList.get(i).indexOf(".")).equals("check")){
				binScriptName=scriptNameList.get(i);
			}
		}
		String nshFileLocation="//"+ip+"/"+Path+"/"+allInitName;
		String nshFielDbKey=(String) getFileDbKey(CheckConstants.nshFileType, allInitNshGroup, allInitName);
		if(nshFielDbKey.equals("void")){
		StringBuilder allInitNshFile = new StringBuilder();
		allInitNshFile.append("TargetIP=$1").append(crlf);
		allInitNshFile.append("Syspath=$2").append(crlf);
		allInitNshFile.append("PushFile=$3").append(crlf);
		allInitNshFile.append("ExecuteCommonInitnsh=$4").append(crlf);
		allInitNshFile.append("BinFileList=$5").append(crlf);
		allInitNshFile.append("SetFileList=$6").append(crlf);
		allInitNshFile.append("InitFileList=$7").append(crlf);
		allInitNshFile.append("Script=$8").append(crlf);
		allInitNshFile.append("Execute=$9").append(crlf);
		allInitNshFile.append("Set=${10}").append(crlf);
		allInitNshFile.append("Init=${11}").append(crlf);
		allInitNshFile.append("Bin=${12}").append(crlf);
		allInitNshFile.append("nsh -c \"$ExecuteCommonInitnsh\" /CHECK_INIT/ALLINIT m000_path_init.nsh $TargetIP $PushFile").append(crlf);
		allInitNshFile.append("#bin脚本下发").append(crlf);
		allInitNshFile.append("if [[ \"$Script\" = y && \"$Bin\" = y ]]; then").append(crlf);
		allInitNshFile.append("for checksh in `cat $BinFileList`").append(crlf);
		allInitNshFile.append("do").append(crlf);
		allInitNshFile.append(" eval path=`echo $checksh|cut -d ';' -f1`").append(crlf);
		allInitNshFile.append(" eval name=`echo $checksh|cut -d ';' -f2`").append(crlf);
		allInitNshFile.append(" #echo $path").append(crlf);
		allInitNshFile.append(" echo $name").append(crlf);
		allInitNshFile.append("if [[ \"$name\" != MARKDELETE* ]]; then").append(crlf);
		allInitNshFile.append(" cp $path //$TargetIP$Syspath/bin/$name").append(crlf);
		allInitNshFile.append("fi").append(crlf);
		allInitNshFile.append("done").append(crlf);
		allInitNshFile.append("fi").append(crlf);
		allInitNshFile.append("#set脚本下发").append(crlf);
		allInitNshFile.append("if [[ \"$Script\" = y && \"$Set\" = y ]]; then").append(crlf);
		allInitNshFile.append("for setsh in `cat $SetFileList`").append(crlf);
		allInitNshFile.append("do").append(crlf);
		allInitNshFile.append("	eval path=`echo $setsh|cut -d ';' -f1`").append(crlf);
		allInitNshFile.append("	eval name=`echo $setsh|cut -d ';' -f2`").append(crlf);
		allInitNshFile.append("	#echo $path").append(crlf);
		allInitNshFile.append("	echo $name").append(crlf);
		allInitNshFile.append("	cp $path //$TargetIP$Syspath/set/$name").append(crlf);
		allInitNshFile.append("done").append(crlf);
		allInitNshFile.append("fi").append(crlf);
		allInitNshFile.append("#init脚本下发").append(crlf);
		allInitNshFile.append("if [[ \"$Script\" = y && \"$Init\" = y ]]; then").append(crlf);
		allInitNshFile.append("for initsh in `cat $InitFileList`").append(crlf);
		allInitNshFile.append("do").append(crlf);
		allInitNshFile.append(" eval path=`echo $initsh|cut -d ';' -f1`").append(crlf);
		allInitNshFile.append("	eval name=`echo $initsh|cut -d ';' -f2`").append(crlf);
		allInitNshFile.append("	#echo $path").append(crlf);
		allInitNshFile.append("	echo $name").append(crlf);
		allInitNshFile.append("	cp $path //$TargetIP$Syspath/init/$name").append(crlf);
		allInitNshFile.append("done").append(crlf);
		allInitNshFile.append("fi").append(crlf);
		allInitNshFile.append("#set脚本执行").append(crlf);
		allInitNshFile.append("if [[ \"$Execute\" = y && \"$Set\" = y ]]; then").append(crlf);
		allInitNshFile.append("cp $SetFileList //$TargetIP$Syspath/set/").append(crlf);
		allInitNshFile.append("nsh -c \"$PushFile\" /CHECK_INIT/ALLINIT SetFileList.sh //$TargetIP$Syspath/set/").append(crlf);
		allInitNshFile.append("nexec -l -e \"cd $Syspath/set/;chmod a+x SetFileList.sh;sh SetFileList.sh;rm -f SetFileList*\"").append(crlf);
		allInitNshFile.append("fi").append(crlf);
		allInitNshFile.append("#init脚本执行").append(crlf);
		allInitNshFile.append("if [[ \"$Execute\" = y && \"$Init\" = y ]]; then").append(crlf);
		allInitNshFile.append("cp $InitFileList //$TargetIP$Syspath/init/").append(crlf);
		allInitNshFile.append("nsh -c \"$PushFile\" /CHECK_INIT/ALLINIT InitFileList.sh //$TargetIP$Syspath/init/").append(crlf);
		allInitNshFile.append("nexec -l -e \"cd $Syspath/init/;chmod a+x InitFileList.sh;sh InitFileList.sh;rm -f InitFileList*\"").append(crlf);
		allInitNshFile.append("fi").append(crlf);
		allInitNshFile.append("if [ $? != 0 ]; ").append(crlf);
		allInitNshFile.append("then").append(crlf);
		allInitNshFile.append("exit 151").append(crlf);
		allInitNshFile.append("fi").append(crlf);
		File file = new File(shPath);
		if(!file.exists()){
			file.mkdirs();
		}
		PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(shPath.concat(File.separator).concat(allInitName)),"utf-8"));
		out.println(allInitNshFile);
		out.flush();
		out.close();
		addNshToDepot(allInitNshGroup, nshFileLocation, allInitName);
		String nshDbKey=(String) getFileDbKey(CheckConstants.nshFileType, allInitNshGroup, allInitName);
		applyAclPolicy(nshDbKey, CheckConstants.celv);
		addParamToAllInitNshScript(allInitNshGroup,allInitName);
		}
	}
	/**
	 * 将脚本下发到BSA文件服务器上
	 * @throws SQLException 
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public void deployToBsa(CheckItemInfoVo checkItemInfoVo,
			List<String> scriptNameList) throws Exception {
		// TODO Auto-generated method stub
		String osType=checkItemInfoVo.getOsType();
		String nshName="";
		for(int i=0;i<scriptNameList.size();i++){
			if(scriptNameList.get(i).substring(scriptNameList.get(i).lastIndexOf("_")+1, scriptNameList.get(i).indexOf(".")).equals("check")){
				nshName=scriptNameList.get(i).substring(0,scriptNameList.get(i).indexOf(".")).concat(".nsh");
			}
		}
		String scriptName = "ScriptDeploy.nsh";
		String scriptPath = "/BMC Maintenance/SysTools/filepush";
		//bsa服务器的ip
		String bsaServer = messages.getMessage("bsa.ipAddress");
		String jobGroup=CheckConstants.ChenkGroupName+"/"+CheckConstants.AllinitGroupName;
		String jobName="ScriptDeployNshJob".concat((new SimpleDateFormat("yyyyMMddHHmmss").format(new Date())).toString());
		createToolJob(jobGroup,jobName,scriptPath,scriptName,bsaServer);
		addDeployJobParam(jobGroup,jobName,osType,nshName);
		String nshJobDbkey=(String) getNshJobDbKey(jobGroup, jobName);
		//执行作业
		exceNshJob(nshJobDbkey);
		//删除作业
		deleteJob(jobGroup,jobName);
	}
	/**
	 * 创建脚本下发到BSA文件服务器作业
	 * @throws SQLException 
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	private void addDeployJobParam(String jobGroup, String jobName,
			String osType, String nshName) throws Exception {
		// TODO Auto-generated method stub

		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));

		
		CLITunnelServiceClient jobParentGroupName0 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames0 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","clearNSHScriptParameterValuesByGroupAndName",new String[] {"/"+jobGroup+"",jobName});
		String DbKey0 = (String) jobParentGroupNames0.get_return().getReturnValue();
		
		//设置参数
		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/"+jobGroup+"",jobName,"0","??TARGET.CHECK_PushFile??"});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		
		CLITunnelServiceClient jobParentGroupName1 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames1 = jobParentGroupName1.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/"+jobGroup+"",jobName,"1","/CHECK_INIT/"+osType+"/OS/BIN/NSHELL"});
		String DbKey1 = (String) jobParentGroupNames1.get_return().getReturnValue();
		
		CLITunnelServiceClient jobParentGroupName2 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames2 = jobParentGroupName2.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/"+jobGroup+"",jobName,"2",nshName});
		String DbKey2 = (String) jobParentGroupNames2.get_return().getReturnValue();
		
		CLITunnelServiceClient jobParentGroupName3 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames3 = jobParentGroupName3.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/"+jobGroup+"",jobName,"3","??TARGET.CHECK_BsaFileServer??"});
		String DbKey3 = (String) jobParentGroupNames3.get_return().getReturnValue();
		
		CLITunnelServiceClient jobParentGroupName4 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames4 = jobParentGroupName4.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/"+jobGroup+"",jobName,"4","/bbsa/blstorage/CHECK/SYS_CHECK/"+osType+"/NSH"});
		String DbKey4 = (String) jobParentGroupNames4.get_return().getReturnValue();
	}

	/**
	 * 保存
	 * @throws SQLException 
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public void save(CheckItemInfoVo checkItemInfoVo, List<String> scriptNameList,String itemNshName) throws SQLException {
		String osType=checkItemInfoVo.getOsType();
		String fieldType=checkItemInfoVo.getFieldType();
		String checkItemName=checkItemInfoVo.getCheckItemName();
		String checkObject=checkItemInfoVo.getCheckObject();
		String checkItemCode="";
		String itemNshGroup="/"+CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"ITEM";
		String allInitNshGroup="/"+CheckConstants.ChenkGroupName+"/"+CheckConstants.AllinitGroupName;
		String allInitName="ALLINIT_"+checkItemInfoVo.getOsType()+".nsh";
		CheckItemScriptInfoVo checkItemScriptInfoVo=null;
		for(int i=0;i<scriptNameList.size();i++){
			if(scriptNameList.get(i).substring(scriptNameList.get(i).lastIndexOf("_")+1, scriptNameList.get(i).indexOf(".")).equals("check")){
				checkItemScriptInfoVo=new CheckItemScriptInfoVo();
				String binScriptName=scriptNameList.get(i);
				String shellGroup="/"+CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"BIN"+"/"+"SHELL";
				checkItemCode=checkItemInfoVo.getOsType()+"_"+checkItemInfoVo.getFieldType()+"_"+binScriptName.substring(0,binScriptName.indexOf("."));
				checkItemScriptInfoVo.setCheckItemCode(checkItemCode);
				checkItemScriptInfoVo.setScriptName(binScriptName);
				checkItemScriptInfoVo.setScriptPath(shellGroup);
				checkItemScriptInfoVo.setScriptType("BIN");
				getSession().save(checkItemScriptInfoVo);
			}
			if(scriptNameList.get(i).substring(scriptNameList.get(i).lastIndexOf("_")+1, scriptNameList.get(i).indexOf(".")).equals("init")){
				checkItemScriptInfoVo=new CheckItemScriptInfoVo();
				String initScriptName=scriptNameList.get(i);
				String shellGroup="/"+CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"INIT"+"/"+"SHELL";
				checkItemScriptInfoVo.setCheckItemCode(checkItemCode);
				checkItemScriptInfoVo.setScriptName(initScriptName);
				checkItemScriptInfoVo.setScriptPath(shellGroup);
				checkItemScriptInfoVo.setScriptType("INIT");
				getSession().save(checkItemScriptInfoVo);
			}
			if(scriptNameList.get(i).substring(scriptNameList.get(i).lastIndexOf("_")+1, scriptNameList.get(i).indexOf(".")).equals("set")){
				checkItemScriptInfoVo=new CheckItemScriptInfoVo();
				String setScriptName=scriptNameList.get(i);
				String shellGroup="/"+CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"SET"+"/"+"SHELL";
				checkItemScriptInfoVo.setCheckItemCode(checkItemCode);
				checkItemScriptInfoVo.setScriptName(setScriptName);
				checkItemScriptInfoVo.setScriptPath(shellGroup);
				checkItemScriptInfoVo.setScriptType("SET");
				getSession().save(checkItemScriptInfoVo);
			}
		  }
		CheckItemNshInfoVo checkItemNshInfoVo=new CheckItemNshInfoVo();
		checkItemNshInfoVo.setCheckItemCode(checkItemCode);
		checkItemNshInfoVo.setItemScriptName(itemNshName);
		checkItemNshInfoVo.setItemScriptPath(itemNshGroup);
		getSession().save(checkItemNshInfoVo);
		String osTypeValue=getOstypeValue(osType);
		CheckItemInfoVo vo=new CheckItemInfoVo();
		vo.setCheckItemCode(checkItemCode);
		vo.setCheckItemName(checkItemName);
		vo.setOsType(osTypeValue);
		vo.setFieldType(fieldType);
		vo.setCheckObject(checkObject);
		vo.setAllinitNshScriptName(allInitName);
		vo.setAllinitNshScriptPath(allInitNshGroup);
		String username = securityUtils.getUser().getUsername();
		vo.setScriptCreator(username);
		Timestamp time=new Timestamp(System.currentTimeMillis());
		vo.setScriptCreated(time);
		getSession().save(vo);
		}
	/**
	 * 
	 * 修改页面数据
	 * @throws SQLException 
	 */
	public Object query(String osType, String fieldType, String binScriptName) throws SQLException {
		// TODO Auto-generated method stub
		String OsType=getOstype(osType);
		String checkItemCode=OsType+"_"+fieldType+"_"+binScriptName.substring(0,binScriptName.indexOf("."));
		StringBuilder sql = new StringBuilder();
		sql.append("select  m.osType as \"osType\",")
				.append(" m.checkItemCode as \"checkItemCode\", ")
				.append("m.fieldType as \"fieldType\", ")
				.append("m.checkObject as \"checkObject\", ")
				.append("m.checkItemName as \"checkItemName\", ")
				.append("m.scriptType as \"scriptType\", ")
				.append("m.scriptName as \"scriptName\" ")
				.append(" from (  ")
				.append(" select t.os_type as osType, t.check_item_code as checkItemCode, ")
				.append(" t.field_type as fieldType, t.check_object as checkObject, ")
				.append(" t.check_item_name as checkItemName, ")
				.append(" o.script_type as scriptType, ")
				.append(" o.script_name  as scriptName")
				.append(" from check_item_info t, check_item_script_info o  ")
				.append(" where t.check_item_code = o.check_item_code and t.check_item_code=:check_item_code) m where 1=1 ");
		Query query =   getSession().createSQLQuery(sql.toString())
				.addScalar("osType", StringType.INSTANCE)
				.addScalar("checkItemCode", StringType.INSTANCE)
				.addScalar("checkObject", StringType.INSTANCE)
				.addScalar("fieldType", StringType.INSTANCE)
				.addScalar("checkItemName", StringType.INSTANCE)
				.addScalar("scriptType", StringType.INSTANCE)
				.addScalar("scriptName", StringType.INSTANCE)
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
				.setString("check_item_code", checkItemCode);
		List<HashMap<String,String>> list=query.list();
		HashMap<String,String> map=new HashMap<String,String>();
		for(int i =0;i<list.size();i++){
			map.put("osType", list.get(i).get("osType").toString());
			map.put("fieldType", list.get(i).get("fieldType"));
			map.put("checkObject", list.get(i).get("checkObject"));
			map.put("checkItemName", list.get(i).get("checkItemName"));
			if(list.get(i).get("scriptType").equals("BIN")){
				map.put("binScriptName", list.get(i).get("scriptName"));
			}
			if(list.get(i).get("scriptType").equals("SET")){
				map.put("setScriptName", list.get(i).get("scriptName"));
			}
			if(list.get(i).get("scriptType").equals("INIT")){
				map.put("initScriptName", list.get(i).get("scriptName"));
			}
		}
		return map;
	}
	/**
	 * 修改脚本
	 * @throws Exception 
	 */
	@SuppressWarnings("unchecked")
	public void editShScriptToBsa(CheckItemInfoVo checkItemInfoVo,
			String fileTxt, String shPath) throws Exception {
		String osType=getOstype(checkItemInfoVo.getOsType());
		String fieldType=checkItemInfoVo.getFieldType();
		String toolNshScriptPath = "/BMC Maintenance/SysTools/filepush";
		String bsaServer = messages.getMessage("bsa.ipAddress"); 
		//取服务器的ip
		String ip=messages.getMessage("systemServer.ip");
		String Path="";
		if(ComUtil.isWindows){
			Path=shPath.replace(":", "").replace("\\", "/");
		}else{
			Path=shPath.substring(1);
		}
		String path=checkItemInfoVo.getPath();
		JSONArray pathParam = JSONArray.fromObject(path);
		List<String> pathParams = (List<String>) JSONArray.toCollection(pathParam, String.class);
		String binScriptPath = null;
		String initScriptPath = null;
		String setScriptPath = null;
		//如果.sh文件存在时替换脚本
		String toolNshScriptName = "DepotScriptUpload.nsh";
		//替换脚本创建的作业名字
		String toolJobName = toolNshScriptName.substring(0,toolNshScriptName.indexOf(".")).concat((new SimpleDateFormat("yyyyMMddHHmmss").format(new Date())).toString());
		String allInitNshGroup=CheckConstants.ChenkGroupName+"/"+CheckConstants.AllinitGroupName;
		for (String paths : pathParams) {
			binScriptPath=ComUtil.checkNull(paths.split(Constants.SPLIT_SEPARATEOR)[0]);
			initScriptPath=ComUtil.checkNull(paths.split(Constants.SPLIT_SEPARATEOR)[2]);
			setScriptPath=ComUtil.checkNull(paths.split(Constants.SPLIT_SEPARATEOR)[1]);
		}
		
		if(!binScriptPath.equals("") && fileTxt.substring(fileTxt.lastIndexOf("_")+1, fileTxt.indexOf(".")).equals("check")){
			String shellGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"BIN"+"/"+"SHELL";
			String fileLocation="//"+ip+"/"+Path;
			//创建替换bin脚本的作业
			createToolJob(allInitNshGroup,toolJobName,toolNshScriptPath,toolNshScriptName,bsaServer);
			//给作业附参数
			addToolJobParam1(allInitNshGroup,toolJobName,fileLocation,fileTxt,shellGroup);
			//获取作业的DbKey
			String nshJobDbkey=(String) getNshJobDbKey(allInitNshGroup, toolJobName);
			//执行作业
			exceNshJob(nshJobDbkey);
			//删除作业
			deleteJob(allInitNshGroup,toolJobName);
		}
		if(!initScriptPath.equals("") && fileTxt.substring(fileTxt.lastIndexOf("_")+1, fileTxt.indexOf(".")).equals("init")){
			String fileLocation="//"+ip+"/"+Path+"/"+fileTxt;
			String shellGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"INIT"+"/"+"SHELL";
			String nshellGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"INIT"+"/"+"NSH";
			String initNshName=fileTxt.substring(0,fileTxt.indexOf(".")).concat(".nsh");
			deleteShFile(shellGroup, fileTxt);
			deleteNshFile(nshellGroup, initNshName);
			addFileToDepot(shellGroup, fileLocation, fileTxt);
			String shDbKey=(String) getFileDbKey(CheckConstants.fileType, shellGroup, fileTxt);
			applyAclPolicy(shDbKey, CheckConstants.celv);
			String shDbKey1=(String) getFileDbKey(CheckConstants.fileType, shellGroup, fileTxt);
			applyAclPolicy(shDbKey1, CheckConstants.allSysadminCelv);
			String nshName=fileTxt.substring(0,fileTxt.indexOf(".")).concat(".nsh");
			String nshFileLocation="//"+ip+"/"+Path+"/"+nshName;
			String nshDbKey0=(String) getFileDbKey(CheckConstants.nshFileType, nshellGroup, nshName);
			if(nshDbKey0.equals("void")){
			Object nshNeiRong = nshText(shellGroup, fileTxt, "init");
			File file = new File(shPath);
			if(!file.exists()){
				file.mkdirs();
			}
			PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(shPath.concat(File.separator).concat(nshName)),"utf-8"));
			out.println(nshNeiRong);
			out.flush();
			out.close();
			addNshToDepot(nshellGroup, nshFileLocation, nshName);
			String nshDbKey=(String) getFileDbKey(CheckConstants.nshFileType, nshellGroup, nshName);
			applyAclPolicy(nshDbKey, CheckConstants.celv);
			String nshDbKey1=(String) getFileDbKey(CheckConstants.nshFileType, nshellGroup, nshName);
			applyAclPolicy(nshDbKey1, CheckConstants.allSysadminCelv);
			addParamToNshScript(nshellGroup,nshName);
			}	
		}
		if(!setScriptPath.equals("") && fileTxt.substring(fileTxt.lastIndexOf("_")+1, fileTxt.indexOf(".")).equals("set")){
			String fileLocation="//"+ip+"/"+Path+"/"+fileTxt;
			String shellGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"SET"+"/"+"SHELL";
			String nshellGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"SET"+"/"+"NSH";
			String setNshName=fileTxt.substring(0,fileTxt.indexOf(".")).concat(".nsh");
			deleteShFile(shellGroup, fileTxt);
			deleteNshFile(nshellGroup, setNshName);
			addFileToDepot(shellGroup, fileLocation, fileTxt);
			String shDbKey=(String) getFileDbKey(CheckConstants.fileType, shellGroup, fileTxt);
			applyAclPolicy(shDbKey, CheckConstants.celv);
			String shDbKey1=(String) getFileDbKey(CheckConstants.fileType, shellGroup, fileTxt);
			applyAclPolicy(shDbKey1, CheckConstants.allSysadminCelv);
			String nshName=fileTxt.substring(0,fileTxt.indexOf(".")).concat(".nsh");
			String nshFileLocation="//"+ip+"/"+Path+"/"+nshName;
			String nshDbKey0=(String) getFileDbKey(CheckConstants.nshFileType, nshellGroup, nshName);
			if(nshDbKey0.equals("void")){
			Object nshNeiRong = nshText(shellGroup, fileTxt, "set");
			File file = new File(shPath);
			if(!file.exists()){
				file.mkdirs();
			}
			PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(shPath.concat(File.separator).concat(nshName)),"utf-8"));
			out.println(nshNeiRong);
			out.flush();
			out.close();
			addNshToDepot(nshellGroup, nshFileLocation, nshName);
			String nshDbKey=(String) getFileDbKey(CheckConstants.nshFileType, nshellGroup, nshName);
			applyAclPolicy(nshDbKey, CheckConstants.celv);
			String nshDbKey1=(String) getFileDbKey(CheckConstants.nshFileType, nshellGroup, nshName);
			applyAclPolicy(nshDbKey1, CheckConstants.allSysadminCelv);
			addParamToNshScript(nshellGroup,nshName);
			}
		}
	}
	
	/**
	 * 修改保存
	 * @throws Exception 
	 */
	@SuppressWarnings("unchecked")
	public void edit(CheckItemInfoVo checkItemInfoVo,
			List<String> scriptNameList, String shPath) throws Exception {
		// TODO Auto-generated method stub
		String osType=getOstype(checkItemInfoVo.getOsType());
		String fieldType=checkItemInfoVo.getFieldType();
		String checkItemName=checkItemInfoVo.getCheckItemName();
		CheckItemScriptInfoVo checkItemScriptInfoVo=null;
		String checkItemCode="";
		String json = checkItemInfoVo.getValue();
		JSONArray arrayparam = JSONArray.fromObject(json);
		List<String> scriptNames = (List<String>) JSONArray.toCollection(arrayparam, String.class);
		String binScriptName = null;
		String initScriptName = null;
		String setScriptName = null;
	
		for (String scriptName : scriptNames) {
			binScriptName=ComUtil.checkNull(scriptName.split(Constants.SPLIT_SEPARATEOR)[0]);
			initScriptName=ComUtil.checkNull(scriptName.split(Constants.SPLIT_SEPARATEOR)[2]);
			setScriptName=ComUtil.checkNull(scriptName.split(Constants.SPLIT_SEPARATEOR)[1]);
			if(!binScriptName.equals("") && binScriptName.substring(binScriptName.lastIndexOf("_")+1, binScriptName.indexOf(".")).equals("check")){
				checkItemScriptInfoVo=new CheckItemScriptInfoVo();
				String shellGroup="/"+CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"BIN"+"/"+"SHELL";
				checkItemCode=osType+"_"+checkItemInfoVo.getFieldType()+"_"+binScriptName.substring(0,binScriptName.indexOf("."));
				checkItemScriptInfoVo.setCheckItemCode(checkItemCode);
				checkItemScriptInfoVo.setScriptName(binScriptName);
				checkItemScriptInfoVo.setScriptPath(shellGroup);
				checkItemScriptInfoVo.setScriptType("BIN");
				String sqlCheckItemScriptInfo = "delete check_item_script_info where check_item_code = '"+checkItemCode+"' " ;
				getSession().createSQLQuery(sqlCheckItemScriptInfo).executeUpdate();
				getSession().save(checkItemScriptInfoVo);
			}
			if(!initScriptName.equals("") && initScriptName.substring(initScriptName.lastIndexOf("_")+1, initScriptName.indexOf(".")).equals("init")){
				checkItemScriptInfoVo=new CheckItemScriptInfoVo();
				String shellGroup="/"+CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"INIT"+"/"+"SHELL";
				checkItemScriptInfoVo.setCheckItemCode(checkItemCode);
				checkItemScriptInfoVo.setScriptName(initScriptName);
				checkItemScriptInfoVo.setScriptPath(shellGroup);
				checkItemScriptInfoVo.setScriptType("INIT");
				getSession().save(checkItemScriptInfoVo);
			}
			if(!setScriptName.equals("") && setScriptName.substring(setScriptName.lastIndexOf("_")+1, setScriptName.indexOf(".")).equals("set")){
				checkItemScriptInfoVo=new CheckItemScriptInfoVo();
				String shellGroup="/"+CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"SET"+"/"+"SHELL";
				checkItemScriptInfoVo.setCheckItemCode(checkItemCode);
				checkItemScriptInfoVo.setScriptName(setScriptName);
				checkItemScriptInfoVo.setScriptPath(shellGroup);
				checkItemScriptInfoVo.setScriptType("SET");
				getSession().save(checkItemScriptInfoVo);
			}
		}
		String param=checkItemInfoVo.getParam();
		JSONArray Param = JSONArray.fromObject(param);
		List<String> oldScriptNames = (List<String>) JSONArray.toCollection(Param, String.class);
		String initNshGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"INIT"+"/"+"NSH";
		String setNshGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"SET"+"/"+"NSH";
		String binShGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"BIN"+"/"+"SHELL";
		String initShGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"INIT"+"/"+"SHELL";
		String setShGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"SET"+"/"+"SHELL";
		String oldBinScriptName = null;
		String oldInitScriptName = null;
		String oldSetScriptName = null;
		for (String oldScriptName : oldScriptNames) {
			oldBinScriptName=ComUtil.checkNull(oldScriptName.split(Constants.SPLIT_SEPARATEOR)[0]);
			oldInitScriptName=ComUtil.checkNull(oldScriptName.split(Constants.SPLIT_SEPARATEOR)[2]);
			oldSetScriptName=ComUtil.checkNull(oldScriptName.split(Constants.SPLIT_SEPARATEOR)[1]);
			if(!oldInitScriptName.equals("") && initScriptName.equals("")){
				String initNshName=oldInitScriptName.substring(0,oldInitScriptName.indexOf(".")).concat(".nsh");
				deleteShFile(initShGroup, oldInitScriptName);
				deleteNshFile(initNshGroup, initNshName);
			}
			if(!oldSetScriptName.equals("") && setScriptName.equals("")){
				String setNshName=oldSetScriptName.substring(0,oldSetScriptName.indexOf(".")).concat(".nsh");
				deleteShFile(setShGroup, oldSetScriptName);
				deleteNshFile(setNshGroup, setNshName);
			}
		}	
		String username = securityUtils.getUser().getUsername();
		String sqlCheckItemInfo = "	update check_item_info set check_item_name = '"+checkItemInfoVo.getCheckItemName()+"', script_modifier='"+username+"', script_modified=sysdate,check_item_desc='"+checkItemInfoVo.getCheckItemDesc()+"' where check_item_code = '"+checkItemCode+"'" ;
		getSession().createSQLQuery(sqlCheckItemInfo).executeUpdate();
	}
	
	@SuppressWarnings("unchecked")
	public void editItemScript(CheckItemInfoVo checkItemInfoVo,
			List<String> scriptNameList, String shPath) throws Exception {
		// TODO Auto-generated method stub
		String osType=getOstype(checkItemInfoVo.getOsType());
		String fieldType=checkItemInfoVo.getFieldType();
		String itemNshGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"ITEM";
		String checkItemCode="";
		String itemNshName="";
		String binNshGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"BIN"+"/"+"NSH";
		String initNshGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"INIT"+"/"+"NSH";
		String setNshGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"SET"+"/"+"NSH";
		String json = checkItemInfoVo.getValue();
		//取服务器的ip
		String ip=messages.getMessage("systemServer.ip");
		String Path="";
		if(ComUtil.isWindows){
			Path=shPath.replace(":", "").replace("\\", "/");
		}else{
			Path=shPath.substring(1);
		}
		JSONArray arrayparam = JSONArray.fromObject(json);
		List<String> scriptNames = (List<String>) JSONArray.toCollection(arrayparam, String.class);
		for (String scriptName : scriptNames) {
			String binScriptName=ComUtil.checkNull(scriptName.split(Constants.SPLIT_SEPARATEOR)[0]);
			if(!binScriptName.equals("") && binScriptName.substring(binScriptName.lastIndexOf("_")+1, binScriptName.indexOf(".")).equals("check")){
				itemNshName=binScriptName.substring(0,binScriptName.indexOf(".")).concat("_item.nsh");
				checkItemCode=osType+"_"+checkItemInfoVo.getFieldType()+"_"+binScriptName.substring(0,binScriptName.indexOf("."));
			}
		}
		deleteNshFile(itemNshGroup, itemNshName);
		StringBuilder sql = new StringBuilder();
		sql.append("select t.script_name,t.script_path,t.script_type from check_item_script_info t where t.check_item_code='"+checkItemCode+"' ");
		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		List<Map<String,String>> list=query.list();
		String crlf=System.getProperty("line.separator");
		StringBuilder itemNshFile = new StringBuilder();
		itemNshFile.append("TargetIP=$1").append(crlf);
		itemNshFile.append("PushFile=$2").append(crlf);
		itemNshFile.append("Syspath=$3").append(crlf);
		itemNshFile.append("Script=$4").append(crlf);
		itemNshFile.append("Execute=$5").append(crlf);
		itemNshFile.append("ExecuteCommonInitnsh=$6").append(crlf);
		itemNshFile.append("Set=$7").append(crlf);
		itemNshFile.append("Init=$8").append(crlf);
		itemNshFile.append("Bin=$9").append(crlf);
		for(int i=0;i<list.size();i++){
			if(list.get(i).get("SCRIPT_TYPE").equals("BIN")){
				String nshName=list.get(i).get("SCRIPT_NAME").substring(0,list.get(i).get("SCRIPT_NAME").indexOf(".")).concat(".nsh");
				itemNshFile.append("if [ $Bin = y ];").append(crlf).append("then")
				.append("nsh -c \"$ExecuteCommonInitnsh\" /"+binNshGroup+" "+nshName+" $TargetIP $PushFile $Syspath").append(crlf).append("fi").append(crlf);
			}
			if(list.get(i).get("SCRIPT_TYPE").equals("INIT")){
				String nshName=list.get(i).get("SCRIPT_NAME").substring(0,list.get(i).get("SCRIPT_NAME").indexOf(".")).concat(".nsh");
				itemNshFile.append("if [ $Init = y ];").append(crlf).append("then")
				.append("nsh -c \"$ExecuteCommonInitnsh\" /"+initNshGroup+" "+nshName+" $TargetIP $PushFile $Syspath $Script $Execute").append(crlf).append("fi").append(crlf);
			}
			if(list.get(i).get("SCRIPT_TYPE").equals("SET")){
				String nshName=list.get(i).get("SCRIPT_NAME").substring(0,list.get(i).get("SCRIPT_NAME").indexOf(".")).concat(".nsh");
				itemNshFile.append("if [ $Set = y ];").append(crlf).append("then")
				.append("nsh -c \"$ExecuteCommonInitnsh\" /"+setNshGroup+" "+nshName+" $TargetIP $PushFile $Syspath $Script $Execute").append(crlf).append("fi").append(crlf);
			}
		}
		itemNshFile.append("if [ $? != 0 ];").append(crlf);
		itemNshFile.append("then").append(crlf);
		itemNshFile.append("exit 151").append(crlf);
		itemNshFile.append("fi").append(crlf);
		File file = new File(shPath);
		if(!file.exists()){
			file.mkdirs();
		}
		PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(shPath.concat(File.separator).concat(itemNshName)),"utf-8"));
		out.println(itemNshFile);
		out.flush();
		out.close();
		String nshFileLocation="//"+ip+"/"+Path+"/"+itemNshName;
		addNshToDepot(itemNshGroup, nshFileLocation, itemNshName);
		String nshDbKey=(String) getFileDbKey(CheckConstants.nshFileType, itemNshGroup, itemNshName);
		applyAclPolicy(nshDbKey, CheckConstants.celv);
		String nshDbKey1=(String) getFileDbKey(CheckConstants.nshFileType, itemNshGroup, itemNshName);
		applyAclPolicy(nshDbKey1, CheckConstants.allSysadminCelv);
		addParamToItemNshScript(itemNshGroup,itemNshName);
	}
	/**
	 * 删除多条
	 * @param shPath 
	 * @throws Exception 
	 */
	public void deleteByIds(String[] osTypes, String[] fieldTypes,
			String[] binScriptNames, String[] setScriptNames,
			String[] initScriptNames, String shPath) throws Exception {
		// TODO Auto-generated method stub
		for (int i = 0; i < osTypes.length && i < fieldTypes.length && i < binScriptNames.length; i++) {
			String checkItemCode=getOstype(osTypes[i])+"_"+fieldTypes[i]+"_"+binScriptNames[i].substring(0,binScriptNames[i].indexOf("."));
			if(setScriptNames.length>0 && initScriptNames.length>0){
				deleteById(getOstype(osTypes[i]), fieldTypes[i],binScriptNames[i],setScriptNames[i],initScriptNames[i],checkItemCode,shPath);
			}
			if(setScriptNames.length==0 && initScriptNames.length!=0){
				deleteById(getOstype(osTypes[i]), fieldTypes[i],binScriptNames[i],"",initScriptNames[i],checkItemCode,shPath);
			}
			if(initScriptNames.length==0 && setScriptNames.length!=0){
				deleteById(getOstype(osTypes[i]), fieldTypes[i],binScriptNames[i],setScriptNames[i],"",checkItemCode,shPath);
			}
			if(setScriptNames.length==0 && initScriptNames.length==0){
				deleteById(getOstype(osTypes[i]), fieldTypes[i],binScriptNames[i],"","",checkItemCode,shPath);
			}
		}		
	}
	/**
	 * 删除单条
	 * @throws Exception 
	 */
	@Transactional(rollbackFor=Exception.class)
	@SuppressWarnings("unchecked")
	private void deleteById(String osType, String fieldType, String binScriptName,
			String setScriptName, String initScriptName, String checkItemCode, String shPath) throws Exception {
		// TODO Auto-generated method stub
		String sqlCheckItemInfo = "delete check_item_info where check_item_code = '"+checkItemCode+"' ";
		getSession().createSQLQuery(sqlCheckItemInfo).executeUpdate();
		
		String sqlCheckItemNshInfo = "delete check_item_nsh_info where check_item_code = '"+checkItemCode+"' " ;
		getSession().createSQLQuery(sqlCheckItemNshInfo).executeUpdate();
		
		String sqlCheckItemScriptInfo = "delete check_item_script_info where check_item_code = '"+checkItemCode+"' " ;
		getSession().createSQLQuery(sqlCheckItemScriptInfo).executeUpdate();
		
		String binNshGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"BIN"+"/"+"NSH";
		String binNshellGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"BIN"+"/"+"NSHELL";
		String initNshGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"INIT"+"/"+"NSH";
		String setNshGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"SET"+"/"+"NSH";
		
		String binShellGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"BIN"+"/"+"SHELL";
		String setShellGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"SET"+"/"+"SHELL";
		String initShellGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"INIT"+"/"+"SHELL";
		
		String binNshName=binScriptName.substring(0,binScriptName.indexOf(".")).concat(".nsh");
		String initNshName=null;
		if(!initScriptName.equals("")){
		initNshName=initScriptName.substring(0,initScriptName.indexOf(".")).concat(".nsh");
		}
		String setNshName=null;
		if(!setScriptName.equals("")){
		setNshName=setScriptName.substring(0,setScriptName.indexOf(".")).concat(".nsh");
		}
		String itemNshGroup=CheckConstants.ChenkGroupName+"/"+osType+"/"+fieldType+"/"+"ITEM";
		String itemNshName=binScriptName.substring(0,binScriptName.indexOf(".")).concat("_item.nsh");
		//删除set
		if(!setScriptName.equals("")){
		deleteShFile(setShellGroup, setScriptName);
		deleteNshFile(setNshGroup, setNshName);
		}
		//删除init
		if(!initScriptName.equals("")){
		deleteShFile(initShellGroup, initScriptName);
		deleteNshFile(initNshGroup, initNshName);
		}
		//删除Item
		deleteNshFile(itemNshGroup, itemNshName);
		String allInitName="ALLINIT_"+osType+".nsh";
		//替换脚本的位置		String toolNshScriptPath = "/BMC Maintenance/SysTools/filepush";
		//bsa服务器的ip
		String bsaServer = messages.getMessage("bsa.ipAddress");
		String allInitNshGroup=CheckConstants.ChenkGroupName+"/"+CheckConstants.AllinitGroupName;
		StringBuilder sql = new StringBuilder();
		String osTypeValue=getOstypeValue(osType);
		sql.append("select t.item_script_path,t.item_script_name from check_item_nsh_info t ,check_item_info d where t.check_item_code=d.check_item_code and d.os_type='"+osTypeValue+"' " );
		Query query = getSession().createSQLQuery(sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		List<Map<String,String>> list=query.list();
		if(list.size()==0){
			deleteNshFile(allInitNshGroup, allInitName);
		}else{}
		String blpackageName="ALLFILES_"+osType;
		String osTypeGroup=CheckConstants.ChenkGroupName+"/"+osType;
		String moveFileScript="MoveDepotFilestoagroup.nsh";
		String toolJobName = moveFileScript.substring(0,moveFileScript.indexOf(".")).concat((new SimpleDateFormat("yyyyMMddHHmmss").format(new Date())).toString());
		String groupId=(String) groupNameToId(osTypeGroup);
		createBlpackage(blpackageName,groupId);
		StringBuilder Sql = new StringBuilder();
		Sql.append("select t.script_name,t.script_path from check_item_script_info t ,check_item_info o where t.script_type='BIN' and t.check_item_code=o.check_item_code and o.os_type='"+osTypeValue+"' ");
		Query Query = getSession().createSQLQuery(Sql.toString())
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		List<Map<String,String>> List=Query.list();
		if(List.size()==0){
			//删除bin
			deleteShFile(binShellGroup, binScriptName);
			deleteShFile(binNshellGroup, binNshName);
			deleteNshFile(binNshGroup, binNshName);
		}else{
			for(int i=0;i<List.size();i++){
				String shellGroup=List.get(i).get("SCRIPT_PATH").substring(1);
				importDepotObjectToPackage(osTypeGroup,blpackageName,shellGroup,List.get(i).get("SCRIPT_NAME"),CheckConstants.fileType,osType,"SHELL");
				String nshellGroup=shellGroup.substring(0,shellGroup.lastIndexOf("/")+1).concat("NSHELL");
				String nshellName=List.get(i).get("SCRIPT_NAME").substring(0,List.get(i).get("SCRIPT_NAME").indexOf(".")).concat(".nsh");
				importDepotObjectToPackage(osTypeGroup,blpackageName,nshellGroup,nshellName,CheckConstants.fileType,osType,"NSH");
			}
			String allinitGroup=CheckConstants.ChenkGroupName+"/"+CheckConstants.AllinitGroupName;
			updateByName(blpackageName, blpackageName, osTypeGroup, allinitGroup);
			deleteBlpackage(osTypeGroup,blpackageName);
			createToolJob(allInitNshGroup, toolJobName, toolNshScriptPath, moveFileScript, bsaServer);
			addToolJobParam1(allInitNshGroup, toolJobName, binShellGroup, binScriptName, binShellGroup,binNshellGroup,binNshName);
			String nshJobDbkey1=(String) getNshJobDbKey(allInitNshGroup, toolJobName);
			exceNshJob(nshJobDbkey1);
			deleteJob(allInitNshGroup, toolJobName);
			deleteNshFile(binNshGroup, binNshName);
		}
	}

	private void addToolJobParam1(String jobGroup,String toolJobName,String wenjianPath,String nshName, String shellGroup,
			String binNshellGroup, String binNshName) throws Exception {
		// TODO Auto-generated method stub
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		//清除参数
		CLITunnelServiceClient jobParentGroupName0 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames0 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","clearNSHScriptParameterValuesByGroupAndName",new String[] {"/"+jobGroup+"",toolJobName});
		String DbKey0 = (String) jobParentGroupNames0.get_return().getReturnValue();
		
		//设置参数
		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/"+jobGroup+"",toolJobName,"0","/"+wenjianPath+""});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		
		CLITunnelServiceClient jobParentGroupName2 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames2 = jobParentGroupName2.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/"+jobGroup+"",toolJobName,"2","/"+shellGroup+""});
		String DbKey2 = (String) jobParentGroupNames2.get_return().getReturnValue();
		
		CLITunnelServiceClient jobParentGroupName1 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames1 = jobParentGroupName1.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/"+jobGroup+"",toolJobName,"1",nshName});
		String DbKey1 = (String) jobParentGroupNames1.get_return().getReturnValue();
		
		CLITunnelServiceClient jobParentGroupName3 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames3 = jobParentGroupName3.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/"+jobGroup+"",toolJobName,"3","/"+binNshellGroup+""});
		String DbKey3 = (String) jobParentGroupNames3.get_return().getReturnValue();
		
		CLITunnelServiceClient jobParentGroupName4 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames4 = jobParentGroupName4.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/"+jobGroup+"",toolJobName,"4",binNshName});
		String DbKey4 = (String) jobParentGroupNames4.get_return().getReturnValue();
	}

	/**
	 * 获取操作系统名称
	 * return HP-UX
	 */
	@Transactional(readOnly = true)
	public String getOstype(String value)throws SQLException {
		
		StringBuilder sql = new StringBuilder();
		sql.append("select o.sub_item_name from jeda_sub_item o where o.item_id='OS_TYPE' and o.sub_item_value=:sub_item_value ");
		Query query = getSession().createSQLQuery(sql.toString())
				.setString("sub_item_value",value);
		return query.list().get(0).toString();
	}
	/**
	 * 获取操作系统名称
	 * return 2
	 */
	@Transactional(readOnly = true)
	
	public String getOstypeValue(String name)throws SQLException {
		
		StringBuilder sql = new StringBuilder();
		sql.append("select o.sub_item_value from jeda_sub_item o where o.item_id='OS_TYPE' and o.sub_item_name=:sub_item_name ");
		Query query = getSession().createSQLQuery(sql.toString())
				.setString("sub_item_name",name);
		return query.list().get(0).toString();
	}
	/**
	 * 写文件
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object binNshText(String nshellGroup,String fileName) throws Exception {
		String crlf=System.getProperty("line.separator");
		StringBuilder BinNshFile = new StringBuilder();
		BinNshFile.append("TargetIP=$1").append(crlf);
		BinNshFile.append("PushFile=$2").append(crlf);
		BinNshFile.append("Syspath=$3").append(crlf);
		BinNshFile.append("nsh -c \"$PushFile\" /"+nshellGroup+" "+fileName+" //$TargetIP$Syspath/bin").append(crlf);
		BinNshFile.append("if [ $? != 0 ];").append(crlf);
		BinNshFile.append("then").append(crlf);
		BinNshFile.append("exit 151").append(crlf);
		BinNshFile.append("fi").append(crlf);
		return BinNshFile;
	}
	/**
	 * 写文件
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object binNshFile(String binNshName,String logName) throws Exception {
		String crlf=System.getProperty("line.separator");
		StringBuilder nshFile = new StringBuilder();
		nshFile.append("Host=$1").append(crlf);
		nshFile.append("SysPath=$2").append(crlf);
		nshFile.append("StorePath=$3").append(crlf);
		nshFile.append("LogPath=$4").append(crlf);
		nshFile.append("CheckDate=`date \"+%Y%m%d%H%M%S\"`").append(crlf);
		nshFile.append("echo \"CheckDate $CheckDate\"").append(crlf);
		nshFile.append("Date=`date \"+%Y%m%d\"`").append(crlf);
		nshFile.append("if [ ! -f //$Host$SysPath/bin/"+binNshName+" ] ; then").append(crlf);
		nshFile.append("echo \""+binNshName+" NOSCRIPT\"").append(crlf);
		nshFile.append("exit 0").append(crlf);
		nshFile.append("fi").append(crlf);
		nshFile.append("nexec $Host su root -c \"cd $SysPath/bin;sh "+binNshName+" $CheckDate\" ").append(crlf);
		nshFile.append("cd $LogPath").append(crlf);
		nshFile.append("if [ ! -d $LogPath/$Date ] ; then").append(crlf);
		nshFile.append("mkdir $Date").append(crlf);
		nshFile.append("fi").append(crlf);
		nshFile.append("cd //$Host/home/sysadmin/check/log/errorlog/").append(crlf);
		nshFile.append("a=m_`hostname`_${CheckDate}_"+logName+"").append(crlf);
		nshFile.append("b=`ls|grep $a`").append(crlf);
		nshFile.append("if [ \"$b\" = \"\" ] ; then").append(crlf);
		nshFile.append("exit 0").append(crlf);
		nshFile.append("else").append(crlf);
		nshFile.append("cp -f m_`hostname`_${CheckDate}_"+logName+"* $LogPath/$Date").append(crlf);
		nshFile.append("fi");
		return nshFile;
	}
	/**
	 * 写文件

	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object nshText(String fileLocation,String fileName,String shType) throws Exception {
		String crlf=System.getProperty("line.separator");
		StringBuilder nshFile = new StringBuilder();
		nshFile.append("TargetIP=$1").append(crlf);
		nshFile.append("PushFile=$2").append(crlf);
		nshFile.append("Syspath=$3").append(crlf);
		nshFile.append("Script=$4").append(crlf);
		nshFile.append("Execute=$5").append(crlf);
		nshFile.append("if [ $Script = y ];").append(crlf);
		nshFile.append("then").append(crlf);
		nshFile.append("nsh -c \"$PushFile\" /"+fileLocation+" "+fileName+" //$TargetIP$Syspath/"+shType+"").append(crlf);
		nshFile.append("fi").append(crlf);
		nshFile.append("if [ $Execute = y ];").append(crlf);
		nshFile.append("then").append(crlf);
		nshFile.append("nexec $TargetIP \"cd $Syspath/"+shType+";sh "+fileName+"\" ").append(crlf);
		nshFile.append("fi").append(crlf);
		nshFile.append("if [ $? != 0 ];").append(crlf);
		nshFile.append("then").append(crlf);
		nshFile.append("exit 151").append(crlf);
		nshFile.append("fi");
		return nshFile;
	}
	/**
	 * 删除Blpackage包

	 * @throws Exception
	 * @throws JEDAException
	 */
	private void deleteBlpackage(String parentGroup, String packageName) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator).concat(File.separator).concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("BlPackage","deleteBlPackageByGroupAndName",new String[] {"/"+parentGroup+"",packageName});
	}
	/**
	 * 替换blpackage包

	 * @throws Exception
	 * @throws JEDAException
	 */
	private Object updateByName(String srcBlPackageName,String destBlPackageName,String srcBlPackageGroupName,String destBlPackageGroupName) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("BlPackage","updateByName",new String[] {srcBlPackageName,destBlPackageName,"/"+srcBlPackageGroupName+"","/"+destBlPackageGroupName+""});
		String value = (String) serverPropertyNames.get_return().getReturnValue();
		return value;
	}
	/**
	 * 删除.nsh文件
	 * @throws Exception
	 * @throws JEDAException
	 */
	private Object deleteNshFile(String group,String nshName) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("NSHScript","deleteNSHScriptByGroupAndName",new String[] {"/"+group+"",nshName});
		String value = (String) serverPropertyNames.get_return().getReturnValue();
		return value;
	}
	/**
	 * 删除.sh文件
	 * @throws Exception
	 * @throws JEDAException
	 */
	private Object deleteShFile(String group,String scriptName) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("DepotFile","deleteFileByGroupAndName",new String[] {"/"+group+"",scriptName});
		String value = (String) serverPropertyNames.get_return().getReturnValue();
		return value;
	}
	/**
	 * 创建JOB文件夹

	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object createJobGroup(String group,String parentGroup) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名

		CLITunnelServiceClient createGroup = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse result = createGroup.executeCommandByParamList("JobGroup","createGroupWithParentName",new String[] { group,"/"+parentGroup+""});
		String value = (String) result.get_return().getReturnValue();
		return value;
	}
	/**
	 * 检查JOB文件夹是否存在

	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object jobGroupExists(String group) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名

		CLITunnelServiceClient GroupName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse GroupNames = GroupName.executeCommandByParamList("JobGroup","groupExists",new String[] { "/"+group+""});
		String value = (String) GroupNames.get_return().getReturnValue();
		return value;
	}
	/**
	 * JOB文件夹附策略
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object jobGroupApplyAclPolicy(String group,String celv) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名

		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("JobGroup","applyAclPolicy",new String[] {"/"+group+"",celv});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		return DbKey;
	}
	/**
	 * 清除脚本中的参数内容
	 * @throws Exception
	 * @throws JEDAException
	 */
	private Object clearNSHScriptParametersByGroupAndName(String nshGroup, String nshName)  throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("NSHScript","clearNSHScriptParametersByGroupAndName",new String[] {"/"+nshGroup+"",nshName});
		String value = (String) serverPropertyNames.get_return().getReturnValue();
		return value;
	}
	/**
	 * 删除作业
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object deleteJob(String jobGroup,String toolJobName) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("NSHScriptJob","deleteJobByGroupAndName",new String[] {"/"+jobGroup+"",toolJobName});
		String value = (String) serverPropertyNames.get_return().getReturnValue();
		return value;
	}
	/**
	 * 执行NshJob
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object exceNshJob(String nshJobDbkey) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名

		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("NSHScriptJob","executeJobGetJobResultKey",new String[] {""+nshJobDbkey+""});
		String value = (String) jobParentGroupNames.get_return().getReturnValue();
		return value;
	}
	/**
	 * 取NshJob的DbKey
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object getNshJobDbKey(String jobGroup,String toolJobName) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名

		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("NSHScriptJob","getDBKeyByGroupAndName",new String[] {"/"+jobGroup+"",toolJobName});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		return DbKey;
	}
	/**
	 * 创建TOOLS作业附参数

	 * 
	 * @throws Exception
	 * @throws JEDAException  
	 */
	public Object addToolJobParam(String jobGroup,String toolJobName,String wenjianPath,String nshName) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		//清除参数
		CLITunnelServiceClient jobParentGroupName0 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames0 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","clearNSHScriptParameterValuesByGroupAndName",new String[] {"/"+jobGroup+"",toolJobName});
		String DbKey0 = (String) jobParentGroupNames0.get_return().getReturnValue();
		
		//设置参数
		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/"+jobGroup+"",toolJobName,"0",wenjianPath});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		
		CLITunnelServiceClient jobParentGroupName2 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames2 = jobParentGroupName2.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/"+jobGroup+"",toolJobName,"1",nshName});
		String DbKey2 = (String) jobParentGroupNames2.get_return().getReturnValue();
	
		CLITunnelServiceClient jobParentGroupName1 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames1 = jobParentGroupName1.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/"+jobGroup+"",toolJobName,"2","/"+jobGroup+""});
		String DbKey1 = (String) jobParentGroupNames1.get_return().getReturnValue();
		
		
		return DbKey;
	}
	/**
	 * 创建TOOLS作业附参数
	 * @param shellGroup 

	 * 
	 * @throws Exception
	 * @throws JEDAException  
	 */
	public Object addToolJobParam1(String jobGroup,String toolJobName,String wenjianPath,String nshName, String shellGroup) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		//清除参数
		CLITunnelServiceClient jobParentGroupName0 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames0 = jobParentGroupName0.executeCommandByParamList("NSHScriptJob","clearNSHScriptParameterValuesByGroupAndName",new String[] {"/"+jobGroup+"",toolJobName});
		String DbKey0 = (String) jobParentGroupNames0.get_return().getReturnValue();
		
		//设置参数
		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/"+jobGroup+"",toolJobName,"0",wenjianPath});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		
		CLITunnelServiceClient jobParentGroupName2 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames2 = jobParentGroupName2.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/"+jobGroup+"",toolJobName,"2","/"+shellGroup+""});
		String DbKey2 = (String) jobParentGroupNames2.get_return().getReturnValue();
		
		CLITunnelServiceClient jobParentGroupName1 = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames1 = jobParentGroupName1.executeCommandByParamList("NSHScriptJob","addNSHScriptParameterValueByGroupAndName",new String[] {"/"+jobGroup+"",toolJobName,"1",nshName});
		String DbKey1 = (String) jobParentGroupNames1.get_return().getReturnValue();
		
		return DbKey;
	}
	/**
	 * 创建TOOLS作业
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object createToolJob(String jobPath,String toolJobName,String toolNshScriptPath,String toolNshScriptName,String bsaServer) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名

		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("NSHScriptJob","createNSHScriptJob",new String[] {"/"+jobPath+"",toolJobName," ",toolNshScriptPath,toolNshScriptName,bsaServer,"100"});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		return DbKey;
	}
	/**
	 * 取Depot文件夹的Id
	 * @throws Exception
	 * @throws JEDAException
	 */
	private Object groupNameToId(String gruopName) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("DepotGroup","groupNameToId",new String[] {"/"+gruopName+""});
		String groupId = (String) serverPropertyNames.get_return().getReturnValue();
		return groupId;
	}
	/**
	 * 向blpackage中加入软连接
	 * @throws Exception
	 * @throws JEDAException
	 */
	private void importDepotObjectToPackage(String allinitGroup,String blpackageName,String scriptGroup,String scriptName,String fileType,String osType,String scriptGroupName) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		String ming="";
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名
		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("BlPackage","importDepotObjectToPackage",new String[] {"/"+allinitGroup+"",blpackageName,"true","false","false","false","false","/"+scriptGroup+"",scriptName,fileType,"Path","??TARGET.CHECK_STOREPATH??/CHECK/SYS_CHECK/"+osType+"/"+scriptGroupName+"/"+scriptName+"","NotRequired","NotRequired"});
	}
	/**
	 * 创建一个blpackage包

	 * @throws Exception
	 * @throws JEDAException
	 */
	private void createBlpackage(String blpackageName,String groupId) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames = serverPropertyName.executeCommandByParamList("BlPackage","createEmptyPackage",new String[] {blpackageName," ",groupId});
	}
	
	/**
	 * 给nsh脚本附加参数
	 * @throws Exception
	 * @throws JEDAException
	 */
	@SuppressWarnings("unchecked")
	private void addParamToAllInitNshScript(String nshFileLocation,String nshName) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames1 = serverPropertyName.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+nshFileLocation+"",nshName,"TargetIP"," ","??TARGET.IP_ADDRESS??","7"});
		ExecuteCommandByParamListResponse serverPropertyNames2 = serverPropertyName.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+nshFileLocation+"",nshName,"Syspath"," ","??TARGET.CHECK_SYSPATH??","7"});
		ExecuteCommandByParamListResponse serverPropertyNames3 = serverPropertyName.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+nshFileLocation+"",nshName,"PushFile"," ","??TARGET.CHECK_PushFile??","7"});
		ExecuteCommandByParamListResponse serverPropertyNames4 = serverPropertyName.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+nshFileLocation+"",nshName,"ExecuteCommonInitnsh"," ","??TARGET.CHECK_ExecuteCommonInitnsh??","7"});
		ExecuteCommandByParamListResponse serverPropertyNames5 = serverPropertyName.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+nshFileLocation+"",nshName,"BinFileList"," "," ","7"});
		ExecuteCommandByParamListResponse serverPropertyNames6 = serverPropertyName.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+nshFileLocation+"",nshName,"SetFileList"," "," ","7"});
		ExecuteCommandByParamListResponse serverPropertyNames7 = serverPropertyName.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+nshFileLocation+"",nshName,"InitFileList"," "," ","7"});
		ExecuteCommandByParamListResponse serverPropertyNames8 = serverPropertyName.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+nshFileLocation+"",nshName,"Script"," ","n","7"});
		ExecuteCommandByParamListResponse serverPropertyNames9 = serverPropertyName.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+nshFileLocation+"",nshName,"Execute"," ","n","7"});
		ExecuteCommandByParamListResponse serverPropertyNames10 = serverPropertyName.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+nshFileLocation+"",nshName,"Set"," ","y","7"});
		ExecuteCommandByParamListResponse serverPropertyNames11 = serverPropertyName.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+nshFileLocation+"",nshName,"Init"," ","y","7"});
		ExecuteCommandByParamListResponse serverPropertyNames12 = serverPropertyName.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+nshFileLocation+"",nshName,"Bin"," ","y","7"});
	}
	/**
	 * 给nsh脚本附加参数
	 * @throws Exception
	 * @throws JEDAException
	 */
	@SuppressWarnings("unchecked")
	private void addParamToBinNshScript(String nshFileLocation,String nshName) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames1 = serverPropertyName.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+nshFileLocation+"",""+nshName+"","TargetIP"," ","??TARGET.IP_ADDRESS??","7"});
		ExecuteCommandByParamListResponse serverPropertyNames2 = serverPropertyName.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+nshFileLocation+"",""+nshName+"","PushFile"," ","??TARGET.CHECK_PushFile??","7"});
		ExecuteCommandByParamListResponse serverPropertyNames3 = serverPropertyName.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+nshFileLocation+"",""+nshName+"","Syspath"," ","??TARGET.CHECK_SYSPATH??","7"});
	}
	/**
	 * 给nsh脚本附加参数
	 * @throws Exception
	 * @throws JEDAException
	 */
	@SuppressWarnings("unchecked")
	private void addParamToItemNshScript(String nshFileLocation,String nshName) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames1 = serverPropertyName.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+nshFileLocation+"",""+nshName+"","TargetIP"," ","??TARGET.IP_ADDRESS??","7"});
		ExecuteCommandByParamListResponse serverPropertyNames2 = serverPropertyName.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+nshFileLocation+"",""+nshName+"","PushFile"," ","??TARGET.CHECK_PushFile??","7"});
		ExecuteCommandByParamListResponse serverPropertyNames3 = serverPropertyName.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+nshFileLocation+"",""+nshName+"","Syspath"," ","??TARGET.CHECK_SYSPATH??","7"});
		ExecuteCommandByParamListResponse serverPropertyNames5 = serverPropertyName.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+nshFileLocation+"",""+nshName+"","Script"," ","y","7"});
		ExecuteCommandByParamListResponse serverPropertyNames6 = serverPropertyName.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+nshFileLocation+"",""+nshName+"","Execute"," ","y","7"});
		ExecuteCommandByParamListResponse serverPropertyNames4 = serverPropertyName.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+nshFileLocation+"",""+nshName+"","ExecuteCommonInitnsh"," ","??TARGET.CHECK_ExecuteCommonInitnsh??","7"});
		ExecuteCommandByParamListResponse serverPropertyNames7 = serverPropertyName.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+nshFileLocation+"",""+nshName+"","Set"," ","y","7"});
		ExecuteCommandByParamListResponse serverPropertyNames8 = serverPropertyName.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+nshFileLocation+"",""+nshName+"","Init"," ","y","7"});
		ExecuteCommandByParamListResponse serverPropertyNames9 = serverPropertyName.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+nshFileLocation+"",""+nshName+"","Bin"," ","y","7"});
	}
	/**
	 * 给nsh脚本附加参数
	 * @throws Exception
	 * @throws JEDAException
	 */
	@SuppressWarnings("unchecked")
	private void addParamToNshScript(String nshFileLocation,String nshName) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));

		CLITunnelServiceClient serverPropertyName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse serverPropertyNames1 = serverPropertyName.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+nshFileLocation+"",""+nshName+"","TargetIP"," ","??TARGET.IP_ADDRESS??","7"});
		ExecuteCommandByParamListResponse serverPropertyNames2 = serverPropertyName.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+nshFileLocation+"",""+nshName+"","PushFile"," ","??TARGET.CHECK_PushFile??","7"});
		ExecuteCommandByParamListResponse serverPropertyNames3 = serverPropertyName.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+nshFileLocation+"",""+nshName+"","Syspath"," ","??TARGET.CHECK_SYSPATH??","7"});
		ExecuteCommandByParamListResponse serverPropertyNames4 = serverPropertyName.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+nshFileLocation+"",""+nshName+"","Script"," ","y","7"});
		ExecuteCommandByParamListResponse serverPropertyNames5 = serverPropertyName.executeCommandByParamList("NSHScript","addNSHScriptParameterByGroupAndName",new String[] {"/"+nshFileLocation+"",""+nshName+"","Execute"," ","y","7"});
	}
	/**
	 * 上传nsh脚本
	 * @param shJia 
	 * @param serverName 
	 * @param appsysCode 
	 * @param jobName 
	 * @param ip 
	 * @param path 
	 * @param ip 
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object addNshToDepot(String groupName, String fileLocation, String name) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名

		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("NSHScript","addNSHScriptToDepotByGroupName",new String[] {"/"+groupName+"","2",fileLocation,name," "});
		String value = (String) jobParentGroupNames.get_return().getReturnValue();
		return value;
	}
	/**
	 * 文件附策略

	 * @throws NoSuchMessageException 
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	private Object applyAclPolicy( String shDbKey,String celv) throws NoSuchMessageException, Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名
		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("DepotObject","applyAclPolicy",new String[] {shDbKey,celv});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		return DbKey;
	}
	/**
	 * 取文件的DbKey(Depot)
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object getFileDbKey(String depotObjectTypeString,String groupName,String depotObjectName) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名

		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("DepotObject","getDBKeyByTypeStringGroupAndName",new String[] {depotObjectTypeString,"/"+groupName+"",depotObjectName});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		return DbKey;
	}
	/**
	 * 检查DEPOT文件夹是否存在

	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object groupExists(String groupName) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名

		CLITunnelServiceClient GroupName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse GroupNames = GroupName.executeCommandByParamList("DepotGroup","groupExists",new String[] { "/"+groupName+""});
		String value = (String) GroupNames.get_return().getReturnValue();
		return value;
	}
	/**
	 * 创建DEPOT文件夹

	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object createGroup(String groupName,String parentGroupName) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名

		CLITunnelServiceClient createGroup = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse result = createGroup.executeCommandByParamList("DepotGroup","createGroupWithParentName",new String[] {groupName,"/"+parentGroupName+""});
		String value = (String) result.get_return().getReturnValue();
		return value;
	}
	/**
	 * Depot文件夹附策略
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object groupApplyAclPolicy(String groupName,String celv) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名
		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("DepotGroup","applyAclPolicy",new String[] {"/"+groupName+"",celv});
		String DbKey = (String) jobParentGroupNames.get_return().getReturnValue();
		return DbKey;
	}
	/**
	 * 上传脚本.sh
	 * @param shJia 
	 * @param serverName 
	 * @param appsysCode 
	 * @param jobName 
	 * @param ip 
	 * @param path 
	 * @param ip 
	 * 
	 * @throws Exception
	 * @throws JEDAException
	 */
	public Object addFileToDepot(String groupName, String fileLocation, String name) throws Exception {
		LoginServiceClient loginClient = null;
		LoginUsingUserCredentialResponse res4Login = null;
		AssumeRoleServiceClient aRoleClient = null;
		// BSA用户登陆
		loginClient = new LoginServiceClient(
				messages.getMessage("bsa.userNameRbac"),
				messages.getMessage("bsa.userPassword"),
				messages.getMessage("bsa.authenticationType"), null,
				System.getProperty("maop.root").concat(File.separator) + messages.getMessage("bsa.truststoreFile"),
				messages.getMessage("bsa.truststoreFilePassword"));
		res4Login = loginClient.loginUsingUserCredential();
		// 设置用户角色
		aRoleClient = new AssumeRoleServiceClient(res4Login.getReturnSessionId(), null);
		aRoleClient.assumeRole(messages.getMessage("bsa.roleRbac2"));
		// 取得服务分组名

		CLITunnelServiceClient jobParentGroupName = new CLITunnelServiceClient(
				res4Login.getReturnSessionId(), null);
		ExecuteCommandByParamListResponse jobParentGroupNames = jobParentGroupName.executeCommandByParamList("DepotFile","addFileToDepot",new String[] {"/"+groupName+"",fileLocation,name," "});
		String value = (String) jobParentGroupNames.get_return().getReturnValue();
		return value;
	}

}