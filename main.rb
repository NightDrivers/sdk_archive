$LOAD_PATH.unshift(File.dirname(__FILE__))
#LOAD_PATH 为文件加载的路径数组，这段代码表示将当前文件所在的目录添加至加载目录
require "xcframework.rb"

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

xcframework_archive(sdk_target_name)

