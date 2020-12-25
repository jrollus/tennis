import { Controller } from 'stimulus'

export default class extends Controller {
    static targets = ['set_1_1', 'set_1_2', 'set_2_1', 'set_2_2', 'set_3_1','set_3_2','set_3_1_2','set_3_2_2',
                      'tie_break_1_1', 'tie_break_1_1_2', 'tie_break_1_2', 'tie_break_1_2_2', 'tie_break_2_1',
                      'tie_break_2_1_2', 'tie_break_2_2', 'tie_break_2_2_2', 'tie_break_3_1', 'tie_break_3_1_2',
                      'tie_break_3_2', 'tie_break_3_2_2', 'set_3_number', 'set_3_id', 'tie_break_1_id', 
                      'tie_break_2_id', 'tie_break_3_id', 'set_3_destroy', 'tie_break_1_destroy', 'tie_break_2_destroy',
                      'tie_break_3_destroy', 'match_points_saved']

    connect() {
      this.checkSets()
    }

    // In case of edit check before submitting the form whether some sets/tie breaks have to be deleted
    checkDelete(){
      if (this.hasSet_3_idTarget) {
        if (this.set_3_1Target.value == 0 && this.set_3_2Target.value == 0) {
          this.set_3_idTarget.disabled = false;
          this.set_3_destroyTarget.value = true;
          this.set_3_destroyTarget.disabled = false;
        }
      }

      if (this.hasTie_break_1_idTarget) {
        if (this.tie_break_1_1Target.value == 0 && this.tie_break_1_2Target.value == 0) {
          this.tie_break_1_idTarget.disabled = false;
          this.tie_break_1_destroyTarget.value = true;
          this.tie_break_1_destroyTarget.disabled = false;
        }
      }

      if (this.hasTie_break_2_idTarget) {
        if (this.tie_break_2_1Target.value == 0 && this.tie_break_2_2Target.value == 0) {
          this.tie_break_2_idTarget.disabled = false;
          this.tie_break_2_destroyTarget.value = true;
          this.tie_break_2_destroyTarget.disabled = false;
        }
      }

      if (this.hasTie_break_3_idTarget) {
        if (this.tie_break_3_1Target.value == 0 && this.set_3_2Target.value == 0) {
          this.tie_break_3_idTarget.disabled = false;
          this.tie_break_3_destroyTarget.value = true;
          this.tie_break_3_destroyTarget.disabled = false;
        }
      }
    }

    // In case of edit check sets that have already defined values to enable them and have them visible
    checkSets() {
      if (this.set_3_1Target.value || this.set_3_2Target.value) {
        this.set_3_1_2Target.classList.add("visibility-on")
        this.set_3_2_2Target.classList.add("visibility-on")
        this.set_3_numberTarget.disabled = false;
        this.set_3_1Target.disabled = false;
        this.set_3_2Target.disabled = false;
        if (this.hasSet_3_idTarget) {
          this.set_3_idTarget.disabled = false;
        }
      }

      if (this.tie_break_1_1Target.value || this.tie_break_1_2Target.value) {
        this.tie_break_1_1_2Target.classList.add("visibility-on")
        this.tie_break_1_2_2Target.classList.add("visibility-on")
        this.tie_break_1_1Target.disabled = false;
        this.tie_break_1_2Target.disabled = false;
        if (this.hasTie_break_1_idTarget) {
          this.tie_break_1_idTarget.disabled = false;
        }
      }

      if (this.tie_break_2_1Target.value || this.tie_break_2_2Target.value) {
        this.tie_break_2_1_2Target.classList.add("visibility-on")
        this.tie_break_2_2_2Target.classList.add("visibility-on")
        this.tie_break_2_1Target.disabled = false;
        this.tie_break_2_2Target.disabled = false;
        if (this.hasTie_break_2_idTarget) {
          this.tie_break_2_idTarget.disabled = false;
        }
      }

      if (this.tie_break_3_1Target.value || this.tie_break_3_2Target.value) {
        this.tie_break_3_1_2Target.classList.add("visibility-on")
        this.tie_break_3_2_2Target.classList.add("visibility-on")
        this.tie_break_3_1Target.disabled = false;
        this.tie_break_3_2Target.disabled = false;
        if (this.hasTie_break_3_idTarget) {
          this.tie_break_3_idTarget.disabled = false;
        }
      }

    }
    setsHandler() {
      // Third set
      if (this.set_1_1Target.value && this.set_1_2Target.value && this.set_2_1Target.value && this.set_2_2Target.value) {
        if (((this.set_1_1Target.value > this.set_1_2Target.value) && (this.set_2_1Target.value < this.set_2_2Target.value)) ||
           ((this.set_1_1Target.value < this.set_1_2Target.value) && (this.set_2_1Target.value > this.set_2_2Target.value))) {
          this.set_3_1_2Target.classList.add("visibility-on")
          this.set_3_2_2Target.classList.add("visibility-on")
          this.set_3_numberTarget.disabled = false;
          this.set_3_1Target.disabled = false;
          this.set_3_2Target.disabled = false;
          if (this.hasSet_3_idTarget) {
            this.set_3_idTarget.disabled = false;
          }
        } else {
          this.set_3_1_2Target.classList.remove("visibility-on")
          this.set_3_1Target.value = '';
          this.set_3_2_2Target.classList.remove("visibility-on")
          this.set_3_2Target.value = '';
          this.set_3_1Target.disabled = true;
          this.set_3_2Target.disabled = true;
          this.set_3_numberTarget.disabled = true;
          if (this.hasSet_3_idTarget) {
            this.set_3_idTarget.disabled = true;
          }
        }
      } else {
        this.set_3_1_2Target.classList.remove("visibility-on")
        this.set_3_1Target.value = '';
        this.set_3_2_2Target.classList.remove("visibility-on")
        this.set_3_2Target.value = '';
        this.set_3_1Target.disabled = true;
        this.set_3_2Target.disabled = true;
        this.set_3_numberTarget.disabled = true;
        if (this.hasSet_3_idTarget) {
          this.set_3_idTarget.disabled = true;
        }
      }

      // Tie Break 1
      if (Math.abs(this.set_1_1Target.value - this.set_1_2Target.value) == 1) {
        this.tie_break_1_1_2Target.classList.add("visibility-on")
        this.tie_break_1_2_2Target.classList.add("visibility-on")
        this.tie_break_1_1Target.disabled = false;
        this.tie_break_1_2Target.disabled = false;
        if (this.hasTie_break_1_idTarget) {
          this.tie_break_1_idTarget.disabled = false;
        }
      } else {
        this.tie_break_1_1_2Target.classList.remove("visibility-on")
        this.tie_break_1_1Target.value = '';
        this.tie_break_1_2_2Target.classList.remove("visibility-on")
        this.tie_break_1_2Target.value = '';
        this.tie_break_1_1Target.disabled = true;
        this.tie_break_1_2Target.disabled = true;
        if (this.hasTie_break_1_idTarget) {
          this.tie_break_1_idTarget.disabled = true;
        }
      }

      // Tie Break 2 
      if (Math.abs(this.set_2_1Target.value - this.set_2_2Target.value) == 1) {
        this.tie_break_2_1_2Target.classList.add("visibility-on")
        this.tie_break_2_2_2Target.classList.add("visibility-on")
        this.tie_break_2_1Target.disabled = false;
        this.tie_break_2_2Target.disabled = false;
        if (this.hasTie_break_2_idTarget) {
        this.tie_break_2_idTarget.disabled = false;
        }
      } else {
        this.tie_break_2_1_2Target.classList.remove("visibility-on")
        this.tie_break_2_1Target.value = '';
        this.tie_break_2_2_2Target.classList.remove("visibility-on")
        this.tie_break_2_2Target.value = '';
        this.tie_break_2_1Target.disabled = true;
        this.tie_break_2_2Target.disabled = true;
        if (this.hasTie_break_2_idTarget) {
          this.tie_break_2_idTarget.disabled = true;
        }
      }

      // Tie Break 3
      if (Math.abs(this.set_3_1Target.value - this.set_3_2Target.value) == 1) {
        this.tie_break_3_1_2Target.classList.add("visibility-on")
        this.tie_break_3_2_2Target.classList.add("visibility-on")
        this.tie_break_3_1Target.disabled = false;
        this.tie_break_3_2Target.disabled = false;
        if (this.hasTie_break_3_idTarget) {
          this.tie_break_3_idTarget.disabled = false;
        }
      } else {
        this.tie_break_3_1_2Target.classList.remove("visibility-on")
        this.tie_break_3_1Target.value = '';
        this.tie_break_3_2_2Target.classList.remove("visibility-on")
        this.tie_break_3_2Target.value = '';
        this.tie_break_3_1Target.disabled = true;
        this.tie_break_3_2Target.disabled = true;
        if (this.hasTie_break_3_idTarget) {
          this.tie_break_3_idTarget.disabled = true;
        }
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