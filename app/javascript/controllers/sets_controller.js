import { Controller } from 'stimulus'

export default class extends Controller {
    static targets = ['set_1_1', 'set_1_2', 'set_2_1', 'set_2_2', 'set_3_1','set_3_2','set_3_1_2','set_3_2_2',
                      'tie_break_1_1', 'tie_break_1_1_2', 'tie_break_1_2', 'tie_break_1_2_2', 'tie_break_2_1',
                      'tie_break_2_1_2', 'tie_break_2_2', 'tie_break_2_2_2', 'tie_break_3_1', 'tie_break_3_1_2',
                      'tie_break_3_2', 'tie_break_3_2_2', 'set_3_number', 'match_points_saved']

    setsHandler() {
      // Third set
      if (this.set_1_1Target.value && this.set_1_2Target.value && this.set_2_1Target.value && this.set_2_2Target.value) {
        if (((this.set_1_1Target.value > this.set_1_2Target.value) && (this.set_2_1Target.value < this.set_2_2Target.value)) ||
           ((this.set_1_1Target.value < this.set_1_2Target.value) && (this.set_2_1Target.value > this.set_2_2Target.value))) {
          this.set_3_1_2Target.classList.add("visibility-on")
          this.set_3_2_2Target.classList.add("visibility-on")
          this.set_3_1Target.disabled = false;
          this.set_3_2Target.disabled = false;
          this.set_3_numberTarget.disabled = false;
        } else {
          this.set_3_1_2Target.classList.remove("visibility-on")
          this.set_3_1Target.value = '';
          this.set_3_2_2Target.classList.remove("visibility-on")
          this.set_3_2Target.value = '';
          this.set_3_1Target.disabled = true;
          this.set_3_2Target.disabled = true;
          this.set_3_numberTarget.disabled = true;
        }
      } else {
        this.set_3_1_2Target.classList.remove("visibility-on")
        this.set_3_1Target.value = '';
        this.set_3_2_2Target.classList.remove("visibility-on")
        this.set_3_2Target.value = '';
      }

      // Tie Break 1
      if (Math.abs(this.set_1_1Target.value - this.set_1_2Target.value) == 1) {
        this.tie_break_1_1_2Target.classList.add("visibility-on")
        this.tie_break_1_2_2Target.classList.add("visibility-on")
        this.tie_break_1_1Target.disabled = false;
        this.tie_break_1_2Target.disabled = false;
      } else {
        this.tie_break_1_1_2Target.classList.remove("visibility-on")
        this.tie_break_1_1Target.hidden = '';
        this.tie_break_1_2_2Target.classList.remove("visibility-on")
        this.tie_break_1_2Target.hidden = '';
        this.tie_break_1_1Target.disabled = true;
        this.tie_break_1_2Target.disabled = true;
      }

      // Tie Break 2 
      if (Math.abs(this.set_2_1Target.value - this.set_2_2Target.value) == 1) {
        this.tie_break_2_1_2Target.classList.add("visibility-on")
        this.tie_break_2_2_2Target.classList.add("visibility-on")
        this.tie_break_2_1Target.disabled = false;
        this.tie_break_2_2Target.disabled = false;
      } else {
        this.tie_break_2_1_2Target.classList.remove("visibility-on")
        this.tie_break_2_1Target.hidden = '';
        this.tie_break_2_2_2Target.classList.remove("visibility-on")
        this.tie_break_2_2Target.hidden = '';
        this.tie_break_2_1Target.disabled = true;
        this.tie_break_2_2Target.disabled = true;
      }

      // Tie Break 3
      if (Math.abs(this.set_3_1Target.value - this.set_3_2Target.value) == 1) {
        this.tie_break_3_1_2Target.classList.add("visibility-on")
        this.tie_break_3_2_2Target.classList.add("visibility-on")
        this.tie_break_3_1Target.disabled = false;
        this.tie_break_3_2Target.disabled = false;
      } else {
        this.tie_break_3_1_2Target.classList.remove("visibility-on")
        this.tie_break_3_1Target.hidden = '';
        this.tie_break_3_2_2Target.classList.remove("visibility-on")
        this.tie_break_3_2Target.hidden = '';
        this.tie_break_3_1Target.disabled = true;
        this.tie_break_3_2Target.disabled = true;
      }

      // Match Points
      if (this.set_1_1Target.value && this.set_1_2Target.value && this.set_2_1Target.value && this.set_2_2Target.value && this.set_3_1Target.value && this.set_3_2Target.value) {
        // Won first set
        if ((this.set_1_1Target.value > this.set_1_2Target.value) && (this.set_2_1Target.value < this.set_2_2Target.value) && (this.set_3_1Target.value < this.set_3_2Target.value)) {
          if ((this.set_2_1Target.value >= 5) || (this.set_3_1Target.value >= 5)) {
            this.match_points_savedTarget.hidden = false;
          } else {
            this.match_points_savedTarget.hidden = true;
            this.match_points_savedTarget.value = 0;
          }
        } 

        // Won second set
        if ((this.set_1_1Target.value < this.set_1_2Target.value) && (this.set_2_1Target.value > this.set_2_2Target.value) && (this.set_3_1Target.value < this.set_3_2Target.value)) {
          if (this.set_3_1Target.value >= 5) {
            this.match_points_savedTarget.hidden = false;
          } else {
            this.match_points_savedTarget.hidden = true;
            this.match_points_savedTarget.value = 0;
          }
        } 

      } else {
        this.match_points_savedTarget.hidden = true;
        this.match_points_savedTarget.value = 0;
      }

    }
}