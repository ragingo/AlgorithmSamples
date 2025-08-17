#include "sort/bubble_sort.hpp"

#include "demo_registry.hpp"

#include <algorithm>
#include <iostream>
#include <numeric>
#include <random>
#include <string>
#include <vector>

constexpr auto ELEMENT_COUNT = 10'000;

static void bubble_sort_demo([[maybe_unused]] const std::vector<std::string>& args) {
    std::cout << "Bubble Sort Demo" << std::endl;
    std::cout << ELEMENT_COUNT << " 件のデータを準備します..." << std::endl;

    std::vector<int> v(ELEMENT_COUNT);
    std::iota(v.begin(), v.end(), 1);

    std::cout << ELEMENT_COUNT << " 件のデータをシャッフルします..." << std::endl;

    std::shuffle(v.begin(), v.end(), std::mt19937(std::random_device()()));

    std::cout << ELEMENT_COUNT << " 件のデータをソートします..." << std::endl;

    bubble_sort(v.begin(), v.end(), std::less<>());

    std::cout << ELEMENT_COUNT << " 件のデータのソートが完了しました。" << std::endl;

    for (auto n : v) {
        std::cout << n << ' ';
    }
    std::cout << '\n';
}

REGISTER_DEMO(bubble_sort, bubble_sort_demo);
