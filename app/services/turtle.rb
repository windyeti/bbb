class Services::Turtle
  attr_reader :period, :max_request, :requests

  # period -- ограничение по времении, в течение которого должы быть запросы. Задается в секундах.
  # max_count_request -- ограничение по количеству запросов в период времени period.
  def initialize(period, max_request)
    @period = period*1000
    @max_request = max_request
    @requests = []
  end

  def check
    time_now = Time.now.to_f*1000
    add_request(time_now)
    cut_requests_by(time_now)
    request_count = requests.count
    p " >>> #{request_count}"
    if request_count >= max_request
      sleep_time = get_sleep_time
      requests.shift
      p "SLEEP #{(sleep_time / 1000).ceil} sec"
      p Time.now
      sleep (sleep_time / 1000).ceil
      p Time.now
      p "WORK CONTINUED"
    end
  end

  private

  def cut_requests_by(time_now)
    cut_time = time_now - period
    @requests = requests.select {|time| time >= cut_time}
  end

  def get_sleep_time
    diff = requests.last - requests.first
    period - diff
  end

  def requests=(reqs)
    @requests = reqs
  end

  def add_request(value)
    @requests.push value
    p " +++ #{@requests.count}"
  end
end
