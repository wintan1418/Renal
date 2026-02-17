import { Controller } from "@hotwired/stimulus"

// Dynamically adds/removes prescription items in the form
export default class extends Controller {
  static targets = ["items", "template"]

  add(event) {
    event.preventDefault()
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
    this.itemsTarget.insertAdjacentHTML("beforeend", content)
  }

  remove(event) {
    event.preventDefault()
    const item = event.target.closest("[data-prescription-item]")
    const destroyField = item.querySelector("input[name*='_destroy']")
    if (destroyField) {
      destroyField.value = "1"
      item.classList.add("hidden")
    } else {
      item.remove()
    }
  }
}
