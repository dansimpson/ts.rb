### ts.rb

Utility class for time series data, which does not require periodicity.

##### Install

```
gem install ts
```

##### Usage

```ruby
require "ts"

ts = TS.new([
  [time, value],
  # ...
  [time, value]
])

ts.each { |time, value|
  #...
}

ts.stats
ts.slice start, finish
ts.after time
ts.before time
```

See rdoc for all methods.