class Sandbox::Xmlparser

  def self.processxml(data)    
    #data is raw xml data from file
    processedxml = removeheader(data)
    processedxml = removeenvelope(processedxml)
    #Now we have 30 days data separated by the newline character
    dataByDate =  processedxml.split("\n")
    #The data is now in an array with each element representing a single day's data
    return arrayToHash(dataByDate)
    #The returned data is a hash (key = date, value = hash (key = country, value = rate))
  end  

  def self.removeheader(data)
    #removes everything before the data
    return data[data.index('</gesmes:Sender>')+22..-1]
  end

  def self.removeenvelope(data)
    return data[0..data.index('</gesmes:Envelope>')-8]
    #removes the last line 
  end

  def self.arrayToHash(array)
    resulthash = Hash.new
    dayhash = Hash.new
    array.each do
    #each element of the array contains data for one day.
      |dateblock| entries = dateblock.gsub("\"",' ').split('<Cube ').reject{|s| s.empty?}
      dayhash.clear
      dateValue = ""
      entries.each do |entry| 
	#each element of entries contains a country and exchange rate except the first which contains the date
        #the first element contains the date          
	if (entry.include?('time'))
	  dateValue = extractSubstring(entry,6,15)
	else
          currencyName = extractSubstring(entry,10,12)
	  currencyRate = extractSubstring(entry,21,26)
	  dayhash[currencyName] = currencyRate
	end
      end
    #All the entries are referenced to EUR so it doesn't appear in the list. To make calculations simpler lets add it here
    dayhash['EUR'] = '1.0000'
    resulthash[dateValue] = dayhash    
    end
  return resulthash
  end

  def self.extractSubstring(data,from,to)
    return data[from..to]
  end
end

