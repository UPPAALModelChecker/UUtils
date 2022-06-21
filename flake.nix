{
  description = "UPPAAL Utility Library";

  inputs.nixpkgs.url = "nixpkgs/master";

  outputs = { self, nixpkgs }:
    let
      # System types to support.
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
      crossNixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        crossSystem = nixpkgs.lib.systems.examples.mingwW64;
      });
    in
    {

      # Adds a cross compiling check to package if it is built for a MinGW target
      addCrossCheck = (pkgs: nativePkgs: dv: if !pkgs.stdenv.targetPlatform.isMinGW then dv else
      dv.overrideAttrs (oldAttrs: rec {
        cmakeFlags = oldAttrs.cmakeFlags ++ [ "-DCMAKE_TOOLCHAIN_FILE=toolchains/mingw.cmake" ];

        # Add the wine64 package, and a script wine, which just execs wine64
        nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ (nativePkgs.writeShellScriptBin "wine" "exec ${nativePkgs.wine64Packages.stableFull}/bin/wine64 $@") ];

        # Adds an extra build phase, which runs tests using Wine
        postPhases = [ "crossCheck" ];
        crossCheck = "
        # Wine needs a home directory to put some stuff in
        HOME=$(mktemp -d);

          # Add required DLLS to WINEPATH
          export WINEPATH=\"$WINEPATH;$(dirname $(PATH=$PATH:$($CC -print-search-dirs | ${nativePkgs.ripgrep}/bin/rg 'libraries: =' | sed 's/libraries: =//g') ${nativePkgs.which}/bin/which libgcc_s_seh-1.dll))\";
          export WINEPATH=\"$WINEPATH;${pkgs.windows.mcfgthreads}/bin\";
          ctest --output-on-failure";
      }));

      library = (pkgs: nativePkgs:
        self.addCrossCheck pkgs nativePkgs (pkgs.stdenv.mkDerivation {
          pname = "UUtils";
          version = "1.0.0";
          src = ./.;
          nativeBuildInputs = with nativePkgs; [ cmake ];
          buildInputs = with pkgs; [ doctest boost174 ];
          propagatedBuildInputs = with pkgs; [ xxHash ];
          cmakeFlags = [ "-DTESTING=ON" ];

          doCheck = true;
        }));

      defaultPackage = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        self.library pkgs pkgs);


      crossPackage = forAllSystems (system:
        let
          nativePkgs = nixpkgsFor.${system};
          pkgs = crossNixpkgsFor.${system};
        in
        (self.library pkgs nativePkgs));

    };
}
