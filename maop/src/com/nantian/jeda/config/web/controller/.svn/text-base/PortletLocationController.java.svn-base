/**
 * PortletLocationController.java
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.jeda.config.web.controller;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.jeda.Constants;
import com.nantian.jeda.ErrorCode;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.common.model.Portlet;
import com.nantian.jeda.common.model.PortletLocation;
import com.nantian.jeda.common.model.Position;
import com.nantian.jeda.config.service.PortletLocationService;
import com.nantian.jeda.config.service.PortletService;
import com.nantian.jeda.security.service.PositionService;

/**
 * @author <a href="mailto:daizhenzhong@nantian.com.cn">daizhenzhong</a>
 * 
 */
@Controller
@RequestMapping("/" + Constants.FRAMEWORK_REQUEST_PATH + "/portletlocation")
public class PortletLocationController {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(PortletLocationController.class);

	/** 服务 */
	@Autowired
	private PortletLocationService portletLocationService;

	@Autowired
	private PortletService portletService;

	@Autowired
	private PositionService positionService;

	@RequestMapping(value = "/layout", method = RequestMethod.GET)
	public @ResponseBody
	ModelMap layout(@RequestParam("positionId") Long positionId, ModelMap modelMap) throws JEDAException {

		try {
			List<Map<String, Object>> list = portletLocationService.findByPosition(positionId);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, list == null ? new ArrayList<Map<String, Object>>() : list);
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}

	/**
	 * 保存新建数据
	 * 
	 * @param ids
	 * @param column
	 * @param row
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/create", method = RequestMethod.POST)
	@ResponseBody
	public ModelMap create(@RequestParam("ids") String[] ids, @RequestParam("positionId") Long positionId) throws JEDAException {
		ModelMap modelMap = new ModelMap();
		Set<PortletLocation> plSet = new HashSet<PortletLocation>();
		PortletLocation pl = null;
		List<Map<String, Object>> positions = portletLocationService.findByPosition(positionId);
		try {
			for (String id : ids) {
				pl = new PortletLocation();
				pl.setPortlet((Portlet) portletService.get(id));
				A: for (int i = 0; i < 10; i++) {
					for (int j = 0; j < 3; j++) {
						boolean inUse = false;
						for (Map<String, Object> map : positions) {
							if (Integer.valueOf(map.get("row").toString()).intValue() == i
									&& Integer.valueOf(map.get("column").toString()).intValue() == j) {
								inUse = true;
								break;
							}
						}
						for (PortletLocation portletLocation : plSet) {
							if (portletLocation.getRow().intValue() == i && portletLocation.getColumn().intValue() == j) {
								inUse = true;
								break;
							}
						}
						if (inUse) {
							continue;
						} else {
							pl.setColumn(j);
							pl.setRow(i);
							break A;
						}
					}
				}
				pl.setPosition((Position) positionService.get(positionId));
				plSet.add(pl);
			}
			portletLocationService.save(plSet);
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}

	@RequestMapping(value = "/save", method = RequestMethod.POST)
	@ResponseBody
	public ModelMap save(@RequestParam("ids") String[] ids, @RequestParam("positionId") Long positionId, @RequestParam("rows") Integer[] rows,
			@RequestParam("columns") Integer[] columns) throws JEDAException {
		ModelMap modelMap = new ModelMap();
		Set<PortletLocation> plSet = new HashSet<PortletLocation>();
		PortletLocation pl = null;
		try {
			for (int i = 0; i < ids.length; i++) {
				if (ids[i].isEmpty()) {
					continue;
				}
				pl = new PortletLocation();
				pl.setPortlet((Portlet) portletService.get(ids[i]));
				pl.setColumn(columns[i]);
				pl.setRow(rows[i]);
				pl.setPosition((Position) positionService.get(positionId));
				plSet.add(pl);
			}
			portletLocationService.update(plSet, positionId);
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
}
