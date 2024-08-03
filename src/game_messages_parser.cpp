#include "game_messages_parser.h"
#include <game_messages.pb.h>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <openssl/rand.h>
#include <openssl/ssl.h>

using namespace godot;

void GameMessagesParser::_bind_methods() {
    // ClassDB::bind_method(D_METHOD("parse_from_byte_array"),
    //                      &GameMessagesParser::parse_from_byte_array);
    ClassDB::bind_static_method("GameMessagesParser",
                                D_METHOD("parse_from_byte_array", "bytes"),
                                &GameMessagesParser::parse_from_byte_array);
    ClassDB::bind_static_method(
        "GameMessagesParser",
        D_METHOD("log_in_request", "username", "password"),
        &GameMessagesParser::log_in_request);
    ClassDB::bind_static_method(
        "GameMessagesParser",
        D_METHOD("client_update", "user_id", "character_id", "character_state"),
        &GameMessagesParser::client_update);
    ClassDB::bind_static_method(
        "GameMessagesParser",
        D_METHOD("join_world_request", "user_id", "character_id"),
        &GameMessagesParser::join_world_request);
    ClassDB::bind_static_method(
        "GameMessagesParser",
        D_METHOD("join_world_response", "user_id", "character_data"),
        &GameMessagesParser::join_world_response);
    ClassDB::bind_static_method("GameMessagesParser",
                                D_METHOD("server_update", "server_update_data"),
                                &GameMessagesParser::server_update);
}

GameMessagesParser::GameMessagesParser() {
    // Initialize any variables here.
    time_passed = 0.0;
}

GameMessagesParser::~GameMessagesParser() {
    // Add your cleanup here.
}

PackedByteArray string_to_packed_byte_array(std::string bytes) {
    auto result = PackedByteArray();
    result.resize(bytes.size());
    std::memcpy(result.ptrw(), bytes.data(), bytes.size());

    // // Stroke of genius that is infortunately MSVC specific :(
    // return PackedByteArray(std::initializer_list<uint8_t>(
    //     (uint8_t *)bytes.data(), (uint8_t *)(bytes.data() +
    //     bytes.length())));

    return result;
}

Dictionary GameMessagesParser::parse_from_byte_array(PackedByteArray bytes) {
    auto message = game_messages::GameMessage();

    message.ParseFromArray(bytes.ptr(), bytes.size());

    auto result = Dictionary();
    result["message_type"] = message.message_type_case();

    switch ((int)result["message_type"]) {
    case game_messages::GameMessage::kLogInRequest: {
        result["username"] =
            String::utf8(message.log_in_request().username().data());
        result["password"] =
            String::utf8(message.log_in_request().password().data());
        if (message.log_in_request().has_session_id()) {
            result["session_id"] = message.log_in_request().session_id();
        }
        break;
    }

    case game_messages::GameMessage::kLogInResponse: {
        result["username"] =
            String::utf8(message.log_in_response().username().c_str());
        if (message.log_in_response().has_user_id()) {
            result["user_id"] = message.log_in_response().user_id();
        } else {
            result["user_id"] = 0;
        }
        if (message.log_in_response().has_session_id()) {
            result["session_id"] = message.log_in_response().session_id();
        }
        break;
    }

    case game_messages::GameMessage::kJoinWorldRequest: {
        result["user_id"] = message.join_world_request().user_id();
        result["character_id"] = message.join_world_request().character_id();
        break;
    }

    case game_messages::GameMessage::kJoinWorldResponse: {
        result["user_id"] = message.join_world_response().user_id();
        if (message.join_world_response().has_character_data()) {
            auto character_data_pba = string_to_packed_byte_array(
                message.join_world_response().character_data().data());
            Array character_data_array =
                UtilityFunctions::bytes_to_var(character_data_pba);
            result["character_data"] = character_data_array;
        }
        break;
    }

    case game_messages::GameMessage::kClientUpdateState: {
        result["user_id"] = message.client_update_state().user_id();
        auto character_state = Dictionary();
        character_state["character_id"] =
            message.client_update_state().character_state().character_id();
        character_state["character_state"] = UtilityFunctions::bytes_to_var(
            string_to_packed_byte_array(message.client_update_state()
                                            .character_state()
                                            .character_state()));
        result["character_state"] = character_state;
        break;
    }

    case game_messages::GameMessage::kServerUpdateState: {
        auto characters_update_data = Array();
        for (auto element :
             message.server_update_state().characters_update_data()) {
            auto character_data_dictionary = Dictionary();
            character_data_dictionary["character_id"] = element.character_id();
            character_data_dictionary["character_state"] =
                UtilityFunctions::bytes_to_var(
                    string_to_packed_byte_array(element.character_state()));
            characters_update_data.append(character_data_dictionary);
        }
        auto entities_update_data = Array();
        for (auto element :
             message.server_update_state().entities_update_data()) {
            Array entity_data_array = UtilityFunctions::bytes_to_var(
                string_to_packed_byte_array(element.entity_data()));
            entities_update_data.append(entity_data_array);
        }
        result["characters_update_data"] = characters_update_data;
        result["entities_update_data"] = entities_update_data;
        break;
    }

    case game_messages::GameMessage::kChatMessageRequest: {
        result["user_id"] = message.chat_message_request().user_id();
        result["chat_group"] = message.chat_message_request().chat_group();
        auto dest_users_id = Array();
        for (auto element : message.chat_message_request().dest_users_id()) {
            dest_users_id.append(element);
        }
        result["dest_users_id"] = dest_users_id;
        result["message"] =
            String::utf8(message.chat_message_request().message().c_str());
        break;
    }

    case game_messages::GameMessage::kChatMessageResponse: {
        result["source_user_id"] =
            message.chat_message_response().source_user_id();
        result["chat_group"] = message.chat_message_response().chat_group();
        auto dest_users_id = Array();
        for (auto element : message.chat_message_response().dest_users_id()) {
            dest_users_id.append(element);
        }
        result["dest_users_id"] = dest_users_id;
        result["message"] =
            String::utf8(message.chat_message_response().message().c_str());
        break;
    }

    default: {
        result["message_type"] =
            game_messages::GameMessage::MESSAGE_TYPE_NOT_SET;
        break;
    }
    }
    return result;
}

PackedByteArray GameMessagesParser::log_in_request(String username,
                                                   String password) {

    auto message = game_messages::GameMessage();
    message.mutable_log_in_request()->set_username(
        std::string(username.utf8().get_data()));
    message.mutable_log_in_request()->set_password(
        std::string(password.utf8().get_data()));
    auto message_string = message.SerializeAsString();
    auto byte_array = string_to_packed_byte_array(message_string);
    return byte_array;
}

PackedByteArray
GameMessagesParser::client_update(int user_id, int character_id,
                                  PackedByteArray character_state) {
    auto message = game_messages::GameMessage();
    message.mutable_client_update_state()->set_user_id(user_id);
    message.mutable_client_update_state()
        ->mutable_character_state()
        ->set_character_id(character_id);
    message.mutable_client_update_state()
        ->mutable_character_state()
        ->set_character_state(
            std::string((char *)character_state.ptr(), character_state.size()));
    return string_to_packed_byte_array(message.SerializeAsString());
}

PackedByteArray GameMessagesParser::join_world_request(int user_id,
                                                       int character_id) {
    auto message = game_messages::GameMessage();
    message.mutable_join_world_request()->set_user_id(user_id);
    message.mutable_join_world_request()->set_character_id(character_id);
    return string_to_packed_byte_array(message.SerializeAsString());
}

PackedByteArray
GameMessagesParser::join_world_response(int user_id,
                                        PackedByteArray character_data) {
    auto message = game_messages::GameMessage();
    message.mutable_join_world_response()->set_user_id(user_id);
    message.mutable_join_world_response()->mutable_character_data()->set_data(
        std::string((char *)character_data.ptr(), character_data.size()));
    return string_to_packed_byte_array(message.SerializeAsString());
}

PackedByteArray
GameMessagesParser::server_update(Dictionary server_update_data) {
    auto message = game_messages::GameMessage();
    auto server_update = message.mutable_server_update_state();
    Array characters_update_data = server_update_data["characters_update_data"];
    Array entities_update_data = server_update_data["entities_update_data"];
    // Add characters
    for (size_t i = 0; i < characters_update_data.size(); i++) {
        Dictionary characters_data_entry = characters_update_data[i];
        auto message_characters_update_data =
            server_update->add_characters_update_data();
        message_characters_update_data->set_character_id(
            characters_data_entry["character_id"]);
        PackedByteArray character_state =
            characters_data_entry["character_state"];
        message_characters_update_data->set_character_state(
            std::string((char *)character_state.ptr(), character_state.size()));
    }
    // Add entities
    for (size_t i = 0; i < entities_update_data.size(); i++) {
        auto message_entity_data = server_update->add_entities_update_data();
        PackedByteArray entity_data = entities_update_data[i];
        message_entity_data->set_entity_data(
            std::string((char *)entity_data.ptr(), entity_data.size()));
    }

    return string_to_packed_byte_array(message.SerializeAsString());
}