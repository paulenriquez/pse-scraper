/* global $, executeScriptFor */

function scope_page_scraper() {
    var label_scraperStatus = $('#label-scraperStatus'),
        table_sessionStatus = $('#table-sessionStatus'),
        table_activeSessionInfo = $('#table-activeSessionInfo');
    var table_scrapeSchedule = $('#table-scrapeSchedule');
    
    function api_getActiveSession() {
        $.ajax('/api/scraper/active_session')
            .done(function(data) {
                if (data.status === 'running') {
                    var session = data.session;
                    label_scraperStatus.html('Scraper is running.');
                    table_sessionStatus.find('tr:eq(0) td:eq(1)').html(`
                        ${session.records_count} record(s) created, ${Number(session.performance_data.time_elapsed).toFixed(2)}s elapsed.<br>
                        ${session.status.text[1]}
                    `);
                    table_activeSessionInfo.find('tr:eq(0) td:eq(1)').html(session.session_num);
                    table_activeSessionInfo.find('tr:eq(1) td:eq(1)').html(session.launched_at);
                    table_activeSessionInfo.find('tr:eq(2) td:eq(1)').html(session.details);
                    table_activeSessionInfo.find('tr:eq(3) td:eq(1)').html(session.scraper_service.name);
                    
                    api_getActiveSession();
                } else {
                    label_scraperStatus.html(
                        `Scraper is not running. ${data.next_scrape != 'no-scheduled-scrape' ? `Next scrape is on ${data.next_scrape}` : ''}
                    `);
                    table_sessionStatus.find('tr:eq(0) td:eq(1)').html('n/a');
                    table_activeSessionInfo.find('tr:eq(0) td:eq(1)').html('n/a');
                    table_activeSessionInfo.find('tr:eq(1) td:eq(1)').html('n/a');
                    table_activeSessionInfo.find('tr:eq(2) td:eq(1)').html('n/a');
                    table_activeSessionInfo.find('tr:eq(3) td:eq(1)').html('n/a');
                    
                    setTimeout(api_getActiveSession, 3000);
                }
            })
            .fail(function(err) {
                label_scraperStatus.html(`<span style="color:red">Failed to retrieve session data from server. Request returned ${err.status} (${err.statusText})</span>`);
                setTimeout(api_getActiveSession, 5000);
            });
    }
    api_getActiveSession();
    
    function api_getSchedule() {
        $.ajax('/api/scraper/schedule')
            .done(function(data) {
                if (data.status === 'has-scheduled-scrapes') {
                    var schedule = data.schedule;
                    var html = '';
                    schedule.forEach(function(item, index) {
                        html += '<tr>';
                        if ((item.status === 'pending' && index === 0)
                           || (item.status === 'pending' && index === 1 && schedule[0].status === 'running')) {
                            html += '<td style="color:orangered;">●</td>';
                        } else if (item.status === 'running' && index === 0) {
                            html += '<td style="color:darkgreen;">●</td>';
                        } else {
                            html += '<td></td>';
                        }
                        html += `
                            <td>${item.launched_at}</td>
                            <td>${item.time_distance_in_words}</td>
                            <td>${item.details}</td>
                        `;
                        html += '</tr>';
                    });
                    table_scrapeSchedule.find('tbody').html(html);
                } else {
                    table_scrapeSchedule.find('tbody').html(`
                        <tr>
                            <td colspan="2">Auto scraper is disabled. Set a scrape schedule to enable.</td>
                        <tr>
                    `);
                }
                setTimeout(api_getSchedule, 3000);
            })
            .fail(function(err) {
                table_scrapeSchedule.find('tbody').html(`<span style="color:red">Failed to retrieve schedule data from server. Request returned ${err.status} (${err.statusText})</span>`);
                setTimeout(api_getSchedule, 5000);
            });
    }
    api_getSchedule();
}

function scope_page_scraper_configure_schedule() {
    var input_scrapeSched = $('#input-scrapeSched'),
        button_submitScrapeSched = $('#button-submitScrapeSched'),
        label_cronEval = $('#label-cronEval');
    
    function api_validateCron() {
        $.ajax(`/api/scraper/validate_cron?exp=${input_scrapeSched.val()}`)
            .done(function(data) {
                if (data === 'valid') {
                    button_submitScrapeSched.attr('disabled', false);
                    label_cronEval.html('<span style="color:darkgreen;">Crontab expression is valid.</span>');
                } else {
                    button_submitScrapeSched.attr('disabled', true);
                    label_cronEval.html(`<span style="color:red;">Invalid crontab expression.</span>`);
                    
                    if ((input_scrapeSched.val().split(' ').length >= 5 && input_scrapeSched.val().split(' ').length <= 6)
                        || input_scrapeSched.val().startsWith('@')) {
                        api_validateCron();
                    }
                }
            })
            .fail(function(err) {
                label_cronEval.html(`<span style="color:red">Failed to retrieve input validation data from server. Request returned ${err.status} (${err.statusText})</span>`)
                api_validateCron();
            });
    }
    
    input_scrapeSched.on('input', function() {
        if ($(this).val() != '') {
            api_validateCron();
        }
    });
}

function scope_page_database_show_session() {
    var table_preview = $('#table-preview');
    var linkCollection_dataPreview = $('.link-dataPreview');
    
    function api_getTablePreview(id, table) {
        table_preview.find('tbody').html('Loading...');
        $.ajax(`/api/database/table_preview?scraper_session_id=${id}&table=${table}`)
            .done(function(data) {
                if (data.status === 'has-preview') {
                    var sessionData = data.session_data
                    var html = '';
                    
                    sessionData.forEach(function(row) {
                        html += '<tr>';
                        row.forEach(function(val) {
                            html += `<td>${val}</td>`;
                        });
                        html += '</tr>';
                    });
                    
                    table_preview.find('tbody').html(html);
                } else {
                    
                }
            })
            .fail(function(err) {
                table_preview.find('tbody').html(`<span style="color:red">Failed to retrieve scraped data from server. Request returned ${err.status} (${err.statusText})</span>`);
            });
    }

    linkCollection_dataPreview.click(function(e) {
        var thisLink = $(this);
        api_getTablePreview(thisLink.data('id'), $(this).data('table'));
        linkCollection_dataPreview.each(function() {
            if ($(this).html() == thisLink.html()) {
                $(this).addClass('selected');
            } else {
                $(this).removeClass('selected');
            }
        });
    });
}

executeScriptFor('.scope-page-scraper', scope_page_scraper);
executeScriptFor('.scope-page-scraper-configure-schedule', scope_page_scraper_configure_schedule);
executeScriptFor('.scope-page-database-show-session', scope_page_database_show_session);
