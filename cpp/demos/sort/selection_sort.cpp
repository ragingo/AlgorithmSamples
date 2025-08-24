#include "sort/selection_sort.hpp"
#include "demo_registry.hpp"
#include <algorithm>
#include <numeric>
#include <print>
#include <random>
#include <string>
#include <vector>

using namespace AlgorithmSamples::Sort;

constexpr auto ELEMENT_COUNT = 1'000;

static void selection_sort_demo([[maybe_unused]] const std::vector<std::string>& args) {
    std::println("Selection Sort Demo");
    std::println("{:L} 件のデータを準備します...", ELEMENT_COUNT);

    std::vector<int> v(ELEMENT_COUNT);
    std::iota(v.begin(), v.end(), 1);

    std::println("{:L} 件のデータをシャッフルします...", ELEMENT_COUNT);

    std::shuffle(v.begin(), v.end(), std::mt19937(std::random_device()()));

    std::println("{:L} 件のデータをソートします...", ELEMENT_COUNT);

    auto loopCount = selection_sort(v.begin(), v.end(), std::less<>());

    std::println("{:L} 件のデータのソートが完了しました。", ELEMENT_COUNT);
    std::println("ループ回数: {:L}", loopCount);

    for (auto n : v) {
        std::print("{} ", n);
    }
    std::println();
}

REGISTER_DEMO(selection_sort, selection_sort_demo);
