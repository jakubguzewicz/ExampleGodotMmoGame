#ifndef MONGO_CONNECTION_HANDLER_H
#define MONGO_CONNECTION_HANDLER_H

#include <godot_cpp/classes/node.hpp>
#include <mongocxx/client.hpp>
#include <mongocxx/instance-fwd.hpp>
#include <mongocxx/instance.hpp>
#include <mongocxx/pool.hpp>

namespace godot {

class MongoConnectionHandler : public Node {
    GDCLASS(MongoConnectionHandler, Node)

  private:
    // mongocxx::v_noabi::client client;
    // mongocxx::instance instance;
    std::string connection_uri_string;
    bool was_db_connected = false;
    bool update_character_data(Dictionary character_data);

  protected:
    static void _bind_methods();

  public:
    MongoConnectionHandler();
    ~MongoConnectionHandler();
    void setup_connection(String connection_uri);
    Dictionary retrieve_character_data(int character_id);
    bool update_characters_data(Array update_data);
};

} // namespace godot

#endif