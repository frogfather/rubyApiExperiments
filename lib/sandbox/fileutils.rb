module Fileutils

  def Fileutils.Writefile(data,filename)
    file = File.open(filename, 'w')
    file.puts data
    file.close
  end

  def Fileutils.Readfile(filename)
    file = File.open(filename, 'r')
    contents = file.read
    return contents
  end

  def Fileutils.Fileexist(filename)
    return File.exist?(filename)
  end

end

