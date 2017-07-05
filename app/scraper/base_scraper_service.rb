class BaseScraperService
    @scraper_service  = nil
    @data_tables      = nil
    @details          = nil
    @current_session  = nil
    @start_on         = nil
    @cron_exp         = nil
    
    def launch
        run if ScraperSession.exists?(run_state: 'running') == false
    end
    
    private
        def initialize_scraper_service(config)
            @scraper_service = config[:scraper_service]
            @data_tables = config[:data_tables]
            @details = config[:details]
            @start_on = (config[:start_on] == nil ? Time.zone.now : config[:start_on])
            @cron_exp = config[:cron_exp]
            create_new_session
        end
        
        def create_new_session
            if ScraperSession.exists?(run_state: 'initialized')
                @current_session = ScraperSession.find_by(run_state: 'initialized')
            else
                @current_session = ScraperSession.new
            end
            
            @current_session.launched_at = (@start_on != nil ? @start_on : Time.zone.now)
            @current_session.scraper_service = @scraper_service
            @current_session.data_tables = @data_tables
            @current_session.details = @details
            @current_session.run_state = 'initialized'
            @current_session.repeat = !@cron_exp.nil?
            @current_session.performance_data = {}
            @current_session.status = {}

            @current_session.save
        end
        
        def run
            delay(
                queue: 'scraper_service',
                run_at: @start_on,
                job_metadata: { scraper_session_id: @current_session.id }
            ).session_cycle_wrapper
        end
        
        def session_cycle_wrapper
            retry_existing_session
            start_session
            execute_scraper
            end_session
            reschedule_session
        end
        
        def retry_existing_session
            if ScraperSession.exists?(run_state: 'running')
                @current_session = ScraperSession.find_by(run_state: 'running')
                
                @current_session.update(run_state: 'interrupted')
                @current_session.update(performance_data: @current_session.performance_data.merge(
                    { time_end: Time.parse(@current_session.status['text'][0]) }    
                ))
                
                interrupted_session_id = @current_session.id
                interrupted_session_num = @current_session.session_num
                
                session_delayed_job = Delayed::Job.find_by("job_metadata#>>'{scraper_session_id}'='#{@current_session.id}'")
                
                create_new_session
                @current_session.update(details: "retry-interrupted session:#{interrupted_session_id}")
                @current_session.update(launched_at: Time.zone.now)
                
                session_delayed_job.update(job_metadata: session_delayed_job.job_metadata.merge(
                    { scraper_session_id: @current_session.id }
                ))
            end
        end
        def start_session
            @current_session.update(run_state: 'running')
            @current_session.update(performance_data: @current_session.performance_data.merge(
                { time_start: Time.zone.now, time_end: nil }
            ))
            @current_session.update(status: @current_session.status.merge(
                { text: [] }
            ))
            update_status('Starting session')
        end
        def execute_scraper
            main
        end
        def end_session
            @current_session.update(run_state: 'completed')
            @current_session.update(performance_data: @current_session.performance_data.merge(
                { time_end: Time.zone.now }
            ))
            update_status('Completed')
        end
        def reschedule_session
            if (ScraperSession.find(@current_session.id).repeat == true)
                initialize_scraper_service({
                    scraper_service: @scraper_service,
                    data_tables: @data_tables,
                    details: @details,
                    start_on: CronParser.new(@cron_exp, Time.zone).next,
                    cron_exp: @cron_exp
                })
                launch
            end
        end
        
        
        def update_status(status)
            @current_session.update(status: @current_session.status.merge(
                { text: [Time.zone.now, status] }
            ))
        end
end