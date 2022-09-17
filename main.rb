$LOAD_PATH.unshift(File.dirname(__FILE__))
#LOAD_PATH 为文件加载的路径数组，这段代码表示将当前文件所在的目录添加至加载目录
require "directory.rb"

require 'optparse'

options = {}
opt_parser = OptionParser.new do |opts|
    opts.banner = 'here is help messages of the command line tool.'
    
    opts.separator ''
    opts.separator 'Specific options:'
    opts.separator ''
    
    opts.on('-t Target', '--sdk_target Target', 'Target') do |value|
        options[:sdk_target] = value
    end
    
    opts.on_tail('-h', '--help', 'Show this message') do
        puts opts
        exit
    end
end

opt_parser.parse!(ARGV)

sdk_target_name = options[:sdk_target]

system 'pwd'

work_dir = 'framework'

iphoneos_dir = 'build/Release-iphoneos/%s.framework' % [sdk_target_name]
iphone_simulator_dir = 'build/Release-iphonesimulator/%s.framework' % [sdk_target_name]

if File.directory?('build')
    deleteDirectory('build')
end

#puts iphoneos_dir
#puts iphone_simulator_dir

cmd = 'xcodebuild OTHER_CFLAGS="-fembed-bitcode" -configuration "Release" -target %s -sdk iphoneos build' % [sdk_target_name]

puts cmd

flag = system cmd

puts flag

flag = system 'xcodebuild OTHER_CFLAGS="-fembed-bitcode" -configuration "Release" -target %s -sdk iphonesimulator build' % [sdk_target_name]

puts flag

if File.directory?(work_dir)
    deleteDirectory(work_dir);
end

Dir.mkdir(work_dir)

flag = system 'xcrun xcodebuild -create-xcframework -framework %s -framework %s -output %s/%s.xcframework' % [iphoneos_dir, iphone_simulator_dir, work_dir, sdk_target_name]

puts flag

flag = system 'open framework'

puts flag
