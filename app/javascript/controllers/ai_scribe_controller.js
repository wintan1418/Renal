import { Controller } from "@hotwired/stimulus"

// Sends rough notes to the AI scribe endpoint and fills the SOAP fields.
export default class extends Controller {
  static targets = ["rough", "subjective", "objective", "assessment", "plan", "status", "button"]
  static values = { url: String, patientName: String, reason: String }

  async generate() {
    const notes = this.roughTarget.value.trim()
    if (!notes) {
      this.setStatus("Type some rough notes first.", "text-warning")
      return
    }

    this.buttonTarget.disabled = true
    this.setStatus("Generating SOAP note…", "text-base-content/60")

    try {
      const response = await fetch(this.urlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content || ""
        },
        body: JSON.stringify({
          notes,
          patient_name: this.patientNameValue,
          reason: this.reasonValue
        })
      })

      if (!response.ok) throw new Error(`Server returned ${response.status}`)
      const data = await response.json()

      this.fill("subjective", data.subjective)
      this.fill("objective", data.objective)
      this.fill("assessment", data.assessment)
      this.fill("plan", data.plan)
      this.setStatus(`Drafted via ${data.source}. Review and edit before saving.`, "text-success")
    } catch (e) {
      this.setStatus(`Could not generate: ${e.message}`, "text-error")
    } finally {
      this.buttonTarget.disabled = false
    }
  }

  fill(name, value) {
    const target = this[`${name}Target`]
    if (target && value) target.value = value
  }

  setStatus(message, klass) {
    if (!this.hasStatusTarget) return
    this.statusTarget.textContent = message
    this.statusTarget.className = `text-xs mt-1 ${klass}`
  }
}
