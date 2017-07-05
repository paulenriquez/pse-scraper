include ActionView::Helpers::DateHelper
class ApiController < ApplicationController
    def scraper_get_active_session
        scraper_session = ScraperSession.find_by(run_state: 'running')
    
        if scraper_session != nil
            scraper_session_hash = scraper_session.as_json
            scraper_session_hash['records_count'] = scraper_session.get_records_count
            scraper_session_hash['launched_at'] = scraper_session.launched_at.strftime('%a, %d %b %Y %H:%M:%S')
            scraper_session_hash['performance_data']['time_elapsed'] = scraper_session.get_time_elapsed
            
            render json: { status: 'running', session: scraper_session_hash }
        else
            if Delayed::Job.where(queue: 'scraper_service').empty?
                next_scrape = 'no-scheduled-scrape'
            else
                next_scrape = ScraperSession.find(Delayed::Job.where(queue: 'scraper_service').first.job_metadata['scraper_session_id']).launched_at.strftime('%a, %d %b %Y %H:%M:%S')
            end
            
            render json: { status: 'not-running', next_scrape: next_scrape }
        end
    end
    def scraper_get_validate_cron
        begin
            CronParser.new(params[:exp]).next
        rescue
            render plain: 'invalid'
        else
            render plain: 'valid'
        end
    end
    def scraper_get_schedule
        scraper_sched = []
        
        if ScraperSession.exists?(run_state: 'running')
            scraper_session = ScraperSession.find_by(run_state: 'running')
            scraper_sched.push({
                status: 'running',
                launched_at: scraper_session.launched_at.strftime('%a, %d %b %Y %H:%M:%S'),
                details: scraper_session.details,
                time_distance_in_words: 'Running now'
            })
        end
        
        if !(Setting.first == nil || Setting.first.scraper_schedule.empty?)
            cron_parser = CronParser.new(Setting.first.scraper_schedule, Time.zone)
            current_time = Time.zone.now
            1.upto(scraper_sched.count > 0 ? 4 : 5) do |i|
                next_time = cron_parser.next(current_time)
                scraper_sched.push({
                    status: 'pending',
                    launched_at: next_time.strftime('%a, %d %b %Y %H:%M:%S'),
                    details: 'auto-scheduled',
                    time_distance_in_words: "#{distance_of_time_in_words(Time.zone.now, next_time)} from now"
                })
                current_time = next_time
            end
        end
        
        if (scraper_sched.count > 0)
            render json: { status: 'has-scheduled-scrapes', schedule: scraper_sched }
        else
            render json: { status: 'no-scheduled-scrapes' }
        end
    end
    
    def database_get_table_preview
        if ScraperSession.exists?(params[:scraper_session_id])
            scraper_session = ScraperSession.find(params[:scraper_session_id])
            session_data = scraper_session.get_scraped_data[params[:table]]
            render json: { status: 'has-preview', session_data: session_data }
        else
            render json: { status: 'no-preview' }
        end
    end
    
    def system_get_time
        render plain: Time.zone.now.strftime('%a, %d %b %Y %H:%M:%S')
    end
end
