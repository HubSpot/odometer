Odometer
========

Odometer is javascript and CSS for smoothly transitioning numbers.
See the [demo page](http://github.hubspot.com/odometer/docs/welcome) for some examples.

Odometer's animations are handled entirely in CSS using CSS transforms making
them extremely performant.

Usage
-----

The simplest possible usage is just including [the javascript](http://github.com/HubSpot/odometer/odometer.min.js) and a theme css
file on your page.  Add the `odometer` class to any numbers you'd like to animate on change.  *You're done.*

Just set the `innerHTML`, `innerText`, or use jQuery's `.text()` or `.html()` methods to change their contents, and the animation
will happen automatically.  Any libraries you're using to update their value, provided they don't update by erasing and rerendering
the `odometer` element, will work just fine.

On older browsers, it will automatically fallback to a simpler animation which won't tax their fragile javascript runtime.

Advanced
--------

If you need to, you can set options by creating a `odometerOptions` object before bringing in the odometer source.

```javascript
window.odometerOptions = {
  auto: false, // Don't automatically initialize everything with class 'odometer'
  selector: '.my-numbers', // Change the selector used to automatically find things to be animated
  format: '.ddd', // Change how digit groups are formatted
  duration: 3000, // Change how long the javascript expects the CSS animation to take
  theme: 'car' // Specify the theme (if you have more than one theme css file on the page)
};

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
