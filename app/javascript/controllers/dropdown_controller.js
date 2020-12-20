import { Controller } from 'stimulus'
import { useClickOutside } from 'stimulus-use'

export default class extends Controller {
    static targets = ['button', 'popup']

    connect() {
      useClickOutside(this)
    }

    clickOutside(event) {
      this.popupTarget.classList.remove("show");
    }

    toggleVisibility(event) {
      this.popupTarget.classList.toggle("show");
    }
}