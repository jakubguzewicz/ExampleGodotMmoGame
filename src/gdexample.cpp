#include "gdexample.h"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void GDExample::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_time_passed"),
                         &GDExample::get_time_passed);
    ClassDB::bind_method(D_METHOD("set_time_passed", "time_passed"),
                         &GDExample::set_time_passed);
}

GDExample::GDExample() {
    // Initialize any variables here.
    time_passed = 0.0;
}

GDExample::~GDExample() {
    // Add your cleanup here.
}

void GDExample::set_time_passed(const double time_passed) {
    this->time_passed = time_passed;
}

double GDExample::get_time_passed() const { return this->time_passed; }
