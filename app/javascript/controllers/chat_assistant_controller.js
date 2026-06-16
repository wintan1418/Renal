import { Controller } from "@hotwired/stimulus"

// Lightweight chat UI for the patient triage assistant. Keeps the running
// history client-side and posts it with each message.
export default class extends Controller {
  static targets = ["messages", "input", "send"]
  static values = { url: String }

  connect() {
    this.history = []
  }

  async submit(event) {
    event.preventDefault()
    const text = this.inputTarget.value.trim()
    if (!text) return

    this.append("patient", text)
    this.history.push({ role: "patient", content: text })
    this.inputTarget.value = ""
    this.sendTarget.disabled = true
    const typing = this.appendTyping()

    try {
      const response = await fetch(this.urlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content || ""
        },
        body: JSON.stringify({ message: text, history: this.history.slice(-10) })
      })
      const data = await response.json()
      typing.remove()
      this.append("assistant", data.reply)
      this.history.push({ role: "assistant", content: data.reply })
    } catch (e) {
      typing.remove()
      this.append("assistant", "Sorry, I couldn't respond just now. Please try again, or call the centre for help.")
    } finally {
      this.sendTarget.disabled = false
      this.inputTarget.focus()
    }
  }

  append(role, text) {
    const wrap = document.createElement("div")
    wrap.className = role === "patient" ? "chat chat-end" : "chat chat-start"
    const bubble = document.createElement("div")
    bubble.className = `chat-bubble ${role === "patient" ? "chat-bubble-primary" : ""} whitespace-pre-line text-sm`
    bubble.textContent = text
    wrap.appendChild(bubble)
    this.messagesTarget.appendChild(wrap)
    this.scroll()
  }

  appendTyping() {
    const wrap = document.createElement("div")
    wrap.className = "chat chat-start"
    wrap.innerHTML = '<div class="chat-bubble text-sm"><span class="loading loading-dots loading-sm"></span></div>'
    this.messagesTarget.appendChild(wrap)
    this.scroll()
    return wrap
  }

  scroll() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }
}
