{
  stdenv,
  fetchFromGitHub,
  gfortran,
  cmake,
  python3,
  shared ? true
}:
let
  inherit (stdenv.lib) optional;
  version = "3.9.0";
in

stdenv.mkDerivation {
  pname = "liblapack";
  inherit version;

  src = fetchFromGitHub {
    owner = "Reference-LAPACK";
    repo = "lapack";
    rev = "v${version}";
    sha256 = "0sxnc97z67i7phdmcnq8f8lmxgw10wdwvr8ami0w3pb179cgrbpb";
  };

  nativeBuildInputs = [ gfortran python3 cmake ];

  cmakeFlags = [
    "-DCMAKE_Fortran_FLAGS=-fPIC"
    "-DLAPACKE=ON"
    "-DCBLAS=ON"
    "-DBUILD_TESTING=ON"
  ]
  ++ optional shared "-DBUILD_SHARED_LIBS=ON";

  doCheck = true;

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    inherit version;
    description = "Linear Algebra PACKage";
    homepage = "http://www.netlib.org/lapack/";
    license = licenses.bsd3;
    platforms = platforms.all;
  };
}
