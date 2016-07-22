$ ->
  $("abbr.timeago").timeago()

  $('button.btn-refresh:not(.active)').click ->
    $this = $(@)
    $this.addClass('active')
    $.ajax $this.data('url'),
      type: 'PUT'
      success: (data, textStatus, jqXHR) ->
        location.reload()
      error: (jqXHR, textStatus, errorThrown) ->
      complete: (jqXHR, textStatus) ->
        $this.removeClass('active')
