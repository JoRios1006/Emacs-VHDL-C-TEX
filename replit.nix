{pkgs}: {
  deps = [
    pkgs.coccinelle
    pkgs.sparse
    pkgs.clang-analyzer
    pkgs.semgrep
    pkgs.flawfinder
    pkgs.cppcheck
    pkgs.gdb
    pkgs.qemu
    pkgs.ninja
    pkgs.cmake-format
    pkgs.cmake-language-server
    pkgs.luaPackages.busted
    pkgs.lua-language-server
    pkgs.pkg-config
    pkgs.raylib
    pkgs.vhdl-ls
    pkgs.ispell
    pkgs.fd
    pkgs.ripgrep
    pkgs.gnumake
    pkgs.cmake
    pkgs.clang-tools
    pkgs.gcc
    pkgs.emacs
  ];
}
