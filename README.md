# cmake-watch

A lightweight file watcher and build automation tool for CMake-based C++ projects. Automatically detects source code changes, rebuilds your project, and executes the compiled binary without manual intervention.

## Overview

`cmake-watch` streamlines the local development workflow for C++ projects by eliminating the need to manually run build commands after every code change. The script monitors your project for modifications to source files, headers, and CMake configuration, then automatically triggers a rebuild and runs the resulting executable.

This tool is particularly useful during active development when you need rapid feedback cycles between code changes and testing.

## Features

- Automatic project rebuilding on source file changes
- Watches for modifications in C++ source files (.cpp, .c, .cc, .cxx), headers (.h, .hpp), and CMakeLists.txt
- Automatic execution of compiled binary after successful builds
- Build timing information to track compilation performance
- Verbose output mode for debugging build issues
- Change debouncing to handle rapid successive file modifications
- Color-coded output for clear visual feedback
- Configurable for any CMake project with minimal setup
- Dependency validation with helpful installation instructions
- Skip initial build option for faster iteration startup

## Requirements

- Bash shell (standard on Linux and macOS)
- CMake 3.10 or higher
- inotify-tools (Linux only, Windows WSL users included)
- A C++ compiler (gcc, clang, or compatible)

### Installing Dependencies

On Ubuntu/Debian:
```bash
sudo apt-get install cmake build-essential inotify-tools
```

On Fedora/RHEL:
```bash
sudo dnf install cmake gcc-c++ inotify-tools
```

On macOS (using Homebrew):
```bash
brew install cmake inotify-tools
```

For Windows WSL (Ubuntu):
```bash
sudo apt-get install cmake build-essential inotify-tools
```

## Installation

1. Clone the repository into your CMake project root:
```bash
git clone https://github.com/AdrianParedez/cmake-watch.git
cd cmake-watch
```

2. Make the script executable:
```bash
chmod +x watch.sh
```

3. Move the script to your project root (where CMakeLists.txt is located):
```bash
mv watch.sh ../
cd ..
```

Alternatively, you can copy the script directly to your project without cloning:
```bash
curl -o watch.sh https://raw.githubusercontent.com/AdrianParedez/cmake-watch/main/watch.sh
chmod +x watch.sh
```

## Usage

### Basic Usage

Run with default settings. The executable name defaults to "hello":
```bash
./watch.sh
```

### Specifying Executable Name

Provide the executable name from your CMakeLists.txt `add_executable()` directive:
```bash
./watch.sh my_application
```

### Available Options

- `--no-initial`: Skip the initial build and proceed directly to watching for changes
- `-v, --verbose`: Display full cmake and make output for debugging build issues

### Usage Examples

Watch with a custom executable name:
```bash
./watch.sh my_app
```

Enable verbose output to see detailed build logs:
```bash
./watch.sh my_app -v
```

Skip the initial build (useful if you already have a built binary):
```bash
./watch.sh my_app --no-initial
```

Combine options:
```bash
./watch.sh my_app --no-initial -v
```

## Configuration

The script requires minimal configuration. The only mandatory adjustment is specifying your executable name when running the script.

### Optional Configuration Changes

Edit the following variables at the top of `watch.sh` if your project structure differs from standard conventions:

- `BUILD_DIR`: Change from "build" if your CMake output directory has a different name
- `DEBOUNCE_TIME`: Adjust from 0.3 seconds if you need different change detection timing

### Finding Your Executable Name

Locate the executable name in your CMakeLists.txt file:
```cmake
add_executable(my_app main.cpp source.cpp)  # "my_app" is the executable name
```

## How It Works

1. **Initial Setup**: Creates the build directory if it doesn't exist and performs an initial CMake configuration and build
2. **File Monitoring**: Uses inotifywait to monitor the project directory for changes to source files, headers, and CMake configuration
3. **Change Detection**: Detects modifications and applies debouncing to consolidate rapid successive changes
4. **Rebuild Trigger**: Automatically runs cmake configuration and make build
5. **Execution**: Upon successful compilation, automatically runs the generated executable
6. **Feedback**: Displays colored output with build timing and status information
7. **Continuous Watching**: Returns to monitoring state and repeats the process until interrupted

## Output Information

The script provides color-coded feedback for different types of messages:

- Blue (ℹ): Information messages
- Green (✓): Successful operations
- Red (✗): Errors and failures
- Yellow (⚠): Warnings and status updates

Build timing is displayed in milliseconds to help identify performance bottlenecks during compilation.

## Limitations

- Linux and WSL only (uses inotify for file monitoring)
- Requires a standard CMake project structure with a build directory
- Does not work on native macOS (though WSL on Windows can run this script)
- Executable name must be specified if it differs from the default "hello"

## Troubleshooting

### Executable Not Found Error

Verify that your CMakeLists.txt contains the correct `add_executable()` directive and that the executable name matches what you're passing to the script.

### Build Fails Silently

Run the script with verbose mode to see detailed error output:
```bash
./watch.sh my_app -v
```

### inotifywait Not Found

Install inotify-tools using your system package manager (see Installing Dependencies section).

### Permission Denied

Make the script executable:
```bash
chmod +x watch.sh
```

## Project Structure

For optimal compatibility, organize your project as follows:
```
my_project/
├── CMakeLists.txt
├── watch.sh
├── main.cpp
├── src/
│   └── (source files)
└── include/
    └── (header files)
```

The build directory will be created automatically in the project root.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Contributing

Contributions, suggestions, and bug reports are welcome. Feel free to open an issue or submit a pull request.

## Author

Adrian Paredez

## See Also

For more information on CMake, visit the official documentation at https://cmake.org/documentation/
