(function() {
  var DIGIT_HTML, DURATION, FRAMERATE, FRAMES_PER_VALUE, MAX_VALUES, MS_PER_FRAME, ODOMETER_HTML, Odometer, RIBBON_HTML, VALUE_HTML, createFromHTML, el, odo, renderTemplate,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  ODOMETER_HTML = '<div class="odometer"></div>';

  DIGIT_HTML = '<span class="odometer-digit"><span class="odometer-digit-spacer">8</span><span class="odometer-digit-inner"></span></span>';

  RIBBON_HTML = '<span class="odometer-ribbon"><span class="odometer-ribbon-inner"></span></span>';

  VALUE_HTML = '<span class="odometer-value">{value}</span>';

  FRAMERATE = 60;

  DURATION = 2000;

  FRAMES_PER_VALUE = 0.5;

  MS_PER_FRAME = 1000 / FRAMERATE;

  MAX_VALUES = (DURATION / MS_PER_FRAME) / FRAMES_PER_VALUE;

  renderTemplate = function(template, ctx) {
    return template.replace(/\{([\s\S]*?)\}/gm, function(match, val) {
      return ctx[val];
    });
  };

  createFromHTML = function(html) {
    var el;
    el = document.createElement('div');
    el.innerHTML = html;
    return el.children[0];
  };

  Odometer = (function() {
    Odometer.prototype.template = ODOMETER_HTML;

    Odometer.prototype.digitTemplate = [DIGIT_HTML, RIBBON_HTML, VALUE_HTML];

    function Odometer(options) {
      this.options = options;
      this.value = this.options.value;
      this.el = this.options.el;
      this.el.addEventListener('webkitTransitionEnd transitionEnd', this.render.bind(this));
    }

    Odometer.prototype.render = function() {
      var ctx, digit, _i, _len, _ref, _results;
      this.el.innerHTML = renderTemplate(ODOMETER_HTML);
      this.odometer = this.el.querySelector('.odometer');
      this.digits = [];
      _ref = this.value.toString().split('');
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        digit = _ref[_i];
        ctx = {
          value: digit
        };
        digit = this.renderDigit();
        digit.querySelector('.odometer-ribbon-inner').innerHTML = renderTemplate(VALUE_HTML, ctx);
        this.digits.unshift(digit);
        _results.push(this.odometer.appendChild(digit));
      }
      return _results;
    };

    Odometer.prototype.renderDigit = function() {
      var digit;
      digit = createFromHTML(renderTemplate(DIGIT_HTML));
      digit.querySelector('.odometer-digit-inner').innerHTML = renderTemplate(RIBBON_HTML);
      return digit;
    };

    Odometer.prototype.update = function(newValue) {
      var diff,
        _this = this;
      if (!(diff = newValue - this.value)) {
        return;
      }
      this.animate(newValue);
      setTimeout(function() {
        if (diff > 0) {
          return _this.odometer.className += ' odometer-animating odometer-animating-up';
        } else {
          return _this.odometer.className += ' odometer-animating odometer-animating-down';
        }
      }, 0);
      return this.value = newValue;
    };

    Odometer.prototype.animate = function(newValue) {
      var cur, curFrame, diff, digit, digitCount, digits, frames, i, incr, last, lastFrame, needToSkipDigits, numEl, value, _i, _j, _len, _results;
      diff = newValue - this.value;
      frames = [];
      if (Math.abs(diff) > MAX_VALUES) {
        incr = diff / MAX_VALUES;
      } else {
        incr = diff > 0 ? 1 : -1;
      }
      cur = this.value;
      while ((diff > 0 && cur < newValue) || (diff < 0 && cur > newValue)) {
        cur += incr;
        frames.push(Math.round(cur));
      }
      digitCount = Math.ceil(Math.log(newValue) / Math.log(10));
      needToSkipDigits = [];
      for (i = _i = 0; 0 <= digitCount ? _i <= digitCount : _i >= digitCount; i = 0 <= digitCount ? ++_i : --_i) {
        if (Math.pow(10, digitCount - i) < MAX_VALUES) {
          needToSkipDigits.push(i);
        }
      }
      last = this.value.toString().split('').reverse();
      lastFrame = frames[frames.length - 1];
      _results = [];
      for (_j = 0, _len = frames.length; _j < _len; _j++) {
        curFrame = frames[_j];
        digits = curFrame.toString().split('').reverse();
        _results.push((function() {
          var _k, _len1, _ref, _results1;
          _results1 = [];
          for (i = _k = 0, _len1 = digits.length; _k < _len1; i = ++_k) {
            digit = digits[i];
            if (__indexOf.call(needToSkipDigits, i) < 0 || digit !== last[i] || curFrame === lastFrame) {
              if (curFrame === lastFrame) {
                value = digit;
              } else {
                value = (_ref = last[i]) != null ? _ref : '';
              }
              numEl = createFromHTML(renderTemplate(VALUE_HTML, {
                value: value
              }));
              if (curFrame === lastFrame) {
                numEl.className += ' odometer-terminal-value';
              }
              if (!this.digits[i]) {
                this.digits[i] = this.renderDigit();
                this.odometer.insertBefore(this.digits[i], this.odometer.children[0]);
              }
              this.digits[i].querySelector('.odometer-ribbon-inner').appendChild(numEl);
              _results1.push(last[i] = digit);
            } else {
              _results1.push(void 0);
            }
          }
          return _results1;
        }).call(this));
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

  odo.update(52316);

}).call(this);
