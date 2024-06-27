#ifndef GDEXAMPLE_H
#define GDEXAMPLE_H

#include <godot_cpp/classes/sprite2d.hpp>

namespace godot {

class GDExample : public Node {
    GDCLASS(GDExample, Node)

  private:
    double time_passed;

  protected:
    static void _bind_methods();

  public:
    GDExample();
    ~GDExample();

    void set_time_passed(const double time_passed);
    double get_time_passed() const;
    String test_ssl_linking() const;
};

} // namespace godot

#endif