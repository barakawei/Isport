var Mention = {
  cachedInput : false,
  input: function(){
    if(!Mention.cachedInput){
      Mention.cachedInput = Mention.form().find('#status_message_content');
    }
    return Mention.cachedInput;
  }, 
  
  cachedForm : false,
  form: function(){
    if(!Mention.cachedForm){
      Mention.cachedForm = $('#new_status_message');
    }
    return Mention.cachedForm;
  },
    
  clear: function(){
    this.autocompletion.mentionList.clear();
  },
  
  cachedHiddenInput : false,
  hiddenInput: function(){
    if(!Mention.cachedHiddenInput){
      Mention.cachedHiddenInput = Mention.form().find('#contacts');
    }
    return Mention.cachedHiddenInput;
  },
  
  autocompletion: {
    options : function(){return {
      minChars : 1,
      max : 5,
      onSelect : Mention.autocompletion.onSelect,
      searchTermFromValue: Mention.autocompletion.searchTermFromValue,
      scroll : false,
      formatItem: function(row, i, max) {
          return "<img src='"+ row.avatar +"' class='avatar'/>" + row.name;
      },
      formatMatch: function(row, i, max) {
          return row.name;
      },
      formatResult: function(row) {
          return row.name;
      },
      disableRightAndLeft : true
    };},
    hiddenMentionFromPerson : function(personData){
      return "{" + personData.name + ";" + personData.id + "}";
    },

    onSelect :  function(visibleInput, data, formatted) {
      var visibleCursorIndex = visibleInput[0].selectionStart;
      var visibleLoc = Mention.autocompletion.addMentionToInput(visibleInput, visibleCursorIndex, formatted);
      $.Autocompleter.Selection(visibleInput[0], visibleLoc[1], visibleLoc[1]);

      var mentionString = Mention.autocompletion.hiddenMentionFromPerson(data);
      var mention = { visibleStart: visibleLoc[0],
                      visibleEnd  : visibleLoc[1],
                      mentionString : mentionString
                    };
      Mention.autocompletion.mentionList.push(mention);
      Mention.oldInputContent = visibleInput.val();
      Mention.hiddenInput().val(Mention.autocompletion.mentionList.generateHiddenInput(visibleInput.val()));
    },

    mentionList : {
      mentions : [],
      sortedMentions : function(){
        return this.mentions.sort(function(m1, m2){
          if(m1.visibleStart > m2.visibleStart){
            return -1;
          } else if(m1.visibleStart < m2.visibleStart){
            return 1;
          } else {
            return 0;
          }
        });
      },
      push : function(mention){
        this.mentions.push(mention);
      },
      generateHiddenInput : function(visibleString){
        var resultString = visibleString;
        for(var i in this.sortedMentions()){
          var mention = this.mentions[i];
          var start = resultString.slice(0, mention.visibleStart);
          var insertion = mention.mentionString;
          var end = resultString.slice(mention.visibleEnd);

          resultString = start + insertion + end;
        }
        return resultString;
      },

      insertionAt : function(insertionStartIndex, selectionEnd, keyCode){
        if(insertionStartIndex != selectionEnd){
          this.selectionDeleted(insertionStartIndex, selectionEnd);
        }
        this.updateMentionLocations(insertionStartIndex, 1);
        this.destroyMentionAt(insertionStartIndex);
      },
      deletionAt : function(selectionStart, selectionEnd, keyCode){
        if(selectionStart != selectionEnd){
          this.selectionDeleted(selectionStart, selectionEnd);
          return;
        }

        var effectiveCursorIndex;
        if(keyCode == KEYCODES.DEL){
          effectiveCursorIndex = selectionStart;
        }else{
          effectiveCursorIndex = selectionStart - 1;
        }
        this.updateMentionLocations(effectiveCursorIndex, -1);
        this.destroyMentionAt(effectiveCursorIndex);
      },
      selectionDeleted : function(selectionStart, selectionEnd){
        Mention.autocompletion.mentionList.destroyMentionsWithin(selectionStart, selectionEnd);
        Mention.autocompletion.mentionList.updateMentionLocations(selectionStart, selectionStart - selectionEnd);
      },
      destroyMentionsWithin : function(start, end){
        for (var i = this.mentions.length - 1; i >= 0; i--){
          var mention = this.mentions[i];
          if(start < mention.visibleEnd && end >= mention.visibleStart){
            this.mentions.splice(i, 1);
          }
        }
      },
      clear: function(){
        this.mentions = [];
      },
      destroyMentionAt : function(effectiveCursorIndex){

        var mentionIndex = this.mentionAt(effectiveCursorIndex);
        var mention = this.mentions[mentionIndex];
        if(mention){
          this.mentions.splice(mentionIndex, 1);
        }
      },
      updateMentionLocations : function(effectiveCursorIndex, offset){
        var changedMentions = this.mentionsAfter(effectiveCursorIndex);
        for(var i in changedMentions){
          var mention = changedMentions[i];
          mention.visibleStart += offset;
          mention.visibleEnd += offset;
        }
      },
      mentionAt : function(visibleCursorIndex){
        for(var i in this.mentions){
          var mention = this.mentions[i];
          if(visibleCursorIndex > mention.visibleStart && visibleCursorIndex < mention.visibleEnd){
            return i;
          }
        }
        return false;
      },
      mentionsAfter : function(visibleCursorIndex){
        var resultMentions = [];
        for(var i in this.mentions){
          var mention = this.mentions[i];
          if(visibleCursorIndex <= mention.visibleStart){
            resultMentions.push(mention);
          }
        }
        return resultMentions;
      }
    },
    repopulateHiddenInput: function(){
      var newHiddenVal = Mention.autocompletion.mentionList.generateHiddenInput(Mention.input().val());
      if(newHiddenVal != Mention.hiddenInput().val()){
        Mention.hiddenInput().val(newHiddenVal);
      }
    },

    keyUpHandler : function(event){
      Mention.autocompletion.repopulateHiddenInput();
      //Mention.determineSubmitAvailability();
    },

    keyDownHandler : function(event){
      var input = Mention.input();
      var selectionStart = input[0].selectionStart;
      var selectionEnd = input[0].selectionEnd;
      var isDeletion = (event.keyCode == KEYCODES.DEL && selectionStart < input.val().length) || (event.keyCode == KEYCODES.BACKSPACE && (selectionStart > 0 || selectionStart != selectionEnd));
      var isInsertion = (KEYCODES.isInsertion(event.keyCode) && event.keyCode != KEYCODES.RETURN );

      if(isDeletion){
        Mention.autocompletion.mentionList.deletionAt(selectionStart, selectionEnd, event.keyCode);
      }else if(isInsertion){
        Mention.autocompletion.mentionList.insertionAt(selectionStart, selectionEnd, event.keyCode);
      }
    },

    addMentionToInput: function(input, cursorIndex, formatted){
      var inputContent = input.val();

      var stringLoc = Mention.autocompletion.findStringToReplace(inputContent, cursorIndex);

      var stringStart = inputContent.slice(0, stringLoc[0]);
      var stringEnd = inputContent.slice(stringLoc[1]);

      input.val(stringStart + formatted + stringEnd);
      var offset = formatted.length - (stringLoc[1] - stringLoc[0]);
      Mention.autocompletion.mentionList.updateMentionLocations(stringStart.length, offset);
      return [stringStart.length, stringStart.length + formatted.length];
    },

    findStringToReplace: function(value, cursorIndex){
      var atLocation = value.lastIndexOf('@', cursorIndex);
      if(atLocation == -1){return [0,0];}
      var nextAt = cursorIndex;

      if(nextAt == -1){nextAt = value.length;}
      return [atLocation+1, nextAt];

    },

    searchTermFromValue: function(value, cursorIndex)
    {
      var stringLoc = Mention.autocompletion.findStringToReplace(value, cursorIndex);
      if(stringLoc[0] <= 1){
        stringLoc[0] = 0;
      }else{
        stringLoc[0] -= 1;
      }

      var relevantString = value.slice(stringLoc[0], stringLoc[1]);

      var matches = relevantString.match(/(^|\s)@(.+)/);
      if(matches){
        return matches[2];
      }else{
        return '';
      }
    },

    initialize: function(){
      $.getJSON("/contacts", undefined ,
        function(data){
          Mention.input().autocomplete(data,
            Mention.autocompletion.options());
          Mention.input().result(Mention.autocompletion.selectItemCallback);
          Mention.oldInputContent = Mention.input().val();
        }
      );
    }
  },
};
$(document).ready(function() {
  Mention.autocompletion.initialize();
  Mention.input().keydown(Mention.autocompletion.keyDownHandler);
  Mention.input().keyup(Mention.autocompletion.keyUpHandler);
  
});  


