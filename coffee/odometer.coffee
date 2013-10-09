ODOMETER_HTML = '<div class="odometer"></div>'
DIGIT_HTML = '<span class="odometer-digit"><span class="odometer-digit-spacer">8</span><span class="odometer-digit-inner"></span></span>'
RIBBON_HTML = '<span class="odometer-ribbon"><span class="odometer-ribbon-inner"></span></span>'
VALUE_HTML = '<span class="odometer-value">{value}</span>'

# What is our target framerate?
FRAMERATE = 60

# How long will the animation last?
DURATION = 2000

# What is the minimum number of frames for each value on the wheel?
# We won't render more values than could be reasonably seen
FRAMES_PER_VALUE = 2

# If more than one digit is hitting the frame limit, they would all get
# capped at that limit and appear to be moving at the same rate.  This
# factor adds a boost to subsequent digits to make them appear faster.
DIGIT_SPEEDBOOST = .5

MS_PER_FRAME = 1000 / FRAMERATE
MAX_VALUES = ((DURATION / MS_PER_FRAME) / FRAMES_PER_VALUE) | 0

TRANSITION_EVENTS = 'transitionend webkitTransitionEnd oTransitionEnd otransitionend MSTransitionEnd'

renderTemplate = (template, ctx) ->
  template.replace /\{([\s\S]*?)\}/gm, (match, val) ->
    ctx[val]

createFromHTML = (html) ->
  el = document.createElement('div')
  el.innerHTML = html
  el.children[0]

class Odometer
  template: ODOMETER_HTML
  digitTemplate: [DIGIT_HTML, RIBBON_HTML, VALUE_HTML]

  constructor: (@options) ->
    @value = @options.value
    @el = @options.el

    # The event will be triggered once for each ribbon, we only
    # want one render though
    renderEnqueued = false
    for event in TRANSITION_EVENTS.split(' ')
      @el.addEventListener event, =>
        return if renderEnqueued

        renderEnqueued = true

        setTimeout =>
          @render()
          renderEnqueued = false
        , 0

  render: ->
    @el.innerHTML = renderTemplate ODOMETER_HTML
    @odometer = @el.querySelector '.odometer'

    @ribbons = {}

    @digits = []
    for digit in @value.toString().split('')
      ctx = {value: digit}

      digit = @renderDigit()
      digit.querySelector('.odometer-ribbon-inner').innerHTML = renderTemplate VALUE_HTML, ctx

      @digits.unshift digit
      @odometer.appendChild digit

  renderDigit: ->
      digit = createFromHTML renderTemplate DIGIT_HTML
      digit.querySelector('.odometer-digit-inner').innerHTML = renderTemplate RIBBON_HTML
      digit

  update: (newValue) ->
    return unless diff = newValue - @value

    if diff > 0
      @odometer.className += ' odometer-animating-up'
    else
      @odometer.className += ' odometer-animating-down'

    @animate newValue

    setTimeout =>
      # Force a repaint
      @odometer.offsetHeight

      @odometer.className += ' odometer-animating'
    , 0

    @value = newValue

  animate: (newValue) ->
    diff = newValue - @value

    digitCount = Math.ceil(Math.log(Math.max(newValue, @value)) / Math.log(10))

    digits = []
    boosted = 0
    # We create a array to represent the series of digits which should be
    # animated in each column
    for i in [0...digitCount]
      start = Math.floor(@value / Math.pow(10, (digitCount - i - 1)))
      end = Math.floor(newValue / Math.pow(10, (digitCount - i - 1)))

      dist = end - start

      if Math.abs(dist) > MAX_VALUES
        # We need to subsample
        frames = []

        # Subsequent digits need to be faster than previous ones
        incr = dist / (MAX_VALUES + MAX_VALUES * boosted * DIGIT_SPEEDBOOST)
        cur = start
        while (dist > 0 and cur < end) or (dist < 0 and cur > end)
          cur += incr
          frames.push Math.round cur
        frames.push end

        boosted++
      else
        frames = [start..end]

      # We only care about the last digit
      for frame, i in frames
        frames[i] = frame % 10

      digits.push frames

    for frames, i in digits.reverse()
      if not @digits[i]
        @digits[i] = @renderDigit()
        @odometer.insertBefore @digits[i], @odometer.children[0]

      @ribbons[i] ?= @digits[i].querySelector('.odometer-ribbon-inner')
      @ribbons[i].innerHTML = ''

      if diff < 0
        frames = frames.reverse()

      for frame, j in frames
        numEl = createFromHTML renderTemplate VALUE_HTML, {value: frame}

        @ribbons[i].appendChild numEl

        if j == frames.length - 1
          numEl.className += ' odometer-last-value'
        if j == 0
          numEl.className += ' odometer-first-value'

el = document.querySelector('div')
odo = new Odometer({value: 343, el})
odo.render()
odo.update(3453853)
