#!/bin/sh
#------------------------------------------------------------------------------
# Spustí tento stlačitelný axiální-turbínový case ve foam-extend 4.1 Docker
# image. Použij na stroji s Dockerem a přístupem na Docker Hub.
#
#   ./run-in-docker.sh                     # výchozí image
#   FE_IMAGE=dicehub/openfoam:foam-extend-4.1 ./run-in-docker.sh
#
# Skript namountuje adresář case do kontejneru, najde a nasourcuje foam-extend
# bashrc a spustí ./Allrun (m4 -> blockMesh -> transformPoints -> GGI -> solver).
#------------------------------------------------------------------------------
set -eu

FE_IMAGE="${FE_IMAGE:-solids4foam/solids4foam:v2.0-foam-extend-4.1}"
CASE_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ">> image: $FE_IMAGE"
echo ">> case : $CASE_DIR"

docker pull "$FE_IMAGE"

docker run --rm -t \
    -v "$CASE_DIR":/case \
    -w /case \
    "$FE_IMAGE" \
    /bin/bash -lc '
        set -e
        # najdi foam-extend bashrc (cesta se liší podle image)
        BASHRC="$(find / -maxdepth 6 -type f -path "*foam-extend*/etc/bashrc" 2>/dev/null | head -1)"
        if [ -z "$BASHRC" ]; then
            echo "!! foam-extend bashrc nenalezen v image $0" >&2
            exit 1
        fi
        echo ">> source $BASHRC"
        . "$BASHRC"
        ./Allclean 2>/dev/null || true
        ./Allrun
        echo ">> hotovo. Log solveru:"
        ls -1 log.* 2>/dev/null || true
        tail -n 20 log.rhoPorousMRFPimpleFoam 2>/dev/null || true
    '
