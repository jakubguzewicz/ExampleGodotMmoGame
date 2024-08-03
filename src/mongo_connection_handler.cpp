#include "mongo_connection_handler.h"

#include <mongocxx/instance-fwd.hpp>
#include <mongocxx/pool.hpp>

#include <bsoncxx/builder/basic/document.hpp>
#include <bsoncxx/json.hpp>
#include <mongocxx/client.hpp>
#include <mongocxx/instance.hpp>
#include <mongocxx/stdx.hpp>
#include <mongocxx/uri.hpp>

#include <bsoncxx/builder/basic/kvp.hpp>
#include <bsoncxx/json-fwd.hpp>
#include <cstdint>
#include <iostream>
#include <vector>

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/builtin_vararg_methods.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

using bsoncxx::builder::basic::kvp;
using bsoncxx::builder::basic::make_array;
using bsoncxx::builder::basic::make_document;

void MongoConnectionHandler::_bind_methods() {
    ClassDB::bind_method(D_METHOD("setup_connection", "connection_uri"),
                         &MongoConnectionHandler::setup_connection);
    ClassDB::bind_method(D_METHOD("retrieve_character_data", "character_id"),
                         &MongoConnectionHandler::retrieve_character_data);
    ClassDB::bind_method(D_METHOD("update_characters_data", "update_data"),
                         &MongoConnectionHandler::update_characters_data);
    // ClassDB::bind_static_method("GameMessagesParser",
    //                             D_METHOD("parse_from_byte_array", "bytes"),
    //                             &GameMessagesParser::parse_from_byte_array);
}

MongoConnectionHandler::MongoConnectionHandler() {
    // Initialize any variables here.
    instance = mongocxx::instance();
}

MongoConnectionHandler::~MongoConnectionHandler() {
    // Add your cleanup here.
}

void MongoConnectionHandler::setup_connection(String connection_uri) {
    connection_uri_string = std::string_view(connection_uri.utf8().get_data());
}

Dictionary MongoConnectionHandler::retrieve_character_data(int character_id) {
    auto mongo_pool = mongocxx::pool(mongocxx::uri(connection_uri_string));
    auto entry = mongo_pool.acquire();
    auto &client = (*entry);
    UtilityFunctions::print("before collection");
    auto characters_data_collection = client["game_data"]["characters_data"];
    UtilityFunctions::print("before find one");
    auto query_result = characters_data_collection.find_one(
        make_document(kvp("character_id", character_id)));
    UtilityFunctions::print("after find one");
    auto character_data = Dictionary();
    if (!query_result) {
        UtilityFunctions::print("There was no character like that");
        auto data_to_insert = make_document(
            kvp("character_id", int32_t(character_id)),
            kvp("transform", make_array(0.0, 0.0, 0.0)),
            kvp("equipment",
                make_array(int32_t(0), int32_t(0), int32_t(0), int32_t(0),
                           int32_t(0), int32_t(0), int32_t(0), int32_t(0))));
        // Need to create a new character
        characters_data_collection.insert_one(data_to_insert.view());
        UtilityFunctions::print("Inserted new character");
    }

    character_data["character_id"] =
        query_result.value()["character_id"].get_int32().value;
    auto transform = Array();
    transform.resize(2);
    auto transform_result = query_result.value()["transform"].get_array();
    // Just beautiful ugliness :)
    transform[0] = Vector2(transform_result.value[0].get_double().value,
                           transform_result.value[1].get_double().value);
    transform[1] = transform_result.value[2].get_double().value;
    character_data["transform"] = transform;
    auto equipment = Array();
    equipment.resize(8);
    auto equipment_result = query_result.value()["equipment"].get_array();
    for (int i = 0; i < equipment_result.value.length(); i++) {
        equipment[i] = equipment_result.value[i].get_int32().value;
    }
    character_data["equipment"] = equipment;
    return character_data;
}

bool MongoConnectionHandler::update_characters_data(Array update_data) {
    auto result = true;
    for (size_t i = 0; i < update_data.size(); i++) {
        result = result && update_character_data(update_data[0]);
    }
    return result;
}

bool MongoConnectionHandler::update_character_data(Dictionary character_data) {
    auto mongo_pool = mongocxx::pool(mongocxx::uri(connection_uri_string));
    auto entry = mongo_pool.acquire();
    auto &client = (*entry);
    auto transform_array = Array(character_data["transform"]);
    auto position_vector = Vector2(transform_array[0]);
    auto e = Array(character_data["equipment"]);
    double rotation = transform_array[1];
    auto data_to_insert = make_document(
        kvp("character_id", int32_t(character_data["character_id"])),
        kvp("transform",
            make_array(position_vector.x, position_vector.y, rotation)),
        kvp("equipment", make_array(int32_t(e[0]), int32_t(e[1]), int32_t(e[2]),
                                    int32_t(e[3]), int32_t(e[4]), int32_t(e[5]),
                                    int32_t(e[6]), int32_t(e[7]))));

    return client["game_data"]["characters_data"]
        .find_one_and_replace(
            make_document(
                kvp("character_id", int32_t(character_data["character_id"]))),
            data_to_insert.view())
        .has_value();
}
