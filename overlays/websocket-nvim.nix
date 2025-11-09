{
  pkgs,
  luaPackages ? pkgs.luaPackages,
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

  luaRocksDeps = [
    (import ./lua-websockets.nix {
      pkgs = pkgs;
      luaPackages = luaPackages;
    })
  ];
  doCheck = false;
}
