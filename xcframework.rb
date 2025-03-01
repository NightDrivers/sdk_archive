require 'optparse'
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'directory.rb'

def xcframework_archive(sdk_target_name, dst_path, product_name = nil, extraSimulatorBuildSettings = nil, build_macos = false)
    puts "Building XCFramework with settings:"
    puts "- Target: #{sdk_target_name}"
    puts "- Destination: #{dst_path}"
    puts "- Product: #{product_name || sdk_target_name}"
    puts "- Build macOS: #{build_macos}"
    
    if dst_path == nil
        dst_path = 'framework'
    end
    if product_name == nil
        product_name = sdk_target_name
    end

    iphoneos_dir = 'build/Release-iphoneos/%s.framework' % [product_name]
    iphone_simulator_dir = 'build/Release-iphonesimulator/%s.framework' % [product_name]
    macos_dir = 'build/Release/%s.framework' % [product_name]

    if File.directory?('build')
        deleteDirectory('build')
    end

    # Build iOS device version
    puts "\nBuilding iOS device framework..."
    cmd = 'xcodebuild OTHER_CFLAGS="-fembed-bitcode" -configuration "Release" -target %s -sdk iphoneos build' % [sdk_target_name]
    puts cmd
    flag = system cmd
    puts "iOS device build #{flag ? 'succeeded' : 'failed'}"

    # Build iOS simulator version
    puts "\nBuilding iOS simulator framework..."
    cmd = 'xcodebuild OTHER_CFLAGS="-fembed-bitcode"'
    if extraSimulatorBuildSettings != nil
        cmd = cmd + ' %s ' % [extraSimulatorBuildSettings]
    end
    cmd = cmd + ' -configuration "Release" -target %s -sdk iphonesimulator build' % [sdk_target_name]
    flag = system cmd
    puts "iOS simulator build #{flag ? 'succeeded' : 'failed'}"

    # Build macOS version if requested
    if build_macos
        puts "\nBuilding macOS framework..."
        cmd = 'xcodebuild -configuration "Release" -target %s -sdk macosx build' % [sdk_target_name]
        flag = system cmd
        puts "macOS build #{flag ? 'succeeded' : 'failed'}"
    end

    if File.directory?(dst_path)
        deleteDirectory(dst_path)
    end

    Dir.mkdir(dst_path)

    # Create XCFramework command
    puts "\nCreating XCFramework..."
    xcframework_cmd = 'xcrun xcodebuild -create-xcframework -framework %s -framework %s' % [iphoneos_dir, iphone_simulator_dir]
    
    if build_macos
        xcframework_cmd += ' -framework %s' % [macos_dir]
    end
    
    xcframework_cmd += ' -output %s/%s.xcframework' % [dst_path, product_name]

    flag = system xcframework_cmd
    puts "XCFramework creation #{flag ? 'succeeded' : 'failed'}"

    deleteDirectory('build')

    # flag = system 'open framework'

    # puts flag
end

#$0指执行脚本文件名，判断是否当前文件是否为执行文件
if __FILE__ == $0
    options = {}
    opt_parser = OptionParser.new do |opts|
        opts.banner = 'here is help messages of the command line tool.'
        
        opts.separator ''
        opts.separator 'Specific options:'
        opts.separator ''
        
        opts.on('--sdk_target_name target', 'sdk target name') do |value|
            options[:sdk_target_name] = value
        end
        
        opts.on('--dst_path path', 'destination path') do |value|
            options[:dst_path] = value
        end

        opts.on('--product_name name', 'product path') do |value|
            options[:product_name] = value
        end

        opts.on('--extra_simulator_build_settings settings', 'extra simulator build settings') do |value|
            options[:extra_simulator_build_settings] = value
        end

        opts.on('--build_macos', 'build macOS framework') do |value|
            options[:build_macos] = value
        end
        
        opts.on_tail('-h', '--help', 'Show this message') do
            puts opts
            exit
        end
    end

    opt_parser.parse!(ARGV)

    sdk_target_name = options[:sdk_target_name]
    dst_path = options[:dst_path]
    product_name = options[:product_name]
    extra_simulator_build_settings = options[:extra_simulator_build_settings]
    build_macos = options[:build_macos]
    if dst_path == nil
        dst_path = 'framework'
    end

    xcframework_archive(sdk_target_name, dst_path, product_name, extra_simulator_build_settings, build_macos)

    system 'open %s' % [File.expand_path(dst_path, Dir.pwd)]
end
