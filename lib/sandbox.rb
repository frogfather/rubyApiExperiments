require "sandbox/fileutils"
class Sandbox
  include Fileutils
  @defaultDataFilename = "data.txt"
  @defaultConfigFilename = "config.txt"
  @defaultUrl = "http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml"
  
  @rawXMLFromFile = ""
  @configData = {}
  @fxData = {}

  def self.request(url = @defaultUrl)    
    done = false 
    loopCount = 0
    httptest = Httptest.new(url)
    puts "retrieving fresh data from server"
    #try three times to get the data
    while !done do      
      httptest.sendrequest
      if (httptest.getresponsecode == 200)      
        #only updates the stored data if a valid response is received      
        Fileutils::Writefile(httptest.getresponsebody,@defaultDataFilename)
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
    return 0 if (!dateValid(date)) #check supplied date is within range. If not return 0 indicating error
    validateCurrency(base) 
    validateCurrency(counter)

    #Read the config file into the @configData hash
    readConfig()

    #Request fresh data from the server if it's out of date or doesn't exist
    if (!checkConfigData(date) || !Fileutils::Fileexist(@defaultDataFilename))
      request(getConfig('url'))
    end    

    #We always get the conversion data from our stored file
    @RawXMLFromFile = Fileutils::Readfile(@defaultDataFilename)      
    @fxData = Xmlparser.processxml(@RawXMLFromFile)
    
    #The data from the source is not updated until 12 noon and isn't updated at all at weekends. 
    #We don't want to return 0 for weekends
    #We should adjust the date to be the nearest date for which data exists
    if (!dataExists(date))
      date = adjustDate(date)
      return 0 if (!dateValid(date)) 
    end
    
    baseRate = getRate(date, base)
    counterRate = getRate(date, counter)   
    return getConversion(baseRate,counterRate)

  end

  def self.dataExists(date)
    dateKey = date.strftime("%Y-%m-%d")
    return (@fxData.has_key?(dateKey))
  end

  def self.adjustDate(date)
    done = false
    while (!done) do
      #we decrement date until either we find data or the date is invalid
      date -= 1
      done = dataExists(date) || !dateValid(date) 
    end
  puts "adjusted date to "+date.strftime("%Y-%m-%d")
  return date
  end

  def self.getRate(date, currency)
    #we should have already checked that the date has valid data, but another check here does no harm.
    dateKey = date.strftime("%Y-%m-%d")
    if (@fxData.has_key?(dateKey))
      return @fxData[dateKey][currency]
    else
      return ""
    end    
  end

  def self.getConversion(from, to)
    if (from == "" || to == "")
      return 0 #returning zero not ideal but better than returning nil and indicates problem
    else
      return (to.to_f / from.to_f).round(4)
    end 
  end

  def self.dateValid(date)
    return (date <= Date.today && date >= Date.today - 89)    
  end

  def self.validateCurrency(currency)
    return true #for the moment
  end

  def self.updateUrl(url)
    updateConfig('url',url)
    writeConfigData
  end

  def self.readConfig()
    if (Fileutils::Fileexist(@defaultConfigFilename))
      data =  Fileutils::Readfile(@defaultConfigFilename)
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
    Fileutils::Writefile(dataToWrite,@defaultConfigFilename)
  end

  def self.checkConfigData(date)    
    #if the date of the last read is before the requested date we need to update our data
    return false if getConfig('readdate') == ""
    return false if (date > Date.parse(getConfig('readdate')))          
    return false if (getConfig('url') != getConfig('readurl'))
    return true #is this needed? - check.    
  end

  def self.getConfig(key)
    return @configData[key]
  end

  def self.updateConfig(key, value)
    @configData[key] = value
    writeConfigData
  end

end

require "sandbox/httptest"
require "sandbox/xmlparser"

