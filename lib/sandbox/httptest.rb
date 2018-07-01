class Sandbox::Httptest

  def initialize(url)
    @url = url
  end

  def sendrequest()
    @response = HTTP.get(@url)
  end

  def getresponsecode()
    return @response.code
  end

  def getresponsebody()
    return @response.to_s
  end 

end

require "http"
