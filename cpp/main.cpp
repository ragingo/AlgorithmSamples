#include "demo_registry.hpp"

#include <algorithm>
#include <chrono>
#include <functional>
#include <iostream>
#include <limits>
#include <locale>
#include <stdexcept>
#include <string>
#include <vector>

namespace {
static std::vector<std::pair<std::string, DemoFn>> g_demos;

struct RegistrarImpl {
    RegistrarImpl(const std::string& name, DemoFn fn) { g_demos.emplace_back(name, fn); }
};
}  // namespace

DemoRegistrar::DemoRegistrar(const std::string& name, DemoFn fn) { static RegistrarImpl impl(name, fn); }

void register_demo(const std::string& name, DemoFn fn) { g_demos.emplace_back(name, fn); }

const std::vector<std::pair<std::string, DemoFn>>& list_demos() { return g_demos; }

DemoFn find_demo(const std::string& name) {
    auto it = std::find_if(g_demos.begin(), g_demos.end(), [&](auto& p) { return p.first == name; });
    if (it == g_demos.end()) {
        return DemoFn();
    }
    return it->second;
}

int main(int argc, char** argv) {
#ifdef _WIN32
    // Windowsの場合
    std::locale::global(std::locale("ja-JP"));
#elif __APPLE__
    // macOSの場合
    std::locale::global(std::locale("ja_JP.UTF-8"));
#else
    // その他のシステム（Linuxなど）の場合
    std::locale::global(std::locale("ja_JP.UTF-8"));
#endif
    auto& demos = list_demos();

    if (demos.empty()) {
        std::cout << "No demos registered. Add .cpp files under cpp/demos/ that register "
                     "themselves.\n";
        return 0;
    }

    if (argc > 1) {
        std::vector<std::string> args(argv + 1, argv + argc);

        bool bench = false;

        // parse minimal flags: --bench and --expect <file>
        std::vector<std::string> demo_args;
        for (size_t i = 0; i < args.size(); ++i) {
            if (args[i] == "--bench") {
                bench = true;
            } else {
                demo_args.push_back(args[i]);
            }
        }

        if (demo_args.empty()) {
            std::cerr << "No demo specified\n";
            return 1;
        }

        std::string id = demo_args[0];
        DemoFn fn;
        try {
            size_t idx = std::stoul(id);
            if (idx >= demos.size()) {
                std::cerr << "Demo index " << idx << " is out of range (0-" << demos.size() - 1 << ")\n";
                return 2;
            }
            fn = demos[idx].second;
        } catch (const std::invalid_argument&) {
            fn = find_demo(id);  // 文字列として処理
        } catch (const std::out_of_range&) {
            std::cerr << "Number too large: " << id << "\n";
            return 2;
        }

        if (!fn) {
            std::cerr << "Unknown demo: " << id << '\n';
            std::cerr << "Available demos: ";
            for (size_t i = 0; i < demos.size(); ++i) {
                std::cerr << i << " (" << demos[i].first << ")";
                if (i < demos.size() - 1) {
                    std::cerr << ", ";
                }
            }
            std::cerr << "\n";
            return 2;
        }

        try {
            if (bench) {
                auto start = std::chrono::high_resolution_clock::now();
                fn(std::vector<std::string>(demo_args.begin() + 1, demo_args.end()));
                auto end = std::chrono::high_resolution_clock::now();
                std::chrono::duration<double> dur = end - start;
                std::cout << "Elapsed: " << dur.count() << " s\n";
            } else {
                fn(std::vector<std::string>(demo_args.begin() + 1, demo_args.end()));
            }
        } catch (const std::exception& e) {
            std::cerr << "Demo execution failed: " << e.what() << "\n";
            return 3;
        } catch (...) {
            std::cerr << "Demo execution failed with unknown error\n";
            return 3;
        }

        return 0;
    }

    // Interactive mode
    std::cout << "Available demos:\n";
    for (size_t i = 0; i < demos.size(); ++i) {
        std::cout << i << ": " << demos[i].first << "\n";
    }

    std::cout << "Select demo index (0-" << demos.size() - 1 << ") and press Enter: ";
    size_t idx = 0;
    if (!(std::cin >> idx)) {
        std::cin.clear();                                                    // エラー状態をクリア
        std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');  // バッファクリア
        std::cerr << "Invalid input. Please enter a number.\n";
        return 1;
    }
    if (idx >= demos.size()) {
        std::cerr << "Invalid index " << idx << ". Valid range is 0-" << demos.size() - 1 << "\n";
        return 2;
    }

    try {
        demos[idx].second(std::vector<std::string>());
    } catch (const std::exception& e) {
        std::cerr << "Demo execution failed: " << e.what() << "\n";
        return 3;
    } catch (...) {
        std::cerr << "Demo execution failed with unknown error\n";
        return 3;
    }
    return 0;
}
