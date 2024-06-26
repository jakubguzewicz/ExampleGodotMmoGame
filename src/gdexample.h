#ifndef GDEXAMPLE_H
#define GDEXAMPLE_H

#include <godot_cpp/classes/sprite2d.hpp>

namespace godot {

class GDExample : public Object {
    GDCLASS(GDExample, Object)

  private:
    double time_passed;

  protected:
    static void _bind_methods();

  public:
    GDExample();
    ~GDExample();

    void set_time_passed(const double time_passed);
    double get_time_passed() const;
};

} // namespace godot

#endif