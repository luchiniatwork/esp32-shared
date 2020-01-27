(fn parse-raw-state [raw total-battery-voltage threshold-voltage]
  (let [voltage (* (/ raw 4095) 4.5)]
    {:voltage voltage
     :state (if (> voltage threshold-voltage)
                :normative :low)}))

(fn start
  [opts]
  "Starts a thread for a battery management system (BMS). The signal
  expected is on an ADC-capable pin from 0V to 3.3V (max 3.6V). It is
  recommended that your battery source is plugged to a divider in
  order to achieve this range. The BMS will take care of the math.

Input is a table with:

- `:battery-pin` - the pin where this is connected (i.e. `pio.GPI34`)

- `:total-battery-voltage` - the total amount in volts of the battery
  pack you currently have in your system (i.e. 3.7 or 4.5, etc)

- `:threshold-voltage` - the voltage that will trigger a low battery
  event (i.e. 3.3)

- `:delay` - delay in seconds between each read (default is 5)

- `:core` - which CPU core to use (defaults to 0)

Returns a `low-battery-event`, triggered when the battery level
reaches the threshold voltage.

The returned function `get-state` returns either a table indicating
the last `:voltage` and the `:state` (either `:normative` or `:low`)"
  (let [low-battery-event (event.create)
        battery-pin (. opts :battery-pin)
        total-battery-voltage (. opts :total-battery-voltage)
        threshold-voltage (. opts :threshold-voltage)
        delay (or (. opts :delay) 5)
        core (or (. opts :core) 0)
        channel (adc.attach adc.ADC1 battery-pin)]
    (var state nil)
    (thread.start
     (fn []
       (pio.pin.setdir pio.INPUT battery-pin)
       (pio.pin.setpull pio.NOPULL battery-pin)
       (while true
         (let [new-state (parse-raw-state (channel:read)
                                          total-battery-voltage
                                          threshold-voltage)]
           (set state new-state)
           (when (= :low (. state :state))
             (low-battery-event:broadcast))
           (tmr.delay delay))))
     2048 20 core "bms")
    {:low-battery-event low-battery-event
     :get-state (fn [] state)}))

{:start start}
