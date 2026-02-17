import { Controller } from "@hotwired/stimulus"

// Simple date navigation controller for appointment views
export default class extends Controller {
  static targets = ["dateInput", "display"]
  static values = { url: String }

  connect() {
    this.updateDisplay()
  }

  previous() {
    this.changeDate(-1)
  }

  next() {
    this.changeDate(1)
  }

  today() {
    this.dateInputTarget.value = new Date().toISOString().split("T")[0]
    this.navigate()
  }

  changeDate(days) {
    const current = new Date(this.dateInputTarget.value)
    current.setDate(current.getDate() + days)
    this.dateInputTarget.value = current.toISOString().split("T")[0]
    this.navigate()
  }

  navigate() {
    this.updateDisplay()
    const date = this.dateInputTarget.value
    if (this.hasUrlValue) {
      window.location.href = `${this.urlValue}?date=${date}`
    } else {
      // Submit the parent form
      const form = this.element.closest("form")
      if (form) form.requestSubmit()
    }
  }

  updateDisplay() {
    if (this.hasDisplayTarget && this.hasDateInputTarget) {
      const date = new Date(this.dateInputTarget.value + "T00:00:00")
      const options = { weekday: "long", year: "numeric", month: "long", day: "numeric" }
      this.displayTarget.textContent = date.toLocaleDateString("en-NG", options)
    }
  }
}
