import { Controller } from "@hotwired/stimulus"

// Manages the multi-step appointment booking wizard
// Steps: 1. Select Department → 2. Select Doctor → 3. Select Date → 4. Select Time → 5. Confirm
export default class extends Controller {
  static targets = [
    "step", "stepIndicator",
    "departmentSelect", "doctorSelect", "dateSelect", "timeSelect",
    "doctorsFrame", "datesFrame", "slotsFrame",
    "confirmDoctor", "confirmService", "confirmDate", "confirmTime",
    "submitBtn", "reasonField",
    "hiddenDoctor", "hiddenService", "hiddenDate", "hiddenTime"
  ]

  static values = {
    currentStep: { type: Number, default: 1 },
    doctorsUrl: String,
    datesUrl: String,
    slotsUrl: String
  }

  connect() {
    this.showStep(this.currentStepValue)
  }

  selectDepartment(event) {
    const departmentId = event.currentTarget.dataset.departmentId
    const departmentName = event.currentTarget.dataset.departmentName

    // Highlight selected
    this.departmentSelectTargets.forEach(el => el.classList.remove("border-primary", "bg-primary/5"))
    event.currentTarget.classList.add("border-primary", "bg-primary/5")

    // Load doctors for this department via Turbo Frame
    const url = `${this.doctorsUrlValue}?department_id=${departmentId}`
    this.doctorsFrameTarget.src = url

    this.goToStep(2)
  }

  selectDoctor(event) {
    const doctorId = event.currentTarget.dataset.doctorId
    const doctorName = event.currentTarget.dataset.doctorName
    const serviceId = event.currentTarget.dataset.serviceId

    // Highlight selected
    document.querySelectorAll("[data-doctor-id]").forEach(el => {
      el.classList.remove("border-primary", "bg-primary/5")
    })
    event.currentTarget.classList.add("border-primary", "bg-primary/5")

    // Set hidden fields
    if (this.hasHiddenDoctorTarget) this.hiddenDoctorTarget.value = doctorId
    if (this.hasHiddenServiceTarget) this.hiddenServiceTarget.value = serviceId

    // Load available dates
    const url = `${this.datesUrlValue}?doctor_id=${doctorId}`
    this.datesFrameTarget.src = url

    // Update confirmation
    if (this.hasConfirmDoctorTarget) this.confirmDoctorTarget.textContent = doctorName

    this.goToStep(3)
  }

  selectDate(event) {
    const date = event.currentTarget.dataset.date
    const dateDisplay = event.currentTarget.dataset.dateDisplay
    const doctorId = this.hasHiddenDoctorTarget ? this.hiddenDoctorTarget.value : ""

    // Highlight selected
    document.querySelectorAll("[data-date]").forEach(el => {
      el.classList.remove("border-primary", "bg-primary/5", "text-primary")
    })
    event.currentTarget.classList.add("border-primary", "bg-primary/5", "text-primary")

    // Set hidden field
    if (this.hasHiddenDateTarget) this.hiddenDateTarget.value = date

    // Load available slots
    const url = `${this.slotsUrlValue}?doctor_id=${doctorId}&date=${date}`
    this.slotsFrameTarget.src = url

    // Update confirmation
    if (this.hasConfirmDateTarget) this.confirmDateTarget.textContent = dateDisplay

    this.goToStep(4)
  }

  selectTime(event) {
    const time = event.currentTarget.dataset.time
    const timeDisplay = event.currentTarget.dataset.timeDisplay

    // Highlight selected
    document.querySelectorAll("[data-time]").forEach(el => {
      el.classList.remove("border-primary", "bg-primary", "text-primary-content")
      el.classList.add("border-base-300")
    })
    event.currentTarget.classList.remove("border-base-300")
    event.currentTarget.classList.add("border-primary", "bg-primary", "text-primary-content")

    // Set hidden field
    if (this.hasHiddenTimeTarget) this.hiddenTimeTarget.value = time

    // Update confirmation
    if (this.hasConfirmTimeTarget) this.confirmTimeTarget.textContent = timeDisplay

    // Enable submit
    if (this.hasSubmitBtnTarget) {
      this.submitBtnTarget.disabled = false
      this.submitBtnTarget.classList.remove("btn-disabled")
    }

    this.goToStep(5)
  }

  goToStep(step) {
    this.currentStepValue = step
    this.showStep(step)
  }

  goBack(event) {
    const step = parseInt(event.currentTarget.dataset.step || this.currentStepValue - 1)
    this.goToStep(step)
  }

  showStep(step) {
    // Show/hide step content
    this.stepTargets.forEach((el, index) => {
      el.classList.toggle("hidden", index + 1 !== step)
    })

    // Update step indicators
    this.stepIndicatorTargets.forEach((el, index) => {
      const stepNum = index + 1
      el.classList.remove("step-primary", "step-neutral")
      if (stepNum <= step) {
        el.classList.add("step-primary")
      }
    })
  }
}
