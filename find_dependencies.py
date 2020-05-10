#!/bin/python3

import subprocess
import shutil
import os

system_library_paths = [
    b'/System/Library',
    b'/usr/lib/'
]

def otool(s):
    o = subprocess.Popen(['/usr/bin/otool', '-L', s], stdout=subprocess.PIPE)
    o.stdout.readline()
    if s.endswith(b'.dylib'):
        o.stdout.readline()
    for l in o.stdout:
        yield l.strip().split()[0]

def change_dependency_path(path, dep_old, dep_new):
    subprocess.Popen(['/usr/bin/install_name_tool', '-change', dep_old, dep_new, path]).wait()

def change_id_name(path, id_new):
    subprocess.Popen(['/usr/bin/install_name_tool', '-id', id_new, path]).wait()

def find_dependencies(path, deps = []):
    for dep_path in otool(path):

        skip = False

        for system_path in system_library_paths:
            if dep_path.startswith(system_path):
                skip = True

        if not skip and not dep_path in deps:
            deps.append(dep_path)
            find_dependencies(dep_path, deps)

    return deps
 

def create_frameworks_directory():
    if (os.path.exists(frameworks_path)):
        shutil.rmtree(frameworks_path)
    os.mkdir(frameworks_path)

def bundled_library_path(input_path, deps):
    if input_path in deps:
        basename = os.path.basename(input_path)
        return os.path.join(frameworks_path, basename)
    else:
        return output_path

bundle_path = b'/Users/thomasbarrett/Desktop/minima.app/'
executable_path = os.path.join(bundle_path, b'Contents/MacOS/minima')
frameworks_path = os.path.join(bundle_path, b'Contents/Frameworks')

create_frameworks_directory()

deps = find_dependencies(executable_path)
deps.sort()

print()
print(f"Bundling {len(deps)} dependencies to {frameworks_path.decode('utf8')}")
for dep in deps:
    print(dep.decode('utf8'))
print()

for input_path in deps:
    basename = os.path.basename(input_path)
    output_path = os.path.join(frameworks_path, basename)
    if input_path != output_path:
        shutil.copyfile(input_path, output_path)

for input_path in deps:
    basename = os.path.basename(input_path)
    output_path = os.path.join(frameworks_path, basename)
    rel_output_path = os.path.join(b'@executable_path/../Frameworks', basename)
    change_id_name(output_path, rel_output_path)

    for dep_input_path in otool(output_path):
        if dep_input_path in deps:
            dep_basename = os.path.basename(dep_input_path)
            dep_output_path = os.path.join(b'@executable_path/../Frameworks', dep_basename)
            change_dependency_path(output_path, dep_input_path, dep_output_path)

for dep_input_path in otool(executable_path):
    if dep_input_path in deps:
        dep_basename = os.path.basename(dep_input_path)
        dep_output_path = os.path.join(b'@executable_path/../Frameworks', dep_basename)
        change_dependency_path(executable_path, dep_input_path, dep_output_path)