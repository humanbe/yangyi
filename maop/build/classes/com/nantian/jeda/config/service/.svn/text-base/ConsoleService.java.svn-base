/**
 * 
 */
package com.nantian.jeda.config.service;

import java.io.IOException;
import java.io.PipedReader;
import java.io.PipedWriter;
import java.io.Writer;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Scanner;

import org.apache.log4j.Appender;
import org.apache.log4j.Logger;
import org.apache.log4j.WriterAppender;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

/**
 * @author daizhenzhong
 * 
 */
@Service
public class ConsoleService {

	final org.slf4j.Logger logger = LoggerFactory.getLogger(ConsoleService.class);

	private List<Map<String, Object>> logs = new LinkedList<Map<String, Object>>();

	private PipedReader reader = new PipedReader();
	private Scanner scanner = new Scanner(reader);

	private boolean started = false;

	@Async
	public void startUpdate() {
		Integer row = logs.size();
		while (scanner.hasNext()) {
			Map<String, Object> log = new HashMap<String, Object>();
			log.put("row", row++);
			log.put("info", highlight(scanner.nextLine()));
			logs.add(log);
		}
		int extra = logs.size() - 1000;
		if (extra > 0) {
			for (int i = 0; i < extra; i++) {
				logs.remove(i);
			}
		}
	}

	public List<Map<String, Object>> find(int startRow) {
		if (!started) {
			try {
				Logger logger = Logger.getLogger("com.nantian");
				Appender appender = logger.getAppender("LogApp");
				Writer writer = new PipedWriter(reader);
				((WriterAppender) appender).setWriter(writer);

			} catch (IOException e) {
				e.printStackTrace();
			}
			this.started = true;
			this.startUpdate();
			return logs;
		} else {
			return logs.subList(startRow, logs.size());
		}
	}

	private String highlight(String log) {
		if (log.startsWith("DEBUG")) {
			return log.replace("DEBUG", "<font style=\"color:black;\">DEBUG</font>");
		} else if (log.startsWith("INFO")) {
			return log.replace("INFO", "<font style=\"color:green;\">INFO</font>");
		} else if (log.startsWith("WARN")) {
			return log.replace("WARN", "<font style=\"color:yellow;\">WARN</font>");
		} else if (log.startsWith("ERROR")) {
			return log.replace("ERROR", "<font style=\"color:red;\">ERROR</font>");
		}
		return log;
	}
}
