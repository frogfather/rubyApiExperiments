class Sandbox::Fileutils

  def self.writefile(data,filename)
    file = File.open(filename, 'w')
    file.puts data
    file.close
  end

  def self.readfile(filename)
    file = File.open(filename, 'r')
    contents = file.read
    return contents
  end

  def self.fileexist(filename)
    return File.exist?(filename)
  end

end

