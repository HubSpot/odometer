(function() {
  var THEMES, animateHeader, init, setupNumberSections, setupOnePageScroll;

  THEMES = [
    {
      name: 'minimal',
      numbers: [
        {
          number: 10000,
          description: '= 28<sup>2</sup> + 96<sup>2</sup> = 60<sup>2</sup> + 80<sup>2</sup>',
          detail: 'two sums of two squares',
          source: 'http://www.wolframalpha.com/input/?i=10000'
        }, {
          number: 99999,
          description: '<span class=\'equals\'>=</span> <span class=\'number\'>11000011010011111</span><sub>2</sub>',
          detail: '11000011010011111 in base 2',
          source: 'http://www.wolframalpha.com/input/?i=99999'
        }
      ]
    }, {
      name: 'car',
      odometerOptions: {
        format: 'd'
      },
      numbers: [
        {
          number: 13476,
          description: 'miles driven',
          detail: 'by the average american each year',
          source: 'http://www.fhwa.dot.gov/ohim/onh00/bar8.htm'
        }, {
          number: 25114,
          description: 'flat tires',
          detail: 'occur in america each hour',
          source: 'http://excelmathmike.blogspot.com/2011/04/phooey-on-flats-part-i.html'
        }
      ]
    }, {
      name: 'digital',
      odometerOptions: {
        format: 'd'
      },
      numbers: [
        {
          number: 87360,
          description: 'minutes of tv watched',
          detail: 'by the average american each year',
          source: 'http://www.nationmaster.com/graph/med_tel_vie-media-television-viewing'
        }, {
          number: 20938,
          description: 'minutes snoozed',
          detail: 'by the average american each year',
          source: 'http://jsfiddle.net/adamschwartz/BWgWj/show/light/'
        }
      ]
    }, {
      name: 'slot-machine',
      numbers: [
        {
          number: 818,
          description: '',
          detail: '',
          source: ''
        }, {
          number: 777,
          description: '',
          detail: '',
          source: ''
        }
      ]
    }, {
      name: 'train-station',
      numbers: [
        {
          number: 682,
          description: 'train cars',
          detail: 'on the longest train in the world',
          source: 'http://en.wikipedia.org/wiki/Longest_trains'
        }, {
          number: 853,
          description: 'people',
          detail: 'capacity of the largest commercial airplane',
          source: 'http://en.wikipedia.org/wiki/Airbus_A380'
        }
      ]
    }
  ];

  animateHeader = function() {
    return $('.title-number-section .odometer').addClass('odometer-animating-up odometer-animating');
  };

  setupOnePageScroll = function() {
    return $(function() {
      $('.main').onepage_scroll({
        sectionContainer: '.section'
      });
      $('.down-arrow').click(function() {
        return $('.main').moveDown();
      });
      return $(document).keydown(function(e) {
        switch (e.keyCode) {
          case 40:
          case 34:
            return $('.main').moveDown();
          case 33:
          case 38:
            return $('.main').moveUp();
        }
      });
    });
  };

  setupNumberSections = function() {
    var $afterSections, $numberSectionTemplate, $numberSectionTemplateClone;
    $afterSections = $('.after-number-sections');
    $numberSectionTemplate = $('.number-section.template');
    $numberSectionTemplateClone = $numberSectionTemplate.clone().removeClass('template');
    _.each(THEMES, function(theme) {
      var $odometerContainer, $section, currentNumber, next, odometer, odometerOptions;
      $section = $numberSectionTemplateClone.clone().addClass('number-section-theme-' + theme.name);
      $afterSections.before($section);
      $odometerContainer = $section.find('.odometer-container');
      $odometerContainer.append('<div/>');
      $odometerContainer = $odometerContainer.find('div');
      currentNumber = 0;
      odometerOptions = $.extend(true, {}, theme.odometerOptions || {}, {
        theme: theme.name,
        value: theme.numbers[1].number,
        el: $odometerContainer[0]
      });
      odometer = new Odometer(odometerOptions);
      odometer.render();
      next = function() {
        var number;
        number = theme.numbers[currentNumber];
        odometer.update(number.number);
        $section.find('.number-description').html(number.description);
        $section.find('.number-detail').html(number.detail);
        $section.find('.number-source').attr('href', number.source);
        return currentNumber = (currentNumber + 1) % theme.numbers.length;
      };
      next();
      return setInterval(function() {
        if ($section.hasClass('active')) {
          return next();
        }
      }, 4 * 1000);
    });
    $afterSections.remove();
    return $numberSectionTemplate.remove();
  };

  init = function() {
    setupNumberSections();
    setupOnePageScroll();
    return setTimeout(function() {
      return animateHeader();
    }, 500);
  };

  init();

}).call(this);
