#include "sort/selection_sort.hpp"
#include <array>
#include <vector>
#include <catch2/catch_test_macros.hpp>

using namespace AlgorithmSamples::Sort;

TEST_CASE("selection_sort - 昇順") {
    std::vector v = {5, 3, 1, 4, 2};
    auto loop_count = selection_sort(v.begin(), v.end());
    REQUIRE(v == std::vector{1, 2, 3, 4, 5});
    REQUIRE(loop_count > 0);
}

TEST_CASE("selection_sort - 降順") {
    std::vector v = {5, 3, 1, 4, 2};
    auto loop_count = selection_sort(v.begin(), v.end(), std::greater<>());
    REQUIRE(v == std::vector{5, 4, 3, 2, 1});
    REQUIRE(loop_count > 0);
}

TEST_CASE("selection_sort - 要素数 0") {
    std::vector<int> empty;
    auto loop_count = selection_sort(empty.begin(), empty.end());
    REQUIRE(empty.empty());
    REQUIRE(loop_count == 0);
}

TEST_CASE("selection_sort - 要素数 1") {
    std::vector single = {42};
    auto loop_count = selection_sort(single.begin(), single.end());
    REQUIRE(single == std::vector{42});
    REQUIRE(loop_count == 0);
}

TEST_CASE("selection_sort - 要素数 2") {
    std::vector two_elements = {2, 1};
    auto loop_count = selection_sort(two_elements.begin(), two_elements.end());
    REQUIRE(two_elements == std::vector{1, 2});
    REQUIRE(loop_count == 1);
}

TEST_CASE("selection_sort - 既にソート済み") {
    std::vector sorted = {1, 2, 3, 4, 5};
    auto loop_count = selection_sort(sorted.begin(), sorted.end());
    REQUIRE(sorted == std::vector{1, 2, 3, 4, 5});
    REQUIRE(loop_count > 0);
}

TEST_CASE("selection_sort - 逆順") {
    std::vector reversed = {5, 4, 3, 2, 1};
    auto loop_count = selection_sort(reversed.begin(), reversed.end());
    REQUIRE(reversed == std::vector{1, 2, 3, 4, 5});
    REQUIRE(loop_count > 0);
}

TEST_CASE("selection_sort - 重複要素あり") {
    std::vector duplicates = {3, 1, 4, 1, 5, 9, 2, 6, 5};
    auto loop_count = selection_sort(duplicates.begin(), duplicates.end());
    REQUIRE(duplicates == std::vector{1, 1, 2, 3, 4, 5, 5, 6, 9});
    REQUIRE(loop_count > 0);
}

TEST_CASE("selection_sort - コンパイル時ソート") {
    constexpr auto result = selection_sort(std::array{5, 3, 1, 4, 2});
    REQUIRE(std::get<0>(result) == std::array{1, 2, 3, 4, 5});
    REQUIRE(std::get<1>(result) > 0);
}

TEST_CASE("selection_sort - コンパイル時降順ソート") {
    constexpr auto result = selection_sort(std::array{5, 3, 1, 4, 2}, std::greater<>());
    REQUIRE(std::get<0>(result) == std::array{5, 4, 3, 2, 1});
    REQUIRE(std::get<1>(result) > 0);
}

TEST_CASE("selection_sort - 空配列") {
    constexpr auto result = selection_sort(std::array<int, 0>{});
    REQUIRE(std::get<0>(result) == std::array<int, 0>{});
    REQUIRE(std::get<1>(result) == 0);
}

TEST_CASE("selection_sort - 単一要素") {
    constexpr auto result = selection_sort(std::array{42});
    REQUIRE(std::get<0>(result) == std::array{42});
    REQUIRE(std::get<1>(result) == 0);
}

TEST_CASE("selection_sort - 文字列ソート") {
    std::vector<std::string> strings = {"banana", "apple", "cherry", "date"};
    selection_sort(strings.begin(), strings.end());
    REQUIRE(strings == std::vector<std::string>{"apple", "banana", "cherry", "date"});
}

TEST_CASE("selection_sort - 浮動小数点数") {
    std::vector<double> floats = {3.14, 2.71, 1.41, 1.73};
    selection_sort(floats.begin(), floats.end());
    REQUIRE(floats == std::vector<double>{1.41, 1.73, 2.71, 3.14});
}
