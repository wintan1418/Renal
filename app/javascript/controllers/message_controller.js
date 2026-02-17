import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "messages"]

  connect() {
    this.scrollToBottom()
  }

  scrollToBottom() {
    if (this.hasMessagesTarget) {
      this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
    }
  }

  clearInput() {
    if (this.hasInputTarget) {
      this.inputTarget.value = ""
      this.inputTarget.focus()
    }
  }
}
