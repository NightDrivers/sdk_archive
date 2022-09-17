
require 'optparse'

options = {}
opt_parser = OptionParser.new do |opts|
    opts.banner = 'here is help messages of the command line tool.'
    
    opts.separator ''
    opts.separator 'Specific options:'
    opts.separator ''
    
    opts.on('-t Target', '--target Target', 'Target') do |value|
        options[:target] = value
    end
    
    opts.on_tail('-h', '--help', 'Show this message') do
        puts opts
        exit
    end
end

opt_parser.parse!(ARGV)

target_name = options[:target]

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

work_dir = 'framework'

iphoneos_dir = 'build/Release-iphoneos/%s.framework' % [target_name]
iphone_simulator_dir = 'build/Release-iphonesimulator/%s.framework' % [target_name]

if File.directory?('build')
    deleteDirectory('build')
end

#puts iphoneos_dir
#puts iphone_simulator_dir

flag = system 'xcodebuild OTHER_CFLAGS="-fembed-bitcode" -configuration "Release" -target %s -sdk iphoneos build' % [target_name]

puts flag

flag = system 'xcodebuild OTHER_CFLAGS="-fembed-bitcode" -configuration "Release" -target %s -sdk iphonesimulator build' % [target_name]

puts flag

if File.directory?(work_dir)
    deleteDirectory(work_dir);
end

Dir.mkdir(work_dir)

flag = system 'xcrun xcodebuild -create-xcframework -framework %s -framework %s -output %s/%s.xcframework' % [iphoneos_dir, iphone_simulator_dir, work_dir, target_name]

puts flag

flag = system 'open framework'

puts flag
