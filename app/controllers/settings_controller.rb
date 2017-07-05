class SettingsController < ApplicationController
    def set_schedule
        if Setting.all.empty?
            @setting = Setting.new
            @setting.save
        else
            @setting = Setting.first
        end
        
        @setting.update(settings_params)
        rebuild_schedule_queue
        redirect_to pages_scraper_path, notice: "Scraper schedule successfully changed. Next run is on #{CronParser.new(Setting.first.scraper_schedule, Time.zone).next.strftime('%a, %d %b %Y %H:%M:%S')}"
    end
    def clear_schedule
        if !(Setting.all.empty? || Setting.first.scraper_schedule.empty?)
            Setting.first.update(scraper_schedule: '')
            rebuild_schedule_queue
        end
        redirect_to pages_scraper_path, notice: "Auto scraper successfully disabled."
    end
    
    private
        def settings_params
            params.require(:setting).permit!
        end
        def rebuild_schedule_queue
            ScraperSession.where(run_state: 'running').update(repeat: false)
            ScraperSession.where(run_state: 'initialized').destroy_all
            Delayed::Job.where(queue: 'scraper_service').destroy_all
            
            if !(Setting.all.empty? || Setting.first.scraper_schedule.empty?)
                cronline = Setting.first.scraper_schedule
                next_runtime = CronParser.new(cronline, Time.zone).next
                PseEdgeLaunchWrapper.new('auto-scheduled', next_runtime, cronline)
            end
        end
end
