VALUE_HTML = '<span class="odometer-value"></span>'
RIBBON_HTML = '<span class="odometer-ribbon"><span class="odometer-ribbon-inner">' + VALUE_HTML + '</span></span>'
DIGIT_HTML = '<span class="odometer-digit"><span class="odometer-digit-spacer">8</span><span class="odometer-digit-inner">' + RIBBON_HTML + '</span></span>'
FORMAT_MARK_HTML = '<span class="odometer-formatting-mark"></span>'

# The bit within the parenthesis will be repeated, so (,ddd) becomes 123,456,789....
#
# If your locale uses spaces to seperate digits, you could consider using a
# Narrow No-Break Space ( ), as it's a bit more correct.
#
# Numbers will be rounded to the number of digits after the radix seperator.
#
# When values are set using `.update` or the `.innerHTML`-type attributes,
# strings are assumed to already be in the locale's format.
#
# This is just the default, it can also be set as options.format.
DIGIT_FORMAT = '(,ddd).dd'

FORMAT_PARSER = /^\(?([^)]*)\)?(?:(.)(d+))?$/

# What is our target framerate?
FRAMERATE = 30

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

transitionCheckStyles = document.createElement('div').style
TRANSITION_SUPPORT = transitionCheckStyles.transition? or transitionCheckStyles.webkitTransition? or
                     transitionCheckStyles.mozTransition? or transitionCheckStyles.oTransition?

requestAnimationFrame = window.requestAnimationFrame or window.mozRequestAnimationFrame or
                        window.webkitRequestAnimationFrame or window.msRequestAnimationFrame

MutationObserver = window.MutationObserver or window.WebKitMutationObserver or window.MozMutationObserver

createFromHTML = (html) ->
  el = document.createElement('div')
  el.innerHTML = html
  el.children[0]

removeClass = (el, name) ->
  el.className = el.className.replace new RegExp("(^| )#{ name.split(' ').join('|') }( |$)", 'gi'), ' '

addClass = (el, name) ->
  removeClass el, name
  el.className += " #{ name }"

trigger = (el, name) ->
  # Custom DOM events are not supported in IE8
  if document.createEvent?
    evt = document.createEvent('HTMLEvents')
    evt.initEvent(name, true, true)
    el.dispatchEvent(evt)

now = ->
  window.performance?.now?() ? +new Date

round = (val, precision=0) ->
  return Math.round(val) unless precision

  val *= Math.pow(10, precision)
  val += 0.5
  val = Math.floor(val)
  val /= Math.pow(10, precision)

truncate = (val) ->
  # | 0 fails on numbers greater than 2^32
  if val < 0
    Math.ceil(val)
  else
    Math.floor(val)

fractionalPart = (val) ->
  val - round(val)

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
          if not val? or not this[0]?.odometer?
            return old.apply this, arguments

          this[0].odometer.update val

# In case jQuery is brought in after this file
setTimeout wrapJQuery, 0

class Odometer
  constructor: (@options) ->
    @el = @options.el
    return @el.odometer if @el.odometer?

    @el.odometer = @

    for k, v of Odometer.options
      if not @options[k]?
        @options[k] = v

    @options.duration ?= DURATION
    @MAX_VALUES = ((@options.duration / MS_PER_FRAME) / FRAMES_PER_VALUE) | 0

    @resetFormat()

    @value = @cleanValue(@options.value ? '')

    @renderInside()
    @render()

    try
      for property in ['innerHTML', 'innerText', 'textContent'] when @el[property]?
        do (property) =>
          Object.defineProperty @el, property,
            get: =>
              if property is 'innerHTML'
                @inside.outerHTML
              else
                # It's just a single HTML element, so innerText is the
                # same as outerText.
                @inside.innerText ? @inside.textContent
            set: (val) =>
              @update val
    catch e
      # Safari
      @watchForMutations()

    @

  renderInside: ->
    @inside = document.createElement 'div'
    @inside.className = 'odometer-inside'
    @el.innerHTML = ''
    @el.appendChild @inside

  watchForMutations: ->
    # Safari doesn't allow us to wrap .innerHTML, so we listen for it
    # changing.
    return unless MutationObserver?

    try
      @observer ?= new MutationObserver (mutations) =>
        newVal = @el.innerText

        @renderInside()
        @render @value
        @update newVal

      @watchMutations = true
      @startWatchingMutations()
    catch e

  startWatchingMutations: ->
    if @watchMutations
      @observer.observe @el, {childList: true}

  stopWatchingMutations: ->
    @observer?.disconnect()

  cleanValue: (val) ->
    if typeof val is 'string'
      # We need to normalize the format so we can properly turn it into
      # a float.
      val = val.replace((@format.radix ? '.'), '<radix>')
      val = val.replace /[.,]/g, ''
      val = val.replace '<radix>', '.'
      val = parseFloat(val, 10) or 0

    round(val, @format.precision)

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

          trigger @el, 'odometerdone'
        , 0

        true
      , false

  resetFormat: ->
    format = @options.format ? DIGIT_FORMAT
    format or= 'd'

    parsed = FORMAT_PARSER.exec format
    if not parsed
      throw new Error "Odometer: Unparsable digit format"

    [repeating, radix, fractional] = parsed[1..3]

    precision = fractional?.length or 0

    @format = {repeating, radix, precision}

  render: (value=@value) ->
    @stopWatchingMutations()
    @resetFormat()

    @inside.innerHTML = ''

    theme = @options.theme

    classes = @el.className.split(' ')
    newClasses = []
    for cls in classes when cls.length
      if match = /^odometer-theme-(.+)$/.exec(cls)
        theme = match[1]
        continue

      if /^odometer(-|$)/.test(cls)
        continue

      newClasses.push cls

    newClasses.push 'odometer'

    unless TRANSITION_SUPPORT
      newClasses.push 'odometer-no-transitions'

    if theme
      newClasses.push "odometer-theme-#{ theme }"
    else
      # This class matches all themes, so it should do what you'd expect if only one
      # theme css file is brought into the page.
      newClasses.push "odometer-auto-theme"

    @el.className = newClasses.join(' ')

    @ribbons = {}

    @digits = []
    wholePart = not @format.precision or not fractionalPart(value) or false
    for digit in value.toString().split('').reverse()
      if digit is '.'
        wholePart = true

      @addDigit digit, wholePart

    @startWatchingMutations()

  update: (newValue) ->
    newValue = @cleanValue newValue

    return unless diff = newValue - @value

    removeClass @el, 'odometer-animating-up odometer-animating-down odometer-animating'
    if diff > 0
      addClass @el, 'odometer-animating-up'
    else
      addClass @el, 'odometer-animating-down'

    @stopWatchingMutations()
    @animate newValue
    @startWatchingMutations()

    setTimeout =>
      # Force a repaint
      @el.offsetHeight

      addClass @el, 'odometer-animating'
    , 0

    @value = newValue

  renderDigit: ->
    createFromHTML DIGIT_HTML

  insertDigit: (digit, before) ->
    if before?
      @inside.insertBefore digit, before
    else if not @inside.children.length
      @inside.appendChild digit
    else
      @inside.insertBefore digit, @inside.children[0]

  addSpacer: (chr, before, extraClasses) ->
    spacer = createFromHTML FORMAT_MARK_HTML
    spacer.innerHTML = chr
    addClass(spacer, extraClasses) if extraClasses
    @insertDigit spacer, before

  addDigit: (value, repeating=true) ->
    if value is '-'
      return @addSpacer value, null, 'odometer-negation-mark'

    if value is '.'
      return @addSpacer (@format.radix ? '.'), null, 'odometer-radix-mark'

    if repeating
      resetted = false
      while true
        if not @format.repeating.length
          if resetted
            throw new Error "Bad odometer format without digits"

          @resetFormat()
          resetted = true

        chr = @format.repeating[@format.repeating.length - 1]
        @format.repeating = @format.repeating.substring(0, @format.repeating.length - 1)

        break if chr is 'd'

        @addSpacer chr

    digit = @renderDigit()
    digit.querySelector('.odometer-value').innerHTML = value
    @digits.push digit

    @insertDigit digit

  animate: (newValue) ->
    if not TRANSITION_SUPPORT or @options.animation is 'count'
      @animateCount newValue
    else
      @animateSlide newValue

  animateCount: (newValue) ->
    return unless diff = +newValue - @value

    start = last = now()

    cur = @value
    do tick = =>
      if (now() - start) > @options.duration
        @value = newValue
        @render()
        trigger @el, 'odometerdone'
        return

      delta = now() - last

      if delta > COUNT_MS_PER_FRAME
        last = now()

        fraction = delta / @options.duration
        dist = diff * fraction

        cur += dist
        @render Math.round cur

      if requestAnimationFrame?
        requestAnimationFrame tick
      else
        setTimeout tick, COUNT_MS_PER_FRAME

  getDigitCount: (values...) ->
    for value, i in values
      values[i] = Math.abs(value)

    max = Math.max values...

    Math.ceil(Math.log(max + 1) / Math.log(10))

  getFractionalDigitCount: (values...) ->
    # This assumes the value has already been rounded to
    # @format.precision places
    #
    parser = /^\-?\d*\.(\d*?)0*$/
    for value, i in values
      values[i] = value.toString()

      parts = parser.exec values[i]

      if not parts?
        values[i] = 0
      else
        values[i] = parts[1].length

    Math.max values...

  resetDigits: ->
    @digits = []
    @ribbons = []
    @inside.innerHTML = ''
    @resetFormat()

  animateSlide: (newValue) ->
    oldValue = @value

    fractionalCount = @getFractionalDigitCount oldValue, newValue

    if fractionalCount
      newValue = newValue * Math.pow(10, fractionalCount)
      oldValue = oldValue * Math.pow(10, fractionalCount)

    return unless diff = newValue - oldValue

    @bindTransitionEnd()

    digitCount = @getDigitCount(oldValue, newValue)

    digits = []
    boosted = 0
    # We create a array to represent the series of digits which should be
    # animated in each column
    for i in [0...digitCount]
      start = truncate(oldValue  / Math.pow(10, (digitCount - i - 1)))
      end = truncate(newValue / Math.pow(10, (digitCount - i - 1)))

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

        if frames[frames.length - 1] isnt end
          frames.push end

        boosted++
      else
        frames = [start..end]

      # We only care about the last digit
      for frame, i in frames
        frames[i] = Math.abs(frame % 10)

      digits.push frames

    @resetDigits()

    for frames, i in digits.reverse()
      if not @digits[i]
        @addDigit ' ', (i >= fractionalCount)

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
          addClass numEl, 'odometer-last-value'
        if j == 0
          addClass numEl, 'odometer-first-value'

    if start < 0
      @addDigit '-'

    mark = @inside.querySelector('.odometer-radix-mark')
    mark.parent.removeChild(mark) if mark?

    if fractionalCount
      @addSpacer @format.radix, @digits[fractionalCount - 1], 'odometer-radix-mark'

Odometer.options = window.odometerOptions ? {}

setTimeout ->
  # We do this in a seperate pass to allow people to set
  # window.odometerOptions after bringing the file in.
  if window.odometerOptions
    for k, v of window.odometerOptions
      Odometer.options[k] ?= v
, 0

Odometer.init = ->
  if not document.querySelectorAll?
    # IE 7 or 8 in Quirksmode
    return

  elements = document.querySelectorAll (Odometer.options.selector or '.odometer')

  for el in elements
    el.odometer = new Odometer {el, value: (el.innerText ? el.textContent)}

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


if typeof define is 'function' and define.amd
  # AMD. Register as an anonymous module.
  define ['jquery'], ->
    Odometer
else if typeof exports is not 'undefined'
  # CommonJS
  module.exports = Odometer
else
  # Browser globals
  window.Odometer = Odometer
