#pragma once
#include <array>
#include <cassert>
#include <concepts>
#include <iterator>
#include <type_traits>
#include <utility>

namespace AlgorithmSamples::Sort {

template <std::random_access_iterator Iterator, typename Comparator = std::less<>, std::integral Result = size_t>
constexpr Result bubble_sort(Iterator begin, Iterator end, Comparator comparator = {}) {
    if (begin == end || std::next(begin) == end) {
        return 0;
    }

    Result loopCount = 0;
    for (auto a = std::prev(end); a != begin; --a) {
        for (auto b = begin; b != a; ++b) {
            if (comparator(*std::next(b), *b)) {
                std::swap(*std::next(b), *b);
            }
            ++loopCount;
        }
    }
    return loopCount;
}

template <std::integral T, std::size_t N, typename Comparator = std::less<>>
constexpr std::array<T, N> bubble_sort_const(const std::array<T, N>& input, Comparator comparator = {}) {
    std::array<T, N> arr = input;
    if (input.begin() == input.end() || std::next(input.begin()) == input.end()) {
        return arr;
    }

    for (auto a = std::prev(arr.end()); a != arr.begin(); --a) {
        for (auto b = arr.begin(); b != a; ++b) {
            if (comparator(*std::next(b), *b)) {
                std::swap(*std::next(b), *b);
            }
        }
    }
    return arr;
}

static_assert(bubble_sort_const(std::array{5, 3, 1, 4, 2}) == std::array{1, 2, 3, 4, 5});
static_assert(bubble_sort_const(std::array{5, 3, 1, 4, 2}, std::greater<>()) == std::array{5, 4, 3, 2, 1});

}  // namespace AlgorithmSamples::Sort
