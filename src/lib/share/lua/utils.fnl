(fn listen
  [event handler]
  (thread.start
   (fn []
     (while true
       (: event :wait)
       (handler)
       (: event :done)))))

{:listen listen}
