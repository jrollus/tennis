import { Controller } from 'stimulus'

export default class extends Controller {
    static targets = ['modal', 'modalClose'];

    show(event) {
      this.modalTarget.style.display = 'block';
    }

    hide(event) {
      this.modalTarget.style.display = 'none';
    }
}