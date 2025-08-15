#pragma once
#include <functional>
#include <string>
#include <vector>

using DemoFn = std::function<void(const std::vector<std::string>& args)>;

struct DemoRegistrar {
    DemoRegistrar(const std::string& name, DemoFn fn);
};

#define REGISTER_DEMO(NAME, FN) static DemoRegistrar _demo_registrar_##NAME(#NAME, FN)

void register_demo(const std::string& name, DemoFn fn);
const std::vector<std::pair<std::string, DemoFn>>& list_demos();
DemoFn find_demo(const std::string& name);
