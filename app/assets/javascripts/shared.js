/* global $ */
$(document).ready(function() {
    var label_systemTime = $('#label-systemTime');

    setInterval(incrementSystemTime, 1000);
    function incrementSystemTime() {
        label_systemTime.html(
            new Date(label_systemTime.html()).incrementByOneSecond()
        );
    }
    
    function api_getSystemTime() {
        $.ajax('/api/system/time')
            .done(function(data) {
                label_systemTime.html(data);
                setTimeout(api_getSystemTime, 15000);
            })
            .fail(function() {
                api_getSystemTime();
            });
    }
    api_getSystemTime();
    
});

function executeScriptFor(selector, f) {
    $(document).ready(function() {
       if ($(selector).length > 0) f(); 
    });
}

Date.prototype.incrementByOneSecond = function() {
    var date = new Date(this);
    date.setSeconds(date.getSeconds() + 1);
    
    var dayOfWk, dayOfMon, monName, year, hour, min, sec;
    
    dayOfWk = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][date.getDay()];
    dayOfMon = date.getDate().toString().length == 1 ? `0${date.getDate()}` : date.getDate();
    monName = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.getMonth()];
    year = date.getFullYear();
    hour = date.getHours().toString().length == 1 ? `0${date.getHours()}` : date.getHours();
    min = date.getMinutes().toString().length == 1 ? `0${date.getMinutes()}` : date.getMinutes();
    sec = date.getSeconds().toString().length == 1 ? `0${date.getSeconds()}` : date.getSeconds();
    
    return `${dayOfWk}, ${dayOfMon} ${monName} ${year} ${hour}:${min}:${sec}`;
}

String.prototype.capitalize = function() {
    return this[0].toUpperCase() + this.slice(1);
}

function validateCronExpression(exp) {
    var parsedExp = exp.split(' ');
    var result = {valid: true, message: null};
    
    var minute = parsedExp[0],
        hour = parsedExp[1],
        dayOfTheMon = parsedExp[2],
        monOfTheYear = parsedExp[3],
        dayOfTheWk = parsedExp[4],
        year = parsedExp[5];
        
    var ALLOWED_VALUES = {
        minute:           ['0-59'],
        hour:             ['0-23'],
        dayOfTheMon:      ['1-31'],
        monOfTheYear:     ['1-12', 'jan-dec'],
        dayOfTheWk:       ['1-7', 'mon-sun'],
        year:             ['1900-3000']
    }
    
    function expandRange(rangeString) {
        var DAYS_OF_WK = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
            MONTHS = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
        
        var min = rangeString.split('-')[0].toLowerCase(),
            max = rangeString.split('-')[1].toLowerCase();
            
        var rangeType;
        
        var result = [];
        
        if (!(isNaN(min) && isNaN(max))) {
            rangeType = 'numeric';
        } else if (DAYS_OF_WK.includes(min) && DAYS_OF_WK.includes(max)) {
            rangeType = 'days_of_wk';
        } else if (MONTHS.includes(min) && MONTHS.includes(max)) {
            rangeType = 'months';
        } else {
            rangeType = 'invalid';
        }
        
        if (rangeType === 'numeric' && (parseInt(min) < parseInt(max))) {
            for (var i = min; i <= max; i++) {
                result.push(parseInt(i));
            }
        } else if (rangeType === 'days_of_wk' && (DAYS_OF_WK.indexOf(min) < DAYS_OF_WK.indexOf(max))) {
            for (var i = DAYS_OF_WK.indexOf(min); i <= DAYS_OF_WK.indexOf(max); i++) {
                result.push(DAYS_OF_WK[i]);
            }
        } else if (rangeType === 'months' && (MONTHS.indexOf(min) < MONTHS.indexOf(max))) {
            for (var i = MONTHS.indexOf(min); i <= MONTHS.indexOf(max); i++) {
                result.push(MONTHS[i]);
            }
        }
        
        return result;
    }
    
    function isValid(field, fieldVal) {
        var result = true;
        if (fieldVal.includes(',')) {
            var parsedSubExp = fieldVal.split(',');
            parsedSubExp.forEach(function(item) {
                
            });
        } else {
            
        }
    }
    
    if (parsedExp.length < 5 || parsedExp.length > 6) result.message = '';
    
    
} 