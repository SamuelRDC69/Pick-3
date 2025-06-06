# frozen_string_literal: true

module Weeks
  class ChangeService
    prepend ApplicationService

    def initialize(
      finish_service: Weeks::FinishService,
      start_service:  Weeks::StartService,
      coming_service: Weeks::ComingService
    )
      @finish_service = finish_service
      @start_service  = start_service
      @coming_service = coming_service
    end

    def call(week_id:)
      @week = Week.coming.find_by(id: week_id)
      fail!(I18n.t('services.weeks.change.record_is_not_exists')) if @week.nil?
      return if failure?

      update_weeks
    end

    private

    def update_weeks
      update_league_maintenance(true)
      ActiveRecord::Base.transaction do
        @finish_service.call(week: @week.previous)
        @start_service.call(week: @week)
        @coming_service.call(week: @week.next)
      end
      update_league_maintenance(false)
    end

    def update_league_maintenance(maintenance)
      @week.league.update(maintenance: maintenance)
    end
  end
end
