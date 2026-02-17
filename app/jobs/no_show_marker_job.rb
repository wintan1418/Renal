class NoShowMarkerJob < ApplicationJob
  queue_as :default

  # Mark appointments as no_show if they weren't checked in by end of day
  def perform
    yesterday = Date.yesterday
    no_shows = Appointment.where(scheduled_date: yesterday, status: [:pending, :confirmed])

    Rails.logger.info "[NoShowMarker] Marking #{no_shows.count} appointments as no-show for #{yesterday}"

    no_shows.update_all(status: :no_show)
  end
end
