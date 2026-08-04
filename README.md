# openfoam_extended_app

OpenFOAM (foam-extend) výpočetní případy a rozšíření.

## Případy (`cases/`)

| případ | popis | řešič |
|--------|-------|-------|
| [`axialTurbineCompressible`](cases/axialTurbineCompressible/) | Axiální turbína (rozváděč + oběžné kolo + savka) spojená přes GGI, **stlačitelné** proudění | `rhoPorousMRFPimpleFoam` (foam-extend 4.0) |

Detaily, předpoklady a návod ke spuštění jsou v README daného případu.

### Rychlý start

```sh
cd cases/axialTurbineCompressible
./Allrun
```

Vyžaduje nainstalovaný **foam-extend 4.0** (kvůli GGI a řešiči
`rhoPorousMRFPimpleFoam`).
