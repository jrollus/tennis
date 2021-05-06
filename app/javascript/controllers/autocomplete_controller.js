import { Controller } from 'stimulus'
import { useClickOutside } from 'stimulus-use'

export default class extends Controller {
    static targets = ['wrapper', 'autocomplete', 'popup'];

    connect() {
      this.minSearchChars = 4;
      this.timeOut = null;
    }

    autocomplete() {
      if (this.autocompleteTarget.value.length < this.minSearchChars) {
        this.closeAllPopups();
        return;
      }

      if (this.timeOut) {
        clearTimeout(this.timeOut);
      }
      const stimulusController = this;
      this.timeOut = setTimeout(async function() {
        const query = `query=${stimulusController.autocompleteTarget.value}`
        const response = await fetch('/players?' + query, { headers: { accept: 'application/json' } });
        if (response.ok) {
          const data = await response.json()
          // Close all other Popups
          stimulusController.closeAllPopups();

          // Generate DIV wrapper
          const popup = document.createElement('DIV');
          popup.setAttribute('class', 'autocomplete-popup');
          popup.dataset.target = 'autocomplete.popup';
          stimulusController.wrapperTarget.appendChild(popup);
          useClickOutside(stimulusController, { element: stimulusController.popupTarget });

          // Add search hits within the popup
          data.forEach((player) => {
            let popupItem = document.createElement('DIV');
            popupItem.dataset.action = 'click->autocomplete#selectPopupItem';
            const reg = new RegExp(stimulusController.autocompleteTarget.value, 'gi');
            const result = `${player.description}`;
            popupItem.innerHTML = result.replace(reg, function(str) {return '<b>'+str+'</b>'});
            popup.appendChild(popupItem);
          });
        } else {
          stimulusController.closeAllPopups();
        }
      }, 500);
    }

    clickOutside(event) {
      if (this.hasPopupTarget) {
        let e = event
        if (e.target.tagName == 'B') {
          e = e.parentElement;
        }
        if (e) {
          if (e.target.parentElement == this.popupTarget) {
            this.selectPopupItemFromClickOutside(e.target.innerHTML)
            
          } else {
            this.closeAllPopups();
          }
        }
      }
    }

    selectPopupItemFromClickOutside(player) {
      this.autocompleteTarget.value = player.replace(/<\/?b>/gi,'');
      this.closeAllPopups();
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