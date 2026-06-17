import { Controller } from "@hotwired/stimulus"

// Posts an analytics question and renders the AI answer.
export default class extends Controller {
  static targets = ["input", "answer", "button", "status"]
  static values = { url: String }

  ask(event) {
    event?.preventDefault()
    const question = this.inputTarget.value.trim()
    if (!question) return
    this.run(question)
  }

  suggest(event) {
    this.inputTarget.value = event.currentTarget.textContent.trim()
    this.run(this.inputTarget.value)
  }

  async run(question) {
    this.buttonTarget.disabled = true
    this.statusTarget.textContent = "Analysing…"
    this.answerTarget.classList.add("opacity-40")

    try {
      const res = await fetch(this.urlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content || ""
        },
        body: JSON.stringify({ question })
      })
      const data = await res.json()
      this.answerTarget.textContent = data.answer || "No answer."
      this.statusTarget.textContent = `via ${data.source}`
    } catch (e) {
      this.answerTarget.textContent = "Sorry, I couldn't answer that just now."
      this.statusTarget.textContent = ""
    } finally {
      this.buttonTarget.disabled = false
      this.answerTarget.classList.remove("opacity-40")
    }
  }
}
