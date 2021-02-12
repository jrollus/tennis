import { Controller } from 'stimulus'

export default class extends Controller {
    static targets = ['year', 'playerInput', 'container'];

    async selectGames() {
      const query = `year=${this.yearTarget.value}&player=${this.playerInputTarget.value}`;
      const response = await fetch('/games?' + query, { headers: { accept: 'application/json' } });
      if (response.ok) {
        const data = await response.json()
        this.containerTarget.innerHTML = data['html_data'];
      } else {
        this.containerTarget.innerHTML = 'Aucun match trouvé';
      }
    }

    async selectStats() {
      const query = `year=${this.yearTarget.value}&player=${this.playerInputTarget.value}`;
      const response = await fetch('/stats?' + query, { headers: { accept: 'application/json' } });
      if (response.ok) {
        const data = await response.json()
        this.containerTarget.innerHTML = data['html_data'];
      } else {
        this.containerTarget.innerHTML = 'Aucun match trouvé';
      }
    }

}