require 'optparse'
$LOAD_PATH.unshift(File.dirname(__FILE__))
#LOAD_PATH 为文件加载的路径数组，这段代码表示将当前文件所在的目录添加至加载目录
require "xcframework.rb"
require 'project_helper.rb'

#使用sdk target生成xcframework
#删除sdk项目，将xcframework导入demo项目
#项目文件压缩打包

if __FILE__ == $0
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

        opts.on('--dst_path path', 'destination path') do |value|
            options[:dst_path] = value
        end

        opts.on('--dynamic_framework', 'is dynamic framework') do |value|
            options[:dynamic_framework] = value
        end

        opts.on('--skip_xcframework_archive', '跳过xcframework打包，忽略时默认将framework文件夹下的库添加到demo项目') do
            options[:skip_xcframework_archive] = true
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
    dst_path = options[:dst_path]
    skip_xcframework_archive = options[:skip_xcframework_archive]
    dynamic_framework = options[:dynamic_framework]

    if dst_path == nil
        dst_path = '~/Desktop/home'
    end

    dst_path = File.expand_path(dst_path)

    puts 'project path =>       ' + project_path
    puts 'demo target =>        ' + demo_target
    puts 'sdk target =>         ' + sdk_target
    puts 'destination path =>   ' + dst_path

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

    if skip_xcframework_archive
        if !File.directory?(File.expand_path(sdk_framework_path, Dir.pwd))
            puts '%s not found' % [sdk_framework_path]
            exit
        end 
    else
        xcframework_archive(sdk_target, xcframework_archive_home)
    end

    current_path = Dir.pwd

    if !File.directory?(dst_path)
        cmd = 'mkdir %s' % [dst_path]
        puts cmd
        flag = system cmd
        puts flag
    end

    home_dir_name = current_path.split('/').last
    dst_path_project_path = File.expand_path(home_dir_name, dst_path)

    if File.directory?(dst_path_project_path)
        deleteDirectory(dst_path_project_path)
    end

    moveProject(current_path, dst_path_project_path)
    version = relpaceTargetWithFramework(dst_path_project_path, project_path, demo_target, sdk_target, sdk_framework_path, dynamic_framework)

    zip_name = '%s-iOS-%s' % [home_dir_name, version]

    git_repo_path = File.expand_path('.git', dst_path_project_path)

    if File.directory?(git_repo_path)
        cmd = 'rm -rf %s' % [git_repo_path]
        puts cmd
        flag = system cmd
        puts flag
    end

    cmd = 'cd %s;rm -f *.sh' % [dst_path_project_path]
    puts cmd
    flag = system cmd
    puts flag

    cmd = 'cd %s;zip -r %s/%s.zip %s' % [dst_path, dst_path, zip_name, home_dir_name]
    puts cmd
    flag = system cmd
    puts flag

    cmd = 'open %s' % [dst_path]
    puts cmd
    flag = system cmd
    puts flag
end
