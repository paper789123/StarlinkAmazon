# The Effects of Starlink Adoption on Forest Degradation in the Amazon

Replication package. Municipality-level panel of the 772 units of the Brazilian
Legal Amazon, estimated by shift-share 2SLS.

## 1. Overview

The baseline replication uses two scripts, run in order:

```
code/work_dataframe.Rmd     raw provider files  ->  the two analysis panels
code/starlink_results.Rmd   the panels          ->  every table and figure
```

The selected specification in `code/starlink_results.Rmd` includes GEO subscriptions and Copernicus ERA5-Drought SPEI-12. The panel-construction script calls `code/spei_copernicus_era5.R` to create the December/calendar and July/PRODES-year municipal anchors. The vertical 2022/2024 map is built inline in the results script.

Both resolve every path relative to their own folder, so the package can sit anywhere. Two settings near the top of `work_dataframe.Rmd` control where data is read from and written to:

```
DATA_DIR = "../data/"            # what the pipeline WRITES: intermediates + panels
DRAW     = paste0(DATA_DIR, "raw/")   # where the raw provider downloads ARE
```

They are separate on purpose. Raw downloads are large and often already sit somewhere else — a shared folder, an external drive, an existing archive — and pointing `DRAW` at that collection avoids duplicating tens of gigabytes:

```
DRAW = "D:/data/starlink-raw/"        # absolute paths are fine
```

Nothing is written under `DRAW`. The results scripts have the same `DATA_DIR` and read the committed panels plus the compact RDS inputs listed below. They do not need the 226 MB DETER or 22 MB mobile-coverage source archives to redraw Figure 1.

Run each script from the folder that contains it. Both stop with a clear message if they cannot locate themselves, rather than resolving relative paths against the wrong directory.

## Repository structure

```
code/
  work_dataframe.Rmd         raw provider files -> the two analysis panels
  starlink_results.Rmd       the panels -> every table and figure
  starlink_results.html      rendered output, read it without running anything
  spei_copernicus_era5.R     called by work_dataframe.Rmd for the SPEI anchors
data/
  dataset_normalyr.RDS       calendar panel, Jan 2022 - Dec 2024      committed
  dataset_prodesyr.RDS       compact native-PRODES panel, 2017-2025   committed
  cmdty_price_monthly.RDS    commodity price series                   committed
  cmdty_price_anonormal.RDS  annual commodity price averages          committed
  ipca_mensal_sidra.csv      IPCA deflator (IBGE SIDRA table 1737)    committed
  prodes_source.txt          PRODES vintage note                      committed
  raw/                       provider downloads, one folder each      not committed
    FBSP/amazon_factions_2023_2024.csv  hand-coded, not downloadable  committed
  processed/                 pipeline intermediates, rebuilt by work_dataframe.Rmd
    figure1_deter_2022_2024.RDS         DETER polygons for Figure 1   committed
    figure1_mobile_coverage.RDS         mobile-coverage geometry      committed
    figure_ax_deter_fire_2021_2024.RDS  DETER fire scars, appendix    committed
    mun_zone.RDS                        772-unit map geometry         committed
    spei12_copernicus_era5_normalyr.RDS SPEI-12, calendar year        committed
    spei12_copernicus_era5_prodesyr.RDS SPEI-12, PRODES year          committed
    starlink_normalyr.RDS               municipal Starlink rates      committed
    everything else                                                   not committed
```

Raw downloads go under `data/raw/<PROVIDER>/`, one folder per provider, named exactly as in section 2. After downloading, `data/raw/` looks like:

```
data/raw/
├── ANA/          geoft_bho_2017_linha_costa.gpkg
├── ANATEL/       cobertura_movel.zip, areas_cobertas.zip,
│                 acessos_banda_larga_fixa.zip
├── CAMS-EAC4/    data_sfc.nc
├── CHC/
│   ├── CHIRPS-v3_latam/      monthly precipitation `.tif`/`.tiff` files
│   └── CHIRTS-ERA5_Tmax/     monthly maximum-temperature `.tif` files
├── Copernicus/   SPEI-12_Amazon_2017_2025.zip
├── CNFP/         CNFP_2020.zip
├── DATASUS/      yearly mortality .csv / .zip files
├── DNIT/         202201B.zip, vw_cide_rod_2021.zip, BaseFerro.zip
├── FAO-GAEZ/     soy yield .tif, fggd_pasture/
├── FBSP/         amazon_factions_2023_2024.csv
├── FUNAI/        indigenous_area_legal_amazon.zip
├── IBAMA/        auto_infracao_csv.zip
├── IBGE/         municipal polygons, census tables, tracts, localities, RGI table
├── ICMBio/       conservation_units_legal_amazon.zip, autos_infracao_icmbio_shp.zip
├── INCRA/        Assentamento Brasil.zip
├── INPE/         PRODES, DETER, VIIRS hotspots
├── MapBiomas/    brazil_coverage_YYYY.tif
├── SEAB-PR/      commodity price spreadsheets, by year
└── SICAR/        AREA_IMOVEL_<UF>.zip, nine states
```

## 2. Downloading datasets

The datasets are **not** included in this repository, because of size and licensing. Follow the instructions below and place each file in the folder named above. The pipeline checks all nineteen folders before it starts and stops with the list of any that are missing or empty.

> **Note for non-Portuguese speakers:** several datasets are hosted on Brazilian
> government portals whose interfaces are entirely in Portuguese. Step-by-step
> instructions in English are given for each of those.

Total download is roughly **79 GB**, dominated by INPE (55 GB) and MapBiomas (7 GB).

---

### Geographic base

#### 2.1 Legal Amazon municipalities

| **File** | `IBGE/municipalities_legal_amazon.zip` |
|---|---|
| **Source** | TerraBrasilis — INPE |
| **URL** | <https://terrabrasilis.dpi.inpe.br/download/dataset/legal-amz-aux/vector/municipalities_legal_amazon.zip> |
| **License** | CC0 |

**Instructions:** direct download — save the `.zip` to `data/raw/IBGE/` without extracting; the scripts read from inside the archive.

This layer is already clipped to the Legal Amazon boundary, which is why the 21 partially included Maranhão municipalities have a smaller area than their full territory. `starlink_results.Rmd` also reads it, for the variance-share map.

---

#### 2.2 Municipal population, 2022 Census

| **File** | `IBGE/tabela4714.csv` |
|---|---|
| **Source** | IBGE — SIDRA |
| **URL** | <https://sidra.ibge.gov.br/tabela/4714> |
| **License** | CC0 |

**Instructions:**

1. Open the URL. You will see a query interface called **SIDRA**.
2. Leave ticked only *População residente (Pessoas)* and *Município [5570/5570]*.
3. Click **Download** at the bottom of the page.
4. Under *Formato*, select **CSV (US)**.
5. Tick **Exibir códigos de territórios** ("show territory codes") — this adds
   the numeric municipality code the scripts key on.
6. Save as `tabela4714.csv` in `data/raw/IBGE/`.

---

#### 2.3 Census tracts and population aggregates, 2022

| **Files** | `IBGE/MA_setores_CD2022.gpkg`, `IBGE/Agregados_por_setores_basico_BR_20260520.zip` |
|---|---|
| **Source** | IBGE — Censo Demográfico 2022 |
| **License** | CC0 |

Used to estimate population inside the Legal Amazon portion of the 21 Maranhão municipalities the boundary cuts, by areal interpolation over census tracts.

**Instructions:** the pipeline downloads both automatically if absent. To fetch them by hand:

```
https://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_de_setores_censitarios__divisoes_intramunicipais/censo_2022/setores/gpkg/UF/MA/MA_setores_CD2022.gpkg
https://ftp.ibge.gov.br/Censos/Censo_Demografico_2022/Agregados_por_Setores_Censitarios/Agregados_por_Setor_csv/Agregados_por_setores_basico_BR_20260520.zip
```

Use the **definitive** 2026-05-20 aggregates, not the 2024-03 preliminaries.

---

#### 2.4 Municipal seats and Brasília

| **File** | `IBGE/Localidades_Municipios_kml.zip` |
|---|---|
| **Source** | IBGE |
| **URL** | <https://www.ibge.gov.br/geociencias/organizacao-do-territorio/estrutura-territorial/27385-localidades.html> |
| **License** | CC0 |

**Instructions:**

1. Open the URL. The page is titled *Localidades do Brasil*.
2. Scroll to **Localidades do Brasil - Municípios (kml)** and click **kml**.
3. Save to `data/raw/IBGE/` without extracting. All municipal-seat coordinates
   and the distance-to-Brasília control come from this archive.

---

#### 2.5 Immediate geographic regions (RGI 2017)

| **File** | `IBGE/regioes_geograficas_composicao_por_municipios_2017_20180911.xlsx` |
|---|---|
| **Source** | IBGE |
| **URL** | <https://www.ibge.gov.br/geociencias/organizacao-do-territorio/divisao-regional/15778-divisoes-regionais-do-brasil.html> |
| **License** | CC0 |

**Instructions:** open the URL, go to *Divisão regional do Brasil em regiões geográficas imediatas e intermediárias — 2017*, download the composition spreadsheet and save it to `data/raw/IBGE/` under the name above. This defines `microreg`, the cluster unit for every reported standard error.

---

#### 2.6 South America coastline

| **File** | `ANA/geoft_bho_2017_linha_costa.gpkg` |
|---|---|
| **Source** | ANA — National Water and Sanitation Agency |
| **URL** | <https://metadados.snirh.gov.br/geonetwork/srv/por/catalog.search#/metadata/0f57c8a0-6a0f-4283-8ce3-114ba904b9fe> |
| **License** | CC0 |

**Instructions:** open the URL, scroll to **Linha de Costa (gpkg)**, click
**Baixar**, and save the `.gpkg` to `data/raw/ANA/`.

---

### Land tenure

#### 2.7 SICAR rural property registry

| **Files** | `SICAR/AREA_IMOVEL_<UF>.zip` for AC, AM, AP, MA, MT, PA, RO, RR, TO |
|---|---|
| **Source** | SICAR — Sistema Nacional de Cadastro Ambiental Rural |
| **URL** | <https://consultapublica.car.gov.br/publico/estados/downloads> |
| **License** | Public data, free use |

**Instructions:**

1. Open the URL. The page is titled *Downloads por estado*.
2. For each of the nine Legal Amazon states, select the state and download the    **Área do Imóvel** shapefile.
3. Save each as `AREA_IMOVEL_<UF>.zip` in `data/raw/SICAR/`, without extracting.

The tenure build reads these directly and is the longest stage of the pipeline.

---

#### 2.8 Conservation units

| **File** | `ICMBio/conservation_units_legal_amazon.zip` |
|---|---|
| **Source** | TerraBrasilis — INPE |
| **URL** | <https://terrabrasilis.dpi.inpe.br/download/dataset/legal-amz-aux/vector/conservation_units_legal_amazon.zip> |
| **License** | CC BY-SA 4.0 |

**Instructions:** direct download to `data/raw/ICMBio/`, without extracting.

---

#### 2.9 Indigenous territories

| **File** | `FUNAI/indigenous_area_legal_amazon.zip` |
|---|---|
| **Source** | TerraBrasilis — INPE |
| **URL** | <https://terrabrasilis.dpi.inpe.br/download/dataset/legal-amz-aux/vector/indigenous_area_legal_amazon.zip> |
| **License** | CC BY-SA 4.0 |

**Instructions:** direct download to `data/raw/FUNAI/`, without extracting.

---

#### 2.10 Settlement perimeters

| **File** | `INCRA/Assentamento Brasil.zip` |
|---|---|
| **Source** | INCRA — Certificação de Imóveis Rurais |
| **URL** | <https://certificacao.incra.gov.br/csv_shp/export_shp.py> |
| **License** | CC0 |

**Instructions:** open the URL, download **Assentamento Brasil**, and save the
archive to `data/raw/INCRA/` keeping the space in the filename.

---

#### 2.11 Undesignated public forests

| **File** | `CNFP/CNFP_2020.zip` |
|---|---|
| **Source** | Serviço Florestal Brasileiro — Cadastro Nacional de Florestas Públicas |
| **URL** | <https://www.gov.br/florestal/pt-br/assuntos/cadastro-nacional-de-florestas-publicas> |
| **License** | CC0 |

**Instructions:** open the URL, scroll to **Atualizações**, click
**Atualização 2020**, and then click **Download** on the page that opens. Save
the archive as `CNFP_2020.zip` in `data/raw/CNFP/`, without extracting. The
pipeline uses only TIPO B (undesignated) polygons.

---

### Deforestation and degradation

#### 2.12 PRODES annual deforestation

| **File** | `INPE/yearly_deforestation_amazonia_legal.zip` |
|---|---|
| **Source** | TerraBrasilis — INPE |
| **URL** | <https://terrabrasilis.dpi.inpe.br/downloads/> |
| **License** | CC BY-SA 4.0 |

**Instructions:** open the URL, find **Amazônia Legal — PRODES (Desmatamento)**, and download the yearly-deforestation shapefile for the **Legal Amazon** product. Save to `data/raw/INPE/` without extracting.

This must be the *administrative Legal Amazon* product, not the Amazon-biome one: the estimation sample is the administrative region, matching DETER and the municipal panel.

---

#### 2.13 DETER degradation alerts

| **File** | `INPE/deter-amz-public-2026mar29.zip` |
|---|---|
| **Source** | TerraBrasilis — INPE |
| **URL** | <https://terrabrasilis.dpi.inpe.br/downloads/> |
| **License** | CC BY-SA 4.0 |

**Instructions:** on the same page, find **Bioma Amazônia — DETER (Avisos)** and download the public alert shapefile. Save it to `data/raw/INPE/` without extracting, and set `DETER_shp` in chunk 0 of `work_dataframe.Rmd` to the filename you downloaded. Figure 1 uses the legacy degradation layer `deter-amz-deter-public.shp` inside this archive. The committed `figure1_deter_2022_2024.RDS` retains only its 2022 and 2024 fire-scar, degradation, and selective-logging polygons.

---

#### 2.14 VIIRS active-fire hotspots

| **Files** | `INPE/focos_br_todos-sats_YYYY.zip`, 2017–2025 |
|---|---|
| **Source** | INPE — Programa Queimadas |
| **URL** | <https://dataserver-coids.inpe.br/queimadas/queimadas/focos/csv/anual/Brasil_todos_sats/> |
| **License** | CC BY-SA 4.0 |

**Instructions:** open the annual **Brasil_todos_sats** directory, download `focos_br_todos-sats_YYYY.zip` for every year from 2017 through 2025, and save the archives to `data/raw/INPE/` without extracting. Fire ignitions are built by clustering these with `spotoroo`; the pipeline uses the NOAA-20, NPP-375 and NPP-375D sensors and excludes AQUA.

---

#### 2.15 MapBiomas annual land cover

| **Files** | `MapBiomas/brazil_coverage_YYYY.tif`, 2016–2024 |
|---|---|
| **Source** | MapBiomas, Collection 10 |
| **License** | CC BY 4.0 |

**Instructions:** download each year from the URL pattern below, replacing `YYYY`, and save to `data/raw/MapBiomas/`.

```
https://storage.googleapis.com/mapbiomas-public/initiatives/brasil/collection_10/lulc/coverage/brazil_coverage_YYYY.tif
```

---

### Transport infrastructure

#### 2.16 Roads and railways

| **Files** | `DNIT/202201B.zip`, `DNIT/vw_cide_rod_2021.zip`, `DNIT/BaseFerro.zip` |
|---|---|
| **Source** | DNIT — Departamento Nacional de Infraestrutura de Transportes |
| **URLs** | SNV: <https://servicos.dnit.gov.br/dnitcloud/index.php/s/oTpPRmYs5AAdiNr?path=%2FSNV%20Bases%20Geom%C3%A9tricas%20%282013-Atual%29%20%28SHP%29> <br> State roads: <https://servicos.dnit.gov.br/vgeo/> <br> Railways: <https://www.gov.br/transportes/pt-br/assuntos/dados-de-transportes/bit/Base-GEO/BaseFerro.zip> |
| **License** | CC0 |

**Instructions:**

1. For federal highways, open the SNV cloud directory, select `202201B.zip`,    and save it to `data/raw/DNIT/`. The surface field the scripts read is    `ds_sup_fed`.
2. For state highways, open **VGeo** and select **Layers → Rodoviário →    Rodovias Estaduais**. Click the layer name, use its download button, retain the Shapefile format, and save the result as `vw_cide_rod_2021.zip` in `data/raw/DNIT/`. The surface field the scripts read is `Superficie`.
3. Download the railway archive from its direct URL and save it as `BaseFerro.zip` in `data/raw/DNIT/`. Do not extract any of the three archives. Only railway records whose `tip_situac` describes an operating line are retained.

Paved road density and operating railway density are two of the seven year-interacted controls and therefore affect every reported estimate. No other transport measure is constructed for the replication panel.

---

### Enforcement

#### 2.17 IBAMA infraction notices

| **File** | `IBAMA/auto_infracao_csv.zip` |
|---|---|
| **Source** | IBAMA |
| **URL** | <https://dados.gov.br/dados/conjuntos-dados/fiscalizacao-auto-de-infracao> |
| **License** | CC0 |

**Instructions:** open the URL, click **Recursos**, find *Autos de infração* and click **Acessar o recurso**. Save the ZIP to `data/raw/IBAMA/` without extracting.

---

#### 2.18 ICMBio infraction notices

| **File** | `ICMBio/autos_infracao_icmbio_shp.zip` |
|---|---|
| **Source** | ICMBio |
| **URL** | <https://www.gov.br/icmbio/pt-br/assuntos/dados_geoespaciais/mapa-tematico-e-dados-geoestatisticos-das-unidades-de-conservacao-federais> |
| **License** | CC0 |

**Instructions:** open the URL, scroll to **Autos de Infração ICMBio - shp**, download, and save to `data/raw/ICMBio/` without extracting.

---

### Broadband and mobile coverage

#### 2.19 Fixed broadband subscriptions

| **File** | `ANATEL/acessos_banda_larga_fixa.zip` |
|---|---|
| **Source** | ANATEL |
| **URL** | <https://dados.gov.br/dados/conjuntos-dados/acessos---banda-larga-fixa> |
| **License** | CC BY |

**Instructions:** open the URL, under **Recursos** find *Dados de Acessos de Comunicação Multimídia*, click **Acessar o recurso**, and save the ZIP to `data/raw/ANATEL/` without extracting.

This is the source of both the Starlink subscription counts (the treatment) and the other geostationary satellite providers used as a control.

---

#### 2.20 Mobile network coverage

##### 2.20a Coverage by census sector (tabular)

| **File** | `ANATEL/cobertura_movel.zip` |
|---|---|
| **Source** | ANATEL |
| **URL** | <https://dados.gov.br/dados/conjuntos-dados/cobertura_movel> |
| **License** | CC BY |

**Instructions:** open the URL, click **Recursos**, find *Cobertura Móvel* and download the ZIP as `cobertura_movel.zip` to `data/raw/ANATEL/` without extracting. The pipeline reads the 2021 municipal coverage variables from this archive.

##### 2.20b Coverage polygons by municipality

| **File** | `ANATEL/areas_cobertas.zip` |
|---|---|
| **Source** | ANATEL |
| **URL** | <https://dados.gov.br/dados/conjuntos-dados/cobertura_movel> |
| **License** | CC BY |

**Instructions:** on the same page under **Recursos**, find *Áreas Cobertas* (Coverage Areas) and download the ZIP as `areas_cobertas.zip` to `data/raw/ANATEL/` without extracting. The committed `figure1_mobile_coverage.RDS` combines the nine Legal Amazon state layers and clips them to the panel boundary.

---

### Climate, pollution and mortality

#### 2.21 CAMS particulate-matter reanalysis

| **File** | `CAMS-EAC4/data_sfc.nc` |
|---|---|
| **Source** | Copernicus Atmosphere Monitoring Service (CAMS) |
| **URL** | <https://ads.atmosphere.copernicus.eu/datasets/cams-global-reanalysis-eac4?tab=download> |
| **License** | CC BY 4.0 |

**Instructions:**

1. You need a free [Copernicus account](https://ads.atmosphere.copernicus.eu/user/register).
2. Log in and open the dataset URL — **CAMS global reanalysis (EAC4)**.
3. Under **Variable → Single level** select **PM1**, **PM2.5** and **PM10**.
4. Set temporal coverage **2017-01-01** to **2024-12-31**, and select all times    from 00:00 to 21:00.
5. Under **Geographical area**, choose **Sub-region extraction**: 6°N to −19°S,    −75°W to −43°W.
6. Under **Format**, choose **Zipped netCDF (experimental)**.
7. Submit; processing can take an hour. Download and unzip to
   `data/raw/CAMS-EAC4/data_sfc.nc`.

---

#### 2.22 Temperature and precipitation

| **Files** | `CHC/CHIRTS-ERA5_Tmax/CHIRTS-ERA5.monthly_Tmax.YYYY.MM.tif` and `CHC/CHIRPS-v3_latam/chirps-v3.0.YYYY.MM.tif[f]` |
|---|---|
| **Source** | Climate Hazards Center, UC Santa Barbara |
| **URLs** | <https://data.chc.ucsb.edu/experimental/CHIRTS-ERA5/tmax/tifs/monthly/> <br> <https://data.chc.ucsb.edu/products/CHIRPS/v3.0/monthly/latam/tifs/> |
| **License** | CC BY 4.0 |

**Instructions:** download the monthly GeoTIFFs from **January 2017 through July 2025**. Put CHIRTS-ERA5 files in `data/raw/CHC/CHIRTS-ERA5_Tmax/` and CHIRPS files in `data/raw/CHC/CHIRPS-v3_latam/`. Keep the `.tif` or `.tiff` extensions as published. The pipeline identifies the products by their folders rather than by relying on different extensions.

#### 2.22a Copernicus ERA5-Drought SPEI-12

| **File** | `Copernicus/SPEI-12_Amazon_2017_2025.zip` |
|---|---|
| **Source** | Copernicus Climate Data Store, ERA5-Drought monthly indices |
| **Dataset** | [Monthly drought indices from 1940 to present derived from ERA5 reanalysis](https://cds.climate.copernicus.eu/datasets/derived-drought-historical-monthly?tab=download) |
| **DOI** | <https://doi.org/10.24381/9bea5e16> |

**Instructions:** register for or log in to a Copernicus Climate Data Store account, open the dataset link, and accept the CC-BY license. Select:

- **Standardised indices:** Standardised precipitation evapotranspiration index only (do not select the Standardised precipitation index).
- **Accumulation period:** 12 only.
- **Product type:** Reanalysis only (do not select Ensemble members).
- **Dataset type:** Consolidated dataset.
- **Years:** 2017 through 2025.
- **Months:** January through December.
- **Geographical area:** Sub-region extraction, using the same coordinates as the CAMS particulate-matter request: 6°N to 19°S and 75°W to 43°W.

Submit the request, download the resulting ZIP of monthly NetCDF files, and save it to `data/raw/Copernicus/` as `SPEI-12_Amazon_2017_2025.zip` without extracting it.

The archive contains monthly 0.25-degree NetCDF files. Copernicus derives the index from ERA5 reanalysis using Penman--Monteith potential evapotranspiration and a 1991--2020 reference period. The panel pipeline calls the extractor for SPEI-12. It reads the archive inventory and temporarily unpacks only the 17 December/calendar and July/PRODES endpoint files needed by the two panels. This avoids unpacking the full archive and avoids GDAL NetCDF auxiliary-metadata errors observed with direct `/vsizip/` access.

```
Rscript code/spei_copernicus_era5.R 12
```

The extractor writes `spei12_copernicus_era5_normalyr.RDS` and `spei12_copernicus_era5_prodesyr.RDS` to `data/processed/`. The selected results script uses the December anchor for January--December outcomes and the July anchor for August--July PRODES-year outcomes. Exploratory MERRA, SPEI-6, and BR-DWGD tests are retained only under `code/archive/spei_tests_2026-09-01/` and are not part of the active workflow.

---

#### 2.23 Mortality microdata

| **Files** | `DATASUS/Mortalidade_Geral_YYYY_csv.zip` and `DATASUS/DOYYOPEN_csv.zip` |
|---|---|
| **Source** | Ministério da Saúde — DATASUS, SIM |
| **URL** | <https://dados.gov.br/dados/conjuntos-dados/sim-1979-2019> |
| **License** | CC BY-ND 3.0 |

**Instructions:** open the URL, and under **Recursos** download *Mortalidade Geral* for each year 2017–2024. Provider filenames and whether the download is already compressed can differ by year. Arrange the files in `data/raw/DATASUS/` as follows so they match the names read by the pipeline:

- 2017–2021: `Mortalidade_Geral_YYYY_csv.zip`, containing   `Mortalidade_Geral_YYYY.csv`.
- 2022–2024: `DOYYOPEN_csv.zip`, containing `DOYYOPEN.csv`, where `YY` is the two-digit year.

If a CSV is downloaded uncompressed, place it in a ZIP archive with the corresponding name above. If the provider supplies the same contents under a different archive name, rename the archive. Do not rename the CSV inside it to anything other than the corresponding name above.

---

### Agriculture

#### 2.24 Soy yield potential and pasture suitability

| **Files** | `FAO-GAEZ/DATA_GAEZ-V5_MAPSET_RES05-YXX_GAEZ-V5.RES05-YXX.HP0120.AGERA5.HIST.SOY.HRLM.tif`, `FAO-GAEZ/fggd_pasture/` |
|---|---|
| **Source** | FAO — Global Agro-Ecological Zones v5, and FGGD pasture suitability |
| **URLs** | Soy: <https://storage.googleapis.com/fao-gismgr-gaez-v5-data/DATA/GAEZ-V5/MAPSET/RES05-YXX/GAEZ-V5.RES05-YXX.HP0120.AGERA5.HIST.SOY.HRLM.tif> <br> Pasture: <https://data.fao.org/catalog/dataset/2b357400-891a-11db-b9b2-000d939bc5d8> |
| **License** | CC BY-NC-SA 3.0 IGO |

**Instructions:** download the soy raster and save it to `data/raw/FAO-GAEZ/` as `DATA_GAEZ-V5_MAPSET_RES05-YXX_GAEZ-V5.RES05-YXX.HP0120.AGERA5.HIST.SOY.HRLM.tif`. For pasture suitability, download `Map6_56.zip` (**Suitability of global land area for pasture**) from the FAO catalog. Extract it under `data/raw/FAO-GAEZ/fggd_pasture/` so the ArcInfo grid is located at `fggd_pasture/pasture_si/` and its sibling `fggd_pasture/info/` directory is retained. Both are heterogeneity splitters, not controls.

---

#### 2.25 Commodity prices

| **Files** | `SEAB-PR/<year>/*.xlsx` |
|---|---|
| **Source** | SEAB-PR — Secretaria da Agricultura e do Abastecimento do Paraná |
| **URL** | <https://www.agricultura.pr.gov.br/deral/precos> |
| **License** | Public data, free use |

**Instructions:** download the daily price bulletins for 2016–2024 and place them in `data/raw/SEAB-PR/<year>/`. The pipeline skips `-impressao` print copies
and ` - Copia` duplicates automatically.

---

#### 2.26 IPCA deflator

| **File** | `data/ipca_mensal_sidra.csv` |
|---|---|
| **Source** | IBGE — SIDRA table 1737, variable 63 |
| **License** | CC0 |

Fetched automatically from the SIDRA API by `work_dataframe.Rmd` for January 2016 through December 2024 and cached beside the analysis panels. Prices are stored directly in December 2024 BRL. **The cache is committed deliberately:** IBGE revises the series, so deleting it can change the deflator. Delete it only if you intend that.

---

### Faction presence

#### 2.27 Cartografias da Violência na Amazônia

| **File** | `FBSP/amazon_factions_2023_2024.csv` (included) |
|---|---|
| **Source** | Fórum Brasileiro de Segurança Pública / Instituto Mãe Crioula |
| **URL** | <https://forumseguranca.org.br/publicacoes/> |
| **License** | CC BY 4.0 |

**Construction:** the included CSV records municipal faction presence from the 2023 and 2024 editions, with one row per municipality, faction, and report year. The pipeline pools the two editions into a single time-invariant indicator: a municipality is classified as faction-present in every panel year if either edition documents a faction there. The `report_year` column is retained for provenance and is not used to create a time-varying measure. No transcription from the reports is required to run the replication. Only verbatim explicit alliance statements are coded; co-occurrence is not treated as evidence of alliance.

---

## 3. Steps to run

1. **Install the packages** listed under Session info below.
2. **Download the raw data** per section 2 into `data/raw/<PROVIDER>/`.
3. **Check `DATA_DIR` and `DRAW`** at the top of `work_dataframe.Rmd`, and    `DATA_DIR` in `starlink_results.Rmd`. If the raw downloads already exist    somewhere, point `DRAW` there instead of copying them. Nothing else needs editing.
4. **Set `DETER_shp`** in chunk 0 of `work_dataframe.Rmd` to the DETER filename you downloaded (2.13).
5. **Build the panels** by knitting `code/work_dataframe.Rmd`. Allow many hours    and roughly 32 GB of RAM; the SICAR tenure build alone runs for hours. Worker counts are set by `max_workers` in chunk 0.
6. **Produce the selected results** by knitting `code/starlink_results.Rmd`. One knit reads the Copernicus SPEI-12 anchors created in step 5 and writes all tables and figures into `manuscript/tables/` and `manuscript/figs/`. There are no parameters or active render variants.

Step 6 alone reproduces every number in the paper from the committed panels, so a reader who only wants the tables can skip steps 2, 4 and 5.

Expect step 6 to take hours: the leave-one-microregion-out and leave-one-state-out sweeps re-estimate every outcome once per dropped unit and dominate the cost. Raise `robust_max_workers` near the top of the file if you have cores to spare; it defaults to 3.

## 4. Sample definition

The calendar panel runs January 2022 to December 2024. The compact PRODES panel is used only for native PRODES deforestation polygons of 6.25 ha or larger. It is built on PRODES years (August to July) and ends with PRODES year 2025, which closes in July 2025. Nothing from August 2025 onward enters either panel.

The PRODES panel contains six native municipal outcomes in both polygon counts and mapped area: total deforestation, combined clear-cut, clear-cut with exposed soil, clear-cut with vegetation, deforestation by progressive degradation, and mining-pattern deforestation. All polygons meet PRODES's 6.25 ha minimum mapping unit. The panel does not construct August--July versions of DETER degradation, enforcement, pollution, mortality, MapBiomas transitions, ignition, dispersion, or heterogeneity outcomes. Those analyses use the calendar panel only.

Outcomes are normalized by municipal **forest** area. The headline degradation outcome is DETER alert counts (flags), reported per 100 km². Degraded area is retained as supporting evidence.

Mojuí dos Campos was split from Santarém in 2013 and is merged back into it throughout, giving 772 minimum-comparable units against the 773 polygons the IBGE shapefile ships.

## 5. Session info

Recorded from the machine that produced the shipped results. Versions matter  most for `sf`, which sits on GEOS/GDAL: a version change there can move geometry results slightly. In particular, the cross-source road de-duplication samples points against a 50 m buffer, and its split between municipalities is approximate — totals are exact, but the per-municipality allocation can shift by around a tenth of a percent across GEOS versions.

```
R 4.4.3 (Windows)

Core:       tidyverse, sf, terra, exactextractr, lwgeom, units
Estimation: fixest, ivDiag, lfe, broom, fastDummies
Spatial:    spotoroo, spatstat.geom, spatstat.explore, surveillance, vegan
IO:         haven, readxl, openxlsx, tiff, httr, jsonlite
Parallel:   future, future.apply, tictoc
Output:     knitr, kableExtra, ggplot2, ggpubr, ggnewscale, patchwork, scales
```

`httr` and `jsonlite` are used only for the one-off SIDRA deflator fetch.

## 6. Notes on the data

`dataset_normalyr.RDS` and `dataset_prodesyr.RDS` carry the full variable names. The calendar input has 99 columns: 63 raw outcome inputs and 36 keys, treatment/instrument, clustering, denominator, selected-control, and active heterogeneity inputs. The compact PRODES input has 35 columns: six polygon-count outcomes, the same six mapped-area outcomes, and only the inputs needed to estimate them. The `.dta` twins the pipeline also writes are abbreviated — Stata caps variable names at 32 characters — so the `.RDS` files are authoritative and are what the results script reads.

MapBiomas land-cover extraction uses pixel counts rather than area-weighted coverage. The area-weighted validation covered forest area and all nine originally considered transitions and gives the same results. The replication pipeline constructs only the seven transition outcomes still used by `starlink_results.Rmd`. See the note in chunk 10 of the pipeline.

Figure 1 is reproduced from four compact spatial inputs in `data/processed/`: the panel-matched municipal geometry, Starlink rates, mobile coverage, and the 2022/2024 legacy DETER degradation polygons. Source filenames, SHA-256 hashes, and processing summaries are stored as RDS object attributes for the two provider-derived figure layers.

Road kilometres are de-duplicated twice: within each source, where one roadbed carrying several BR designations is stored once per designation with identical geometry; and across sources, where a state road running within 50 m of a federal line for at least 300 m is dropped in favour of the federal record. Together these remove 3.9% of drivable kilometres.

## License

Code MIT, data CC BY 4.0. See `LICENSE`. Raw sources listed above are covered by their own providers' terms.
