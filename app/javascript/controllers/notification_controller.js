import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["badge", "dropdown"]

  connect() {
    this.pollInterval = setInterval(() => this.fetchCount(), 60000)
  }

  disconnect() {
    clearInterval(this.pollInterval)
  }

  async fetchCount() {
    try {
      const response = await fetch("/notifications/unread_count.json", {
        headers: { "Accept": "application/json" }
      })
      if (response.ok) {
        const data = await response.json()
        this.updateBadge(data.count)
      }
    } catch (e) {
      // silent fail
    }
  }

  updateBadge(count) {
    if (this.hasBadgeTarget) {
      if (count > 0) {
        this.badgeTarget.textContent = count > 99 ? "99+" : count
        this.badgeTarget.classList.remove("hidden")
      } else {
        this.badgeTarget.classList.add("hidden")
      }
    }
  }
}
