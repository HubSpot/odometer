(function() {
  var DIGIT_HTML, ODOMETER_HTML, Odometer, RIBBON_HTML, VALUE_HTML, el, insertTemplate, odo, renderTemplate;

  ODOMETER_HTML = '<div class="odometer"></div>';

  DIGIT_HTML = '.odometer > <span class="odometer-digit"><span class="odometer-digit-spacer">8</span><span class="odometer-digit-inner"></span></span>';

  RIBBON_HTML = '.odometer-digit-inner > <span class="odometer-ribbon"><span class="odometer-ribbon-inner"></span></span>';

  VALUE_HTML = '.odometer-ribbon-inner > <span class="odometer-value">{value}</span>';

  renderTemplate = function(template, ctx) {
    return template.replace(/\{([\s\S]*?)\}/gm, function(match, val) {
      return ctx[val];
    });
  };

  insertTemplate = function(template, el, ctx) {
    var format, html, match, nel, node, selector, temp, _i, _j, _len, _len1, _ref, _ref1, _results;
    if (typeof template === 'object') {
      for (_i = 0, _len = template.length; _i < _len; _i++) {
        temp = template[_i];
        insertTemplate(temp, el, ctx);
      }
      return;
    }
    _ref = /(?:([^>]+) > )?(.*)/.exec(template), match = _ref[0], selector = _ref[1], format = _ref[2];
    if (selector) {
      el = el.querySelector(selector);
    }
    html = renderTemplate(format, ctx);
    if (el.children) {
      nel = document.createElement('div');
      nel.innerHTML = html;
      _ref1 = nel.children;
      _results = [];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        node = _ref1[_j];
        _results.push(el.appendChild(node));
      }
      return _results;
    } else {
      return el.innerHTML = html;
    }
  };

  Odometer = (function() {
    Odometer.prototype.template = ODOMETER_HTML;

    Odometer.prototype.digitTemplate = [DIGIT_HTML, RIBBON_HTML, VALUE_HTML];

    function Odometer(options) {
      this.options = options;
      this.value = this.options.value;
      this.el = this.options.el;
    }

    Odometer.prototype.render = function() {
      var digit, _i, _len, _ref, _results;
      insertTemplate(this.template, this.el, {});
      _ref = this.value.toString().split('');
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        digit = _ref[_i];
        _results.push(insertTemplate(this.digitTemplate, this.el, {
          value: digit
        }));
      }
      return _results;
    };

    return Odometer;

  })();

  el = document.querySelector('div');

  odo = new Odometer({
    value: 343,
    el: el
  });

  odo.render();

}).call(this);
