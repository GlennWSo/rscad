{
numpy,
pyvista,
buildPythonPackage,
lib,
rustPlatform,
setuptools-rust,
}:

buildPythonPackage rec {
  pname = "rhello";
  version = "2.28.1";
  # disabled = pythonOlder "3.7";
  # src = fetchPypi {
  #   inherit pname version;
  #   hash = "sha256-fFWZsQL+3apmHIJsVqtP7ii/0X9avKHrvj5/GdfJeYM=";
  # };
	src = ./.;

	# extra run time deps
  propagatedBuildInputs = [
    pyvista
  ];

  # preBuild = ''
  # cp Cargo.lock hello/
  # '';

	cargoDeps = rustPlatform.importCargoLock {
	  lockFile = ./Cargo.lock;
    outputHashes = { "parry3d-f64-0.13.0" = "sha256-2BHcDDkVYET9wNddVXq2yE/QJeYc7GNlDZHfeD3k9kM=";};
    }; 

  buildInputs = [
  ];

  nativeBuildInputs =  [
    setuptools-rust
    rustPlatform.cargoSetupHook
    rustPlatform.rust.cargo
    rustPlatform.rust.rustc
  ];

  pythonImportsCheck = [
    "radcad.hello"
  ];

  # meta = with lib; {
  #   description = "HTTP library for Python";
  #   homepage = "http://docs.python-requests.org/";
  #   license = licenses.asl20;
  #   maintainers = with maintainers; [ fab ];
  # };
}
