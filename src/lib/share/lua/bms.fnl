(fn parse-raw-state [raw total-battery-voltage threshold-voltage]
  (let [voltage (* (/ raw 4095) 4.5)]
    {:voltage voltage
     :state (if (> voltage threshold-voltage)
                :normative :low)}))

(fn start
  [opts]
  "Starts a thread for a door contact switch. Input is a table with:

- `:door-pin` - the pin where this dooor is
connected (i.e. `pio.GPIO4`)

- `:pin-mode` - whether the pin is connected to 3v3 (`pio.PULLDOWN`)
  or to GND (`pio.PULLUP`)

- `:actuation-mode` - either :NO or :NC (:NO is normally open i.e. the
contacts are normally open and close when the switch is actuated. :NC
is normally closed i.e. the contacts are normally closed and open when
the switch is actuated.

Returns two events `open-event`, triggered when the door is open and
`close-event`, triggered when the door is close.

The returned function `get-state` returns either `:open` or `:closed`
of the current state of the door."
  (let [low-battery-event (event.create)]
    (var state nil)
    (thread.start
     (fn []
       (let [battery-pin (. opts :battery-pin)
             total-battery-voltage (. opts :total-battery-voltage)
             threshold-voltage (. opts :threshold-voltage)
             delay (or (. opts :delay) 5)
             channel (adc.attach adc.ADC1 battery-pin)]
         (pio.pin.setdir pio.INPUT battery-pin)
         (pio.pin.setpull pio.NOPULL battery-pin)
         (while true
           (let [new-state (parse-raw-state (channel:read)
                                            total-battery-voltage
                                            threshold-voltage)]
             (set state new-state)
             (when (= :low (. state :state))
               (low-battery-event:broadcast))
             (tmr.delay delay))))))
    {:low-battery-event low-battery-event
     :get-state (fn [] state)}))

{:start start}
