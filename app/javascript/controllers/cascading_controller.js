import { Controller } from 'stimulus'

export default class extends Controller {
    static targets = ['club', 'category', 'date', 'interclub', 'tournament', 'division', 'tournamentCB', 'interclubCB'];
    
    toggle(event) {
      console.log(event.currentTarget)
      if (event.currentTarget.dataset.gameType == 'interclub') {
        this.interclubSelected();
      } else if (event.currentTarget.dataset.gameType == 'tournament') {
        this.tournamentSelected();
      }
    }

    interclubSelected() {
      this.interclubTarget.classList.remove('visibility-off');
      this.tournamentTarget.classList.add('visibility-off');
      this.dateTarget.disabled = true;
      this.divisionTarget.disabled = false;
    }

    tournamentSelected() {
      this.interclubTarget.classList.add('visibility-off');
      this.tournamentTarget.classList.remove('visibility-off');
      this.divisionTarget.disabled = true;
      this.dateTarget.disabled = false;
    }

    async autofill(event) {
      let type = (event.currentTarget == this.clubTarget) ? 'club' : 'category';
      let query = `club=${this.clubTarget.value}&category=${this.categoryTarget.value}&type=${type}&ctype=single`;
      let response = await fetch('/tournaments?' + query, { headers: { accept: 'application/json' } });
      if (response.ok) {
        let data = await response.json()
        if (type == 'club') {
          this.categoryTarget.disabled = false;
          this.categoryTarget.innerHTML = data.join();
          this.dateTarget.disabled = true;
          this.dateTarget.innerHTML = '';
          if (data.length == 2) {
            type = 'category';
            query = `club=${this.clubTarget.value}&category=${this.categoryTarget.value}&type=${type}&ctype=single`;
            response = await fetch('/tournaments?' + query, { headers: { accept: 'application/json' } });
            if (response.ok) {
              let data = await response.json();
              this.dateTarget.disabled = false;
              this.dateTarget.innerHTML = data.join();
            }
          }
        } else if (type == 'category') {
          this.dateTarget.disabled = false;
          this.dateTarget.innerHTML = data.join();
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
