#include "sort/bubble_sort.hpp"

#include "demo_registry.hpp"

#include <iostream>
#include <numeric>
#include <random>
#include <string>
#include <vector>

static void bubble_demo([[maybe_unused]] const std::vector<std::string>& args) {
    std::vector<int> v(10'000);
    std::iota(v.begin(), v.end(), 1);
    std::shuffle(v.begin(), v.end(), std::mt19937(std::random_device()()));

    bubble_sort(v.begin(), v.end(), std::less<>());
    for (auto n : v) {
        std::cout << n << ' ';
    }
    std::cout << '\n';
}

REGISTER_DEMO(bubble, bubble_demo);
