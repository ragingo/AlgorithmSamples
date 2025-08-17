#pragma once
#include <cassert>
#include <concepts>
#include <iterator>
#include <type_traits>
#include <utility>

template <std::random_access_iterator Iterator, typename Comparator = std::less<>, std::integral Result = std::size_t>
Result bubble_sort(Iterator begin, Iterator end, Comparator comparator = {}) {
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
