//
// Copyright 2012-2013,2016-2017 Ettus Research LLC
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#ifndef INCLUDED_UHD_UTILS_ATOMIC_HPP
#define INCLUDED_UHD_UTILS_ATOMIC_HPP

#include <uhd/config.hpp>
#include <uhd/types/time_spec.hpp>
#include <boost/thread/thread.hpp>
#include <atomic>

namespace uhd{

    /*!
     * Spin-wait on a condition with a timeout.
     * \param cond an atomic variable to compare
     * \param value compare to atomic for true/false
     * \param timeout the timeout in seconds
     * \return true for cond == value, false for timeout
     */
    template<typename T>
    UHD_INLINE bool spin_wait_with_timeout(
        std::atomic<T> &cond,
        const T value,
        const double timeout
    ){
        if (cond == value) return true;
        const time_spec_t exit_time = time_spec_t::get_system_time() + time_spec_t(timeout);
        while (cond != value) {
            if (time_spec_t::get_system_time() > exit_time) {
                return false;
            }
            boost::this_thread::interruption_point();
            boost::this_thread::yield();
        }
        return true;
    }

    /*!
     * Claimer class to provide synchronization for multi-thread access.
     * Claiming enables buffer classes to be used with a buffer queue.
     */
    class simple_claimer{
    public:
        simple_claimer(void){
            this->release();
        }

        UHD_INLINE void release(void){
            _locked = false;
        }

        UHD_INLINE bool claim_with_wait(const double timeout){
            if (spin_wait_with_timeout(_locked, false, timeout)){
                _locked = true;
                return true;
            }
            return false;
        }

    private:
        std::atomic<bool> _locked;
    };

} //namespace uhd

#endif /* INCLUDED_UHD_UTILS_ATOMIC_HPP */
