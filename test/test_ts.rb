require "test/unit"
require "ts"

class TSTest < Test::Unit::TestCase

  def setup
    raw = (1..1000).map { |i|
      [i * 1000, i.to_f]
    }
    @ts = TS.new(raw)
  end

  def test_init
    assert_equal 1000, @ts.size
  end

  def test_enum
    assert_equal 1000, @ts.count
  end

  def test_stats
    assert_equal 1, @ts.stats[:min]
    assert_equal 1000, @ts.stats[:max]
    assert_equal 1000, @ts.stats[:num]
    assert_equal (1000 * (1000 + 1)) / 2, @ts.stats[:sum]
    assert_in_delta 288, @ts.stats[:stddev], 1.0
    assert_in_delta 500, @ts.stats[:mean], 1.0
  end

  def test_slice
    assert_equal 3, @ts.slice(1000, 3000).size
  end

  def test_after
    assert_equal 999, @ts.after(1000).size
  end

  def test_before
    assert_equal 1, @ts.before(2000).size
  end

  def test_timestamps
    assert_equal 1000, @ts.timestamps.size
  end

  def test_values
    assert_equal 1000, @ts.values.last
  end

  def test_regression
    assert_in_delta 0.001, @ts.regression[:slope], 0.001
    assert_in_delta 1.0, @ts.regression[:r2], 0.01
    assert_in_delta 0.0, @ts.regression[:y_intercept], 0.1
  end

  def test_collect
    assert @ts.map { |t, v| [t, v * 2] }.stats[:min] == 2
  end

  def test_sma
    assert_equal [2000, 2], @ts.data[1]
    assert_equal [2000, 1.5], @ts.sma(7).data[1]
  end

  def test_projection
    assert_equal 5000, @ts.projected_value(5000000)
  end

  def test_projection_time
    assert_equal 5000000, @ts.projected_time(5000)
    assert_equal -1000, @ts.projected_time(-1)
  end

end