import { Controller } from "@hotwired/stimulus"

// Manages SOAP note form - toggling sections and previewing
export default class extends Controller {
  static targets = ["subjective", "objective", "assessment", "plan", "body", "soapFields", "freeTextFields", "noteType"]

  connect() {
    this.toggleFields()
  }

  toggleFields() {
    const noteType = this.noteTypeTarget.value
    if (noteType === "soap") {
      this.soapFieldsTarget.classList.remove("hidden")
      this.freeTextFieldsTarget.classList.add("hidden")
    } else {
      this.soapFieldsTarget.classList.add("hidden")
      this.freeTextFieldsTarget.classList.remove("hidden")
    }
  }
}
