# usage:
# it "should return a result of 5" do
#   eventually { long_running_thing.result.should eq(5) }
# end
# see https://gist.github.com/mattwynne/1228927
module AsyncHelper
  def eventually(options = {})
    timeout = options[:timeout] || 2
    interval = options[:interval] || 0.1
    time_limit = Time.now + timeout
    elapsed = 0
    loop do
      begin
        yield
      rescue Exception => error
      end
      return if error.nil?
      raise error if Time.now >= time_limit
      sleep interval
    end
  end
end

