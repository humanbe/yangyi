/**
 * 
 */
package com.nantian.jeda.config.web.controller;

import javax.servlet.http.HttpServletRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.orm.hibernate3.HibernateOptimisticLockingFailureException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.ServletRequestDataBinder;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.jeda.Constants;
import com.nantian.jeda.ErrorCode;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.common.model.Property;
import com.nantian.jeda.config.service.PropertyService;

/**
 * @author daizhenzhong
 * 
 */
@Controller
@RequestMapping("/" + Constants.FRAMEWORK_REQUEST_PATH + "/config/property")
public class PropertyController {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(PropertyController.class);

	/** 领域对象名称 */
	private String domain = Property.class.getSimpleName().toLowerCase();

	/** 视图前缀 */
	private String viewPrefix = Constants.FRAMEWORK_REQUEST_PATH + "/config/" + domain + "/" + domain + "_";

	/** 服务 */
	@Autowired
	private PropertyService propertyService;

	@ResponseBody
	@RequestMapping
	public ModelMap get(ModelMap modelMap) throws JEDAException {
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, propertyService.get());
		return modelMap;
	}

	@RequestMapping(value = "/portlet", method = RequestMethod.GET)
	public String portlet(ModelMap modelMap) throws JEDAException {
		return viewPrefix + "portlet";
	}

	@RequestMapping(value = "/edit", method = RequestMethod.GET)
	public String edit(ModelMap modelMap) throws JEDAException {
		return viewPrefix + "edit";
	}

	@ResponseBody
	@RequestMapping(value = "/find", method = RequestMethod.GET)
	public ModelMap find(ModelMap modelMap) throws JEDAException {
		try {
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, propertyService.find());
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}

	@ResponseBody
	@RequestMapping(value = "/edit", method = RequestMethod.POST)
	public ModelMap edit(HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		try {
			Property property = (Property) propertyService.get();
			ServletRequestDataBinder binder = new ServletRequestDataBinder(property);
			binder.bind(request);
			propertyService.update(property);
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (HibernateOptimisticLockingFailureException e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.OPTIMISTIC_LOCKING);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
}
