import { Controller } from 'stimulus'

export default class extends Controller {
    static targets = ['status', 'set_1_1', 'set_1_2', 'set_2_1', 'set_2_2', 'set_3_1','set_3_2','set_3_1_2','set_3_2_2',
                      'tie_break_1_1', 'tie_break_1_1_2', 'tie_break_1_2', 'tie_break_1_2_2', 'tie_break_2_1',
                      'tie_break_2_1_2', 'tie_break_2_2', 'tie_break_2_2_2', 'tie_break_3_1', 'tie_break_3_1_2',
                      'tie_break_3_2', 'tie_break_3_2_2', 'set_1_number', 'set_1_id', 'set_2_number', 'set_2_id',
                      'set_3_number', 'set_3_id', 'tie_break_1_id', 'tie_break_2_id', 'tie_break_3_id', 'set_3_destroy',
                      'tie_break_1_destroy', 'tie_break_2_destroy', 'tie_break_3_destroy', 'match_points_saved', 'label']

    connect() {
      debugger;
      // Initialize Data
      this.set1 = [this.set_1_1Target, this.set_1_2Target, this.set_1_numberTarget, this.hasSet_1_idTarget,  (this.hasSet_1_idTarget ? this.set_1_idTarget : null)];
      this.set2 = [this.set_2_1Target, this.set_2_2Target, this.set_2_numberTarget, this.hasSet_2_idTarget,  (this.hasSet_2_idTarget ? this.set_2_idTarget : null)];
      this.set3 = [this.set_3_1Target, this.set_3_2Target, this.set_3_numberTarget, this.hasSet_3_idTarget,  (this.hasSet_3_idTarget ? this.set_3_idTarget : null),
                   this.set_3_1_2Target, this.set_3_2_2Target, (this.hasSet_3_idTarget ? this.set_3_destroyTarget : null)];
      this.tieBreak1 = [this.tie_break_1_1Target, this.tie_break_1_2Target, this.hasTie_break_1_idTarget, (this.hasTie_break_1_idTarget ? this.tie_break_1_idTarget : null),
                        this.tie_break_1_1_2Target, this.tie_break_1_2_2Target, (this.hasTie_break_1_idTarget ? this.tie_break_1_destroyTarget : null)];
      this.tieBreak2 = [this.tie_break_2_1Target, this.tie_break_2_2Target, this.hasTie_break_2_idTarget, (this.hasTie_break_2_idTarget ? this.tie_break_2_idTarget : null), 
                        this.tie_break_2_1_2Target, this.tie_break_2_2_2Target, (this.hasTie_break_2_idTarget ? this.tie_break_2_destroyTarget : null)];
      this.tieBreak3 = [this.tie_break_3_1Target, this.tie_break_3_2Target, this.hasTie_break_3_idTarget, (this.hasTie_break_3_idTarget ? this.tie_break_3_idTarget : null), 
                        this.tie_break_3_1_2Target, this.tie_break_3_2_2Target, (this.hasTie_break_3_idTarget ? this.tie_break_3_destroyTarget : null)];

      // Check whether there is some data in the form already to enable third set and/or tie breaks if necessary
      this.checkSets()
    }

    // In case of edit check sets that have already defined values to enable them and have them visible
    checkSets() {
      if (this.set_3_1Target.value || this.set_3_2Target.value ||
         ((this.set_1_1Target.value > this.set_1_2Target.value) && (this.set_2_1Target.value < this.set_2_2Target.value)) ||
         ((this.set_1_1Target.value < this.set_1_2Target.value) && (this.set_2_1Target.value > this.set_2_2Target.value))) {
        this.setsOnOff([this.set3], true);
      }

      if (this.tie_break_1_1Target.value || this.tie_break_1_2Target.value ||
         (this.set_1_1Target.value == '7' && this.set_1_2Target.value == '6') ||
         (this.set_1_1Target.value == '6' && this.set_1_2Target.value == '7')) {
        this.tieBreaksOnOff([this.tieBreak1], true);
      }

      if (this.tie_break_2_1Target.value || this.tie_break_2_2Target.value ||
         (this.set_2_1Target.value == '7' && this.set_2_2Target.value == '6') ||
         (this.set_2_1Target.value == '6' && this.set_2_2Target.value == '7')) {
       this.tieBreaksOnOff([this.tieBreak2], true);
      }

      if (this.tie_break_3_1Target.value || this.tie_break_3_2Target.value || 
         (this.set_3_1Target.value == '7' && this.set_3_2Target.value == '6') ||
         (this.set_3_1Target.value == '6' && this.set_3_2Target.value == '7')) {
       this.tieBreaksOnOff([this.tieBreak3], true);
       this.labelTarget.classList.remove('visibility-off');
      }
    }

    submitForm() {
      const allScores = [this.set1, this.set2, this.set3, this.tieBreak1, this.tieBreak2, this.tieBreak3]
      allScores.forEach((score, i) => {
        if (score[0].value == '' || score[1].value == '') {
          score[0].disabled = true;
          score[1].disabled = true;
          if (i <= 2) {
            score[2].disabled = true;
          }
        }
      });
    }

    setsOnOff(structuredSets, on) {
      structuredSets.forEach((gameSet, i)  => {
        if (gameSet.length == 8) {
          if (on) {
            gameSet[5].classList.add('visibility-on');
            gameSet[6].classList.add('visibility-on');
            this.labelTarget.classList.remove('visibility-off');
          } else {
            gameSet[5].classList.remove('visibility-on');
            gameSet[6].classList.remove('visibility-on');
            this.labelTarget.classList.add('visibility-off');
          }

          if (gameSet[3]) {
            gameSet[7].disabled = (on ? true : false);
            gameSet[7].value = (on ? false : true);
          }
        }
        gameSet[0].disabled = (on ? false : true);
        gameSet[1].disabled = (on ? false : true);

        if (on == false) {
          gameSet[0].value = '';
          gameSet[1].value = '';
        }

        gameSet[2].disabled = (on ? false : true);
      });
    }

    tieBreaksOnOff(structuredTieBreaks, on) {
      structuredTieBreaks.forEach((TieBreak, i) => {
        if (on) {
          TieBreak[4].classList.add('visibility-on');
          TieBreak[5].classList.add('visibility-on');
        } else {
          TieBreak[4].classList.remove('visibility-on');
          TieBreak[5].classList.remove('visibility-on');
        }
        
        TieBreak[0].disabled = (on ? false : true);
        TieBreak[1].disabled = (on ? false : true);

        if (on == false) {
          TieBreak[0].value = '';
          TieBreak[1].value = '';
        }
        
        if (TieBreak[2]) {
          TieBreak[6].disabled = (on ? true : false);
          TieBreak[6].value = (on ? false : true);
        }
      });
    }

    setsHandler() {
      // Status
      if (this.statusTarget.value == 'WO') {
        // Sets
        this.setsOnOff([this.set3], false);
        [this.set_1_1Target, this.set_1_2Target, this.set_2_1Target, this.set_2_2Target].forEach((setScore, i)  => {
          setScore.value = '0';
          setScore.readOnly = true;
        });

        // Tie Breaks
        this.tieBreaksOnOff([this.tieBreak1, this.tieBreak2, this.tieBreak3], false);
      } else {
        this.setsOnOff([this.set1, this.set2], true);
        [this.set_1_1Target, this.set_1_2Target, this.set_2_1Target, this.set_2_2Target].forEach((setScore, i)  => {
          if (setScore.readOnly == true) {
            setScore.value = '';
          };
          setScore.readOnly = false;
        });
      }

      // Third set
      if (this.set_1_1Target.value && this.set_1_2Target.value && this.set_2_1Target.value && this.set_2_2Target.value) {
        if (((this.set_1_1Target.value > this.set_1_2Target.value) && (this.set_2_1Target.value < this.set_2_2Target.value)) ||
           ((this.set_1_1Target.value < this.set_1_2Target.value) && (this.set_2_1Target.value > this.set_2_2Target.value))) {
            this.setsOnOff([this.set3], true);
        } else {
          this.setsOnOff([this.set3], false);
        }
      } else {
        this.setsOnOff([this.set3], false);
      }

      // Tie Break 1
      if ((Math.abs(this.set_1_1Target.value - this.set_1_2Target.value) == 1) && ([7, 4].includes(Math.max(this.set_1_1Target.value, this.set_1_2Target.value)))) {
        this.tieBreaksOnOff([this.tieBreak1], true);
      } else {
        this.tieBreaksOnOff([this.tieBreak1], false);
      }

      // Tie Break 2 
      if ((Math.abs(this.set_2_1Target.value - this.set_2_2Target.value) == 1) && ([7, 4].includes(Math.max(this.set_2_1Target.value, this.set_2_2Target.value)))) {
        this.tieBreaksOnOff([this.tieBreak2], true);
      } else {
        this.tieBreaksOnOff([this.tieBreak2], false);
      }

      // Tie Break 3
      if ((Math.abs(this.set_3_1Target.value - this.set_3_2Target.value) == 1) && ([7,4].includes(Math.max(this.set_3_1Target.value, this.set_3_2Target.value)))) {
        this.tieBreaksOnOff([this.tieBreak3], true);
      } else {
        this.tieBreaksOnOff([this.tieBreak3], false);
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