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
};

} // namespace godot

#endif