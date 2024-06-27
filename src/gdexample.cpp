#include "gdexample.h"
#include <godot_cpp/core/class_db.hpp>
#include <openssl/rand.h>
#include <openssl/ssl.h>

using namespace godot;

void GDExample::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_time_passed"),
                         &GDExample::get_time_passed);
    ClassDB::bind_method(D_METHOD("set_time_passed", "time_passed"),
                         &GDExample::set_time_passed);
    ClassDB::bind_method(D_METHOD("test_ssl_linking"),
                         &GDExample::test_ssl_linking);
}

GDExample::GDExample() {
    // Initialize any variables here.
    time_passed = 0.0;
}

GDExample::~GDExample() {
    // Add your cleanup here.
}

String GDExample::test_ssl_linking() const {
    auto const buf_size = 32;
    auto buf = std::array<unsigned char, buf_size>();
    RAND_bytes(buf.data(), buf_size);
    auto rand_bytes =
        std::array<unsigned char, buf_size / 3 + (buf_size % 3 != 0) + 1>();
    EVP_EncodeBlock(rand_bytes.data(), buf.data(), buf_size);
    String result = String((char *)rand_bytes.data());
    return result;
}

void GDExample::set_time_passed(const double time_passed) {
    this->time_passed = time_passed;
}

double GDExample::get_time_passed() const { return this->time_passed; }
