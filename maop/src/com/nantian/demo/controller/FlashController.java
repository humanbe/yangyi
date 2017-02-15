package com.nantian.demo.controller;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.demo.service.AddressBookInfoService;
import com.nantian.demo.service.AppSystemInfoService;
import com.nantian.demo.service.FlashService;
import com.nantian.demo.service.ServeInfoService;
import com.nantian.demo.service.TranInfoService;
import com.nantian.jeda.Constants;
import com.nantian.jeda.ErrorCode;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.util.RequestUtil;

@Controller
@RequestMapping("/" + Constants.APP_PATH + "/demo")
public class FlashController {

	/** 视图前缀 */
	private final String viewPrefix = "demo/flash/flash_";

	/** 用户数据服务 */
	@Autowired
	private FlashService flashService;

	/** 交易数据 */
	@Autowired
	private TranInfoService traninfoService;

	/** 系统数据 */
	@Autowired
	private AppSystemInfoService appsysteminfoService;

	/** 管理员数据 */
	@Autowired
	private AddressBookInfoService addressbookinfoService;

	/** 服务数据 */
	@Autowired
	private ServeInfoService serveInfoService;

	/**
	 * 返回列表页面
	 * 
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String index() throws JEDAException {

		return viewPrefix + "index";
	}

	/**
	 * 根据分页、排序和其他条件查询记录.
	 * 
	 * @param start
	 * @param limit
	 * @param parent
	 * @param sort
	 * @param dir
	 * @param request
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/index", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap list(@RequestParam(value = "start", required = false)
	Integer start, @RequestParam(value = "limit", required = false)
	Integer limit, @RequestParam(value = "sort", required = false)
	String sort, @RequestParam(value = "dir", required = false)
	String dir, @RequestParam(value = "appsystemid", required = true)
	String appsystemid, @RequestParam(value = "chnlno", required = true)
	String chnlno, @RequestParam(value = "outtrancode", required = false)
	String outtrancode, HttpServletRequest request, ModelMap modelMap)
			throws JEDAException {

		Map<String, Object> params = RequestUtil.getQueryMap(request,
				traninfoService.fields);
		try {
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,
					traninfoService.find(start, limit, sort, dir, params));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY,
					traninfoService.count(params));
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			modelMap.addAttribute("success", Boolean.FALSE);
		}
		return modelMap;
	}

	/**
	 * 返回展示
	 * 
	 * @return 列表页面视图名称
	 * @throws FrameworkException
	 */
	@RequestMapping(value = "/flash", method = RequestMethod.GET)
	public String list() throws JEDAException {
		return viewPrefix + "view";
	}

	/**
	 * 返回展示
	 * 
	 * @return 列表页面视图名称
	 * @throws FrameworkException
	 */
	@RequestMapping(value = "/flashsub", method = RequestMethod.GET)
	public String flashsub() throws JEDAException {
		return viewPrefix + "sub";
	}

	/**
	 * 根据ID查询.
	 * 
	 * @param appSystemID
	 *            系统代码
	 * @param outTrancode
	 *            外部交易码
	 * 
	 * 
	 * 
	 * @param modelMap
	 * @return
	 */

	@SuppressWarnings("unchecked")
	// @RequestMapping(value = "/view/{appSystemId}/{outTrancode}", method =
	// RequestMethod.GET)
	@RequestMapping(value = "/view/{tranid}", method = RequestMethod.GET)
	public @ResponseBody
	ModelMap view(@PathVariable("tranid")
	String tranid, ModelMap modelMap) throws JEDAException {
		try {
			String routTrancode = null;
			String outAppSystemID = null;
			String tranId = null;
			String appSystemId_temp = null;
			String serviceName = null;
			String serviceid = null;
			Integer sequence = 10;
			List<Map> nodesList = new ArrayList<Map>();
			List<Map<String, String>> appSystemsList = new ArrayList<Map<String, String>>();
			List<Map<String, String>> serversList = new ArrayList<Map<String, String>>();
			String reqServiceName = "";
			String appSystemID = "";
			String calledId = "";
			String callId = "";

			// 系统属性

			Map<String, String> appsystemmap = new HashMap<String, String>();
			// 服务信息
			Map<String, String> temp_servemap = new HashMap<String, String>();
			Map<String, String> servemap = new HashMap<String, String>();
			// 管理员属性

			Map<String, String> addressbookinfomap = new HashMap<String, String>();
			List<Map<String, String>> accList = new ArrayList<Map<String, String>>();
			List<Map> secondNodList = new ArrayList<Map>();
			Map<String, String> enterNodMap = new HashMap<String, String>();
			Map<String, String> secondNodMap = new HashMap<String, String>();
			Map<String, String> systemmap = new HashMap<String, String>();
			// 起始节点
			accList = (List<Map<String, String>>) flashService
					.findEnter(tranid);
			if (accList.size() == 0) {
				modelMap.addAttribute("nodes", nodesList);
				return modelMap;
			}
			enterNodMap = accList.get(0);
			enterNodMap.put("reqServiceName", "ENTER");
			enterNodMap.put("nodeType", "1");

			routTrancode = enterNodMap.get("routTrancode");
			// 系统框属性
			systemmap.put("appSystemID", enterNodMap.get("appSystemID"));
			systemmap.put("sequence", String.valueOf(sequence));
			sequence=sequence+10;
			appSystemsList.add(systemmap);

			outAppSystemID = enterNodMap.get("outAppSystemId");
			appSystemID = enterNodMap.get("appSystemID");
			tranId = enterNodMap.get("tranId");
			calledId = enterNodMap.get("calledId");
			callId = calledId;

			// 首节点的outAppSystemId应该等于它自己的appSystemID
			enterNodMap.put("outAppSystemId", enterNodMap.get("appSystemID"));
			nodesList.add(enterNodMap);
			
			reqServiceName = enterNodMap.get("serviceName");
			//第二个节点
			
			secondNodList = (List<Map>) flashService.findSecondNode(callId,
					reqServiceName);
			secondNodMap = secondNodList.get(0);
			calledId = secondNodMap.get("calledId");
			callId = calledId;
			reqServiceName = secondNodMap.get("serviceName");
			nodesList.add(secondNodMap);
			systemmap=new HashMap<String, String>();
			systemmap.put("appSystemID", secondNodMap.get("appSystemID"));
			systemmap.put("sequence", String.valueOf(sequence));
			appSystemsList.add(systemmap);
			
			if (enterNodMap.get("serviceId") != null) {
			}

			addNode(callId, nodesList, appSystemsList, sequence,
					reqServiceName);
			for (Map<String, String> tempmap : appSystemsList) {
				Integer count = 0;
				count = Integer.valueOf(tempmap.get("sequence")) + count;
				// 系统的系统代码

				appSystemId_temp = tempmap.get("appSystemID");
				for (int i = 0; i < nodesList.size(); i++) {
					if (nodesList.get(i).get("outAppSystemId").equals(
							appSystemId_temp)) {
						nodesList.get(i).put("sequence", String.valueOf(count));
						count++;
					}
				}
			}
			// 系统属性取得

			for (int i = 0; i < appSystemsList.size(); i++) {
				appsystemmap = (Map<String, String>) appsysteminfoService
						.findById1(appSystemsList.get(i).get("appSystemID"));
				if (appsystemmap != null && appsystemmap.size() != 0) {
					appSystemsList.get(i).put("appSystemName",
							appsystemmap.get("APPSYSTEMNAME"));
					appSystemsList.get(i).put("isSysFlag",
							appsystemmap.get("ISSYSFLAG"));
					appSystemsList.get(i).put("appSystemType",
							appsystemmap.get("APPSYSTEMTYPE"));
					appSystemsList.get(i).put("appSystemTime",
							appsystemmap.get("APPSYSTEMTIME"));
					appSystemsList.get(i).put("meno", appsystemmap.get("MENO"));
					appSystemsList.get(i).put("appadminidA",
							appsystemmap.get("APPADMINIDA"));
					appSystemsList.get(i).put("sysadminidA",
							appsystemmap.get("SYSADMINIDA"));
					appSystemsList.get(i).put("appadminidB",
							appsystemmap.get("APPADMINIDB"));
					appSystemsList.get(i).put("sysadminidB",
							appsystemmap.get("SYSADMINIDB"));
					appSystemsList.get(i).put("bmanagerid",
							appsystemmap.get("BMANAGERID"));
					appSystemsList.get(i).put("cmanagerid",
							appsystemmap.get("CMANAGERID"));
					appSystemsList.get(i).put("busicontact1id",
							appsystemmap.get("BUSICONTACT1ID"));
					appSystemsList.get(i).put("busicontact2id",
							appsystemmap.get("BUSICONTACT2ID"));
				}
			}
			// 追加节点服务信息取得
			for (Map<String, String> nodeMap : nodesList) {
				if ("5".equals(nodeMap.get("nodeType"))) {
			
					serviceid=nodeMap.get("calledId");
				/*	if (serviceid.indexOf("_")!=-1) {
						serviceid1=serviceid.substring(0,serviceid.lastIndexOf("_"));
						serviceid2=serviceid.substring(,serviceid.length());
					}*/
					temp_servemap = (Map<String, String>) serveInfoService
							.findById(nodeMap.get("outAppSystemId"), serviceid);
					if (null != temp_servemap) {
						servemap = new HashMap<String, String>();
						servemap.put("appSystemID", temp_servemap
								.get("appsystemcd"));
						servemap.put("serviceName", nodeMap.get("serviceName"));
						servemap.put("serveID", serviceid);
						servemap.put("serveCD", temp_servemap.get("servecd"));
						servemap.put("serveName", temp_servemap
								.get("servename"));
						servemap.put("serveNum", temp_servemap.get("servenum"));
						servemap.put("queueNmu", temp_servemap.get("queuenum"));
						servemap.put("busiModule", temp_servemap
								.get("busimodule"));
						servemap.put("higServiceId", temp_servemap
								.get("higserviceid"));
						servemap.put("isLoad", temp_servemap.get("isload"));
						serversList.add(servemap);
					}
				}
			}

			modelMap.addAttribute("nodes", nodesList);
			modelMap.addAttribute("appSystems", appSystemsList);
			modelMap.addAttribute("servers", serversList);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}

		return modelMap;
	}



	@SuppressWarnings("unchecked")
	public Integer addNode(String callId,
			List<Map> nodesList,
			List<Map<String, String>> appSystemsList, Integer sequence,
			String rName) {
		System.out.println("callId:"+callId);
		System.out.println("rName:"+rName);
		System.out.println("sequence:"+String.valueOf(sequence));
		List<Map> accList = new ArrayList<Map>();
		Map<String, String> nodeMap = new HashMap<String, String>();
		Map<String, String> systemmap = new HashMap<String, String>();
		//		String routTrancode = outTrancode;
		String reqServiceName = rName;
		boolean flg = false;
		String appSystemID="";
		String  calledFlag="";
		// 判断是否需要虚拟节点
		String callWay = "";
		String callNum = "";
		String calledId = "";
		String reqServiceName1 = "";
		String outAppSystemId = "";
		String serviceName = "";
		String appSystemId = "";
		// 虚拟用
		Map<String, String> tempNodeMap = null;
		if (flashService.count(callId) != 0) {

			// 并行的交易ID命名顺番
			accList = (List<Map>) flashService.findOhterNode(callId,
					reqServiceName);
			int j = 1;
			String conditionServicename = "";
			boolean flag = false;
			for (Map tempmap : accList) {
				if (accList.size() == 1) {

					nodeMap = accList.get(0);
					// 外部交易码处理一下
					nodeMap.put("outTrancode", nodeMap.get("routTrancode"));
//					nodeMap.put("appSystemID", nodeMap.get("outAppSystemId"));
					nodeMap.put("appSystemID", nodeMap.get("appSystemID"));
					nodesList.add(nodeMap);

				} else {
					System.out.println("查询结果大于一!");
					callWay = String.valueOf(tempmap.get("callWay"));
					callNum = String.valueOf(tempmap.get("callNum"));
					serviceName = String.valueOf(tempmap.get("serviceName"));

					if ("S".equals(callWay)) {
						// 虚拟一个节点
						if (j - 1 == 0) {
							reqServiceName1 = String.valueOf(tempmap.get("reqServiceName"));
						} else {
							reqServiceName1 = String.valueOf(tempmap.get("reqServiceName"))
									+ (j - 1);
						}
						String tempcallId=String.valueOf( tempmap.get("callId"));
						appSystemId=tempcallId.substring(0,tempcallId.indexOf("_"));
						outAppSystemId = String.valueOf(tempmap.get("appSystemID"));
						tempNodeMap = new HashMap<String, String>();
						tempNodeMap.put("reqServiceName", reqServiceName1);
						// 虚拟节点的serviceName=reqServiceName+j
						// 例如serviceName=CCS0002+"1"
						tempNodeMap.put("serviceName", reqServiceName1 + j);
						// 为了页面显示:与XXX系统通讯
						tempNodeMap.put("outTrancode", "与" + outAppSystemId
								+ "通讯");
						tempNodeMap.put("outAppSystemId", appSystemId);
						tempNodeMap.put("appSystemID", appSystemId);
						// 0 虚拟节点
						tempNodeMap.put("nodeType", "0");
						nodesList.add(tempNodeMap);
						// 处理实际节点
						tempmap.put("reqServiceName", reqServiceName1 + j);
						tempmap.put("serviceName", serviceName + callWay
								+ callNum);
						tempmap.put("appSystemID", tempmap
								.get("appSystemID"));

						nodesList.add(tempmap);

					} else {

						if ("T".equals(callWay)) {
							// 标识callWay

							if (!flag) {
								// 虚拟一个菱形节点
								tempNodeMap = new HashMap<String, String>();
								String tempcallId=String.valueOf( tempmap.get("callId"));
								appSystemId=tempcallId.substring(0,tempcallId.indexOf("_"));

//								outAppSystemId = tempmap.get("outAppSystemId");
								outAppSystemId =appSystemId;
								reqServiceName1 = String.valueOf(tempmap.get("reqServiceName"));
								tempNodeMap.put("reqServiceName",
										reqServiceName1);
								tempNodeMap.put("serviceName", reqServiceName1
										+ callWay);
								tempNodeMap.put("outAppSystemId", appSystemId);
								tempNodeMap.put("appSystemID", appSystemId);
								// 2 条件节点
								tempNodeMap.put("nodeType", "2");
								nodesList.add(tempNodeMap);
							}

							// 处理条件实际节点
							// 外部交易码处理一下
							tempmap.put("outTrancode", tempmap
									.get("routTrancode"));
							tempmap.put("reqServiceName", reqServiceName1
									+ callWay);
							tempmap.put("serviceName", serviceName + callWay
									+ callNum);
							tempmap.put("appSystemID", tempmap
									.get("appSystemID"));
							nodesList.add(tempmap);
							conditionServicename = reqServiceName1 + callWay;
							flag = true;
						}

						else {
							// 处理并行实际节点
							tempmap.put("reqServiceName", conditionServicename);
							// 外部交易码处理一下
							tempmap.put("outTrancode", tempmap
									.get("routTrancode"));
							// 并行的serviceName会重复,需要加个变量递增
							tempmap.put("serviceName", serviceName + j);
							tempmap.put("appSystemID", tempmap
									.get("appSystemID"));
							nodesList.add(tempmap);

						}

					}
				}
					calledId = String.valueOf(tempmap.get("calledId"));
					callId=calledId;
				calledFlag=String.valueOf(tempmap.get("calledFlag"));
				if ("2".equals(calledFlag)) {
					tempmap.put("nodeType", "5");
					tempmap.put("outSerivcesId", tempmap
							.get("calledId"));
				}

				// 保存上一次系统代码
				// 调用外部系统代码
				reqServiceName = String.valueOf(tempmap.get("serviceName"));

				appSystemID = String.valueOf(tempmap.get("appSystemID"));
				System.out.println("appSystemID:" + appSystemID);
				for (Map<String, String> tempsystem : appSystemsList) {
					if (appSystemID.equals(tempsystem.get("appSystemID"))) {
						flg = true;
					}
				}
				if (flg == false) {
					systemmap = new HashMap<String, String>();
					systemmap.put("appSystemID", appSystemID);
					sequence = sequence + 10;
					System.out.println("sequence:" + sequence);
					systemmap.put("sequence", String.valueOf(sequence));
					appSystemsList.add(systemmap);
				}
				flg = false;
				j++;
				if ( flashService.count(callId)!=0) {
					sequence = this.addNode(callId, nodesList, appSystemsList, sequence, reqServiceName);
				}

			}
		}
		return sequence;

	}
}
