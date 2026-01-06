#!/usr/bin/env python3
"""
Script to add ComprehensiveMonitoringPlugin.swift to Xcode project
"""
import uuid
import re

# Generate unique IDs for Xcode
def generate_id():
    return uuid.uuid4().hex[:24].upper()

# Read the project file
with open('macos/Runner.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

# Generate IDs for our new file
comprehensive_file_ref_id = generate_id()
comprehensive_build_file_id = generate_id()

print(f"Generated IDs:")
print(f"  ComprehensiveMonitoringPlugin file ref: {comprehensive_file_ref_id}")
print(f"  ComprehensiveMonitoringPlugin build file: {comprehensive_build_file_id}")

# 1. Add to PBXBuildFile section
build_file_section = re.search(r'(/\* Begin PBXBuildFile section \*/.*?)(/\* End PBXBuildFile section \*/)', content, re.DOTALL)
if build_file_section:
    new_build_files = f"""\t\t{comprehensive_build_file_id} /* ComprehensiveMonitoringPlugin.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {comprehensive_file_ref_id} /* ComprehensiveMonitoringPlugin.swift */; }};
"""
    content = content.replace(
        '/* End PBXBuildFile section */',
        new_build_files + '\t/* End PBXBuildFile section */'
    )
    print("✅ Added to PBXBuildFile section")

# 2. Add to PBXFileReference section
file_ref_section = re.search(r'(/\* Begin PBXFileReference section \*/.*?)(/\* End PBXFileReference section \*/)', content, re.DOTALL)
if file_ref_section:
    new_file_refs = f"""\t\t{comprehensive_file_ref_id} /* ComprehensiveMonitoringPlugin.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ComprehensiveMonitoringPlugin.swift; sourceTree = "<group>"; }};
"""
    content = content.replace(
        '/* End PBXFileReference section */',
        new_file_refs + '\t/* End PBXFileReference section */'
    )
    print("✅ Added to PBXFileReference section")

# 3. Add to Runner group (find the group with AppDelegate.swift)
# Find the Runner group that contains AppDelegate.swift
runner_group_pattern = r'(33CC10EF2044A3C60003C045 /\* Runner \*/ = \{[^}]+children = \([^)]+)(33CC10F02044A3C60003C045 /\* AppDelegate\.swift \*/,)'
match = re.search(runner_group_pattern, content, re.DOTALL)
if match:
    new_children = f"""\t\t\t\t{comprehensive_file_ref_id} /* ComprehensiveMonitoringPlugin.swift */,
\t\t\t\t"""
    content = re.sub(
        runner_group_pattern,
        r'\1' + new_children + r'\2',
        content,
        flags=re.DOTALL
    )
    print("✅ Added to Runner group")

# 4. Add to Sources build phase
# Find the PBXSourcesBuildPhase section for the Runner target
sources_pattern = r'(33CC10EA2044A3C60003C045 /\* Sources \*/ = \{[^}]+files = \([^)]+)(33CC10F12044A3C60003C045 /\* AppDelegate\.swift in Sources \*/,)'
match = re.search(sources_pattern, content, re.DOTALL)
if match:
    new_sources = f"""\t\t\t\t{comprehensive_build_file_id} /* ComprehensiveMonitoringPlugin.swift in Sources */,
\t\t\t\t"""
    content = re.sub(
        sources_pattern,
        r'\1' + new_sources + r'\2',
        content,
        flags=re.DOTALL
    )
    print("✅ Added to Sources build phase")

# Write the modified content back
with open('macos/Runner.xcodeproj/project.pbxproj', 'w') as f:
    f.write(content)

print("\n✅ Successfully added ComprehensiveMonitoringPlugin.swift to Xcode project!")
print("\nNext steps:")
print("1. Run: flutter clean")
print("2. Run: flutter pub get")
print("3. Run: flutter run -d macos")