(fn parse-raw-state [pin-value pin-mode]
  (let [target (if (= pio.PULLDOWN pin-mode) 1 0)]
    (if (= target pin-value) :down :up)))

(fn start
  [opts]
  "Starts a button switch. Input is a table with:

- `:button-pin` - the pin where this button is connected (i.e. `pio.GPIO4`)

- `:pin-mode` - whether the pin is connected to 3v3 (`pio.PULLDOWN`)
  or to GND (`pio.PULLUP`)

Returns three events `down-event`, triggered when the button is
depressed, `up-event`, triggered when the button is released, and
`press-event`, triggered with a full cycle of down->up.

The returned function `get-state` returns either `:down` or `:up` of
the current state of the button."
  (let [down-event (event.create)
        up-event (event.create)
        press-event (event.create)]
    (var state nil)
    (thread.start
     (fn []
       (let [button-pin (. opts :button-pin)
             pin-mode (. opts :pin-mode)]
         (pio.pin.setdir pio.INPUT button-pin)
         (pio.pin.setpull pin-mode button-pin)
         (set state (parse-raw-state (pio.pin.getval button-pin)
                                     pin-mode))
         (while true
           (let [new-state (parse-raw-state (pio.pin.getval button-pin)
                                            pin-mode)]
             (when (and (= :up state) (= :down new-state))
               (down-event:broadcast)
               (set state new-state))
             (when (and (= :down state) (= :up new-state ))
               (up-event:broadcast)
               (press-event:broadcast)
               (set state new-state)))
           ;;(tmr.delayms 200)
           ))))
    {:down-event down-event
     :up-event up-event
     :press-event press-event
     :get-state (fn [] state)}))

{:start start}
