{ pkgs }:

pkgs.mkShell {
  packages = [
    pkgs.nodejs_24
    pkgs.pnpm
    pkgs.bun
    pkgs.typescript
    pkgs.typescript-language-server
    pkgs.prettier
  ];
}
