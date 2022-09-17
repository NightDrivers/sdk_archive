work_space="archive"
project_home="CPExample"
demo_target_name="CPExample"
sdk_target_name="CPPrinterSDK"

if [ -d "${work_space}" ]
then
    rm -rf "${work_space}"
fi

mkdir "${work_space}"

cp -r "${project_home}" "${work_space}/${project_home}"

project_home=${work_space}/${project_home}

rm -rf "${project_home}/.git"
ruby /usr/local/bin/ios_sdk_demo_archive_ruby_file -p "${project_home}/${demo_target_name}.xcodeproj" --demo_target "${demo_target_name}" --sdk_target "${CPPrinterSDK}" --sdk_framework_path "${project_home}/framework/CPPrinterSDK.xcframework"

zip -r "$work_space/${sdk_target_name}.zip" "$project_home"
