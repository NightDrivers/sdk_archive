require 'xcodeproj'
require 'optparse'

options = {}
opt_parser = OptionParser.new do |opts|
    opts.banner = 'here is help messages of the command line tool.'
    
    opts.separator ''
    opts.separator 'Specific options:'
    opts.separator ''
    
    opts.on('--demo_target target', 'demo target') do |value|
        options[:demo_target] = value
    end
    
    opts.on('-p project', '--project project', 'xcode project path') do |value|
        options[:project] = value
    end
    
    opts.on('--sdk_target target', 'sdk target') do |value|
        options[:sdk_target] = value
    end
    
    opts.on('--sdk_framework_path path', 'sdk framework path') do |value|
        options[:sdk_framework_path] = value
    end
    
    opts.on_tail('-h', '--help', 'show this message') do
        puts opts
        exit
    end
end

opt_parser.parse!(ARGV)

project_path = options[:project]
target_name = options[:demo_target]
sdk_target = options[:sdk_target]
sdk_framework_path = options[:sdk_framework_path]

puts 'project path =>       ' + project_path
puts 'demo target =>        ' + target_name
puts 'sdk target =>         ' + sdk_target
puts 'sdk framework path => ' + sdk_framework_path

project = Xcodeproj::Project.open(project_path)

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

#找到目标target
target = project.targets.select do |target|
    target.name == target_name
end.first

puts target.name

#移除Demo target对sdk target 依赖

target.dependencies.select do |dependency|
    puts dependency.target.name
    dependency.target.name == sdk_target
end.each do |dependency|
    dependency.remove_from_project
end

#移除demo以外的target

project.targets.select do |target|
    target.name != target_name
end.each do |target|
    #这里要移除引用文件
    target.remove_from_project
end

#移除demo引用的sdk framework

target.frameworks_build_phase.files.select do |file|
    file.display_name.start_with?(sdk_target)
end.each do |file|
    file.remove_from_project
end

#删除绑定的动态库
#Embed Frameworks

target.copy_files_build_phases.each do |phase|
#    puts phase.name
#    puts phase.dst_path
#    puts phase.dst_subfolder_spec
#    puts phase.pretty_print
    phase.files.select do |file|
        file.display_name.start_with?(sdk_target)
    end.each do |file|
        file.remove_from_project
    end
end

#文件创建引用

file_reference = project.new_file(sdk_framework_path)
#这个两个参数似乎会根据文件路径自动设置
#file_reference.last_known_file_type = 'wrapper.xcframework'
#file_reference.name = sdk_framework_name

#创建copy_files_build_phase

copy_files_build_phase = target.new_copy_files_build_phase('Embed Frameworks')
copy_files_build_phase.dst_path = ''
copy_files_build_phase.dst_subfolder_spec = '10'
copy_files_build_phase_build_file = copy_files_build_phase.add_file_reference(file_reference)
copy_files_build_phase_build_file.settings = {"ATTRIBUTES" => ["CodeSignOnCopy", "RemoveHeadersOnCopy"] }

#添加frameworks_build_phase

framework_build_file = target.frameworks_build_phase.add_file_reference(file_reference)

#移除sdk文件目录引用

project.main_group.children.select do |group|
    group.isa == 'PBXGroup'
end.select do |group|
    group.path == sdk_target
end.each do |group|
    group.remove_from_project
end

deleteDirectory('CPExample/CPPrinterSDK')

#files = target.source_build_phase.files.to_a.map do |pbx_build_file|
#    pbx_build_file.file_ref.real_path.to_s
#    
#end.select do |path|
#    path.end_with?(".m", ".mm", ".swift")
#    
#end.select do |path|
#    File.exists?(path)
#end
#
#files.each do |file|
#    puts file
#end

project.save
