{ pkgs, luaPackages, ... }:

pkgs.luaPackages.buildLuaPackage rec {
  pname = "lua-websockets";
  version = "scm";

  src = pkgs.fetchFromGitHub {
    owner = "lipp";
    repo = "lua-websockets";
    rev = "master";
    sha256 = "79qjhfzQHMwr1LG0fJcgEdQykLeAgHEhs7M0VhQK/qo=";
  };

  buildPhase = ''
    echo "No build needed"
  '';

  installPhase = ''
    mkdir -p $out/share/lua/${luaPackages.lua.luaversion}
    cp -r src/websocket $out/share/lua/${luaPackages.lua.luaversion}/
    cp src/websocket.lua $out/share/lua/${luaPackages.lua.luaversion}/
  '';

  meta = with pkgs.lib; {
    description = "WebSocket client and server library for Lua";
    homepage = "https://github.com/lipp/lua-websockets";
    license = licenses.mit;
  };
}
