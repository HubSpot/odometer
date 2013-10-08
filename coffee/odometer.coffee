ODOMETER_HTML = '<div class="odometer"></div>'
DIGIT_HTML = '.odometer > <span class="odometer-digit"><span class="odometer-digit-spacer">8</span><span class="odometer-digit-inner"></span></span>'
RIBBON_HTML = '.odometer-digit-inner > <span class="odometer-ribbon"><span class="odometer-ribbon-inner"></span></span>'
VALUE_HTML = '.odometer-ribbon-inner > <span class="odometer-value">{value}</span>'

renderTemplate = (template, ctx) ->
  template.replace /\{([\s\S]*?)\}/gm, (match, val) ->
    ctx[val]

insertTemplate = (template, el, ctx) ->
  if typeof template is 'object'
    insertTemplate(temp, el, ctx) for temp in template
    return

  [match, selector, format] = /(?:([^>]+) > )?(.*)/.exec template

  if selector
    el = el.querySelector selector

  html = renderTemplate format, ctx
  if el.children
    nel = document.createElement('div')
    nel.innerHTML = html
    el.appendChild(node) for node in nel.children
  else
    el.innerHTML = html

class Odometer
  template: ODOMETER_HTML
  digitTemplate: [DIGIT_HTML, RIBBON_HTML, VALUE_HTML]

  constructor: (@options) ->
    @value = @options.value
    @el = @options.el

  render: ->
    insertTemplate @template, @el, {}

    for digit in @value.toString().split('')
      insertTemplate @digitTemplate, @el, {value: digit}

el = document.querySelector('div')
odo = new Odometer({value: 343, el})
odo.render()
