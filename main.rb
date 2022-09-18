$LOAD_PATH.unshift(File.dirname(__FILE__))
#LOAD_PATH 为文件加载的路径数组，这段代码表示将当前文件所在的目录添加至加载目录
require "xcframework.rb"
require 'project_helper.rb'
require 'optparse'

#使用sdk target生成xcframework
#删除sdk项目，将xcframework导入demo项目
#项目文件压缩打包

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
    
    opts.on_tail('-h', '--help', 'Show this message') do
        puts opts
        exit
    end
end

opt_parser.parse!(ARGV)

project_path = options[:project]
demo_target = options[:demo_target]
sdk_target = options[:sdk_target]

puts 'project path =>       ' + project_path
puts 'demo target =>        ' + demo_target
puts 'sdk target =>         ' + sdk_target

system 'pwd'

def moveProject(source_path, dst_path)
    puts source_path
    puts dst_path

    cmd = 'cp -r %s %s' % [source_path, dst_path]
    puts cmd
    flag = system cmd
    puts flag
end

xcframework_archive_home = 'framework'
sdk_framework_path = '%s/%s.xcframework' % [xcframework_archive_home, sdk_target]

xcframework_archive(sdk_target, xcframework_archive_home)

current_path = Dir.pwd
work_space = "/Users/ldc/Desktop/home"

if File.directory?(work_space)
    deleteDirectory(work_space)
end

cmd = 'mkdir %s' % [work_space]
puts cmd
flag = system cmd
puts flag

home_dir_name = current_path.split('/').last
work_space_project_path = '%s/%s' % [work_space, home_dir_name]

moveProject(current_path, work_space_project_path)
relpaceTargetWithFramework(work_space_project_path, project_path, demo_target, sdk_target, sdk_framework_path)

zip_name = home_dir_name

git_repo_path = '%s/.git' % [work_space_project_path]

if File.directory?(git_repo_path)
    cmd = 'rm -rf %s' % [git_repo_path]
    puts cmd
    flag = system cmd
    puts flag
end

cmd = 'cd %s;zip -r %s/%s.zip %s' % [work_space, work_space, zip_name, home_dir_name]
puts cmd
flag = system cmd
puts flag

cmd = 'open %s' % [work_space]
puts cmd
flag = system cmd
puts flag