class Sandbox::Httptest

  def initialize(url)
    @url = url
  end

  def dosomething()
    puts @url    
  end 

  def sendrequest()
    @response = HTTP.get(@url)
  end

  def getresponsecode()
    puts @response.code
  end

  def getresponsebody()
    puts @response.to_s
  end 

end

require 'http'

