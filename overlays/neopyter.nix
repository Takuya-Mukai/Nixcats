{ pkgs, ... }:

{
  neopyter = pkgs.pythonPackages.buildPythonPackage rec {
    pname = "neopyter";
    version = "0.3.2";

    src = pkgs.pythonPackages.fetchPypi {
      inherit pname version;
      sha256 = "w5gOSKdRc163UPFmrf/SGtkKRU5C2KOGb6aR6RT0FiM=";
    };

    pyproject = true;

    nativeBuildInputs = [
      pkgs.pythonPackages.hatchling
    ];

    propagatedBuildInputs = [
      pkgs.pythonPackages.jupyterlab
      pkgs.pythonPackages.pynvim
    ];

    # overlay 内では super を使って親の python3 を参照
    python = pkgs.python;

    doCheck = true;
  };
}
