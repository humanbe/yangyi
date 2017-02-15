package com.nantian.common.exception;
import java.util.ArrayList;
import java.util.List;

import jp.co.nri.kinshasa.aplcommons.model.Mina;

/**
 * 异常类
 * @author dong
 */
public abstract class ApplicationException extends Exception {

    private String errorCode = "20";

    private List<Message> messages = new ArrayList<Message>();

    public ApplicationException() {
        super();
    }

    public ApplicationException(Throwable cause) {
        super(cause);
    }

    public void addMessage(String msgId, String... params) {
        messages.add(new Message(msgId, params));
    }
    
    public void addMessage(Message msg) {
        messages.add(msg);
    }
    
    public String getMessage() {
        if (messages.size() > 0) {
            return messages.get(0).toString();
        } else {
            return null;
        }
    }

    public String[] getMessages() {
        String[] list = new String[messages.size()];

        for (int i = 0; i < list.length; i++) {
            list[i] = messages.get(i).toString();
        }

        return list;
    }
    
    public Message[] getMessageObjects() {
        return messages.toArray(new Message[0]);
    }

    public List<Mina> getMinas() {
        String[] messages = getMessages();
        ArrayList<Mina> minas = new ArrayList<Mina>();

        for (int i = 0; i < messages.length; i++) {
            Mina mina = new Mina();
            mina.setMSG_TEXT_SUMMARY(messages[i]);
            minas.add(mina);
        }

        return minas;
    }
    
    public List<String[]> outputToCSV() {
        String[] messages = getMessages();
        ArrayList<String[]> list = new ArrayList<String[]>();
        
        for (int i = 0; i < messages.length; i++) {
            String[] item = new String[1];
            item[0] = messages[i];
            
            list.add(item);
        }
        
        return list;
    }
    
    public void copyMessagesFrom(ApplicationException e) {
        if (e == null) {
            return;
        }
        
        Message[] msgObjs = e.getMessageObjects();
        for (int i = 0; i < msgObjs.length; i++) {
            addMessage(msgObjs[i]);
        }
    }

    public boolean hasHappened() {
        return messages.size() > 0;
    }

    public String getErrorCode() {
        return errorCode;
    }

    public void setErrorCode(String errorCode) {
        this.errorCode = errorCode;
    }

}
