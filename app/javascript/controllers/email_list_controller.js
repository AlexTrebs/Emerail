import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]

  selectEmail(event) {
    // Remove selected class from all items
    this.itemTargets.forEach(item => {
      item.classList.remove("selected")
    })

    // Add selected class to clicked item
    const emailItem = event.currentTarget.closest(".email-item")
    if (emailItem) {
      emailItem.classList.add("selected")
    }
  }
}
