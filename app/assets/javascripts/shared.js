/* global $ */
$(document).ready(function() {
    var label_systemDatetime = $('#label-systemDatetime');

    setInterval(incrementSystemTime, 1000);
    function incrementSystemTime() {
        var date = new Date(label_systemDatetime.html());
        label_systemDatetime.html(new Date(date.setSeconds(date.getSeconds() + 1)).formatToRubyDateString());
    }
});



Date.prototype.formatToRubyDateString = function() {
    var date = new Date(this);
    var resultDate, resultTime, resultOffset;
    
    // Date
    var month = (date.getMonth() + 1).toString(),
        day = date.getDate().toString(),
        year = date.getFullYear().toString();
   
    if (month.length === 1) month = '0' + month;
    if (day.length === 1) day = '0' + day;
    
    resultDate = [year, month, day].join('-');
    
    
    // Time
    var hours = date.getHours().toString(),
        minutes = date.getMinutes().toString(),
        seconds = date.getSeconds().toString();
    
    if (hours.length === 1) hours = '0' + hours;
    if (minutes.length === 1) minutes = '0' + minutes;
    if (seconds.length === 1) seconds = '0' + seconds;
        
    resultTime = [hours, minutes, seconds].join(':');
    
    
    // Offset
    var offset = (date.getTimezoneOffset() / 60) * -1,
        sign = offset > 0 ? '+' : '-';
    
    offset = Math.abs(offset).toString();
    
    if (offset.length === 1) offset = '0' + offset;
    resultOffset = sign + offset + '00';
    
    return [resultDate, resultTime, resultOffset].join(' ');
}