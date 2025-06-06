{
  lib,
  rustPlatform,
  fetchFromGitHub,
  steam-run,
}:

rustPlatform.buildRustPackage rec {
  pname = "game-rs";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "amanse";
    repo = "game-rs";
    rev = "v${version}";
    hash = "sha256-FuZl2yNre5jNSfHqF3tjiGwg5mRKbYer2FOPpLy0OrA=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-klgcHNZ0vwy2iOYpwbdR37++WLAPx1ARNadfYTTqePw=";

  buildFeatures = [ "nixos" ];

  propagatedBuildInputs = [ steam-run ];

  meta = {
    description = "Minimal CLI game launcher for linux";
    homepage = "https://github.com/amanse/game-rs";
    changelog = "https://github.com/Amanse/game-rs/releases/tag/v${version}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ amanse ];
    platforms = lib.platforms.linux;
  };
}
