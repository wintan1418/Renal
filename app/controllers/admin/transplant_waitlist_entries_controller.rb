class Admin::TransplantWaitlistEntriesController < Admin::BaseController
  before_action :set_entry, only: [:show, :edit, :update, :destroy]

  def index
    @entries = TransplantWaitlistEntry.includes(patient: :patient_profile)
                                      .by_priority
    @pagy, @entries = pagy(@entries)
  end

  def show; end

  def new
    @entry = TransplantWaitlistEntry.new(listed_date: Date.current)
  end

  def create
    @entry = TransplantWaitlistEntry.new(entry_params)
    if @entry.save
      redirect_to admin_transplant_waitlist_entries_path, notice: "Patient added to transplant waitlist."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @entry.update(entry_params)
      redirect_to admin_transplant_waitlist_entry_path(@entry), notice: "Waitlist entry updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @entry.destroy
    redirect_to admin_transplant_waitlist_entries_path, notice: "Entry removed."
  end

  private

  def set_entry
    @entry = TransplantWaitlistEntry.find(params[:id])
  end

  def entry_params
    params.require(:transplant_waitlist_entry).permit(:patient_id, :listed_date, :blood_group, :status, :priority, :pra_level, :notes, :transplant_date)
  end
end
