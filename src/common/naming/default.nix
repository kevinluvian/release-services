{ releng_pkgs
}:

let

  inherit (releng_pkgs.lib) mkPython2 fromRequirementsFile filterSource;
  inherit (releng_pkgs.pkgs) writeScript;
  inherit (releng_pkgs.pkgs.lib) fileContents;
  inherit (releng_pkgs.tools) pypi2nix;

  python = import ./requirements.nix { inherit (releng_pkgs) pkgs; };
  project_name = "common-naming";
  name = "mozilla-release-common-naming";
  dirname = "common_naming";
  src_path = "src/common/naming";

  self = mkPython2 {
    inherit python project_name name dirname src_path;
    version = fileContents ./VERSION;
    src = filterSource ./. { inherit name; };
    buildInputs =
      (fromRequirementsFile ./requirements-dev.txt python.packages);
    passthru = {
      update = writeScript "update-${name}" ''
        pushd ${self.src_path}
        ${pypi2nix}/bin/pypi2nix -v \
          -V 3.6 \
          -r requirements-dev.txt
        popd
      '';
    };
  };

in self
