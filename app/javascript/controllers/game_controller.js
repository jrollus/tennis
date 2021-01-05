import { Controller } from 'stimulus'

export default class extends Controller {
    static targets = ['club', 'category', 'date']
    
    async autofill(event) {
      const type = (event.currentTarget == this.clubTarget) ? 'club' : 'category';
      const query = `club=${this.clubTarget.value}&category=${this.categoryTarget.value}&type=${type}&ctype=single`
      const response = await fetch('/api/v1/tournaments?' + query, { headers: { accept: 'application/json' } });
      if (response.ok) {
        const data = await response.json()
        if (type == 'club') {
          this.categoryTarget.disabled = false;
          this.categoryTarget.innerHTML = data.join()
          this.dateTarget.disabled = true;
          this.dateTarget.innerHTML = ''
        } else if (type == 'category') {
          this.dateTarget.disabled = false;
          this.dateTarget.innerHTML = data.join()
        }
      } else {
        this.dateTarget.disabled = true;
        this.dateTarget.innerHTML = '';
        if (type == 'club') {
          this.categoryTarget.disabled = true;
          this.categoryTarget.innerHTML = '';
        }
      }
    }
}
