import { Controller } from "@hotwired/stimulus"

// Calculates BMI in real-time as weight/height are entered
export default class extends Controller {
  static targets = ["weight", "height", "bmi"]

  connect() {
    this.calculateBmi()
  }

  calculateBmi() {
    const weight = parseFloat(this.weightTarget.value)
    const height = parseFloat(this.heightTarget.value)

    if (weight > 0 && height > 0) {
      const heightM = height / 100
      const bmi = (weight / (heightM * heightM)).toFixed(1)
      this.bmiTarget.textContent = `BMI: ${bmi}`
      this.bmiTarget.classList.remove("hidden")
    } else {
      this.bmiTarget.classList.add("hidden")
    }
  }
}
