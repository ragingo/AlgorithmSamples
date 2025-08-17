#pragma once
#include <cassert>
#include <iterator>
#include <type_traits>
#include <utility>

template <typename Iterator, typename Comparator = std::less<>>
void bubble_sort(Iterator begin, Iterator end, Comparator comparator = {}) {
    if (begin == end || std::next(begin) == end) {
        return;
    }

    for (auto a = begin; a != end; ++a) {
        bool swapped = false;
        for (auto b = begin; std::next(b) != end; ++b) {
            if (comparator(*std::next(b), *b)) {
                std::swap(*std::next(b), *b);
                swapped = true;
            }
        }
        if (!swapped) {
            break;
        }
    }
}
