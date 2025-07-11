{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage {
  pname = "evdevremapkeys";
  version = "unstable-2021-05-04";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "philipl";
    repo = "evdevremapkeys";
    rev = "9b6f372a9bdf8b27d39f7e655b74f6b9d1a8467f";
    sha256 = "sha256-FwRbo0RTiiV2AB7z6XOalMnwMbj15jM4Dxs41TsIOQI=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    pyyaml
    pyxdg
    python-daemon
    evdev
    pyudev
  ];

  # hase no tests
  doCheck = false;

  pythonImportsCheck = [ "evdevremapkeys" ];

  meta = with lib; {
    homepage = "https://github.com/philipl/evdevremapkeys";
    description = "Daemon to remap events on linux input devices";
    mainProgram = "evdevremapkeys";
    license = licenses.mit;
    maintainers = [ maintainers.q3k ];
    platforms = platforms.linux;
  };
}
