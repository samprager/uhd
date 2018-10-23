/*
 * Copyright 2015,2016 Ettus Research LLC
 * Copyright 2018 Ettus Research, a National Instruments Company
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

/* #undef HAVE_LOG2 */

/* Version macros */
#define UHD_VERSION_MAJOR 3
#define UHD_VERSION_API   14
#define UHD_VERSION_ABI   0
#define UHD_VERSION_PATCH rfnoc-devel
#define ENABLE_USB
/* #undef ENABLE_LIBERIO */
#ifndef UHD_VERSION
#define UHD_VERSION 3140099
#endif

/* Config file path macros */
#define UHD_SYS_CONF_FILE "/etc/uhd/uhd.conf"
#define UHD_USER_CONF_FILE ".uhd/uhd.conf"
