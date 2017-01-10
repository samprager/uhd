//
// Copyright 2016 Ettus Research
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

#ifndef INCLUDED_UHD_CAL_POWER_CONTAINER_HPP
#define INCLUDED_UHD_CAL_POWER_CONTAINER_HPP

#include <uhd/config.hpp>
#include <uhd/cal/container.hpp>
#include <boost/shared_ptr.hpp>

namespace uhd {
namespace cal {

class UHD_API power_container : public cal_container<std::vector<double>, double> {
public:
    typedef boost::shared_ptr<power_container> sptr;

    /*!
     * Create a container for data related to power calibration.
     *
     * \returns shared pointer to the container
     */
    static sptr make();

    /*!
     * Get the mapping from an input to an output
     * from the calibration container.
     *
     * \param args input values
     * \returns the output of the mapping (a scalar value)
     * \throws uhd::assertion_error if the number of input values are incorrect
     *         for the container type
     */
    virtual double get(const std::vector<double> &args) = 0;

    /*!
     * Add a data point to the container.
     * This function records a mapping R^n -> R between an input vector
     * and output scalar. For example, a mapping might be
     * (power level, frequency, temperature) -> gain.
     *
     * \param output the output of the data point mapping
     * \param args input values
     */
    virtual void add(const double output, const std::vector<double> &args) = 0;

    /*!
     * Associate some metadata with the container.
     *
     * \param data a map of metadata (string -> string).
     */
    virtual void add_metadata(const metadata_t &data) = 0;

    /*!
     * Retrieve metadata from the container.
     *
     * \returns map of metadata.
     */
    virtual const metadata_t &get_metadata() = 0;
};

} // namespace cal
} // namespace uhd

#endif /* INCLUDED_UHD_CAL_POWER_CONTAINER_HPP */
