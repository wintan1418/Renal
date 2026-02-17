import { Controller } from "@hotwired/stimulus"

// Auto-refreshes the queue display at a configurable interval
export default class extends Controller {
  static values = {
    interval: { type: Number, default: 30000 }, // 30 seconds default
    url: String
  }

  connect() {
    if (this.hasUrlValue) {
      this.startPolling()
    }
  }

  disconnect() {
    this.stopPolling()
  }

  startPolling() {
    this.timer = setInterval(() => {
      this.refresh()
    }, this.intervalValue)
  }

  stopPolling() {
    if (this.timer) {
      clearInterval(this.timer)
      this.timer = null
    }
  }

  refresh() {
    // Use Turbo to refresh the frame
    const frame = this.element.querySelector("turbo-frame")
    if (frame) {
      frame.reload()
    } else {
      // Fallback: reload via fetch
      fetch(this.urlValue, {
        headers: {
          "Accept": "text/vnd.turbo-stream.html",
          "X-Requested-With": "XMLHttpRequest"
        }
      })
    }
  }
}
