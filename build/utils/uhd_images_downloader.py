#!/usr/bin/env python
#
# Copyright 2018 Ettus Research, a National Instruments Company
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
"""
Download image files required for USRPs
"""
from __future__ import print_function
import argparse
import hashlib
import json
import math
import os
import re
import shutil
import sys
import tempfile
import zipfile
import requests
try:
    from urllib.parse import urljoin  # Python 3
except ImportError:
    from urlparse import urljoin      # Python 2


_DEFAULT_TARGET_REGEX     = "(fpga|fw|windrv)_default"
_BASE_DIR_STRUCTURE_PARTS = ["share", "uhd", "images"]
_DEFAULT_INSTALL_PATH     = os.path.join("/usr/local", *_BASE_DIR_STRUCTURE_PARTS)
_DEFAULT_BASE_URL         = "http://files.ettus.com/binaries/cache/"
_INVENTORY_FILENAME       = "inventory.json"
_CONTACT                  = "support@ettus.com"
_DEFAULT_BUFFER_SIZE      = 8192
_ARCHIVE_ALGS             = ["zip", "targz", "tarxz"]
_ARCHIVE_DEFAULT_TYPE     = "zip"
_UHD_VERSION              = "3.14.0.rfnoc-devel-783-g9e1383d8"
# Note: _MANIFEST_CONTENTS are placed at the bottom of this file for aesthetic reasons
_LOG_LEVELS = {"TRACE": 1,
               "DEBUG": 2,
               "INFO": 3,
               "WARN": 4,
               "ERROR": 5}
_LOG_LEVEL = _LOG_LEVELS["INFO"]


# TODO: Move to a standard logger?
def log(level, message):
    """Logging function"""
    message_log_level = _LOG_LEVELS.get(level, 0)
    if message_log_level >= _LOG_LEVEL:
        print("[{level}] {message}".format(level=level, message=message))


def parse_args():
    """Setup argument parser and parse"""
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('-t', '--types', action='append',
                        help="RegEx to select image sets from the manifest file.")
    parser.add_argument('-i', '--install-location',
                        default=None,
                        help="Set custom install location for images")
    parser.add_argument('-m', '--manifest-location', type=str, default="",
                        help="Set custom location for the manifest file")
    parser.add_argument('-I', '--inventory-location', type=str, default="",
                        help="Set custom location for the inventory file")
    parser.add_argument('-l', '--list-targets', action="store_true", default=False,
                        help="Print targets in the manifest file, and exit.")
    parser.add_argument("--buffer-size", type=int, default=_DEFAULT_BUFFER_SIZE,
                        help="Set download buffer size")
    parser.add_argument("-b", "--base-url", type=str, default=_DEFAULT_BASE_URL,
                        help="Set base URL for images download location")
    parser.add_argument("-z", "--archive-type", type=str, default=_ARCHIVE_DEFAULT_TYPE,
                        help=("Select archiving function (options: {})"
                              .format(",".join(_ARCHIVE_ALGS))))
    parser.add_argument("-k", "--keep", action="store_true", default=False,
                        help="Keep the downloaded images archives in the image directory")
    parser.add_argument("-T", "--test", action="store_true", default=False,
                        help="Verify the downloaded archives before extracting them")
    parser.add_argument("-n", "--dry-run", action="store_true", default=False,
                        help="Print selected target without actually downloading them.")
    parser.add_argument("--refetch", action="store_true", default=False,
                        help="Ignore the inventory file and download all images.")
    parser.add_argument('-V', '--version', action='version', version=_UHD_VERSION)
    parser.add_argument('-q', '--quiet', action='count', default=0,
                        help="Decrease verbosity level")
    parser.add_argument('-v', '--verbose', action='count', default=0,
                        help="Increase verbosity level")
    return parser.parse_args()


class TemporaryDirectory:
    """Class to create a temporary directory"""
    def __enter__(self):
        try:
            self.name = tempfile.mkdtemp()
            return self.name
        except Exception as ex:
            log("ERROR", "Failed to create a temporary directory (%s)" % ex)
            raise ex

    # Can return 'True' to suppress incoming exception
    def __exit__(self, exc_type, exc_value, traceback):
        try:
            shutil.rmtree(self.name)
            log("TRACE", "Temp directory deleted.")
        except Exception as ex:
            log("ERROR", "Could not delete temporary directory: %s (%s)" % (self.name, ex))
        return exc_type is None


def parse_manifest(manifest_contents):
    """Parse the manifest file, returns a dictionary of potential targets"""
    manifest = {}
    for line in manifest_contents.split('\n'):
        line_unpacked = line.split()
        try:
            # Check that the line isn't empty or a comment
            if not line_unpacked or line.strip().startswith('#'):
                continue

            target, repo_hash, url, sha256_hash = line_unpacked
            manifest[target] = {"repo_hash": repo_hash,
                                "url": url,
                                "sha256_hash": sha256_hash,
                                }
        except ValueError:
            log("WARN", "Warning: Invalid line in manifest file:\n"
                "         {}".format(line))
            continue
    return manifest


def parse_inventory(inventory_fn):
    """Parse the inventory file, returns a dictionary of installed files"""
    try:
        if not os.path.exists(inventory_fn):
            log("INFO", "No inventory file found at {}. Creating an empty one.".format(inventory_fn))
            return {}
        with open(inventory_fn, 'r') as inventory_file:
            # TODO: verify the contents??
            return json.load(inventory_file)
    except Exception as ex:
        log("WARN", "Error parsing the inventory file. Assuming an empty inventory: {}".format(ex))
        return {}


def write_inventory(inventory, inventory_fn):
    """Writes the inventory to file"""
    try:
        with open(inventory_fn, 'w') as inventory_file:
            json.dump(inventory, inventory_file)
            return True
    except Exception as ex:
        log("ERROR", "Error writing the inventory file. Contents may be incomplete or corrupted.\n"
                     "Error message: {}".format(ex))
        return False


def lookup_urls(regex_l, manifest, inventory, refetch=False):
    """Takes a list of RegExs to match within the manifest, returns a list of tuples with
    (hash, URL) that match the targets and are not in the inventory"""
    selected_targets = []
    # Store whether or not we've found a target in the manifest that matches the requested type
    found_one = False
    for target in manifest.keys():
        # Iterate through the possible targets in the manifest.
        # If any of them match any of the RegExs supplied, add the URL to the
        # return list
        if all(map((lambda regex: re.findall(regex, target)), regex_l)):
            found_one = True
            log("TRACE", "Selected target: {}".format(target))
            target_info = manifest.get(target)
            target_url = target_info.get("url")
            target_hash = target_info.get("repo_hash")
            target_sha256 = target_info.get("sha256_hash")
            filename = os.path.basename(target_url)
            # Check if the same filename and hash appear in the inventory
            if not refetch and inventory.get(target, {}).get("repo_hash", "") == target_hash:
                # We already have this file, we don't need to download it again
                log("INFO", "Target {} is up to date.".format(target))
            else:
                # We don't have that exact file, add it to the list
                selected_targets.append({"target": target,
                                         "repo_hash": target_hash,
                                         "filename": filename,
                                         "url": target_url,
                                         "sha256_hash": target_sha256})
    if not found_one:
        log("INFO", "No targets matching '{}'".format(regex_l))
    return selected_targets


def download(images_url, filename, buffer_size=_DEFAULT_BUFFER_SIZE, print_progress=False):
    """ Run the download, show progress """
    log("TRACE", "Downloading {} to {}".format(images_url, filename))
    try:
        resp = requests.get(images_url, stream=True,
                            headers={'User-Agent': 'UHD Images Downloader'})
    except TypeError:
        # requests library versions pre-4c3b9df6091b65d8c72763222bd5fdefb7231149
        # (Dec.'12) workaround
        resp = requests.get(images_url, prefetch=False,
                            headers={'User-Agent': 'UHD Images Downloader'})
    if resp.status_code != 200:
        raise RuntimeError("URL does not exist: {}".format(images_url))
    filesize = float(resp.headers['content-length'])
    filesize_dl = 0
    base_filename = os.path.basename(filename)
    if print_progress and not sys.stdout.isatty():
        print_progress = False
        log("INFO", "Downloading {}, total size: {} kB".format(
            base_filename, filesize/1000))
    with open(filename, "wb") as temp_file:
        sha256_sum = hashlib.sha256()
        for buff in resp.iter_content(chunk_size=buffer_size):
            if buff:
                temp_file.write(buff)
                filesize_dl += len(buff)
                sha256_sum.update(buff)
            if print_progress:
                status = r"%05d kB / %05d kB (%03d%%) %s" % (
                    int(math.ceil(filesize_dl / 1000.)), int(math.ceil(filesize / 1000.)),
                    int(math.ceil(filesize_dl * 100.) / filesize),
                    base_filename)
                if os.name == "nt":
                    status += chr(8) * (len(status) + 1)
                else:
                    sys.stdout.write("\x1b[2K\r")  # Clear previous line
                sys.stdout.write(status)
                sys.stdout.flush()
    if print_progress:
        print('')
    return filesize, filesize_dl, sha256_sum.hexdigest()


def delete_from_inv(target_info, inventory, images_dir):
    """
    Uses the inventory to delete the contents of the archive file specified by in `target_info`
    """
    target = inventory.get(target_info.get("target"), {})
    target_name = target.get("target")
    log("TRACE", "Removing contents of {} from inventory ({})".format(
        target, target.get("contents", [])))
    dirs_to_delete = []
    # Delete all of the files
    for image_fn in target.get("contents", []):
        image_path = os.path.join(images_dir, image_fn)
        if os.path.isfile(image_path):
            os.remove(image_path)
            log("TRACE", "Deleted {} from inventory".format(image_path))
        elif os.path.isdir(image_path):
            dirs_to_delete.append(image_fn)
        else: # File doesn't exist
            log("WARN", "File {} in inventory does not exist".format(image_path))
    # Then delete all of the (empty) directories
    for dir_path in dirs_to_delete:
        try:
            if os.path.isdir(dir_path):
                os.removedirs(dir_path)
        except os.error as ex:
            log("ERROR", "Failed to delete dir: {}".format(ex))
    inventory.pop(target_name, None)
    return True


def extract(archive_path, images_dir, archive_type, test_zip=False):
    """Extract the contents of the archive into `images_dir`"""
    if archive_type == "zip":
        log("TRACE", "Attempting to extracted files from {}".format(archive_path))
        with zipfile.ZipFile(archive_path) as images_zip:
            # Check that the Zip file is valid, in which case `testzip()` returns None.
            # If its bad, that function will return a list of bad files
            try:
                if test_zip and images_zip.testzip():
                    log("ERROR", "Could not extract the following invalid Zip file:"
                                 " {}".format(archive_path))
                    return []
            except OSError:
                log("ERROR", "Could not extract the following invalid Zip file:"
                             " {}".format(archive_path))
                return []
            images_zip.extractall(images_dir)
            archive_namelist = images_zip.namelist()
            log("TRACE", "Extracted files: {}".format(archive_namelist))
            return archive_namelist
    else:
        raise NotImplementedError("Archive type {} not implemented".format(archive_type))


def main():
    """Download the image files requested by the user"""
    args = parse_args()
    archive_type = args.archive_type
    if archive_type not in _ARCHIVE_ALGS:
        log("ERROR", "Selected archive type not supported: {}".format(archive_type))
        return 1
    # Set the verbosity
    global _LOG_LEVEL
    log("TRACE", "Default log level: {}".format(_LOG_LEVEL))
    _LOG_LEVEL = _LOG_LEVEL - args.verbose + args.quiet
    images_dir = _DEFAULT_INSTALL_PATH
    if args.install_location:
        images_dir = args.install_location
    elif os.environ.get("UHD_IMAGES_DIR") != None and os.environ.get("UHD_IMAGES_DIR") != "":
        images_dir = os.environ.get("UHD_IMAGES_DIR")
        log("DEBUG",
            "UHD_IMAGES_DIR environment variable is set, using to set "
            "install location.")
    log("INFO", "Images destination: {}".format(os.path.abspath(images_dir)))
    try:
        # If we're given a path to a manifest file, use it
        if os.path.exists(args.manifest_location):
            manifest_fn = args.manifest_location
            log("INFO", "Using manifest file at location: {}".format(manifest_fn))
            with open(manifest_fn, 'r') as manifest_file:
                manifest_raw = manifest_file.read()
        # Otherwise, use the CMake Magic manifest
        else:
            manifest_raw = _MANIFEST_CONTENTS
            log("TRACE", "Raw manifest contents: {}".format(manifest_raw))

        manifest = parse_manifest(manifest_raw)
        if args.list_targets:
            char_offset = max(map(len, manifest.keys()))
            # Print a couple helpful lines,
            # then print each (Target, URL) pair in the manifest
            log("INFO", "Potential targets in manifest file:\n"
                        "{} : {}\n"
                        "{}".format(
                "# TARGET".ljust(char_offset), "RELATIVE_URL",
                "\n".join("{} : {}".format(key.ljust(char_offset), value["url"])
                          for key, value in sorted(manifest.items()))
            ))
            return 0
        else:
            log("TRACE", "Manifest:\n{}".format(
                "\n".join("{}".format(item) for item in manifest.items())
            ))

        # Read the inventory into a dictionary we can perform lookups on
        if os.path.isfile(args.inventory_location):
            inventory_fn = args.inventory_location
        else:
            inventory_fn = os.path.join(images_dir, _INVENTORY_FILENAME)
        inventory = parse_inventory(inventory_fn=inventory_fn)
        log("TRACE", "Inventory: {}\n{}".format(
            os.path.abspath(inventory_fn),
            "\n".join("{}".format(item) for item in inventory.items())
        ))

        # Determine the URLs to download based on the input regular expressions
        if not args.types:
            types_regex_l = [_DEFAULT_TARGET_REGEX]
        else:
            types_regex_l = args.types

        log("TRACE", "RegExs for target selection: {}".format(types_regex_l))
        targets_info = lookup_urls(types_regex_l, manifest, inventory, args.refetch)
        # Exit early if we don't have anything to download
        if targets_info:
            target_urls = [info.get("url") for info in targets_info]
            log("DEBUG", "URLs to download:\n{}".format(
                "\n".join("{}".format(item) for item in target_urls)
            ))
        else:
            return 0

        with TemporaryDirectory() as temp_dir:
            # Now download all the images archives into a temp directory
            for target_info in targets_info:
                target_name = target_info.get("target")
                target_hash = target_info.get("repo_hash")
                target_rel_url = target_info.get("url")
                target_sha256 = target_info.get("sha256_hash")
                filename = target_info.get("filename")
                temp_path = os.path.join(temp_dir, filename)
                # Add a trailing slash to make sure that urljoin handles things properly
                full_url = urljoin(args.base_url+'/', target_rel_url)
                if not args.dry_run:
                    _, downloaded_size, downloaded_sha256 = download(
                        images_url=full_url,
                        filename=temp_path,
                        buffer_size=args.buffer_size,
                        print_progress=(_LOG_LEVEL <= _LOG_LEVELS.get("INFO", 3))
                    )
                    log("TRACE", "{} successfully downloaded ({} Bytes)"
                        .format(temp_path, downloaded_size))

                    # If the SHA256 in the manifest has the value '0', this is a special case and
                    # we just skip the verification step
                    if target_sha256 == '0':
                        log("DEBUG", "Skipping SHA256 check for {}.".format(full_url))
                    # If the check fails, print an error and don't unzip the file
                    elif downloaded_sha256 != target_sha256:
                        log("ERROR", "Downloaded SHA256 does not match manifest for {}!".format(
                            full_url))
                        continue
                        # Note: this skips the --keep option, so we'll never keep image packages
                        #       that fail the SHA256 checksum

                    # Otherwise, the check has succeeded, and we can proceed
                    delete_from_inv(target_info, inventory, images_dir)
                    archive_namelist = extract(temp_path, images_dir, archive_type, args.test)
                    if args.keep:
                        # If the user wants to keep the downloaded archive,
                        # save it to the images directory and add it to the inventory
                        shutil.copy(temp_path, images_dir)
                        archive_namelist.append(filename)
                    inventory[target_name] = {"repo_hash": target_hash,
                                              "contents": archive_namelist,
                                              "filename": filename}
                else:
                    log("INFO", "[Dry run] {} successfully downloaded"
                        .format(filename))

        if not args.dry_run:
            write_inventory(inventory, inventory_fn)

    except Exception as ex:
        log("ERROR", "Downloader raised an unhandled exception: {ex}\n"
            "You can run this again with the '--verbose' flag to see more information\n"
            "If the problem persists, please email the output to: {contact}"
            .format(contact=_CONTACT, ex=ex))
        return 1
    log("INFO", "Images download complete.")
    return 0

# Placing this near the end of the file so we don't clutter the top
_MANIFEST_CONTENTS = """# UHD Image Manifest File
# Target    hash    url     SHA256
# X300-Series
x3xx_x310_fpga_default          fpga-340bb076       x3xx/fpga-340bb076/x3xx_x310_fpga_default-g340bb076.zip                 2dde0922921e22575210eea9f0afa20df31176059240f9df607c53f7a03a203b
x3xx_x300_fpga_default          fpga-340bb076       x3xx/fpga-340bb076/x3xx_x300_fpga_default-g340bb076.zip                 bfd78d791067cf072298395667ff5e9779707ed95dce0c2c03c4edc3724ebe25
# Example daughterboard targets (none currently exist)
#x3xx_twinrx_cpld_default   example_target
#dboard_ubx_cpld_default    example_target

# E-Series
e3xx_e310_fpga_default          fpga-615d9b8        e3xx/fpga-615d9b8/e3xx_e310_fpga_default-g615d9b8.zip                   058c0536ff70f5026e0e1ad9f88583599603b10c770906cdbfd68435adb4c0ef
e3xx_e310_fpga_rfnoc            fpga-d6a878b        e3xx/fpga-d6a878b/e3xx_e310_fpga_rfnoc-gd6a878b.zip                     5c9b89fb6293423644868c22e914de386a9af39ff031da6800a1cf39a90ea73b
# N300-Series
n3xx_n310_fpga_default          fpga-ebf5eed        n3xx/fpga-ebf5eed/n3xx_n310_fpga_default-gebf5eed.zip                   319d9ed9f08777461c74dda1d7b83ac379d3acf51a98a8f839fa4e413e18c18f
n3xx_n300_fpga_default          fpga-ebf5eed        n3xx/fpga-ebf5eed/n3xx_n300_fpga_default-gebf5eed.zip                   e45d24ae1aa32e905b512d1012ce4dbac21a57c22cf8e3193909a4d94bbdc157
#n3xx_n310_fpga_aurora           fpga-1107862        n3xx/fpga-1107862/n3xx_n310_fpga_aurora-g1107862.zip                    3926d6b247a8f931809460d3957cec51f8407cd3f7aea6f4f3b91d1bbb427c7d
#n3xx_n300_fpga_aurora           fpga-1107862        n3xx/fpga-1107862/n3xx_n300_fpga_aurora-g1107862.zip                    e34e9343572adfba905433a1570cb394fe45207d442268d0fa400c3406253530
#n3xx_n310_cpld_default         fpga-6bea23d        n3xx/fpga-6bea23d/n3xx_n310_cpld_default-g6bea23d.zip                   0
# N3XX Mykonos firmware
#n3xx_n310_fw_default           fpga-6bea23d        n3xx/fpga-6bea23d/n3xx_n310_fw_default-g6bea23d.zip                     0
# N300-Series Filesystems, etc
n3xx_common_sdk_default         meta-ettus-v3.13.0.0  n3xx/meta-ettus-v3.13.0.0/n3xx_common_sdk_default-v3.13.0.0.zip       0
n3xx_common_mender_default      meta-ettus-v3.13.0.0  n3xx/meta-ettus-v3.13.0.0/n3xx_common_mender_default-v3.13.0.0.zip    0
n3xx_common_sdimg_default       meta-ettus-v3.13.0.0  n3xx/meta-ettus-v3.13.0.0/n3xx_common_sdimg_default-v3.13.0.0.zip     0

# B200-Series
b2xx_b200_fpga_default          fpga-63e630a        b2xx/fpga-63e630a/b2xx_b200_fpga_default-g63e630a.zip                   c42f010a90c9a184a2bf8ab7182dcbcc50598a259f06f9b5fda92023dc6cfed8
b2xx_b200mini_fpga_default      fpga-63e630a        b2xx/fpga-63e630a/b2xx_b200mini_fpga_default-g63e630a.zip               75ae4b16d8dc12ab8b38e7f380cb94e81c6065031aefd2e72972f65ec8c23842
b2xx_b210_fpga_default          fpga-63e630a        b2xx/fpga-63e630a/b2xx_b210_fpga_default-g63e630a.zip                   de7464dac5a1cd5be38811f3ec8239410ff5d9d2a8d199039e09de3c423bc63d
b2xx_b205mini_fpga_default      fpga-63e630a        b2xx/fpga-63e630a/b2xx_b205mini_fpga_default-g63e630a.zip               d852c4f0038e6b12fed19303c7baabfd8785271aa00b327c80d22a39835661fa
b2xx_common_fw_default          uhd-455a288         b2xx/uhd-455a288/b2xx_common_fw_default-g455a288.zip                  ac53d8bf9cda7508cb3ee09d190de08495ba9e519279e77f9927eccc953144f6

# USRP2 Devices
usrp2_usrp2_fw_default          fpga-6bea23d        usrp2/fpga-6bea23d/usrp2_usrp2_fw_default-g6bea23d.zip                  d523a18318cb6a7637be40484bf03a6f54766410fee2c1a1f72e8971ea9a9cb6
usrp2_usrp2_fpga_default        fpga-6bea23d        usrp2/fpga-6bea23d/usrp2_usrp2_fpga_default-g6bea23d.zip                505c70aedc8cdfbbfe654bcdbe1ce604c376e733a44cdd1351571f61a7f1cb49
usrp2_n200_fpga_default         fpga-6bea23d        usrp2/fpga-6bea23d/usrp2_n200_fpga_default-g6bea23d.zip                 833a0098d66c0c502b9c3975d651a79e125133c507f9f4b2c472f9eb96fdaef8
usrp2_n200_fw_default           fpga-6bea23d        usrp2/fpga-6bea23d/usrp2_n200_fw_default-g6bea23d.zip                   3eee2a6195caafe814912167fccf2dfc369f706446f8ecee36e97d2c0830116f
usrp2_n210_fpga_default         fpga-6bea23d        usrp2/fpga-6bea23d/usrp2_n210_fpga_default-g6bea23d.zip                 5ce68ac539ee6eeb7d04fb3127c1fabcaff442a8edfaaa2f3746590f9df909bd
usrp2_n210_fw_default           fpga-6bea23d        usrp2/fpga-6bea23d/usrp2_n210_fw_default-g6bea23d.zip                   3646fcd3fc974d18c621cb10dfe97c4dad6d282036dc63b7379995dfad95fb98
n230_n230_fpga_default          fpga-615d9b8        n230/fpga-615d9b8/n230_n230_fpga_default-g615d9b8.zip                   9609e48c14766b8f05f48c13a17d6511807e86d70778fe54c1a3e608e6c92687

# USRP1 Devices
usrp1_usrp1_fpga_default        fpga-6bea23d        usrp1/fpga-6bea23d/usrp1_usrp1_fpga_default-g6bea23d.zip                03bf72868c900dd0853bf48e2ede91058d579829b0e70c021e51b0e282d1d5be
usrp1_b100_fpga_default         fpga-6bea23d        usrp1/fpga-6bea23d/usrp1_b100_fpga_default-g6bea23d.zip                 7f2306f21e17aa3fae3f966d08c6297d6cf42041974f846ca89f0d633ece8769
usrp1_b100_fw_default           fpga-6bea23d        usrp1/fpga-6bea23d/usrp1_b100_fw_default-g6bea23d.zip                   867f17fac085535dbcb01c226ce87acf49806de6ed0ae9b214d7c8da86e2a71d

# Octoclock
octoclock_octoclock_fw_default  uhd-14000041        octoclock/uhd-14000041/octoclock_octoclock_fw_default-g14000041.zip     8da7f1af8cecb7f6259a237a18c39058ba69a11567fa373cffc9704031a1d053

# Legacy USB Windows drivers
usb_common_windrv_default       uhd-14000041        usb/uhd-14000041/usb_common_windrv_default-g14000041.zip                835e94b2bdf2312fd3881a1b78e2ec236c1f42b7a5bd3927f85f73cf5e3a5231
"""
if __name__ == "__main__":
    sys.exit(main())
