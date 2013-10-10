Odometer
========

<style>
.odometer-github-stars {
  margin-bottom: 6px;
}
.odometer-github-stars .odometer-label {
  background: #eee;
  display: inline-block;
  padding: 15px 13px 13px;
  line-height: 1;
  vertical-align: middle;
  border-radius: 4px 0 0 4px;
}
.odometer-github-stars .odometer {
  background: #444;
  color: #fff;
  padding: 13px 21px 11px;
  margin: auto;
  line-height: 1 !important;
  border-radius: 0 4px 4px 0;
}
.odometer-github-stars + p {
  display: none;
}
.odometer-subtitle {
  padding-left: 13px;
  opacity: 0.7;
}
</style>

<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
<link rel="stylesheet" href="https://rawgithub.com/HubSpot/odometer/master/themes/odometer-theme-default.css" />
<script src="https://rawgithub.com/HubSpot/odometer/master/odometer.min.js"></script>
<script>
  update = function(){
    $.ajax("https://api.github.com/repos/HubSpot/odometer", {
      success: function(data){
        if (data.watchers_count)
          document.querySelector('.odometer').innerHTML = data.watchers_count;
      },
      complete: function(){
        setTimeout(update, 2000);
      }
    });
  };

  setTimeout(update, 1000);
</script>

<h3 class="odometer-github-stars"><span class="odometer-label">GitHub ★ s so far:</span><div class="odometer">0</div></h3>
<div class="odometer-subtitle"><a href="http://github.com/HubSpot/odometer" target="_blank">Star odometer</a> on GitHub to to see it update.</div>

Odometer is a Javascript and CSS library for smoothly transitioning numbers.
See the [demo page](http://github.hubspot.com/odometer/docs/welcome) for some examples.

Odometer's animations are handled entirely in CSS using transforms making
them extremely performant, with automatic fallback on older browsers.

The library and largest theme is less than 3kb when minified and compressed.

All of the themes can be resized by setting the `font-size` of the `.odometer` element.

Usage
-----

**The simplest possible usage is just including [the javascript](https://raw.github.com/HubSpot/odometer/v0.3.3/odometer.min.js) and a theme css
file on your page.  Add the `odometer` class to any numbers you'd like to animate on change.  You're done.**

Just set the `innerHTML`, `innerText`, or use jQuery's `.text()` or `.html()` methods to change their contents, and the animation
will happen automatically.  Any libraries you're using to update their value, provided they don't update by erasing and rerendering
the `odometer` element, will work just fine.

On older browsers, it will automatically fallback to a simpler animation which won't tax their fragile javascript runtime.

Advanced
--------

If you need to, you can set options by creating a `odometerOptions` object:

```javascript
window.odometerOptions = {
  auto: false, // Don't automatically initialize everything with class 'odometer'
  selector: '.my-numbers', // Change the selector used to automatically find things to be animated
  format: '.ddd', // Change how digit groups are formatted
  duration: 3000, // Change how long the javascript expects the CSS animation to take
  theme: 'car' // Specify the theme (if you have more than one theme css file on the page)
};
```

You can manually initialize an odometer with the global `Odometer`:

```javascript
var el = document.querySelector('.some-element');

od = Odometer({
  el: el,
  value: 333555,
  format: '',
  theme: 'digital'
});

od.update(555)
// or
el.innerHTML = 555
```

Browser Support
---------------

Odometer is intended to support IE8+, FF4+, Chrome and Safari.

Dependencies
------------

None!

Contributing
------------

Odometer is built using Grunt.  To setup the build environment you first
must have Node.js installed.  Then:

```bash
# In the project directory
npm install
```

To build the project:
```bash
grunt
```

To have it watch for changes and build automatically:
```bash
grunt watch
```

We welcome pull requests!
