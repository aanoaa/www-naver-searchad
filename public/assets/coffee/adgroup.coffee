$.fn.editable.defaults.mode = 'inline'
$.fn.editable.defaults.emptytext = '비어있음'
$.fn.editable.defaults.ajaxOptions =
  type: "PUT"
  dataType: 'json'

$ ->
  $("abbr.timeago").timeago()

  $('input[name=on_off]').change ->
    $this = $(@)
    v = if $this.prop('checked') then 1 else 0
    $.ajax $this.data('url'),
      type: 'PUT'
      data: { on_off: v }
      success: (data, textStatus, jqXHR) ->
      error: (jqXHR, textStatus, errorThrown) ->
      complete: (jqXHR, textStatus) ->

  $('.rank-editable').editable
    params: (params) ->
      params[params.name] = params.value
      params

  $('.rank-rank-editable').editable
    success: -> location.reload()
    source: [
      {value: '1', text: '1'},
      {value: '2', text: '2'},
      {value: '3', text: '3'},
      {value: '4', text: '4'},
      {value: '5', text: '5'},
      {value: '6', text: '6'},
      {value: '7', text: '7'},
      {value: '8', text: '8'},
      {value: '9', text: '9'},
      {value: '10', text: '10'}
    ]
    params: (params) ->
      params[params.name] = params.value
      params