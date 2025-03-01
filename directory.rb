require 'fileutils'

def deleteDirectory(dirPath)
    if File.directory?(dirPath)
        FileUtils.rm_rf(dirPath)
    elsif File.exists?(dirPath)
        File.delete(dirPath)
    end
end