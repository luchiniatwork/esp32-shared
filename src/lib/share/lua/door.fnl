(fn parse-raw-state [pin-value pin-mode actuation-mode]
  (let [target (if (= pio.PULLDOWN pin-mode) 1 0)
        circuit-closed? (= target pin-value)]
    (match actuation-mode
      :NO (if circuit-closed? :open :closed)
      :NC (if circuit-closed? :closed :open))))

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
  (let [open-event (event.create)
        close-event (event.create)]
    (var state nil)
    (thread.start
     (fn []
       (let [door-pin (. opts :door-pin)
             pin-mode (. opts :pin-mode)
             actuation-mode (. opts :actuation-mode)]
         (pio.pin.setdir pio.INPUT door-pin)
         (pio.pin.setpull pin-mode door-pin)
         (set state (parse-raw-state (pio.pin.getval door-pin)
                                     pin-mode
                                     actuation-mode))
         (while true
           (let [new-state (parse-raw-state (pio.pin.getval door-pin)
                                            pin-mode
                                            actuation-mode)]
             (when (not= state new-state)
               (set state new-state)
               (match new-state
                 :closed (close-event:broadcast)
                 :open (open-event:broadcast)))
             ;;(tmr.delayms 200)
             )))))
    {:open-event open-event
     :close-event close-event
     :get-state (fn [] state)}))

{:start start}
