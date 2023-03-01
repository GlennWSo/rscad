{
  inputs =  {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    mach-nix.url = "mach-nix/3.5.0";

  };

  outputs = { self, nixpkgs, flake-utils, mach-nix, }:

    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit  system;
        };
        py = pkgs.python39Packages;
        mach = mach-nix.lib.${system};

        pyEnv = mach.mkPython {
          python = "python39";
          requirements = ''
            pyvista
            pip
          '';
        };

        pyLibPath = pkgs.lib.makeLibraryPath [
          pyEnv
        ];
      in
        {
          devShell = pkgs.mkShell rec {
            name = "pyrust";
            venvDir = ".venv";

            buildInputs = [
              pkgs.nil
              pyEnv
              pkgs.rustPlatform.rust.cargo
              pkgs.rustPlatform.rust.rustc
              pkgs.rust-analyzer
            ];

            shellHook = ''
              SOURCE_DATE_EPOCH=$(date +%s)

              if [ -d "${venvDir}" ]; then
                echo "Skipping venv creation, '${venvDir}' already exists"
              else
                echo "Creating new venv environment in path: '${venvDir}'"
                # Note that the module venv was only introduced in python 3, so for 2.7
                # this needs to be replaced with a call to virtualenv
                ${pyEnv.python.interpreter} -m venv "${venvDir}"
              fi

              # Under some circumstances it might be necessary to add your virtual
              # environment to PYTHONPATH, which you can do here too;
              # PYTHONPATH=$PWD/${venvDir}/${pyEnv.python.sitePackages}/:$PYTHONPATH

              source "${venvDir}/bin/activate"
              # pip install -r requirements.txt
              pip install  .               

              export PYTHONPATH=${pyLibPath}/python3.9/site-packages/:$PYTHONPATH
            '';
          };
        }
    );
}
