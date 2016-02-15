String.prototype.toHHMMSS = function () {
  var sec_num = parseInt(this, 10); // don't forget the second param
  var hours   = Math.floor(sec_num / 3600);
  var minutes = Math.floor((sec_num - (hours * 3600)) / 60);
  var seconds = sec_num - (hours * 3600) - (minutes * 60);

  if (seconds < 10) {seconds = "0"+seconds;}

  if (hours > 0) {
    if (minutes < 10) {minutes = "0"+minutes;}
    var time = hours+':'+minutes+':'+seconds;
  } else {
    var time = minutes+':'+seconds;
  }

  return time;
}

var $trackForm;
var $trackInput;

$(document).ready(function() {
  $trackForm = $('#new_comment');
  $trackInput = $('#comment_content');

  $trackForm.submit(function(event) {
    event.preventDefault();
    console.log('submit')
    $.ajax({
      url: $trackForm.attr('action'),
      method: 'post',
      data: {
        comment: {
          content: $trackInput.val()
        }
      },
      success: function(response) {
        $trackInput.val('');
      }
    });
  });
});
