## Themes

To use a builtin theme, simply include the theme style sheet:

```html
<link rel="stylesheet" href="odometer-theme-default.css" />
```

<table class="hs-table">
<tr>
<th>Name</th>
<th>Theme</th>
<th></th>
</tr>
<tbody>
<tr><td>Default</td><td><a href="https://raw.github.com/HubSpot/odometer/master/themes/odometer-theme-default.css">`default`</a></td><td><div class="odometer-theme-example"><div data-theme="default"><div></div></td></tr>
<tr><td>Minimal</td><td><a href="https://raw.github.com/HubSpot/odometer/master/themes/odometer-theme-minimal.css">`minimal`</a></td><td><div class="odometer-theme-example"><div data-theme="minimal"><div></div></td></tr>
<tr><td>Car</td><td><a href="https://raw.github.com/HubSpot/odometer/master/themes/odometer-theme-car.css">`car`</a></td><td><div class="odometer-theme-example"><div data-theme="car"><div></div></td></tr>
<tr><td>Plaza</td><td><a href="https://raw.github.com/HubSpot/odometer/master/themes/odometer-theme-plaza.css">`plaza`</a></td><td><div class="odometer-theme-example"><div data-theme="plaza"><div></div></td></tr>
<tr><td>Slot Machine</td><td><a href="https://raw.github.com/HubSpot/odometer/master/themes/odometer-theme-slot-machine.css">`slot-machine`</a></td><td><div class="odometer-theme-example"><div data-theme="slot-machine"><div></div></td></tr>
<tr><td>Train Station</td><td><a href="https://raw.github.com/HubSpot/odometer/master/themes/odometer-theme-train-station.css">`train-station`</a></td><td><div class="odometer-theme-example"><div data-theme="train-station"><div></div></td></tr>
<tr><td>Digital</td><td><a href="https://raw.github.com/HubSpot/odometer/master/themes/odometer-theme-digital.css">`digital`</a></td><td><div class="odometer-theme-example"><div data-theme="digital"><div></div></td></tr>
</tbody>
</table>

### Multiple Themes on One Page

If you need to use multipled Odometer themes on a single page, do the following.

```javascript
odometerOptions = { auto: false }; // Disables auto-initialization

// For each odometer, initialize with the theme passed in:
var odometer = new Odometer({ el: $('.odometer')[0], value: 123, theme: 'car' });
odometer.render();
```

<!-- Resources for the demos -->
<p style="-webkit-transform: translateZ(0)"></p>
<link rel="stylesheet" href="/odometer/themes/odometer-theme-minimal.css" />
<script>
    odometerOptions = { auto: false };
</script>
<style>
    .odometer-theme-example {
        font-size: 40px;
        line-height: 60px;
    }
</style>
<link rel="stylesheet" href="/odometer/themes/odometer-theme-default.css" />
<link rel="stylesheet" href="/odometer/themes/odometer-theme-car.css" />
<link rel="stylesheet" href="/odometer/themes/odometer-theme-slot-machine.css" />
<link rel="stylesheet" href="/odometer/themes/odometer-theme-plaza.css" />
<link rel="stylesheet" href="/odometer/themes/odometer-theme-train-station.css" />
<link rel="stylesheet" href="/odometer/themes/odometer-theme-digital.css" />
<script src="/odometer/odometer.js"></script>
<script>
    (function(){
        $('[data-theme]').each(function(){
            var v = 123456;
            var o = new Odometer({
                el: this,
                value: 123456,
                theme: $(this).data('theme')
            });
            o.render();
            setInterval(function(){
                o.update(v++);
            }, 3000);
        });
    })();
</script>
