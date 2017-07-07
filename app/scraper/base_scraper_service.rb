class BaseScraperService
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # DO NOT MODIFY THIS CLASS UNLESS YOU KNOW WHAT YOU ARE DOING!                                #
    # The BaseScraperService is a class that is meant to be inherited by all Scraping Algorithms. #
    # It takes care of session creation, initialization, execution, and rescheduling. It does not #
    # do the actual scraping of data.                                                             #
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
    
    # Class variables
    @scraper_service     = nil # Contains information regarding the scraping algorithm being used
    @data_tables         = nil # Array containing the names of the database tables where the data is being stored
    @details             = nil # Details about the session
    @start_on            = nil # Time when scraper is going to start
    @cron_exp            = nil # Cron expression for session reschedule
    
    @current_session     = nil # Database record of the current session
    @delayed_job_tracker = nil # Tracking code for the Delayed::Job record of the session
    
    # Launches the scraper if there are currently no running sessions by calling the private run() method
    def launch
        run if ScraperSession.exists?(run_state: 'running') == false
    end
    
    private
        # Initializer method for classes which inherit it
        def initialize_scraper_service(config)
            @scraper_service = config[:scraper_service]
            @data_tables = config[:data_tables]
            @details = config[:details]
            @start_on = (config[:start_on] == nil ? Time.zone.now : config[:start_on])
            @cron_exp = config[:cron_exp]
        end
        
        # Creates a new session record in the database
        def create_new_session
            @current_session = ScraperSession.new
            
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
        
        # Runs the scraper using Delayed Job. Delayed Job allows processes to run asynchronously
        # from the main process. It is called by using delay().method_name. The method that contains
        # the session process is session_cycle_wrapper, which is a wrapper function that runs through
        # the session lifecycle.
        #
        # Delayed Job stores its jobs in the Delayed::Job table. To be able to track which Delayed::Job
        # record this session will run on, a random hex generator is used and is assigned to the
        # Delayed::Job record upon creation. This random hex generator is in the generate_delayed_job_tracker()
        # method. It uses the SecureRandom library.
        def run
            @delayed_job_tracker = generate_delayed_job_tracker
            delay(
                queue: 'scraper_service',
                run_at: @start_on,
                job_metadata: { tracker: @delayed_job_tracker }
            ).session_cycle_wrapper
        end
        def generate_delayed_job_tracker
            tracker_code = SecureRandom.hex(3)
            while Delayed::Job.exists?("job_metadata#>>'{tracker}'='#{tracker_code}'")
                tracker_code = SecureRandom.hex(3)
            end
            tracker_code
        end
        
        # Wrapper method that runs through the session lifecycle.
        # A scraper session has five (5) stages:
        #   1. Initialize Session  - Check if an interrupted session needs to be retried.
        #   2. Start Session       - Updates the session record's run_state that it is running.
        #   3. Execute Scraper     - Calls the main() method of the class that inherits the BaseScraperService
        #   4. End Session         - Updates the session record's run_state that it has been completed.
        #   5. Reschedule Session  - Creates a new Delayed::Job if session is recurring.
        def session_cycle_wrapper
            initialize_session
            start_session
            execute_scraper
            end_session
            reschedule_session
        end
        
        # The initialize_session() method is reponsible for creating the session.
        # It first checks if a currently running session is in the database.
        # If there is, it considers it as an interrupted session and updates its
        # record to reflect that. Then a new session is created as to retry the
        # interrupted session.
        #
        # If there is currently no running session, then it just proceeds
        # to create a new session normally.
        def initialize_session
            if ScraperSession.exists?(run_state: 'running')
                @current_session = ScraperSession.find_by(run_state: 'running')
                
                @current_session.update(run_state: 'interrupted')
                @current_session.update(performance_data: @current_session.performance_data.merge(
                    { time_end: Time.parse(@current_session.status['text'][0]) }    
                ))
                
                interrupted_session_num = @current_session.session_num
                
                session_delayed_job = Delayed::Job.find_by("job_metadata#>>'{tracker}'='#{@delayed_job_tracker}'")
                session_delayed_job.update(attempts: session_delayed_job.attempts + 1)
                
                create_new_session
                @current_session.update(details: "retry-interrupted SN-#{interrupted_session_num}")
                @current_session.update(launched_at: Time.zone.now)
            else
                create_new_session
            end
        end
        
        # The start_session() method simply updates the run_state, performance_data['time_start'],
        # and status['text'] of the session.
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
        
        # execute_scraper() will call the main() method of the class which inherits this.
        # The main() method contains the scraping logic.
        def execute_scraper
            main
        end
        
        # Similar to the start_session() method, end_session() updates various attributes
        # of the session to reflect that it has ended.
        def end_session
            @current_session.update(run_state: 'completed')
            @current_session.update(performance_data: @current_session.performance_data.merge(
                { time_end: Time.zone.now }
            ))
            update_status('Completed')
        end
        
        # reschedule_session checks if the @current_session will repeat. If it does,
        # it schedules a new session using the cron expression at @cron_exp.
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
        
        # update_status() is a method which updates the status['text'] attribute
        # of the session. This can be called by the inheriting class as the scraping
        # logic progresses to show the status of the scraper.
        def update_status(status)
            @current_session.update(status: @current_session.status.merge(
                { text: [Time.zone.now, status] }
            ))
        end
end