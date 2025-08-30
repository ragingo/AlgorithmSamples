#include "sort/shaker_sort.hpp"
#include <vector>
#include <catch2/catch_test_macros.hpp>

using namespace AlgorithmSamples::Sort;

TEST_CASE("shaker_sort - 昇順") {
    std::vector v = {5, 3, 1, 4, 2};
    shaker_sort(v.begin(), v.end());
    REQUIRE(v == std::vector{1, 2, 3, 4, 5});
}

TEST_CASE("shaker_sort - 降順") {
    std::vector v = {5, 3, 1, 4, 2};
    shaker_sort(v.begin(), v.end(), std::greater<>());
    REQUIRE(v == std::vector{5, 4, 3, 2, 1});
}

TEST_CASE("shaker_sort - 要素数 0") {
    std::vector<int> empty;
    shaker_sort(empty.begin(), empty.end(), std::greater<>());
    REQUIRE(empty.empty());
}

TEST_CASE("shaker_sort - 要素数 1") {
    std::vector single = {42};
    shaker_sort(single.begin(), single.end(), std::greater<>());
    REQUIRE(single == std::vector{42});
}
