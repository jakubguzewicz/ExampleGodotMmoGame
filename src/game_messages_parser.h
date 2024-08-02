#ifndef GAME_MESSAGES_PARSER_H
#define GAME_MESSAGES_PARSER_H

#include <godot_cpp/classes/node.hpp>

namespace godot {

class GameMessagesParser : public Node {
    GDCLASS(GameMessagesParser, Node)

  private:
    double time_passed;

  protected:
    static void _bind_methods();

  public:
    GameMessagesParser();
    ~GameMessagesParser();
    static Dictionary parse_from_byte_array(PackedByteArray bytes);
    static PackedByteArray log_in_request(String username, String password);
    static PackedByteArray client_update(int user_id, int character_id,
                                         PackedByteArray character_state);
    static PackedByteArray join_world_request(int user_id, int character_id);
    static PackedByteArray join_world_response(int user_id,
                                               PackedByteArray character_data);
    static PackedByteArray server_update(Dictionary server_update_data);
};

} // namespace godot

#endif