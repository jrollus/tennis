import { Controller } from 'stimulus'
import { useClickOutside } from 'stimulus-use'

export default class extends Controller {
    static targets = ['button', 'popup']

    connect() {
      useClickOutside(this.buttonTarget)
    }

    clickOutside(event) {
      // example to close a modal
      event.preventDefault()
      this.popupTarget.classList.remove("show");
    }

    toggleVisibility(event) {
      event.preventDefault()
      this.popupTarget.classList.toggle("show");
    }
}