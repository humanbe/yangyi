package com.nantian.component.log;

import java.text.MessageFormat;

import org.apache.log4j.Level;
import org.apache.log4j.spi.LoggingEvent;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Component;

import com.nantian.common.util.MyApplicationContextUtil;

/*
 * log管理类 */
@Component
public class Logger implements SystemLogger{
	
	private static final String MESSAGE = ".message";
	private static final String LEVEL = ".loglevel";
	private org.apache.log4j.Logger logger;
	private Level level = Level.INFO;
	private String sLevel = null;
	
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	
    private Logger(String clazz) {
	    this.logger = org.apache.log4j.Logger.getLogger(clazz);
	    messages = (MessageSourceAccessor)MyApplicationContextUtil.springContext.getBean("message");
    }

    private Logger() {
        logger = org.apache.log4j.Logger.getRootLogger();
    }

    public static Logger getLogger(Class<?> clazz) {
        return getLogger(clazz.getName());
    }
    
    public static Logger getLogger(String category) {
        return new Logger(category);
    }

    public static Logger getRootLogger() {
        return new Logger();
    }
    
	@Override
	public boolean isEnableFor(Enum<?> paramEnum) {
		// TODO Auto-generated method stub
		return false;
	}
	
    @Override
	public boolean isEnableFor(String msgId) {
		//变量定义
		Boolean rtnFlag = false;
		//资源文件获取message Id定义的输出级别
		sLevel = messages.getMessage(msgId.concat(LEVEL));
		if(sLevel != null){
			//判断日志级别输出日志
			switch(EnumLevel.getLevel(sLevel)){
			case INFO:
				rtnFlag = logger.isEnabledFor(Level.INFO);
				break;
			case DEBUG:
				rtnFlag = logger.isEnabledFor(Level.DEBUG);
				break;
			case WARN:
				rtnFlag = logger.isEnabledFor(Level.WARN);
				break;
			case ERROR:
				rtnFlag = logger.isEnabledFor(Level.ERROR);
				break;
			case FATAL:
				rtnFlag = logger.isEnabledFor(Level.FATAL);
				break;
			}
		}
		return rtnFlag;
	}

	@Override
	public boolean isDebugEnable() {
		return logger.isDebugEnabled();
	}
    
	@Override
	public void log(Enum<?> paramEnum, Object...paramArrayOfObject) {
		// TODO Auto-generated method stub
	}

	@Override
	public void log(Enum<?> paramEnum, Throwable paramThrowable,
			Object...paramArrayOfObject) {
		// TODO Auto-generated method stub
	}

	@Override
	public void log(String pattern, Object...paramArrayOfObject) {
		forcedLog(logger, getLevel(pattern), format(messages.getMessage(pattern.concat(MESSAGE)), paramArrayOfObject));
	}
    
	@Override
    public void log(String pattern, Throwable t, Object... arguments) {
    	forcedLog(logger, getLevel(pattern), format(messages.getMessage(pattern.concat(MESSAGE)), arguments), t);
    }

    public void debug(Object message) {
        if (logger.isDebugEnabled()) {
            forcedLog(logger, Level.DEBUG, message);
        }
    }

    public void debug(Object message, Throwable t) {
        if (logger.isDebugEnabled()) {
            forcedLog(logger, Level.DEBUG, message, t);
        }
    }

    public void debug(String pattern, Object... arguments) {
        if (logger.isDebugEnabled()) {
            forcedLog(logger, Level.DEBUG, format(pattern, arguments));
        }
    }
    public void debug(String pattern, Throwable t, Object... arguments) {
        if (logger.isDebugEnabled()) {
            forcedLog(logger, Level.DEBUG, format(pattern, arguments), t);
        }
    }

    public void assertLog(boolean assertion, String message) {
        if (!assertion) {
            forcedLog(logger, Level.ERROR, message);
        }
    }

    private static void forcedLog(org.apache.log4j.Logger logger, Level level, Object message) {
        logger.callAppenders(new LoggingEvent(FQCN, logger, level, message, null));
    }

    private static void forcedLog(org.apache.log4j.Logger logger, Level level, Object message, Throwable t) {
        logger.callAppenders(new LoggingEvent(FQCN, logger, level, message, t));
    }

    private static String format(String pattern, Object... arguments) {
        return MessageFormat.format(pattern, arguments);
    }

    private static final String FQCN;

    static {
        FQCN = Logger.class.getName();
    }

	/**
	 * 获取资源文件中定义的输出级别
	 * @param msgId
	 */
	public Level getLevel(String msgId){
		//资源文件获取message Id定义的输出级别字符
		sLevel = messages.getMessage(msgId.concat(LEVEL));
		if(sLevel != null){
			//判断日志级别输出日志
			switch(EnumLevel.getLevel(sLevel)){
			case INFO:
				level = Level.INFO;
				break;
			case DEBUG:
				level = Level.DEBUG;
				break;
			case WARN:
				level = Level.WARN;
				break;
			case ERROR:
				level = Level.ERROR;
				break;
			case FATAL:
				level = Level.FATAL;
				break;
			default :
				level = Level.INFO;
				break;
			}
		}
		return level;
	}

	/*
	 *日志输出级别
	 */
	enum EnumLevel {
		INFO,DEBUG,WARN,ERROR,FATAL;
		public static EnumLevel getLevel(String level){    
			return valueOf(level);
		}
	}


}///:~
