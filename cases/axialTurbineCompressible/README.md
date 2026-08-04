# axialTurbineCompressible — stlačitelná axiální turbína (foam-extend 4.0)

Ustálený/kvazi-ustálený **stlačitelný** výpočet axiální turbíny se třemi
komponentami spojenými přes **GGI** (General Grid Interface):

```
GV (guide vanes / rozváděč)  ─GGI─►  RU (runner / oběžné kolo, MRF)  ─GGI─►  DT (draft tube / savka)
```

Osové proudění vstupuje shora (`GVINLET`, `U = (0 0 -1)`), prochází rozváděčem,
rotujícím oběžným kolem (MRF zóna `rotor`, `omega = -10 rad/s` kolem osy z) a
odchází savkou (`DTOUTLET`).

## Odkud to je a co bylo změněno

Případ vznikl spojením dvou tutoriálů z **foam-extend 4.0**:

| co | zdroj |
|----|-------|
| geometrie, mesh (m4), GGI/cyclicGgi rozhraní, MRF zóna, `Allrun`/`setBatchGgi` | `tutorials/incompressible/MRFSimpleFoam/axialTurbine_ggi` |
| stlačitelná fyzika (termofyzika, `T`, `mut`/`alphat`, schémata, PIMPLE řešič) | `tutorials/compressible/rhoPorousMRFPimpleFoam/mixerVessel2D` |

Původní `axialTurbine_ggi` je **nestlačitelný** (`MRFSimpleFoam`). Zde je
převedený na **stlačitelný** řešič **`rhoPorousMRFPimpleFoam`**:

- `p` je nyní **absolutní tlak** `[1 -1 -2]` (Pa), start 1 e5 Pa; na `DTOUTLET` fixní 1 e5 Pa.
- přidané pole **`T`** (293 K), termofyzika **ideální plyn (vzduch)** — `hPsiThermo … perfectGas`.
- turbulence: `nut` → **`mut`** (dynamická turb. viskozita) + **`alphat`**; stěnové funkce
  ve stlačitelných variantách (`compressible::kqRWallFunction`, `compressible::epsilonWallFunction`,
  `mutWallFunction`, `alphatWallFunction`). Model RANS: **RNGkEpsilon**.
- `porousZones` je **prázdný** — oběžné kolo je čistě MRF, ne porézní zóna
  (řešič `rhoPorousMRFPimpleFoam` ale ten slovník vyžaduje, proto je přítomen prázdný).

## Předpoklady

- Nainstalovaný **foam-extend 4.0** (kvůli GGI a `rhoPorousMRFPimpleFoam`;
  standardní OpenFOAM.org/​.com tento řešič ani `ggi` typ patchů nemá).
- Prostředí načtené (`source .../etc/bashrc`), dostupné `m4`, `blockMesh`,
  `transformPoints`, `setSet`, `setsToZones`, `rhoPorousMRFPimpleFoam`.

## Spuštění

```sh
./Allrun          # m4 → blockMesh → transformPoints → GGI zóny → rhoPorousMRFPimpleFoam
```

`Allrun` postupně:

1. `m4 blockMeshDict.m4 > blockMeshDict` a `blockMesh` — vytvoří síť tří bloků včetně cellZone `rotor`.
2. `transformPoints -scale "(1 20 1)"` + `-cylToCart …` — z 2D výseče udělá 3D válcový segment.
3. `cp -r 0_orig 0` — počáteční pole.
4. `setSet -batch setBatchGgi` + `setsToZones -noFlipMap` — faceZony pro GGI rozhraní.
5. `rhoPorousMRFPimpleFoam` — samotný výpočet.

Vyčištění: `./Allclean`. Paralelně: `decomposePar` (viz `system/decomposeParDict`) → `mpirun … rhoPorousMRFPimpleFoam -parallel`.

## Ladění / pozor

Tento případ je **sestavený a strukturálně ověřený** (shoda 19 patchů mezi sítí
a všemi poli, vyvážená syntaxe, m4 projde), ale kvůli chybějícímu foam-extendu
v tomto prostředí **nebyl spuštěn**. Kombinace GGI + stlačitelnost bývá citlivá —
při divergenci doporučuji:

- snížit `maxCo` / `deltaT` v `system/controlDict` (start s `deltaT 1e-6`, `maxCo 1`),
- přidat relaxaci v `system/fvSolution` (`p ~0.3`, `U/h/k/epsilon ~0.5`),
- zkontrolovat výstup `ggiCheck` (bilance toku přes rozhraní) v logu,
- případně nejdřív pár set kroků nestlačitelně (`MRFSimpleFoam`) pro čisté startovní pole.

Otáčky/okrajové hodnoty (`omega`, vstupní `U`, `p`, `T`) uprav podle své turbíny
v `constant/MRFZones` a `0_orig/*`.
