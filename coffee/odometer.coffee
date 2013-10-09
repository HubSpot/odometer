ODOMETER_HTML = '<div class="odometer"></div>'
DIGIT_HTML = '<span class="odometer-digit"><span class="odometer-digit-spacer">8</span><span class="odometer-digit-inner"></span></span>'
RIBBON_HTML = '<span class="odometer-ribbon"><span class="odometer-ribbon-inner"></span></span>'
VALUE_HTML = '<span class="odometer-value">{value}</span>'

FRAMERATE = 60
DURATION = 2000
FRAMES_PER_VALUE = 2
OVERSAMPLE = 2

MS_PER_FRAME = 1000 / FRAMERATE
MAX_VALUES = (DURATION / MS_PER_FRAME) / FRAMES_PER_VALUE

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

    @el.addEventListener 'webkitTransitionEnd transitionEnd', @render.bind(@)

  render: ->
    @el.innerHTML = renderTemplate ODOMETER_HTML
    @odometer = @el.querySelector '.odometer'

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

    @animate newValue

    setTimeout =>
      if diff > 0
        @odometer.className += ' odometer-animating odometer-animating-up'
      else
        @odometer.className += ' odometer-animating odometer-animating-down'
    , 0

    @value = newValue

  animate: (newValue) ->
    diff = newValue - @value

    frames = []
    if Math.abs(diff) > MAX_VALUES
      # We use oversample x to give us a chance to subsample digits where
      # we need their column to move faster than others
      incr = diff / (OVERSAMPLE * MAX_VALUES)
    else
      incr = if diff > 0 then 1 else -1
    
    cur = @value
    while (diff > 0 and cur <= newValue) or (diff < 0 and cur >= newValue)
      cur += incr
      frames.push Math.round cur

    frames[frames.length - 1] = newValue

    digitCount = Math.ceil(Math.log(newValue)/Math.log(10))
    needToSkipDigits = []
    needToScaleDigits = []
    for i in [0...digitCount]
      changePerFrame = diff / MAX_VALUES

      if changePerFrame / Math.pow(10, i) < 1
        needToSkipDigits.push i
      else if i isnt 0
        needToScaleDigits.push i

    counter = {}

    digitScale = {}
    for digit in needToScaleDigits
      fraction = 1 - digit / needToScaleDigits.length

      digitScale[digit] = fraction * (1 - 1/OVERSAMPLE) + 1/OVERSAMPLE

    console.log digitScale

    boringDigits = []
    for i in [0...digitCount]
      boringDigits.push true

    last = @value.toString().split('').reverse()
    lastFrame = frames[frames.length - 1]

    for curFrame in frames
      digits = curFrame.toString().split('').reverse()

      for digit, i in digits
        if last[i] isnt digit
          boringDigits[i] = false


        if i is 1
          console.log digit, last[i], needToSkipDigits
        if i in needToSkipDigits and digit is last[i] and (curFrame isnt lastFrame or boringDigits[i])
          # Don't render multiple copies of the same digit in columns where we have
          # less digit changes than we have frames
          continue

        if curFrame isnt lastFrame and digitScale[i]? and digitScale[i] < Math.random()
          continue

        counter[i] ?= 0
        counter[i]++

        if curFrame is lastFrame
          value = digit
        else
          value = last[i] ? ''

        numEl = createFromHTML renderTemplate VALUE_HTML, {value}

        if curFrame is lastFrame
          numEl.className += ' odometer-terminal-value'

        if not @digits[i]
          @digits[i] = @renderDigit()
          @odometer.insertBefore @digits[i], @odometer.children[0]

        @digits[i].querySelector('.odometer-ribbon-inner').appendChild numEl

        last[i] = digit

    for i in [0...digitCount]
      if boringDigits[i]
        @digits[i].querySelector('.odometer-value').className += ' odometer-terminal-value'

    console.log counter

el = document.querySelector('div')
odo = new Odometer({value: 343, el})
odo.render()
odo.update(3592999)
