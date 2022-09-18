require 'directory.rb'

def xcframework_archive(sdk_target_name)
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
end