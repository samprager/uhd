var page_uhd =
[
    [ "C API", "page_capi.html", [
      [ "Installing the C API", "page_capi.html#capi_install", null ],
      [ "Using the C API", "page_capi.html#capi_usage", null ]
    ] ],
    [ "Python API", "page_python.html", [
      [ "Installing the Python API", "page_python.html#python_install", [
        [ "Python 2 vs. 3", "page_python.html#python_install_2v3", null ],
        [ "Installing on Windows", "page_python.html#python_install_windows", null ]
      ] ],
      [ "Using the Python API", "page_python.html#python_usage", null ],
      [ "One-off transmit/receive applications", "page_python.html#python_usage_oneoff", null ]
    ] ],
    [ "Coding to the API", "page_coding.html", "page_coding" ],
    [ "Converters", "page_converters.html", [
      [ "Overview", "page_converters.html#converters_overview", null ],
      [ "Formats and Converter Choice", "page_converters.html#converters_formats", [
        [ "Internal format strings", "page_converters.html#converters_formats_internal", null ]
      ] ],
      [ "Hardware-specific Converters", "page_converters.html#converters_accel", null ],
      [ "Registering converters", "page_converters.html#converters_register", [
        [ "Outside of UHD", "page_converters.html#converters_register_extra", null ],
        [ "Inside UHD", "page_converters.html#converters_register_internal", null ]
      ] ]
    ] ],
    [ "Device streaming", "page_stream.html", [
      [ "Introduction to Streaming", "page_stream.html#stream_intro", null ],
      [ "Link Layer Encapsulation", "page_stream.html#stream_lle", null ],
      [ "Data Types", "page_stream.html#stream_datatypes", [
        [ "The host/CPU data type", "page_stream.html#stream_datatypes_cpu", null ],
        [ "The link-layer data type", "page_stream.html#stream_datatypes_otw", null ],
        [ "Conversion", "page_stream.html#stream_datatypes_conv", null ]
      ] ]
    ] ],
    [ "Radio Transport Protocols", "page_rtp.html", [
      [ "VRT", "page_rtp.html#rtp_vrt", null ],
      [ "CHDR", "page_rtp.html#rtp_chdr", null ],
      [ "Tools", "page_rtp.html#vrt_tools", null ],
      [ "Code", "page_rtp.html#vrt_code", null ]
    ] ],
    [ "UHD Semantic Versioning", "page_semver.html", [
      [ "Summary", "page_semver.html#semver_summary", null ],
      [ "Introduction", "page_semver.html#semver_intro", null ],
      [ "UHD-SemVer Specification", "page_semver.html#semver_spec", null ],
      [ "License", "page_semver.html#semver_license", null ]
    ] ],
    [ "UHD Logging", "page_logging.html", [
      [ "Log levels", "page_logging.html#logging_levels", null ],
      [ "Logging Macros", "page_logging.html#logging_macros", null ],
      [ "Logging Backends", "page_logging.html#logging_backends", null ]
    ] ],
    [ "R&D Testing Procedures", "page_rdtesting.html", [
      [ "GPSDO Tests", "page_rdtesting.html#rdtesting_gpsdo", [
        [ "Recommendations", "page_rdtesting.html#rdtesting_gpsdo_recommendations", null ],
        [ "Requirements", "page_rdtesting.html#rdtesting_gpsdo_requirements", null ],
        [ "GPSDO: Manual Test Procedure", "page_rdtesting.html#rdtesting_gpsdo_manual", null ],
        [ "GPSDO: Automatic Test Procedure", "page_rdtesting.html#rdtesting_gpsdo_auto", null ]
      ] ],
      [ "Devtests", "page_rdtesting.html#rdtesting_devtest", [
        [ "Requirements", "page_rdtesting.html#rdtesting_devtest_requirements", null ],
        [ "Devtest: Manual Test Procedure", "page_rdtesting.html#rdtesting_devtest_manual", null ],
        [ "Devtest: Automatic Test Procedure", "page_rdtesting.html#rdtesting_devtest_auto", null ]
      ] ],
      [ "FPGA: Testing through Simulations", "page_rdtesting.html#rdtesting_fpga_testbenches", [
        [ "Requirements", "page_rdtesting.html#rdtesting_fpga_testbenches_requirement", null ],
        [ "Manual Test Procedure", "page_rdtesting.html#rdtesting_fpga_testbenches_manual", null ],
        [ "Automatic Test Procedure", "page_rdtesting.html#rdtesting_fpga_testbenches_auto", null ]
      ] ],
      [ "FPGA DSP Verification", "page_rdtesting.html#rdtesting_fpgadspverif", [
        [ "Requirements", "page_rdtesting.html#rdtesting_fpgadspverif_requirements", null ],
        [ "FPGA DSP Verification: Manual Test Procedure", "page_rdtesting.html#rdtesting_fpgadspverif_manual", null ],
        [ "FPGA DSP Verification: Automatic Test Procedure", "page_rdtesting.html#rdtesting_fpgadspverif_auto", null ]
      ] ],
      [ "FPGA Functional Verification", "page_rdtesting.html#rdtesting_fpgafuncverif", [
        [ "Requirements", "page_rdtesting.html#rdtesting_fpgafuncverif_requirements", null ],
        [ "FPGA Functional Verification: Manual Test Procedure", "page_rdtesting.html#rdtesting_fpgafuncverif_manual", null ],
        [ "FPGA Functional Verification: Automatic Test Procedure", "page_rdtesting.html#rdtesting_fpgafuncverif_auto", null ]
      ] ],
      [ "Phase alignment tests", "page_rdtesting.html#rdtesting_phasealignment", [
        [ "Manual phase alignment testing (Receiver)", "page_rdtesting.html#rdtesting_phase_rx_manual", null ],
        [ "X3x0 with TwinRX", "page_rdtesting.html#rdtesting_phase_rx_X3x0_twinrx", null ],
        [ "X3x0 with SBX or UBX", "page_rdtesting.html#rdtesting_phase_rx_X3x0_sbx_ubx", null ],
        [ "N2x0 MIMO with SBX", "page_rdtesting.html#rdtesting_phase_rx_N2x0_MIMO", null ],
        [ "Automatic phase alignment testing (Receiver)", "page_rdtesting.html#rdtesting_phase_rx_auto", null ]
      ] ],
      [ "BISTs", "page_rdtesting.html#rdtesting_bist", [
        [ "N300/N310 Manual Procedure", "page_rdtesting.html#rdtesting_bist_n3x0_manual", null ],
        [ "N300/N310 Automatic Procedure", "page_rdtesting.html#rdtesting_bist_n3x0_auto", null ]
      ] ],
      [ "Required Peripherals", "page_rdtesting.html#rdtesting_n3xx_peripherals", null ],
      [ "DB15 GPIO Loopback", "page_rdtesting.html#rdtesting_n3xx_peripherals_gpiolb", [
        [ "E320 Manual Procedure", "page_rdtesting.html#rdtesting_bist_e320_manual", null ],
        [ "E320 Automatic Procedure", "page_rdtesting.html#rdtesting_bist_e320_auto", null ]
      ] ],
      [ "Required Peripherals", "page_rdtesting.html#rdtesting_e320_peripherals", null ],
      [ "GPIO Loopback", "page_rdtesting.html#rdtesting_e320_peripherals_gpiolb", null ],
      [ "Defining R&D Tests", "page_rdtesting.html#rdtesting_defining", null ]
    ] ]
];