(function() {
  var DIGIT_HTML, DIGIT_SPEEDBOOST, DURATION, FRAMERATE, FRAMES_PER_VALUE, MAX_VALUES, MS_PER_FRAME, ODOMETER_HTML, Odometer, RIBBON_HTML, VALUE_HTML, createFromHTML, el, odo, renderTemplate;

  ODOMETER_HTML = '<div class="odometer"></div>';

  DIGIT_HTML = '<span class="odometer-digit"><span class="odometer-digit-spacer">8</span><span class="odometer-digit-inner"></span></span>';

  RIBBON_HTML = '<span class="odometer-ribbon"><span class="odometer-ribbon-inner"></span></span>';

  VALUE_HTML = '<span class="odometer-value">{value}</span>';

  FRAMERATE = 60;

  DURATION = 2000;

  FRAMES_PER_VALUE = 2;

  DIGIT_SPEEDBOOST = .5;

  MS_PER_FRAME = 1000 / FRAMERATE;

  MAX_VALUES = ((DURATION / MS_PER_FRAME) / FRAMES_PER_VALUE) | 0;

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
      this.ribbons = {};
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
      var boosted, cur, diff, digitCount, digits, dist, end, frame, frames, i, incr, j, numEl, start, _base, _i, _j, _k, _l, _len, _len1, _ref, _results, _results1;
      diff = newValue - this.value;
      digitCount = Math.ceil(Math.log(Math.max(newValue, this.value)) / Math.log(10));
      digits = [];
      boosted = 0;
      for (i = _i = 0; 0 <= digitCount ? _i < digitCount : _i > digitCount; i = 0 <= digitCount ? ++_i : --_i) {
        start = Math.floor(this.value / Math.pow(10, digitCount - i - 1));
        end = Math.floor(newValue / Math.pow(10, digitCount - i - 1));
        dist = end - start;
        if (Math.abs(dist) > MAX_VALUES) {
          frames = [];
          incr = dist / (MAX_VALUES + MAX_VALUES * boosted * DIGIT_SPEEDBOOST);
          cur = start;
          while ((dist > 0 && cur < end) || (dist < 0 && cur > end)) {
            cur += incr;
            frames.push(Math.round(cur));
          }
          frames.push(end);
          boosted++;
        } else {
          frames = (function() {
            _results = [];
            for (var _j = start; start <= end ? _j <= end : _j >= end; start <= end ? _j++ : _j--){ _results.push(_j); }
            return _results;
          }).apply(this);
        }
        for (i = _k = 0, _len = frames.length; _k < _len; i = ++_k) {
          frame = frames[i];
          frames[i] = frame % 10;
        }
        digits.push(frames);
      }
      _ref = digits.reverse();
      _results1 = [];
      for (i = _l = 0, _len1 = _ref.length; _l < _len1; i = ++_l) {
        frames = _ref[i];
        if (!this.digits[i]) {
          this.digits[i] = this.renderDigit();
          this.odometer.insertBefore(this.digits[i], this.odometer.children[0]);
        }
        if ((_base = this.ribbons)[i] == null) {
          _base[i] = this.digits[i].querySelector('.odometer-ribbon-inner');
        }
        this.ribbons[i].innerHTML = '';
        if (diff < 0) {
          frames = frames.reverse();
        }
        _results1.push((function() {
          var _len2, _m, _results2;
          _results2 = [];
          for (j = _m = 0, _len2 = frames.length; _m < _len2; j = ++_m) {
            frame = frames[j];
            numEl = createFromHTML(renderTemplate(VALUE_HTML, {
              value: frame
            }));
            this.ribbons[i].appendChild(numEl);
            if (j === frames.length - 1) {
              _results2.push(numEl.className += ' odometer-last-value');
            } else {
              _results2.push(void 0);
            }
          }
          return _results2;
        }).call(this));
      }
      return _results1;
    };

    return Odometer;

  })();

  el = document.querySelector('div');

  odo = new Odometer({
    value: 343,
    el: el
  });

  odo.render();

  odo.update(225);

}).call(this);
