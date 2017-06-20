class ScraperService
    @scraper_service  = nil
    @launched_from    = nil
    @current_session  = nil

    def launch
        run_session
    end
    
    def current_session
        @current_session
    end
    
    def is_running?
        ScraperSession.exists?(run_state: 'running') ? true : false
    end
    
    private
        def initialize_scraper_service(scraper_service, launched_from = nil)
            @scraper_service = scraper_service
            @launched_from = launched_from
            create_new_session
        end
        
        def create_new_session
            if ScraperSession.exists?(run_state: 'initialized')
                @current_session = ScraperSession.find_by(run_state: 'initialized')
            else
                @current_session = ScraperSession.new({
                    launched_at: Time.zone.now,
                    scraper_service: @scraper_service,
                    launched_from: @launched_from,
                    run_state: 'initialized',
                    performance_data: {},
                    status: {}
                })
                @current_session.save
            end
        end
        
        
        def run_session
            if is_running? == false
                delay(
                    queue: 'scraper_service',
                    job_metadata: { scraper_session_id: @current_session.id }
                ).session_cycle_wrapper
                true
            else
                false
            end
        end
        
        def session_cycle_wrapper
            start_session
            main
            end_session
        end
        
        def start_session
            @current_session.run_state == 'running' ? retry_existing_session : begin_new_session
        end
        def retry_existing_session
            if @current_session.run_state == 'running'
                @current_session.update(run_state: 'interrupted')
                
                session_delayed_job = Delayed::Job.find_by("job_metadata#>>'{scraper_session_id}'='#{@current_session.id}'")
                
                create_new_session
                
                session_delayed_job.update(job_metadata: session_delayed_job.job_metadata.merge(
                    { scraper_session_id: @current_session.id }
                ))
                session_delayed_job.update(attempts: session_delayed_job.attempts.to_i.next)
            end
        end
        def begin_new_session
            @current_session.update(run_state: 'running')
            @current_session.update(performance_data: @current_session.performance_data.merge(
                { time_start: Time.zone.now, time_end: nil }
            ))
            @current_session.update(status: @current_session.status.merge(
                { text: [] }
            ))
        end
        def end_session
            @current_session.update(run_state: 'completed')
            @current_session.update(performance_data: @current_session.performance_data.merge(
                { time_end: Time.zone.now }
            ))
            @current_session = nil
        end
        
        
        def update_status(status)
            @current_session.update(status: @current_session.status.merge(
                { text: [Time.zone.now, status] }
            ))
            puts @current_session.status['text']
        end
end