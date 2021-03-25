# Hello 3D in Zig

![Preview](/zig-mark.gif?raw=true "Preview")

## Install dependencies

Install [Zig](https://ziglang.org/download/) master

### Windows

Requires [vcpkg package manager](https://github.com/microsoft/vcpkg)

```cmd
> vcpkg install sdl2:x64-windows libepoxy:x64-windows
```

### macOS

Requires [Homebrew](https://brew.sh/)

```bash
$ brew install sdl2 libepoxy
```

### Ubuntu Linux

```bash
$ sudo apt install libsdl2-dev libepoxy-dev
```

## Get the source

```bash
$ git clone --recursive https://github.com/fabioarnold/hello-3d
```

## Build and run

```bash
$ cd hello-3d
$ zig build run
```