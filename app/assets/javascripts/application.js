// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require rails-ujs
//= require bootstrap-sprockets
//= require jsoneditor.min.js

JSONEditor.defaults.theme = 'bootstrap3';
JSONEditor.defaults.iconlib = 'bootstrap3';
JSONEditor.defaults.options.object_layout = 'grid'

let submitData = function (method, url, data) {
  let xhr = new XMLHttpRequest();
  xhr.open(method, url, true);
  xhr.setRequestHeader("Content-Type", "application/json");
  xhr.onreadystatechange = function () {
    if (xhr.readyState !== xhr.DONE) {
      return
    }
    rsp = JSON.parse(xhr.responseText)
    switch (xhr.status) {
      case 200:
        alert(rsp.msg)
        break;
      case 301:
        document.location = rsp.url
        break;
      default:
        break;
    }
  };

  let csrf_param_element = document.querySelector('meta[name="csrf-param"]');
  let csrf_param = csrf_param_element && csrf_param_element.getAttribute("content");
  let csrf_token_element = document.querySelector('meta[name="csrf-token"]');
  let csrf_token = csrf_token_element && csrf_token_element.getAttribute("content");
  data[csrf_param] = csrf_token;

  xhr.send(JSON.stringify(data));
}

let syncData = function (method, url, data) {
  let xhr = new XMLHttpRequest();
  xhr.open(method, url, false);
  xhr.onreadystatechange == function () {
    if (xhr.readyState !== xhr.DONE) {
      return
    }
    callback(xhr.response);
  }
  xhr.send(JSON.stringify(data));

  return xhr
}

let renderModal = function (method, target, data, bind_id) {
  let bind_dom = document.getElementById(bind_id);
  bind_dom.innerHTML = syncData(method, target, data).response;
}

let bindChangeEvent = function (editor, msgHolderID, submit_button) {
  editor.on('change', function () {
    // Get an array of errors from the validator
    let errors = editor.validate();
    let holder = document.getElementById(msgHolderID)

    if (holder) {
      if (errors.length) {
        holder.innerText = JSON.stringify(errors);
        holder.className = 'label label-warning label-lg';
      } else {
        holder.innerText = '';
        holder.className = 'label';
      }
    }

    submit_button && (submit_button.disabled = errors.length > 0)
  });
}
