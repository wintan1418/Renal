import { Controller } from "@hotwired/stimulus"

// Client-side category/specialty filtering for services, doctors and blog grids.
export default class extends Controller {
  static targets = ["item", "chip"]

  filter(e) {
    const value = e.currentTarget.dataset.filter
    this.chipTargets.forEach(c => c.classList.toggle("is-active", c === e.currentTarget))
    this.itemTargets.forEach(item => {
      const cats = (item.dataset.category || "").split(",").map(s => s.trim())
      item.hidden = !(value === "All" || cats.includes(value))
    })
  }
}
