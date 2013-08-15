#
# TS
#
# Utility class for [timestamp, number] tuples, where periodicity is not
# guaranteed.
#
class TS

  Version = "1.0.0"

  include Enumerable

  attr_reader :data

  # +data+ an array of [timestamp/time, number] tuples
  def initialize data
    if data.nil?
      raise "Cannot instantiate timeseries without data"
    end

    @data = data
  end

  # The number of elements in the set
  def size
    @data.size
  end

  # see Enumerable
  def each
    @data.each { |v| yield *v }
  end

  # map the [time,value] tuples into other [time,value] tuples
  def map
    TS.new(@data.map { |v| yield *v })
  end

  def stats
    return @stats if @stats

    min  = Float::MAX
    max  = Float::MIN
    sum  = 0.0
    sum2 = 0.0
  
    each { |time, val|
      min = val if val < min
      max = val if val > max
      sum = sum + val
      sum2 = sum2 + val ** 2
    }

    @stats = {
      :num => size,
      :min => min,
      :max => max,
      :sum => sum,
      :mean => sum / size,
      :stddev => Math.sqrt((sum2 / size) - ((sum / size) ** 2))
    }
  end

  # slice a timeseries by timestamps
  # +t1+ start time
  # +t2+ end time
  def slice t1, t2
    idx1 = nearest(t1)
    idx2 = nearest(t2)

    # don't include a value not in range
    if time_at(idx1) < t1
      idx1 += 1
    end

    # slice goes up to, but doesn't include, so only
    # add if the nearest is less than
    if time_at(idx2) < t2
      idx2 += 1
    end

    TS.new(@data[idx1..idx2])
  end

  # give the timeseries with values after time
  # +time+ the time boundary
  def after time
    idx = nearest(time)
    if time_at(idx) <= time
      idx += 1
    end

    TS.new(@data[idx..-1])
  end

  # give the timeseries with values before time
  # +time+ the time boundary
  def before time
    idx = nearest(time)
    if time_at(idx) < time
      idx += 1
    end

    TS.new(@data[0..idx-1])
  end

  def value_at idx
    @data[idx].last
  end

  def time_at idx
    @data[idx].first
  end

  # find the nearest idx for a given time 
  # using a fuzzy binary search
  def nearest time
    bsearch time, 0, size - 1
  end

  def timestamps
    @data.transpose.first
  end

  def values
    @data.transpose.last
  end

  # Run a regression and calculate r, r2, the slope, and intercept
  def regression
    return @regression if @regression

    times, values = @data.transpose

    t_mean = times.reduce(:+) / size
    v_mean = values.reduce(:+) / size

    slope = (0..size - 1).inject(0) { |sum, n|
      sum + (times[n] - t_mean) * (values[n] - v_mean)
    } / times.inject { |sum, n|
      sum + (n - t_mean) ** 2
    }

    # now r2
    r = slope * (stddev(times) / stddev(values))

    @regression = {
      :r2 => r ** 2,
      :slope => slope,
      :y_intercept => v_mean - (slope * t_mean)
    }
  end

  private

  # Find the nearest index for a given time (fuzzy search)
  def bsearch time, idx1, idx2
    mid = ((idx2 - idx1) / 2.0).floor.to_i + idx1
    if idx1 == mid
      diff1 = (time_at(idx1) - time).abs
      diff2 = (time_at(idx2) - time).abs
      diff2 > diff1 ? idx1 : idx2
    elsif time < time_at(mid)
      bsearch time, idx1, mid
    elsif time > time_at(mid)
      bsearch time, mid, idx2
    else
      mid
    end
  end

  def stddev data
    sum  = 0.0
    sum2 = 0.0
    data.each { |v|
      sum  += v
      sum2 += v ** 2
    }
    Math.sqrt(sum2 / data.size - (sum / data.size) ** 2)
  end

end