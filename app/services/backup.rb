class PseEdgeScrapeService
    def run
        scrape_session = ScrapeSession.new({
            session_datetime: DateTime.current,
            triggered_from: triggered_from.downcase
        })
        
        scrape_session.time_start = Time.current
        
        scrape_market_data(scrape_session)
        scrape_index_data(scrape_session)
        scrape_stock_data(scrape_session)
        
        scrape_session.time_end = Time.current
        scrape_session.ms_elapsed = (scrape_session.time_end.to_f - scrape_session.time_start.to_f) * 1000
        scrape_session.save
    end
    handle_asynchronously :run
    
    private
        def scrape_market_data(scrape_session)
            urls = {
                 market_status: 'http://edge.pse.com.ph/index/form.do'
            }
            
            market_status_page = Nokogiri::HTML(HTTParty.get(urls[:market_status]))
            
            market_snapshot = scrape_session.market_snapshots.new
            
            market_snapshot.last_updated  = market_status_page.css('div#market table.list:eq(1) thead tr th:eq(2)').text
            market_snapshot.total_volume  = market_status_page.css('div#market table.list:eq(1) tbody tr:eq(1) td:eq(2)').text
            market_snapshot.total_trades  = market_status_page.css('div#market table.list:eq(1) tbody tr:eq(2) td:eq(2)').text
            market_snapshot.total_value   = market_status_page.css('div#market table.list:eq(1) tbody tr:eq(3) td:eq(2)').text
            market_snapshot.advances      = market_status_page.css('div#market table.list:eq(1) tbody tr:eq(4) td:eq(2)').text
            market_snapshot.declines      = market_status_page.css('div#market table.list:eq(1) tbody tr:eq(5) td:eq(2)').text
            market_snapshot.unchanged     = market_status_page.css('div#market table.list:eq(1) tbody tr:eq(6) td:eq(2)').text
        
            market_snapshot.save
        end
        
        def scrape_index_data(scrape_session)
            urls = {
                indices: 'http://edge.pse.com.ph/index/form.do'
            }
            
            index_data_page = Nokogiri::HTML(HTTParty.get(urls[:indices]))
            
            index_data_page.css('div#index table.list:eq(1) tbody tr').each do |table_row|
                index_snapshot = scrape_session.index_snapshots.new
                
                index_snapshot.index           = table_row.css('td.label').text
                index_snapshot.value           = table_row.css('td:eq(2)').text
                index_snapshot.change          = table_row.css('td:eq(3)').text
                index_snapshot.percent_change  = table_row.css('td:eq(4)').text
                
                index_snapshot.save
            end
        end
        
        def scrape_stock_data(scrape_session)
            urls = {
                company_list: 'http://edge.pse.com.ph/companyDirectory/search.ax#company',
                stock_data: 'http://edge.pse.com.ph/companyPage/stockData.do',
                stock_company_info: 'http://edge.pse.com.ph/companyInformation/form.do'
            }

            company_list_page = Nokogiri::HTML(HTTParty.get(urls[:company_list]))
            
            for page_num in 1..company_list_page.css('div.paging span').count
                company_list_page = Nokogiri::HTML(
                    HTTParty.post(urls[:company_list], body: {pageNo: page_num})
                ) if page_num != 1
                
                company_list_page.css('table.list tbody tr td:eq(1) a').each do |link|
                    company_id = link.attr('onclick').split(';').shift[0..-2].split('(').pop.split(',').shift[1..-2]
                    
                    stock_data_page = Nokogiri::HTML(HTTParty.get(urls[:stock_data] + "?cmpy_id=#{company_id}"))
                    company_info_page = Nokogiri::HTML(HTTParty.get(urls[:stock_company_info] + "?cmpy_id=#{company_id}"))
                    
                    stock_data_page.css('div#contents form select[name=security_id] option').each do |option|
                        security_id = option.attr('value')
                        stock_data_page = Nokogiri::HTML(HTTParty.get(urls[:stock_data] + "?cmpy_id=#{company_id}&security_id=#{security_id}"))
                        
                        stock_snapshot = scrape_session.stock_snapshots.new
                    
                        stock_snapshot.ticker                      = stock_data_page.css('div#contents form select[name=security_id] option[selected]').text
                        stock_snapshot.last_updated                = stock_data_page.css('div#contents form span:eq(1)').text
                        stock_snapshot.status                      = stock_data_page.css('div#contents table.view:eq(1) tr:eq(1) td:eq(1)').text
                        stock_snapshot.issue_type                  = stock_data_page.css('div#contents table.view:eq(1) tr:eq(2) td:eq(1)').text
                        stock_snapshot.isin                        = stock_data_page.css('div#contents table.view:eq(1) tr:eq(3) td:eq(1)').text
                        stock_snapshot.listing_date                = stock_data_page.css('div#contents table.view:eq(1) tr:eq(4) td:eq(1)').text
                        stock_snapshot.board_lot                   = stock_data_page.css('div#contents table.view:eq(1) tr:eq(5) td:eq(1)').text
                        stock_snapshot.par_value                   = stock_data_page.css('div#contents table.view:eq(1) tr:eq(6) td:eq(1)').text
                        stock_snapshot.market_capitalization       = stock_data_page.css('div#contents table.view:eq(1) tr:eq(1) td:eq(2)').text
                        stock_snapshot.outstanding_shares          = stock_data_page.css('div#contents table.view:eq(1) tr:eq(2) td:eq(2)').text
                        stock_snapshot.listed_shares               = stock_data_page.css('div#contents table.view:eq(1) tr:eq(3) td:eq(2)').text
                        stock_snapshot.issued_shares               = stock_data_page.css('div#contents table.view:eq(1) tr:eq(4) td:eq(2)').text
                        stock_snapshot.free_float_level            = stock_data_page.css('div#contents table.view:eq(1) tr:eq(5) td:eq(2)').text
                        stock_snapshot.foreign_ownership_limit     = stock_data_page.css('div#contents table.view:eq(1) tr:eq(6) td:eq(2)').text
                        
                        stock_snapshot.sector                      = company_info_page.css('div#contents table.view:eq(2) tr:eq(1) td:eq(1)').text
                        stock_snapshot.subsector                   = company_info_page.css('div#contents table.view:eq(2) tr:eq(2) td:eq(1)').text
                        
                        stock_snapshot.last_traded_price           = stock_data_page.css('div#contents table.view:eq(2) tr:eq(1) td:eq(1)').text
                        stock_snapshot.change_and_percent_change   = stock_data_page.css('div#contents table.view:eq(2) tr:eq(2) td:eq(1)').text
                        stock_snapshot.opening_price               = stock_data_page.css('div#contents table.view:eq(2) tr:eq(1) td:eq(2)').text
                        stock_snapshot.day_high                    = stock_data_page.css('div#contents table.view:eq(2) tr:eq(2) td:eq(2)').text
                        stock_snapshot.day_low                     = stock_data_page.css('div#contents table.view:eq(2) tr:eq(3) td:eq(2)').text
                        stock_snapshot.average_price               = stock_data_page.css('div#contents table.view:eq(2) tr:eq(4) td:eq(2)').text
                        stock_snapshot.fifty_two_week_high         = stock_data_page.css('div#contents table.view:eq(2) tr:eq(5) td:eq(1)').text
                        stock_snapshot.fifty_two_week_low          = stock_data_page.css('div#contents table.view:eq(2) tr:eq(5) td:eq(2)').text
                        stock_snapshot.previous_close_and_date     = stock_data_page.css('div#contents table.view:eq(2) tr:eq(1) td:eq(3)').text
                        stock_snapshot.pe_ratio                    = stock_data_page.css('div#contents table.view:eq(2) tr:eq(2) td:eq(3)').text
                        stock_snapshot.sector_pe_ratio             = stock_data_page.css('div#contents table.view:eq(2) tr:eq(3) td:eq(3)').text
                        stock_snapshot.book_value                  = stock_data_page.css('div#contents table.view:eq(2) tr:eq(4) td:eq(3)').text
                        stock_snapshot.pbv_ratio                   = stock_data_page.css('div#contents table.view:eq(2) tr:eq(5) td:eq(3)').text
                    end
                end
            end
        end
end