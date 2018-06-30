class Sandbox

  def self.test(url = "http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml")
    @url = url
    puts "URL is " + @url
    httptest = Httptest.new(@url)
    httptest.dosomething
  end

  def self.request()
    httptest = Httptest.new(@url)
    httptest.sendrequest
    httptest.getresponsecode
    httptest.getresponsebody
  end  

end

require 'sandbox/httptest'
