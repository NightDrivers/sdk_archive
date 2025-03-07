require 'directory.rb'
require 'xcodeproj'

def relpaceTargetWithFramework(project_home, project_name, target_name, sdk_target, sdk_framework_path, is_dynamic_framework = false)

    xcodeproj_path = '%s/%s.xcodeproj' % [project_home, project_name]
    xcodeproj_path = File.expand_path('%s.xcodeproj' % [project_name], project_home)
    project = Xcodeproj::Project.open(xcodeproj_path)

    #找到目标target
    target = project.targets.select do |target|
        target.name == target_name
    end.first

    build_settings = target.build_settings('Release')
    marketing_version = build_settings['MARKETING_VERSION']
    current_project_version = build_settings['CURRENT_PROJECT_VERSION']

    puts target.name
    puts marketing_version
    puts current_project_version

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
        phase.files.select do |file|
            file.display_name.start_with?(sdk_target)
        end.each do |file|
            file.remove_from_project
        end
    end

    #文件创建引用

    sdk_framework_path = File.expand_path(sdk_framework_path, project_home)
    file_reference = project.new_file(sdk_framework_path)
    #这个两个参数似乎会根据文件路径自动设置
    #file_reference.last_known_file_type = 'wrapper.xcframework'
    #file_reference.name = sdk_framework_name

    #创建copy_files_build_phase

    if is_dynamic_framework
        # 以下为动态库绑定逻辑 后续增加参数，或者直接根据sdk项目是否是动态库判断是否需要绑定
        copy_files_build_phase = target.new_copy_files_build_phase('Embed Frameworks')
        copy_files_build_phase.dst_path = ''
        copy_files_build_phase.dst_subfolder_spec = '10'
        copy_files_build_phase_build_file = copy_files_build_phase.add_file_reference(file_reference)
        copy_files_build_phase_build_file.settings = {"ATTRIBUTES" => ["CodeSignOnCopy", "RemoveHeadersOnCopy"] }
    end

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

    deleteDirectory(File.expand_path(sdk_target, project_home))

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
    return '%s.%s' % [marketing_version, current_project_version]
end