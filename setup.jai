PLACEHOLDER_NAME :: "bootstrap";
BUILD_FILE :: "build.jai";

rename :: (source_pattern: string, target_name: string)
{
    source_file_name: = tprint(source_pattern, PLACEHOLDER_NAME);

    if file_exists(source_file_name)
    {
        new_file_name: = replace(source_file_name, PLACEHOLDER_NAME, target_name);
        log("Renaming % -> %...", source_file_name, new_file_name);
        file_move(source_file_name, new_file_name);
    }
}

#run {
    // This is not an actual compilation script
    set_build_options_dc(.{do_output=false});

    args := get_build_options().compile_time_command_line;
    project_name: = args[0];

    // Rename project files
    rename("%.sublime-project", project_name);
    rename("%.raddbg_project", project_name);

    // Replace project name in build file
    log("Replacing project name in %...", BUILD_FILE);
    build_file_content: = read_entire_file(BUILD_FILE);
    build_file_content = replace(build_file_content, PLACEHOLDER_NAME, project_name);
    write_entire_file(BUILD_FILE, build_file_content);

    // Removing setup files
    log("Removing setup files...");
    file_delete("setup.jai");
    file_delete("setup.bat");
}

#import "Compiler";
#import "Basic";
#import "File";
#import "File_Utilities";
#import "String";