/**
 * 重写Ext.form.TextField的字符串长度验证
 * 一个中文算2个字符长度
 *适用于Extjs 3.3
 */
Ext.override(Ext.form.TextField,{
	getErrors: function(value) {
        var errors = Ext.form.TextField.superclass.getErrors.apply(this, arguments);
        
        value = Ext.isDefined(value) ? value : this.processValue(this.getRawValue());
        
        if (Ext.isFunction(this.validator)) {
            var msg = this.validator(value);
            if (msg !== true) {
                errors.push(msg);
            }
        }
        
        if (value.length < 1 || value === this.emptyText) {
            if (this.allowBlank) {
                //if value is blank and allowBlank is true, there cannot be any additional errors
                return errors;
            } else {
                errors.push(this.blankText);
            }
        }
        
        if (!this.allowBlank && (value.length < 1 || value === this.emptyText)) { // if it's blank
            errors.push(this.blankText);
        }
        var valueLength=fucCheckLength(value);
        if (valueLength < this.minLength) {
            errors.push(String.format(this.minLengthText+',实际长度  '+valueLength + '(中文占2位)', this.minLength));
        }
        
        if (valueLength > this.maxLength) {
            errors.push(String.format(this.maxLengthText+',实际长度  '+valueLength + '(中文占2位)', this.maxLength));
        }
        
        if (this.vtype) {
            var vt = Ext.form.VTypes;
            if(!vt[this.vtype](value, this)){
                errors.push(this.vtypeText || vt[this.vtype +'Text']);
            }
        }
        
        if (this.regex && !this.regex.test(value)) {
            errors.push(this.regexText);
        }
        
        return errors;
    }
});

/**计算字符串长度，1个中文=2个字符长度*/
function fucCheckLength(strTemp) {
	var i, sum;
	sum = 0;
	for (i = 0; i < strTemp.length; i++) {
		if ((strTemp.charCodeAt(i) >= 0) && (strTemp.charCodeAt(i) <= 255))
			sum = sum + 1;
		else
			sum = sum + 2;
	}
	return sum;
}