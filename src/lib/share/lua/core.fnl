(fn reduce [f i c]
  (var accum (or i {}))
  (each [_ v (ipairs c)]
    (f accum v))
  accum)

(fn reduce-kv [f i c]
  (var accum (or i {}))
  (each [k v (pairs c)]
    (f accum k v))
  accum)

(fn map [f c]
  (reduce (fn [a v] (table.insert a (f v))) {} c))

(fn map-indexed [f c]
  (reduce (fn [a k v] (table.insert a (f k v))) {} c))

(fn filter [f c]
  (reduce
   (fn [a v]
     (when (f v)
       (table.insert a v)))
   {} c))

(fn first [c]
  (. c 1))

(fn second [c]
  (. c 2))

(fn nth [c i]
  (. c i))

(fn inc [x]
  (+ x 1))

(fn dec [x]
  (- x 1))

(fn pos? [x]
  (> x 0))

(fn even? [x]
  (= 0 (% x 2)))

(fn odd? [x]
  (not= 0 (% x 2)))

(fn zero? [x]
  (= 0 x))

(fn empty? [c]
  (= 0 (length c)))

(fn count [c]
  (length c))

(fn range* [start end step]
  (var out {})
  (for [i start end step]
    (table.insert out i))
  out)

(fn range [start end ...]
  (if (empty? [...])
      (range* start end 1)
      (range* start end (first [...]))))

(fn keys [t]
  (reduce-kv (fn [a k _] (table.insert a k)) [] t))

(fn vals [t]
  (reduce-kv (fn [a _ v] (table.insert a v)) [] t))

{:map map
 :map-indexed map-indexed
 :reduce reduce
 :reduce-kv reduce-kv
 :filter filter
 :first first
 :second second
 :nth nth
 :inc inc
 :dec dec
 :range range
 :pos? pos?
 :even? even?
 :odd? odd?
 :zero? zero?
 :empty? empty?
 :count count
 :keys keys
 :vals vals}
