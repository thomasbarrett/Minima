project('minima', 'objcpp', 'cpp')

add_global_arguments('-std=c++14', '-target', 'x86_64-apple-macos10.9', language : 'objcpp')
add_global_arguments('-std=c++14', '-target', 'x86_64-apple-macos10.9', language : 'cpp')

dep_main = dependency('appleframeworks', modules : ['Foundation', 'Cocoa', 'CoreVideo'])
dep_cario = dependency('cairo')
dep_cario_ft = dependency('cairo-ft')
dep_freetype2 = dependency('freetype2')
dep_harfbuzz = dependency('harfbuzz')
dep_curl = dependency('libcurl')

executable('minima', ['src/main.mm', 'src/ViewController.mm', 'src/AppDelegate.mm', 'src/CairoView.mm'], install : true, dependencies: [dep_main, dep_cario, dep_cario_ft, dep_freetype2, dep_harfbuzz, dep_curl])
install_data('minima.icns', install_dir : 'Contents/Resources')
install_data('Info.plist', install_dir : 'Contents')

meson.add_install_script('find_dependencies.py')
