class Sandbox

  @defaultDataFilename = "data.txt"
  @defaultConfigFilename = "config.txt"
  @defaultUrl = "http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml"
  
  @rawXMLFromFile = ""
  @configData = {}
  @fxData = {}

  def self.request(url = @defaultUrl)    
    done = false 
    loopCount = 0
    while !done do
      httptest = Httptest.new(url)
      httptest.sendrequest
      if (httptest.getresponsecode == 200)      
        #only updates the stored data if a valid response is received      
        Fileutils.writefile(httptest.getresponsebody,@defaultDataFilename)
        updateConfig('readdate', Date.today.strftime("%Y-%m-%d"))
        updateConfig('url',url)
        updateConfig('readurl',url)
        writeConfigData	
        done = true
      end
      if (!done)
        sleep 2
        loopCount += 1
        #tries 3 times then gives up
        done = true if loopCount == 3
      end
    end    
  end  

  def self.at(date,base,counter)

    #first, validate the date, base and counter currencies.
    validateDate(date)
    validateCurrency(base)
    validateCurrency(counter)

    #Read the config file into the @configData hash
    readConfig()

    #Request fresh data from the server if it's out of date or doesn't exist
    if (!checkConfigData(date) || !Fileutils.fileexist(@defaultDataFilename))
      request(getConfig('url'))
    end

    #We always get the conversion data from our stored file
    @RawXMLFromFile = Fileutils.readfile(@defaultDataFilename)      
    @fxData = Xmlparser.processxml(@RawXMLFromFile)
    #After all this we have a hash we can query for the date and then the conversion
    baseRate = getRate(date, base)
    counterRate = getRate(date, counter)   
    return getConversion(baseRate,counterRate)

  end

  def self.getRate(date, currency)
    dateKey = date.strftime("%Y-%m-%d")
    if (@fxData.has_key?(dateKey))
      return @fxData[dateKey][currency]
    else
      return ""
    end    
  end

  def self.getConversion(from, to)
    if (from == "" || to == "")
      return 0 #returning zero may not be ideal but probably better than returning nil
    else
      return (to.to_f / from.to_f).round(4)
    end 
  end

  def self.validateDate(date)
    return false if (date > Date.today || date < Date.today - 29)    
  end

  def self.validateCurrency(currency)
    return true #for the moment
  end

  def self.updateUrl(url)
    updateConfig('url',url)
    writeConfigData
  end

  def self.readConfig()
    if (Fileutils.fileexist(@defaultConfigFilename))
      data =  Fileutils.readfile(@defaultConfigFilename)
      #convert the supplied csv data to a hash    
      seplines = data.split(/\n+/)
      seplines.each{|x| @configData[x.split(',')[0]] = x.split(',')[1]}
    end
    #set defaults if the values from file don't make sense
    updateConfig('url', @defaultUrl) if getConfig('url') == nil
    #if there's no date for the last read, set it to 1st Jan which will force a re-read
    updateConfig('readdate','2018-01-01') if getConfig('readdate') == nil     
  end
 
  def self.writeConfigData()
    dataToWrite = ''
    @configData.each {|key,value| dataToWrite += key + "," + value + "\n"}
    Fileutils.writefile(dataToWrite,@defaultConfigFilename)
  end

  def self.checkConfigData(date)    
    #if the date of the last read is before the requested date we need to update our data
    puts getConfig('readdate')
    return false if getConfig('readdate') == ""
    #return false if (date > Date.parse(getConfig('readdate')))          
    return true #is this needed? - check.    
  end

  def self.getConfig(key)
    return @configData[key]
  end

  def self.updateConfig(key, value)
    @configData[key] = value
    puts "adding configData key "+ key + "with value "+value
    writeConfigData
  end

end

require "sandbox/httptest"
require "sandbox/fileutils"
require "sandbox/xmlparser"

