$LOAD_PATH.unshift(File.dirname(__FILE__))
#LOAD_PATH 为文件加载的路径数组，这段代码表示将当前文件所在的目录添加至加载目录
require "xcframework.rb"
require 'project_helper.rb'
require 'optparse'

options = {}
opt_parser = OptionParser.new do |opts|
    opts.banner = 'here is help messages of the command line tool.'
    
    opts.separator ''
    opts.separator 'Specific options:'
    opts.separator ''

    opts.on('-p project', '--project project', 'xcode project path') do |value|
        options[:project] = value
    end

    opts.on('--demo_target target', 'demo target') do |value|
        options[:demo_target] = value
    end
    
    opts.on('--sdk_target target', 'sdk target') do |value|
        options[:sdk_target] = value
    end
    
    opts.on('--sdk_framework_path path', 'sdk framework path') do |value|
        options[:sdk_framework_path] = value
    end
    
    opts.on_tail('-h', '--help', 'Show this message') do
        puts opts
        exit
    end
end

opt_parser.parse!(ARGV)

project_path = options[:project]
demo_target = options[:demo_target]
sdk_target = options[:sdk_target]
sdk_framework_path = options[:sdk_framework_path]

puts 'project path =>       ' + project_path
puts 'demo target =>        ' + demo_target
puts 'sdk target =>         ' + sdk_target
puts 'sdk framework path => ' + sdk_framework_path

system 'pwd'

def moveProject(source_path, dst_path)
    puts source_path
    puts dst_path

    cmd = 'cp -r %s %s' % [source_path, dst_path]
    puts cmd
    flag = system cmd
    puts flag
end

# xcframework_archive(sdk_target)
# relpaceTargetWithFramework(project_path, demo_target, sdk_target, sdk_framework_path)

work_space = "/Users/ldc/Desktop/home"
current_path = Dir.pwd
# current_path = current_path.split('\n').first

if File.directory?(work_space)
    deleteDirectory(work_space)
end

cmd = 'mkdir %s' % [work_space]
puts cmd
flag = system cmd
puts flag

moveProject(current_path, '%s/%s' % [work_space, current_path.split('/').last])