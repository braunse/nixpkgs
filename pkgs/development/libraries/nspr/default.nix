{ stdenv, fetchurl
, CoreServices ? null
, buildPackages }:

let version = "4.29"; in

stdenv.mkDerivation {
  pname = "nspr";
  inherit version;

  src = fetchurl {
    url = "mirror://mozilla/nspr/releases/v${version}/src/nspr-${version}.tar.gz";
    sha256 = "22286bdb8059d74632cc7c2865c139e63953ecfb33bf4362ab58827e86e92582";
  };

  patches = [
    ./0001-Makefile-use-SOURCE_DATE_EPOCH-for-reproducibility.patch
  ];

  outputs = [ "out" "dev" ];
  outputBin = "dev";

  preConfigure = ''
    cd nspr
  '' + stdenv.lib.optionalString stdenv.isDarwin ''
    substituteInPlace configure --replace '@executable_path/' "$out/lib/"
    substituteInPlace configure.in --replace '@executable_path/' "$out/lib/"
  '';

  HOST_CC = "cc";
  depsBuildBuild = [ buildPackages.stdenv.cc ];
  configureFlags = [
    "--enable-optimize"
    "--disable-debug"
  ] ++ stdenv.lib.optional stdenv.is64bit "--enable-64bit";

  postInstall = ''
    find $out -name "*.a" -delete
    moveToOutput share "$dev" # just aclocal
  '';

  buildInputs = [] ++ stdenv.lib.optionals stdenv.isDarwin [ CoreServices ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    homepage = "http://www.mozilla.org/projects/nspr/";
    description = "Netscape Portable Runtime, a platform-neutral API for system-level and libc-like functions";
    platforms = platforms.all;
    license = licenses.mpl20;
  };
}
