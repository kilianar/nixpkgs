{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "tflint-ruleset-google";
  version = "0.32.0";

  src = fetchFromGitHub {
    owner = "terraform-linters";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-d15Co7rjqZpcnazkNWVepfGqh2ngI8tieCRugmZkr70=";
  };

  vendorHash = "sha256-qVzXOg/f9LOnCyV84rRtXi4DGs3jmbrnlviIvoUEEF4=";

  # upstream Makefile also does a go test $(go list ./... | grep -v integration)
  preCheck = ''
    rm integration/integration_test.go
  '';

  subPackages = [ "." ];

  postInstall = ''
    mkdir -p $out/github.com/terraform-linters/${pname}/${version}
    mv $out/bin/${pname} $out/github.com/terraform-linters/${pname}/${version}/
  '';

  meta = with lib; {
    homepage = "https://github.com/terraform-linters/tflint-ruleset-google";
    description = "TFLint ruleset plugin for Terraform Google Provider";
    platforms = platforms.unix;
    maintainers = with maintainers; [ john-rodewald ];
    license = with licenses; [ mpl20 ];
  };
}
