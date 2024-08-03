#!/usr/bin/env python
import os
import sys

env = SConscript("godot-cpp/SConstruct")

# For reference:
# - CCFLAGS are compilation flags shared between C and C++
# - CFLAGS are for C-specific compilation flags
# - CXXFLAGS are for C++-specific compilation flags
# - CPPFLAGS are for pre-processor flags
# - CPPDEFINES are for pre-processor defines
# - LINKFLAGS are for linking flags

# tweak this if you want to use different folders, or more folders, to store your source code in.
proto = env.Command(["proto/include/game_messages.pb.h", "proto/include/game_messages.pb.cc"], "proto/src/game_messages.proto", "protoc -I=proto/src --experimental_allow_proto3_optional --cpp_out=proto/include proto/src/game_messages.proto")
env.Append(CPPPATH=["src/","external/openssl/include/","proto/include/", "external/", "external/mongocxx/include/", "external/mongocxx/include/mongocxx/v_noabi","external/mongocxx/include/bsoncxx/v_noabi"])
# if env["platform"] != "linux":
env.Append(LIBS=["libprotobuf","libbsoncxx", "libmongocxx"], LIBPATH='lib/')
# sources = [Glob("src/*.cpp")]
sources = [Glob("src/*.cpp"), Glob("proto/include/*.cc")]
env.Replace(SCONS_CXX_STANDARD="c++17")

# if env["platform"] == "linux":
#     env.Replace(CXX = "/usr/lib/llvm-17/bin/clang")

if env["platform"] == "macos":
    library = env.SharedLibrary(
        "Godot_SSL_Extension/bin/game_message_parser.{}.{}.framework/game_message_parser.{}.{}".format(
            env["platform"], env["target"], env["platform"], env["target"]
        ),
        source=sources,
    )
else:
    library = env.SharedLibrary(
        "Godot_SSL_Extension/bin/game_message_parser{}{}".format(env["suffix"], env["SHLIBSUFFIX"]),
        source=sources, 
    )
Default(proto)
Default(library)
