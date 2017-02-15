package com.nantian.common.webservice.impl;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;

import com.nantian.common.webservice.IBatchWSService;
import com.nantian.jeda.config.service.SubItemService;

public class BatchWSService implements IBatchWSService{
	
	@Autowired
	private SubItemService subItemService;

	/**
	 * 获取日报批量激活的主机IP
	 * @return IP
	 */
	public String getActiveHostIp() {
		List<Map<String, Object>> list = subItemService.findMapByItem("ACTIVE_BATCH_HOST");
		if(list.size() > 0) {
			return list.get(0).get("value").toString();
		}
		return null;
	}
}
