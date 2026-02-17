import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display"]
  static values = { startTime: String }

  connect() {
    this.startTime = new Date(this.startTimeValue)
    this.tick()
    this.interval = setInterval(() => this.tick(), 1000)
  }

  disconnect() {
    if (this.interval) {
      clearInterval(this.interval)
    }
  }

  tick() {
    const now = new Date()
    const elapsedMs = now - this.startTime

    if (elapsedMs < 0) {
      this.displayTarget.textContent = "00:00:00"
      return
    }

    const totalSeconds = Math.floor(elapsedMs / 1000)
    const hours = Math.floor(totalSeconds / 3600)
    const minutes = Math.floor((totalSeconds % 3600) / 60)
    const seconds = totalSeconds % 60

    this.displayTarget.textContent = [
      String(hours).padStart(2, "0"),
      String(minutes).padStart(2, "0"),
      String(seconds).padStart(2, "0"),
    ].join(":")
  }
}
