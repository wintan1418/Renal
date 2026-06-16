import { Controller } from "@hotwired/stimulus"

// Requests an AI-drafted reply for a lead and drops it into the textarea.
export default class extends Controller {
  static targets = ["output", "status", "button"]
  static values = { url: String }

  async generate() {
    this.buttonTarget.disabled = true
    this.setStatus("Drafting reply…", "text-base-content/60")

    try {
      const response = await fetch(this.urlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content || ""
        }
      })
      if (!response.ok) throw new Error(`Server returned ${response.status}`)
      const data = await response.json()
      this.outputTarget.value = data.reply || ""
      this.setStatus(`Drafted via ${data.source}. Review before sending.`, "text-success")
    } catch (e) {
      this.setStatus(`Could not draft: ${e.message}`, "text-error")
    } finally {
      this.buttonTarget.disabled = false
    }
  }

  setStatus(message, klass) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message
      this.statusTarget.className = `text-xs ${klass}`
    }
  }
}
