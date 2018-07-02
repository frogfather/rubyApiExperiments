class Sandbox::Xmlparser

  def self.processxml(data)    
    #data is raw xml data from file
    processedxml = convertXMLToArray(data)
    #Convert to a hash for easier searching: {date=>{currency=>rate}}
    return arrayToHash(processedxml)
  end  

  def self.convertXMLToArray(data)
    dataWithHeaders = XmlSimple.xml_in(data)
    #dataWithHeaders is a hash. Key 'Cube' returns an array containing the data
    #Element 0 of this array contains a hash with all the data
    #Key 'Cube' of this hash returns an array with each element containing data for a single date
    dataWithoutHeaders = dataWithHeaders['Cube'][0]['Cube']
    #This is specific to the ECB data source. Would need some way of specifying data format for other sources
  end

  def self.arrayToHash(array)
    resulthash = Hash.new
    dayhash = Hash.new
    array.each do
    #each element contains data for one date. 
    |data| 
    dateValue = data['time']	
    rates = data['Cube']
      rates.each do
      #add the rates to dayhash
      |rate| dayhash[rate['currency']] = rate['rate'] 
      end
    #EUR isn't included because all the currencies are referenced to it. 
    #Add it here to make later calculations easier
    dayhash['EUR'] = '1.0000'
    resulthash[dateValue] = dayhash    
    end
  return resulthash
  end

end

require 'xmlsimple'

