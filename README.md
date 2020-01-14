# esp32-shared

These are shared Fennel/Blackdog reusable components and libraries for
ESP32 projects.

It is to be used as a submodule in a Fennel/Blackdog project with:

``` shell
$ git submodule add git@github.com:luchiniatwork/esp32-shared.git
```

Don't forget to:

``` shell
$ git submodule init
```

Update your `watch-dir!` call to include `esp32-shared/src` and then
you'll be able to require components like this iin your Fennel code:

``` common-lisp
(global door (require :door))
(global utils (require :utils))

(local my-button (button.start {:button-pin pio.GPIO33
                                :pin-mode pio.PULLDOWN}))

(utils.listen my-button.press-event
              (fn [] (print "button pressed")))
```
