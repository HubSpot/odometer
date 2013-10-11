VALUE_HTML = '<span class="odometer-value"></span>'
RIBBON_HTML = '<span class="odometer-ribbon"><span class="odometer-ribbon-inner">' + VALUE_HTML + '</span></span>'
DIGIT_HTML = '<span class="odometer-digit"><span class="odometer-digit-spacer">8</span><span class="odometer-digit-inner">' + RIBBON_HTML + '</span></span>'
FORMAT_MARK_HTML = '<span class="odometer-formatting-mark"></span>'
DIGIT_FORMAT = ',ddd'

# What is our target framerate?
FRAMERATE = 60

# How long will the animation last?
DURATION = 2000

# What is the fastest we should update values when we are
# counting up (not using the wheel animation).
COUNT_FRAMERATE = 20

# What is the minimum number of frames for each value on the wheel?
# We won't render more values than could be reasonably seen
FRAMES_PER_VALUE = 2

# If more than one digit is hitting the frame limit, they would all get
# capped at that limit and appear to be moving at the same rate.  This
# factor adds a boost to subsequent digits to make them appear faster.
DIGIT_SPEEDBOOST = .5

MS_PER_FRAME = 1000 / FRAMERATE
COUNT_MS_PER_FRAME = 1000 / COUNT_FRAMERATE

TRANSITION_END_EVENTS = 'transitionend webkitTransitionEnd oTransitionEnd otransitionend MSTransitionEnd'
TRANSITION_SUPPORT = document.createElement('div').style.transition?

createFromHTML = (html) ->
  el = document.createElement('div')
  el.innerHTML = html
  el.children[0]

now = ->
  window.performance?.now() ? +new Date

_jQueryWrapped = false
do wrapJQuery = ->
  return if _jQueryWrapped

  if window.jQuery?
    _jQueryWrapped = true
    # We need to wrap jQuery's .html and .text because they don't always
    # call .innerHTML/.innerText
    for property in ['html', 'text']
      do (property) ->
        old = window.jQuery.fn[property]
        window.jQuery.fn[property] = (val) ->
          if not val? or not this[0].odometer?
            return old.apply this, arguments

          this[0].odometer.update val

# In case jQuery is brought in after this file
setTimeout wrapJQuery, 0

class Odometer
  constructor: (@options) ->
    @el = @options.el
    return @el.odometer if @el.odometer?

    @el.odometer = @

    for k, v in Odometer.options
      if not @options[k]?
        @options[k] = v

    @value = @cleanValue(@options.value ? '')

    @inside = document.createElement 'div'
    @inside.className = 'odometer-inside'
    @el.innerHTML = ''
    @el.appendChild @inside

    @options.format ?= DIGIT_FORMAT
    @options.format or= 'd'

    @options.duration ?= DURATION
    @MAX_VALUES = ((@options.duration / MS_PER_FRAME) / FRAMES_PER_VALUE) | 0

    @render()

    for property in ['HTML', 'Text']
      do (property) =>
        Object.defineProperty @el, "inner#{ property }",
          get: =>
            @inside["outer#{ property }"]

          set: (val) =>
            @update @cleanValue val

    @

  cleanValue: (val) ->
    parseInt(val.toString().replace(/[.,]/g, ''), 10) or 0

  bindTransitionEnd: ->
    return if @transitionEndBound
    @transitionEndBound = true
    
    # The event will be triggered once for each ribbon, we only
    # want one render though
    renderEnqueued = false
    for event in TRANSITION_END_EVENTS.split(' ')
      @el.addEventListener event, =>
        return true if renderEnqueued

        renderEnqueued = true

        setTimeout =>
          @render()
          renderEnqueued = false
        , 0

        true
      , false

  resetFormat: ->
    @format = @options.format.split('').reverse().join('')

  render: (value=@value) ->
    @resetFormat()

    @inside.innerHTML = ''

    classes = @el.className.split(' ')
    newClasses = []
    for cls in classes when cls.length
      unless /^odometer(-|$)/.test(cls)
        newClasses.push cls

    newClasses.push 'odometer'

    unless TRANSITION_SUPPORT
      newClasses.push 'odometer-no-transitions'

    if @options.theme
      newClasses.push "odometer-theme-#{ @options.theme }"
    else
      # This class matches all themes, so it should do what you'd expect if only one
      # theme css file is brought into the page.
      newClasses.push "odometer-auto-theme"

    @el.className = newClasses.join(' ')

    @ribbons = {}

    @digits = []
    for digit in value.toString().split('').reverse()
      ctx = {value: digit}

      @addDigit digit

  update: (newValue) ->
    return unless diff = newValue - @value

    if diff > 0
      @el.className += ' odometer-animating-up'
    else
      @el.className += ' odometer-animating-down'

    @animate newValue

    setTimeout =>
      @el.className += ' odometer-animating'
    , 0

    @value = newValue

  renderDigit: ->
    createFromHTML DIGIT_HTML

  insertDigit: (digit) ->
    if not @inside.children.length
      @inside.appendChild digit
    else
      @inside.insertBefore digit, @inside.children[0]

  addDigit: (value) ->
    resetted = false
    while true
      if not @format.length
        if resetted
          throw new Error "Bad odometer format without digits"

        @resetFormat()
        resetted = true

      char = @format[0]
      @format = @format.substring(1)

      break if char is 'd'

      spacer = createFromHTML FORMAT_MARK_HTML
      spacer.innerHTML = char
      @insertDigit spacer

    digit = @renderDigit()
    digit.querySelector('.odometer-value').innerHTML = value
    @digits.push digit

    @insertDigit digit

  animate: (newValue) ->
    if TRANSITION_SUPPORT
      @animateSlide newValue
    else
      @animateCount newValue

  animateCount: (newValue) ->
    return unless diff = newValue - @value

    start = last = now()

    cur = @value
    do tick = =>
      if (now() - start) > @options.duration
        @value = newValue
        @render()
        return

      delta = now() - last

      if delta > COUNT_MS_PER_FRAME
        last = now()

        fraction = delta / @options.duration
        dist = diff * fraction

        cur += dist
        @render Math.round cur

      if window.requestAnimationFrame?
        requestAnimationFrame tick
      else
        setTimeout tick, COUNT_MS_PER_FRAME

  animateSlide: (newValue) ->
    return unless diff = newValue - @value

    @bindTransitionEnd()

    digitCount = Math.ceil(Math.log(Math.max(Math.abs(newValue), Math.abs(@value)) + 1) / Math.log(10))

    digits = []
    boosted = 0
    # We create a array to represent the series of digits which should be
    # animated in each column
    for i in [0...digitCount]
      start = Math.floor(@value / Math.pow(10, (digitCount - i - 1)))
      end = Math.floor(newValue / Math.pow(10, (digitCount - i - 1)))

      dist = end - start

      if Math.abs(dist) > @MAX_VALUES
        # We need to subsample
        frames = []

        # Subsequent digits need to be faster than previous ones
        incr = dist / (@MAX_VALUES + @MAX_VALUES * boosted * DIGIT_SPEEDBOOST)
        cur = start

        while (dist > 0 and cur < end) or (dist < 0 and cur > end)
          frames.push Math.round cur
          cur += incr
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
        @addDigit ' '

      @ribbons[i] ?= @digits[i].querySelector('.odometer-ribbon-inner')
      @ribbons[i].innerHTML = ''

      if diff < 0
        frames = frames.reverse()

      for frame, j in frames
        numEl = document.createElement('div')
        numEl.className = 'odometer-value'
        numEl.innerHTML = frame

        @ribbons[i].appendChild numEl

        if j == frames.length - 1
          numEl.className += ' odometer-last-value'
        if j == 0
          numEl.className += ' odometer-first-value'

Odometer.options = window.odometerOptions ? {}

setTimeout ->
  # We do this in a seperate pass to allow people to set
  # window.odometerOptions after bringing the file in.
  if window.odometerOptions
    for k, v of window.odometerOptions
      Odometer.options[k] ?= v
, 0

Odometer.init = ->
  elements = document.querySelectorAll (Odometer.options.selector or '.odometer')

  for el in elements
    el.odometer = new Odometer {el, value: el.innerText}

if document.documentElement?.doScroll? and document.createEventObject?
  # IE < 9
  _old = document.onreadystatechange
  document.onreadystatechange = ->
    if document.readyState is 'complete' and Odometer.options.auto isnt false
      Odometer.init()

    _old?.apply this, arguments
else
  document.addEventListener 'DOMContentLoaded', ->
    if Odometer.options.auto isnt false
      Odometer.init()
  , false

window.Odometer = Odometer
