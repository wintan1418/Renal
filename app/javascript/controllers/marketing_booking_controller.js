import { Controller } from "@hotwired/stimulus"

// Drives the public 3-step "Book Appointment" wizard + mobile nav toggle.
export default class extends Controller {
  static targets = [
    "modal", "mobileNav", "panel", "progressBar", "stepLabel", "backBtn",
    "serviceField", "doctorField", "dateField", "timeField",
    "nameField", "phoneField", "emailField", "reasonField", "notesField",
    "continue1", "continue2", "submitBtn",
    "sumService", "sumDoctor", "sumWhen", "confName", "confPhone"
  ]

  connect() { this.step = 1 }

  // ---- nav ----
  toggleNav() { this.mobileNavTarget.hidden = !this.mobileNavTarget.hidden }

  // ---- modal open/close ----
  open(e) {
    if (e) e.preventDefault()
    this.step = 1
    this.modalTarget.hidden = false
    document.body.style.overflow = "hidden"
    this.render()
  }
  close(e) {
    if (e) e.preventDefault()
    this.modalTarget.hidden = true
    document.body.style.overflow = ""
  }
  stop(e) { e.stopPropagation() }

  // ---- selections ----
  selectService(e) {
    const el = e.currentTarget
    this.serviceFieldTarget.value = el.dataset.name
    this._mark(el, ".mk-opt-card")
    this.validate()
  }
  selectDoctor(e) {
    const el = e.currentTarget
    this.doctorFieldTarget.value = el.dataset.name
    this._mark(el, ".mk-pill")
    this.validate()
  }
  selectTime(e) {
    const el = e.currentTarget
    this.timeFieldTarget.value = el.dataset.value
    this._mark(el, ".mk-time")
    this.validate()
  }

  _mark(el, selector) {
    this.element.querySelectorAll(selector).forEach(n => n.classList.remove("is-sel"))
    el.classList.add("is-sel")
  }

  // ---- step flow ----
  next() { if (this.step < 4) { this.step += 1; this.render() } }
  prev() { if (this.step > 1) { this.step -= 1; this.render() } }

  submit() {
    // Fill confirmation summary, then advance to the success panel.
    this.sumServiceTarget.textContent = this.serviceFieldTarget.value || "—"
    this.sumDoctorTarget.textContent = this.doctorFieldTarget.value || "No preference"
    const when = (this.dateFieldTarget.value || "Date TBD") +
      (this.timeFieldTarget.value ? " · " + this.timeFieldTarget.value : "")
    this.sumWhenTarget.textContent = when
    this.confNameTarget.textContent = this.nameFieldTarget.value || "there"
    this.confPhoneTarget.textContent = this.phoneFieldTarget.value || "your number"
    this.step = 4
    this.render()
  }

  validate() {
    if (this.hasContinue1Target)
      this.continue1Target.disabled = !this.serviceFieldTarget.value
    if (this.hasContinue2Target)
      this.continue2Target.disabled = !(this.dateFieldTarget.value && this.timeFieldTarget.value)
    if (this.hasSubmitBtnTarget)
      this.submitBtnTarget.disabled = !(this.nameFieldTarget.value && this.phoneFieldTarget.value)
  }

  render() {
    this.panelTargets.forEach(p => { p.hidden = (parseInt(p.dataset.step, 10) !== this.step) })
    this.element.querySelectorAll("[data-step-btn]").forEach(b => {
      b.hidden = (parseInt(b.dataset.stepBtn, 10) !== this.step)
    })
    const labels = {
      1: "Step 1 of 3 · Select a service",
      2: "Step 2 of 3 · Doctor & time",
      3: "Step 3 of 3 · Your details",
      4: "Confirmed"
    }
    if (this.hasStepLabelTarget) this.stepLabelTarget.textContent = labels[this.step]
    if (this.hasProgressBarTarget)
      this.progressBarTarget.style.width = (this.step >= 4 ? 100 : (this.step / 3) * 100) + "%"
    if (this.hasBackBtnTarget)
      this.backBtnTarget.style.visibility = (this.step > 1 && this.step < 4) ? "visible" : "hidden"
    this.validate()
  }
}
