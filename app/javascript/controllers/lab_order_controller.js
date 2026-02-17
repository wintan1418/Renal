import { Controller } from "@hotwired/stimulus"

// Manages lab test selection with category filtering and count display
export default class extends Controller {
  static targets = ["count", "category", "testGroup"]

  connect() {
    this.updateCount()
  }

  filterCategory() {
    const selected = this.categoryTarget.value
    this.testGroupTargets.forEach(group => {
      if (selected === "" || group.dataset.category === selected) {
        group.classList.remove("hidden")
      } else {
        group.classList.add("hidden")
      }
    })
  }

  updateCount() {
    const checked = this.element.querySelectorAll("input[name='lab_test_ids[]']:checked")
    this.countTarget.textContent = `${checked.length} test(s) selected`
  }
}
