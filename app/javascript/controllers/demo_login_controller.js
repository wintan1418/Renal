import { Controller } from "@hotwired/stimulus"

// Fills the sign-in form with a demo account's credentials and submits it.
// Used by the role buttons on the sign-in page so a client can explore each
// dashboard with one click.
export default class extends Controller {
  static targets = ["form", "email", "password"]

  fill(event) {
    const { email, password } = event.currentTarget.dataset
    if (this.hasEmailTarget) this.emailTarget.value = email
    if (this.hasPasswordTarget) this.passwordTarget.value = password
    if (this.hasFormTarget) this.formTarget.requestSubmit()
  }
}
