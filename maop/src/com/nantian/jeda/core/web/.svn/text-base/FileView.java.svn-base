/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.jeda.core.web;

import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.net.URLEncoder;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.web.servlet.view.AbstractView;

/**
 * @author <a href="mailto:daizhenzhong@nantian.com.cn">daizhenzhong</a>
 * 
 */
public class FileView extends AbstractView {

	public static final String PATH = "PATH";

	private static final String CONTENT_TYPE = "application/force-download";

	/**
	 * 
	 */
	public FileView() {
		setContentType(CONTENT_TYPE);
	}

	/**
	 * @param model
	 * @param request
	 * @param response
	 * @throws Exception
	 * @see org.springframework.web.servlet.view.AbstractView#renderMergedOutputModel(java.util.Map,
	 *      javax.servlet.http.HttpServletRequest, javax.servlet.http.HttpServletResponse)
	 */
	@Override
	protected void renderMergedOutputModel(Map<String, Object> model, HttpServletRequest request, HttpServletResponse response) throws Exception {
		File file = new File(model.get(FileView.PATH).toString());
		if (file.exists()) {
			ByteArrayOutputStream baos = createTemporaryOutputStream();
			int length = 0;
			byte[] buffer = new byte[1024];
			DataInputStream in = new DataInputStream(new FileInputStream(file));
			while ((in != null) && ((length = in.read(buffer)) != -1)) {
				baos.write(buffer, 0, length);
			}
			response.setHeader("Content-Disposition", "attachment; filename=\"" + URLEncoder.encode(file.getName(), "UTF-8") + "\"");
			writeToResponse(response, baos);
		}

	}
}
