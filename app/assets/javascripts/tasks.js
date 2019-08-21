$(function() {
  // convert an object representing a task and convert it to html
  function liToHTML(li) {
    return `<li ${li.done ? 'class="completed"' : ''} id="listItem-${li.id}"><div class="view">` +
    `<input type="checkbox" class="toggle" ${li.done ? 'checked' : ''} data-id="${li.id}"></input>` +
    `<label>${li.title}</label> ${new Date(li.created_at).toLocaleDateString('en-US')}` +
    `</div></li>`
  }

  function registerClick () {
    $('.toggle').change(function(e) {
      $.post('/tasks/' + $(e.target).data('id'), {
          _method: "PUT",
          task: {done: e.target.checked}
      }).success(function(e) {
        $('#listItem-' + e.id).replaceWith(liToHTML(e));
        registerClick();
      });
    });
  }

  $.get('/tasks').success(function(data) {
    $('.todo-list').html(data.map(liToHTML).join("\n") );

    registerClick();
  });

  $('#new-form').submit(function(e) {
    e.preventDefault();
    console.log('intercepted');

    var textbox = $('#new-form .new-todo');

    $.post('/tasks/',{
      _method: "POST",
      task: {done: false, title: textbox.val()}
    }).success(function(e) {
      $('.todo-list').append(liToHTML(e));
      textbox.val('');
      registerClick();
    });
  });
});