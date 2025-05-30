{
  lib,
  buildPythonPackage,
  fetchPypi,
  poetry-core,
  numpy,
  pydantic,
  jsonschema,
  opencv-python-headless,
  sentencepiece,
  typing-extensions,
  tiktoken,
  pillow,
  requests,
}:

buildPythonPackage rec {
  pname = "mistral-common";
  version = "1.5.4";
  pyproject = true;

  src = fetchPypi {
    pname = "mistral_common";
    inherit version;
    hash = "sha256-CvQSSrCdFAl2HpHsYWgUdogtRvlBjuqJCNOcASIuD2s=";
  };

  pythonRelaxDeps = [
    "pillow"
    "tiktoken"
  ];

  build-system = [ poetry-core ];

  dependencies = [
    numpy
    pydantic
    jsonschema
    opencv-python-headless
    sentencepiece
    typing-extensions
    tiktoken
    pillow
    requests
  ];

  doCheck = true;

  pythonImportsCheck = [ "mistral_common" ];

  meta = with lib; {
    description = "mistral-common is a set of tools to help you work with Mistral models.";
    homepage = "https://github.com/mistralai/mistral-common";
    license = licenses.asl20;
    maintainers = with maintainers; [ bgamari ];
  };
}
