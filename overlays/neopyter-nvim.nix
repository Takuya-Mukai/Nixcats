{
  pkgs,
}:

pkgs.vimUtils.buildVimPlugin {
  pname = "websocket-nvim";
  version = "git";

  src = pkgs.fetchFromGitHub {
    owner = "AbaoFromCUG";
    repo = "websocket.nvim";
    rev = "main";
    sha256 = null;
  };

  propagatedBuildInputs = [
    (import ./neopyter.nix { pkgs = pkgs; }).neopyter
  ];
}
