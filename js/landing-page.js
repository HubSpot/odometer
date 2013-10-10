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
          source: ''
        }
      ]
    }, {
      name: 'car',
      odometerOptions: {
        format: 'd'
      },
      numbers: [
        {
          number: 89930,
          description: 'miles driven',
          detail: 'by the average american each year',
          source: 'http://www.fhwa.dot.gov/ohim/onh00/bar8.htm'
        }, {
          number: 90000,
          description: 'flat tires',
          detail: 'experienced by american drivers each year',
          source: ''
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
          source: ''
        }
      ]
    }, {
      name: 'train-station',
      numbers: [
        {
          number: 123,
          description: 'train cars',
          detail: 'on the longest train in america',
          source: ''
        }, {
          number: 456,
          description: 'late trains',
          detail: 'in america each day',
          source: ''
        }
      ]
    }
  ];

  animateHeader = function() {
    return $('.title-number-section .odometer').addClass('odometer-animating-up odometer-animating');
  };

  setupOnePageScroll = function() {
    return $(function() {
      return $('.main').onepage_scroll({
        sectionContainer: '.section'
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
