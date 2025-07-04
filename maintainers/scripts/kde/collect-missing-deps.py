#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3
import pathlib

OK_MISSING = {
    # we don't use precompiled QML
    'Qt6QuickCompiler',
    'Qt6QmlCompilerPlusPrivate',
    # usually used for version numbers
    'Git',
    # useless by itself, will warn if something else is not found
    'PkgConfig',
    # license verification
    'ReuseTool',
    # dev only
    'ClangFormat',
    # doesn't exist
    'Qt6X11Extras',
}

OK_MISSING_BY_PACKAGE = {
    "angelfish": {
        "Qt6Feedback",  # we don't have it
    },
    "attica": {
        "Python3",  # only used for license checks
    },
    "discover": {
        "ApkQt",  # we don't have APK (duh)
        "rpm-ostree-1",  # we don't have rpm-ostree (duh)
        "Snapd",  # we don't have snaps and probably never will
        "packagekitqt6",  # intentionally disabled
    },
    "elisa": {
        "UPNPQT",  # upstream says it's broken
    },
    "extra-cmake-modules": {
        "Sphinx",  # only used for docs, bloats closure size
        "QCollectionGenerator"
    },
    "gwenview": {
        "Tiff",  # duplicate?
    },
    "kio-extras-kf5": {
        "KDSoapWSDiscoveryClient",  # actually vendored on KF5 version
    },
    "kitinerary": {
        "OsmTools",  # used for map data updates, we use prebuilt
    },
    "kosmindoormap": {
        "OsmTools",  # same
        "Protobuf",
    },
    "kpty": {
        "UTEMPTER",  # we don't have it and it probably wouldn't work anyway
    },
    "kpublictransport": {
        "OsmTools",  # same
        "PolyClipping",
        "Protobuf",
    },
    "krfb": {
        "Qt6XkbCommonSupport",  # not real
    },
    "ksystemstats": {
        "Libcap",  # used to call setcap at build time and nothing else
    },
    "kuserfeedback": {
        "Qt6Svg",  # all used for backend console stuff we don't ship
        "QmlLint",
        "Qt6Charts",
        "FLEX",
        "BISON",
        "Php",
        "PhpUnit",
    },
    "kwin": {
        "display-info",  # newer versions identify as libdisplay-info
        "Libcap",  # used to call setcap at build time and nothing else
    },
    "kwin-x11": {
        "Libcap",  # used to call setcap at build time and nothing else
    },
    "libksysguard": {
        "Libcap",  # used to call setcap at build time and nothing else
    },
    "mlt": {
        "Qt5",  # intentionally disabled
        "SWIG",
    },
    "plasma-desktop": {
        "scim",  # upstream is dead, not packaged in Nixpkgs
        "KAccounts6",  # dead upstream
        "AccountsQt6",  # dead upstream
        "signon-oauth2plugin",  # dead upstream
    },
    "plasma-dialer": {
        "KTactileFeedback",  # dead?
    },
    "poppler-qt6": {
        "gobject-introspection-1.0",  # we don't actually want to build the GTK variant
        "gdk-pixbuf-2.0",
        "gtk+-3.0",
    },
    "powerdevil": {
        "DDCUtil",  # cursed, intentionally disabled
        "Libcap",  # used to call setcap at build time and nothing else
    },
    "print-manager": {
        "PackageKitQt6",  # used for auto-installing drivers which does not work for obvious reasons
    },
    "pulseaudio-qt": {
        "Qt6Qml",  # tests only
        "Qt6Quick",
    },
    "skladnik": {
        "POVRay",  # too expensive to rerender all the assets
    },
    "syntax-highlighting": {
        "XercesC",  # only used for extra validation at build time
    }
}

def main():
    here = pathlib.Path(__file__).parent.parent.parent.parent
    logs = (here / "logs").glob("*.log")

    for log in sorted(logs):
        pname = log.stem

        missing = []
        is_in_block = False
        with log.open(errors="replace") as fd:
            for line in fd:
                line = line.strip()
                if line.startswith("--   No package '"):
                    package = line.removeprefix("--   No package '").removesuffix("' found")
                    missing.append(package)
                if line == "-- The following OPTIONAL packages have not been found:" or line == "-- The following RECOMMENDED packages have not been found:":
                    is_in_block = True
                elif line.startswith("--") and is_in_block:
                    is_in_block = False
                elif line.startswith("*") and is_in_block:
                    package = line.removeprefix("* ")
                    missing.append(package)

        missing = {
            package
            for package in missing
            if not any(package.startswith(i) for i in OK_MISSING | OK_MISSING_BY_PACKAGE.get(pname, set()))
        }

        if missing:
            print(pname + ":")
            for line in missing:
                print("  -", line)
            print()

if __name__ == '__main__':
    main()
