import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['input', 'label'];

  connect() {
    this.labelVal =  this.labelTarget.innerHTML;
  }

  checkUpload(e) {
    let fileName = '';
    console.log(e.target.value)
    fileName = e.target.value.split('\\').pop();

    if (fileName) {
      this.labelTarget.querySelector('span').innerHTML = fileName;
    } else {
      this.labelTarget.innerHTML = this.labelVal;
    }
  }
}