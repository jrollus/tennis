import { Controller } from 'stimulus'

export default class extends Controller {
    static targets = ['number', 'firstName', 'lastName', 'gender', 'birthdate','dominantHand', 'club', 'ranking']

    async autofill() {
      const response = await fetch('/api/v1/players/' + this.numberTarget.value, { headers: { accept: "application/json" } });
      if (response.ok) {
        const data = await response.json()
        this.firstNameTarget.value = data.first_name
        this.lastNameTarget.value = data.last_name
        this.genderTarget.value = data.gender
        this.dominantHandTarget.value = data.dominant_hand
        this.clubTarget.value = data.id
        this.rankingTarget.value = data.ranking_id
      }
    }
}