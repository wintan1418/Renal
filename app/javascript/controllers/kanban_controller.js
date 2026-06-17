import { Controller } from "@hotwired/stimulus"

// Drag-and-drop for the CRM lead board. Cards are draggable between stage
// columns; dropping PATCHes the lead's move endpoint and updates the counts.
export default class extends Controller {
  static targets = ["column", "count"]

  dragstart(event) {
    this.dragged = event.target.closest("[data-lead-id]")
    if (!this.dragged) return
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", this.dragged.dataset.leadId)
    requestAnimationFrame(() => this.dragged.classList.add("opacity-40"))
  }

  dragend() {
    this.dragged?.classList.remove("opacity-40")
  }

  dragover(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"
    event.currentTarget.classList.add("ring-2", "ring-primary", "ring-inset")
  }

  dragleave(event) {
    event.currentTarget.classList.remove("ring-2", "ring-primary", "ring-inset")
  }

  async drop(event) {
    event.preventDefault()
    const column = event.currentTarget
    column.classList.remove("ring-2", "ring-primary", "ring-inset")
    if (!this.dragged) return

    const stage = column.dataset.stage
    const list = column.querySelector("[data-kanban-list]")
    const placeholder = list.querySelector("[data-kanban-placeholder]")
    if (placeholder) placeholder.remove()

    const fromColumn = this.dragged.closest("[data-kanban-target='column']")
    list.appendChild(this.dragged)

    try {
      await fetch(`${this.dragged.dataset.moveUrl}?stage=${stage}`, {
        method: "PATCH",
        headers: {
          "Accept": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content || ""
        }
      })
      this.updateCount(fromColumn)
      this.updateCount(column)
    } catch (e) {
      // On failure, reload to resync the board with the server.
      window.location.reload()
    }
  }

  updateCount(column) {
    if (!column) return
    const count = column.querySelectorAll("[data-lead-id]").length
    const badge = column.querySelector("[data-kanban-target='count']")
    if (badge) badge.textContent = count
  }
}
