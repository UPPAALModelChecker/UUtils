#include "base/meta.hpp"

#include <memory>
#include <vector>

int main()
{
    using namespace meta;

    const auto vi = std::vector{1, 2, 3};  // standard container
    static_assert(is_container_v<decltype(vi)>);
    static_assert(!is_unique_ptr_v<decltype(vi)>);
    static_assert(!is_shared_ptr_v<decltype(vi)>);
    static_assert(!is_smart_ptr_v<decltype(vi)>);

    const int ai[] = {1, 2, 3};  // int[3] is an array -> container
    static_assert(is_container_v<decltype(ai)>);
    static_assert(!is_unique_ptr_v<decltype(ai)>);
    static_assert(!is_shared_ptr_v<decltype(ai)>);
    static_assert(!is_smart_ptr_v<decltype(ai)>);

    const auto pc = "123";  // char* is just a pointer, not a container
    static_assert(!is_container_v<decltype(pc)>);
    static_assert(!is_unique_ptr_v<decltype(pc)>);
    static_assert(!is_shared_ptr_v<decltype(pc)>);
    static_assert(!is_smart_ptr_v<decltype(pc)>);

    const auto upi = std::make_unique<int>(5);
    static_assert(!is_container_v<decltype(upi)>);
    static_assert(is_unique_ptr_v<decltype(upi)>);
    static_assert(!is_shared_ptr_v<decltype(upi)>);
    static_assert(is_smart_ptr_v<decltype(upi)>);

    const auto spi = std::make_shared<int>(5);
    static_assert(!is_container_v<decltype(spi)>);
    static_assert(!is_unique_ptr_v<decltype(spi)>);
    static_assert(is_shared_ptr_v<decltype(spi)>);
    static_assert(is_smart_ptr_v<decltype(spi)>);

    return 0;  // tests are evaluated at compile time
}
