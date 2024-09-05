# Example Godot MMO game
This is the repository of example MMO game made in godot that uses Protobuf for message serialization and MongoDB as database.  
It is meant to be used with the repository under link: <https://github.com/jakubguzewicz/GameServer>.

This repository uses scons as build tool.

## Usage
### Setup
Before anything you should run
```bash
git submodule update --init
```
as this project uses Godot engine repository for building purposes.  
You can also use git lfs as this repository is set up for it.
```bash
git lfs install
```
  
Godot project is contained in ``Example_MMO_game`` folder. You also need to add required dynamic libraries in ``lib`` folder. These libraries are used in GDExtension made for Protobuf and MongoDB usage. The same libraries should be placed in ``Example_MMO_game/bin`` directory
  
Windows:
- bson-1.0.lib
- libbsoncsxx.lib
- libmongocxx.lib
- libprotobuf.lib
- mongoc-1.0.lib
  
Linux:
- libbsoncxx.so._noabi
- libmongocxx.so._noabi
- libprotobuf.so.23
  
### Building
After everything is set up, building process is simple. you only need to run a command:
```bash
scons
```
and everything should be built. After that you only need to refresh the Godot project for the changes to take place.
## Source files
Extension source files are placed in ``src`` folder.  
Protobuf message scheme file is located under ``proto/src`` folder.  
Godot project source files are located in ``Example_MMO_game`` folder.  

These are the only source files in this repo. 
