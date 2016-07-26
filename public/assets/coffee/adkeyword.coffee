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

  $.ajax "#{location.href}",
    type: 'GET'
    headers: { Accept: 'Application/json' }
    success: (data, textStatus, jqXHR) ->
      labels = []
      ranks = []
      logs = data.logs
      adkeyword = data.adkeyword
      max_depth = parseInt(adkeyword.max_depth)
      for log in logs
        labels.unshift log.create_date
        rank = parseInt(log.rank)
        if rank is 0 then ranks.unshift 'Unknown' else ranks.unshift rank

      data = {
        labels: labels
        series: [ranks]
      }

      options = {
        height: 450
        axisY: {
          low: max_depth * -1
          high: -1
          onlyInteger: true
          labelInterpolationFnc: (value) -> -value
        }
      }

      new Chartist.Line('.ct-chart', data, options).on 'data', (context) ->
        context.data.series = context.data.series.map (series) ->
          series.map (value) ->
            -value

    error: (jqXHR, textStatus, errorThrown) ->
    complete: (jqXHR, textStatus) ->
