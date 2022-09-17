def deleteDirectory(dirPath)
    if File.directory?(dirPath)
        Dir.foreach(dirPath) do |subFile|
            if subFile != '.' and subFile != '..' 
                deleteDirectory(File.join(dirPath, subFile));
            end
        end
        Dir.rmdir(dirPath);
    else
        if File.exists?(dirPath)
            File.delete(dirPath)
        end
    end
end