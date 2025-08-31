#pragma once
#include <array>
#include <cassert>
#include <concepts>
#include <iterator>
#include <tuple>
#include <type_traits>
#include <utility>

namespace AlgorithmSamples::Sort {

template <std::random_access_iterator Iterator, typename Comparator = std::less<>, std::integral Result = size_t>
constexpr Result shaker_sort(Iterator begin, Iterator end, Comparator comparator = {}) {
    if (begin == end || std::next(begin) == end) {
        return 0;
    }

    Result loopCount = 0;

    auto left = begin;
    auto right = std::prev(end);

    while (left < right) {
        // left to right
        for (auto i = left; i != right; ++i) {
            auto next = std::next(i);
            if (comparator(*next, *i)) {
                std::swap(*i, *next);
            }
            ++loopCount;
        }
        --right;

        // right to left
        for (auto i = right; i != left; --i) {
            auto prev = std::prev(i);
            if (comparator(*i, *prev)) {
                std::swap(*i, *prev);
            }
            ++loopCount;
        }
        ++left;
    }

    return loopCount;
}

template <std::integral T, std::size_t N, typename Comparator = std::less<>>
constexpr std::tuple<std::array<T, N>, size_t> shaker_sort(const std::array<T, N>& input, Comparator comparator = {}) {
    std::array<T, N> arr = input;
    auto loopCount = shaker_sort(arr.begin(), arr.end(), comparator);
    return std::make_tuple(arr, loopCount);
}

static_assert(std::get<0>(shaker_sort(std::array{5, 3, 1, 4, 2})) == std::array{1, 2, 3, 4, 5});
static_assert(std::get<0>(shaker_sort(std::array{5, 3, 1, 4, 2}, std::greater<>())) == std::array{5, 4, 3, 2, 1});

}  // namespace AlgorithmSamples::Sort
