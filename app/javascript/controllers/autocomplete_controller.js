import { Controller } from 'stimulus'
import { useClickOutside } from 'stimulus-use'

export default class extends Controller {
    static targets = ['wrapper', 'autocomplete', 'popup'];

    connect() {
      this.minSearchChars = 4;
    }

    async autocomplete() {
      if (this.autocompleteTarget.value.length < this.minSearchChars) {
        this.closeAllPopups();
        return;
      }
      const query = `query=${this.autocompleteTarget.value}`
      const response = await fetch('/players?' + query, { headers: { accept: 'application/json' } });
      if (response.ok) {
        const data = await response.json()
        // Close all other Popups
        this.closeAllPopups();

        // Generate DIV wrapper
        const popup = document.createElement('DIV');
        popup.setAttribute('class', 'autocomplete-popup');
        popup.dataset.target = 'autocomplete.popup';
        this.wrapperTarget.appendChild(popup);
        useClickOutside(this, { element: this.popupTarget });

        // Add search hits within the popup
        data.forEach((player) => {
          let popupItem = document.createElement('DIV');
          popupItem.dataset.action = 'click->autocomplete#selectPopupItem';
          const reg = new RegExp(this.autocompleteTarget.value, 'gi');
          const result = `${player.description}`;
          popupItem.innerHTML = result.replace(reg, function(str) {return '<b>'+str+'</b>'});
          popup.appendChild(popupItem);
        });
      } else {
        this.closeAllPopups();
      }
    }

    clickOutside(event) {
      if (event.target.parentElement == this.popupTarget) {
        this.selectPopupItem(event)
      } else {
        this.closeAllPopups();
      }
    }

    selectPopupItem(e) {
      this.autocompleteTarget.value = e.currentTarget.innerHTML.replace(/<\/?b>/gi,'');
      this.closeAllPopups();
    }

    closeAllPopups(popup) {
      const allPopups = this.popupTargets
      allPopups.forEach((popup) => {
        popup.remove();
      })
    }

    capitalize(string) {
      return string.charAt(0).toUpperCase() + string.slice(1);
    }
}