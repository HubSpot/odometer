(function() {
  var DIGIT_HTML, DURATION, FRAMERATE, FRAMES_PER_VALUE, MAX_VALUES, MS_PER_FRAME, ODOMETER_HTML, OVERSAMPLE, Odometer, RIBBON_HTML, VALUE_HTML, createFromHTML, el, odo, renderTemplate,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  ODOMETER_HTML = '<div class="odometer"></div>';

  DIGIT_HTML = '<span class="odometer-digit"><span class="odometer-digit-spacer">8</span><span class="odometer-digit-inner"></span></span>';

  RIBBON_HTML = '<span class="odometer-ribbon"><span class="odometer-ribbon-inner"></span></span>';

  VALUE_HTML = '<span class="odometer-value">{value}</span>';

  FRAMERATE = 60;

  DURATION = 2000;

  FRAMES_PER_VALUE = 2;

  OVERSAMPLE = 2;

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

    Odometer.prototype.addAnimateValue = function(i, value, last) {
      var numEl;
      numEl = createFromHTML(renderTemplate(VALUE_HTML, {
        value: value
      }));
      if (last) {
        numEl.className += ' odometer-terminal-value';
      }
      if (!this.digits[i]) {
        this.digits[i] = this.renderDigit();
        this.odometer.insertBefore(this.digits[i], this.odometer.children[0]);
      }
      return this.digits[i].querySelector('.odometer-ribbon-inner').appendChild(numEl);
    };

    Odometer.prototype.animate = function(newValue) {
      var boringDigits, changePerFrame, counter, cur, curFrame, diff, digit, digitCount, digitScale, digits, fraction, frames, i, incr, last, lastFrame, needToScaleDigits, needToSkipDigits, _i, _j, _k, _l, _len, _len1, _len2, _m, _n;
      diff = newValue - this.value;
      frames = [];
      if (Math.abs(diff) > MAX_VALUES) {
        incr = diff / (OVERSAMPLE * MAX_VALUES);
      } else {
        incr = diff > 0 ? 1 : -1;
      }
      cur = this.value;
      while ((diff > 0 && cur <= newValue) || (diff < 0 && cur >= newValue)) {
        cur += incr;
        frames.push(Math.round(cur));
      }
      digitCount = Math.ceil(Math.log(newValue) / Math.log(10));
      needToSkipDigits = [];
      needToScaleDigits = [];
      changePerFrame = diff / MAX_VALUES;
      for (i = _i = 0; 0 <= digitCount ? _i < digitCount : _i > digitCount; i = 0 <= digitCount ? ++_i : --_i) {
        if (changePerFrame / Math.pow(10, i) < 1) {
          needToSkipDigits.push(i);
        } else if (i !== 0) {
          needToScaleDigits.push(i);
        }
      }
      counter = {};
      digitScale = {};
      for (_j = 0, _len = needToScaleDigits.length; _j < _len; _j++) {
        digit = needToScaleDigits[_j];
        fraction = 1 - digit / needToScaleDigits.length;
        digitScale[digit] = fraction * (1 - 1 / OVERSAMPLE) + 1 / OVERSAMPLE;
      }
      console.log(digitScale);
      boringDigits = [];
      for (i = _k = 0; 0 <= digitCount ? _k < digitCount : _k > digitCount; i = 0 <= digitCount ? ++_k : --_k) {
        boringDigits.push(true);
      }
      last = this.value.toString().split('').reverse();
      lastFrame = frames[frames.length - 1];
      for (_l = 0, _len1 = frames.length; _l < _len1; _l++) {
        curFrame = frames[_l];
        digits = curFrame.toString().split('').reverse();
        for (i = _m = 0, _len2 = digits.length; _m < _len2; i = ++_m) {
          digit = digits[i];
          if (last[i] !== digit) {
            boringDigits[i] = false;
          }
          console.log(i, __indexOf.call(needToSkipDigits, i) >= 0, digit === last[i], curFrame !== lastFrame);
          if (__indexOf.call(needToSkipDigits, i) >= 0 && digit === last[i] && (curFrame !== lastFrame || boringDigits[i])) {
            continue;
          }
          if (curFrame !== lastFrame && (digitScale[i] != null) && digitScale[i] < Math.random()) {
            continue;
          }
          if (counter[i] == null) {
            counter[i] = 0;
          }
          counter[i]++;
          this.addAnimateValue(i, last[i], curFrame === lastFrame && digit === last[i]);
          if (digit !== last[i] && curFrame === lastFrame) {
            this.addAnimateValue(i, digit, true);
          }
          last[i] = digit;
        }
      }
      for (i = _n = 0; 0 <= digitCount ? _n < digitCount : _n > digitCount; i = 0 <= digitCount ? ++_n : --_n) {
        if (boringDigits[i]) {
          this.digits[i].querySelector('.odometer-value').className += ' odometer-terminal-value';
        }
      }
      return console.log(counter);
    };

    return Odometer;

  })();

  el = document.querySelector('div');

  odo = new Odometer({
    value: 343,
    el: el
  });

  odo.render();

  odo.update(355);

}).call(this);
