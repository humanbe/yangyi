package com.nantian.component.log;

public interface SystemLogger {
	
	public abstract boolean isEnableFor(Enum<?> paramEnum);

	public abstract boolean isEnableFor(String paramString);

	public abstract boolean isDebugEnable();

	public abstract void log(Enum<?> paramEnum, Object...paramsOfObject);

	public abstract void log(Enum<?> paramEnum, Throwable paramThrowable, Object...paramsOfObject);

	public abstract void log(String paramString, Object...paramArrayOfObject);

	public abstract void log(String paramString, Throwable paramThrowable, Object...paramsOfObject);

	public abstract void debug(String paramString, Object...paramArrayOfObject);

	public abstract void debug(String paramString, Throwable paramThrowable, Object...paramsOfObject);

}
