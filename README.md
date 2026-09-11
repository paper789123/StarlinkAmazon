# The Effects of Starlink Adoption on Forest Degradation in the Amazon

Replication package. Municipality-level panel of the 772 units of the Brazilian Legal Amazon, estimated by shift-share 2SLS.

## 1. Overview

The baseline replication uses two scripts, run in order:

```
code/work_dataframe.Rmd     raw provider files  ->  main calendar panel + appendix PRODES-year panel
code/starlink_results.Rmd   included inputs     ->  every table and figure
```

The selected specification in `code/starlink_results.Rmd` includes GEO subscriptions and Copernicus ERA5-Drought SPEI-12. Section 8 of the panel-construction script extracts the December SPEI-12 anchor for the main calendar-year analysis and the July anchor for the PRODES-year appendix analysis. The vertical 2022/2024 map is built inline in the results script.

Both resolve every path relative to their own folder, so the package can sit anywhere. Two settings near the top of `work_dataframe.Rmd` control where data is read from and written to:

```
DATA_DIR = "../data/"            # what the pipeline WRITES: intermediates + panels
DRAW     = paste0(DATA_DIR, "raw/")   # where the raw provider downloads ARE
```

They are separate on purpose. Raw downloads are large and often already sit somewhere else — a shared folder, an external drive, an existing archive — and pointing `DRAW` at that collection avoids duplicating tens of gigabytes:

```
DRAW = "D:/data/starlink-raw/"        # absolute paths are fine
```

The pipeline reads provider files under `DRAW`; the only file it may create there is the small IPCA API download under `IBGE/`. The results script uses the same `DATA_DIR` and reads the two self-contained panels plus the compact spatial inputs listed below. It does not need the 226 MB DETER or 22 MB mobile-coverage source archives to redraw the maps.

Run each script from the folder that contains it. Both stop with a clear message if they cannot locate themselves, rather than resolving relative paths against the wrong directory.

## Repository structure

```
code/
  work_dataframe.Rmd           raw provider files -> main and appendix panels
  starlink_results.Rmd         included inputs -> every table and figure
  starlink_results.html        rendered output, readable without running anything
data/
  dataset_normalyr.RDS         main calendar-year panel, 772 municipalities, 2017-2024
  dataset_prodesyr.RDS         appendix PRODES-year panel, 772 municipalities, 2017-2025
  processed/
    deter_map.RDS                       DETER polygons used by both maps
    mobile_coverage_2021.RDS            mobile-coverage area used by both maps
    mun_zone.RDS                        merged municipal boundaries for the maps
  raw/
    FBSP/amazon_factions_2023_2024.csv  faction presence, hand-coded (2.27)
    INCRA/Assentamento Brasil.zip       settlement polygons, included (2.10)
```

The main calendar-year panel, appendix PRODES-year panel, and three files under `data/processed/` are everything `starlink_results.Rmd` needs. The included raw INCRA and FBSP files support panel construction but are not read by the results script. Rebuilding the panels with `work_dataframe.Rmd` also requires the other provider inputs in section 2, saved under `data/raw/<PROVIDER>/`. The pipeline writes its intermediates to `data/processed/`.

Raw downloads go under `data/raw/<PROVIDER>/`, one folder per provider, named exactly as in section 2. After downloading, `data/raw/` looks like:

```
data/raw/
├── ANA/          geoft_bho_2017_linha_costa.gpkg
├── ANATEL/       cobertura_movel.zip, areas_cobertas.zip,
│                 acessos_banda_larga_fixa.zip
├── CAMS/         data_sfc.nc, SPEI-12_Amazon_2017_2025.zip
├── CHC/
│   ├── CHIRPS-v3_latam/      monthly precipitation `.tif`/`.tiff` files
│   └── CHIRTS-ERA5_Tmax/     monthly maximum-temperature `.tif` files
├── CNFP/         CNFP_2020.zip
├── DATASUS/      yearly mortality .csv / .zip files
├── DNIT/         202201B.zip, vw_cide_rod_2021.zip, BaseFerro.zip
├── FAO-GAEZ/     soy yield .tif, fggd_pasture/
├── FBSP/         amazon_factions_2023_2024.csv
├── FUNAI/        indigenous_area_legal_amazon.zip
├── IBAMA/        auto_infracao_csv.zip
├── IBGE/         municipal polygons, census tables, tracts, localities, RGI table,
│                 ipca_mensal_sidra.csv (downloaded automatically if absent)
├── ICMBio/       conservation_units_legal_amazon.zip, autos_infracao_icmbio_shp.zip
├── INCRA/        Assentamento Brasil.zip
├── INPE/         PRODES, DETER, VIIRS hotspots
├── MapBiomas/    brazil_coverage_YYYY.tif
├── SEAB-PR/      sima_2016.rar, sima_2017.rar, sima_2018.zip through sima_2024.zip
└── SICAR/        AREA_IMOVEL_<UF>.zip, nine states
```

## 2. Downloading datasets

Most raw datasets are **not** included in this repository because of size and potential licensing concerns. The exact INCRA settlement archive is included because its source requires authenticated gov.br access; the hand-coded FBSP file is also included. Follow the instructions below for the remaining inputs and place each file in the folder named above. The pipeline checks all nineteen folders before it starts and stops with the list of any that are missing or empty.

> **Note for non-Portuguese speakers:** several datasets are hosted on Brazilian government portals whose interfaces are entirely in Portuguese. Step-by-step instructions in English are given for each of those.

A file-level audit of the exact paths and date patterns selected by `work_dataframe.Rmd` totals **14.16 GiB across 302 source files** in the authors' collection. The externally obtained inputs occupy **14.12 GiB** because the included INCRA and FBSP inputs account for 50.2 MB. The largest required components are MapBiomas (6.61 GiB), CHIRTS/CHIRPS (3.09 GiB), ANATEL (1.15 GiB), and INPE (1.13 GiB). These are file-level totals, not provider-folder sizes: unrelated files stored beside the analysis inputs are not required.

---

### Geographic base

#### 2.1 Legal Amazon municipalities

| **File**    | `IBGE/municipalities_legal_amazon.zip`                                                                                                                                                                          |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Source**  | TerraBrasilis — INPE                                                                                                                                                                                             |
| **URL**     | [https://terrabrasilis.dpi.inpe.br/download/dataset/legal-amz-aux/vector/municipalities_legal_amazon.zip](https://terrabrasilis.dpi.inpe.br/download/dataset/legal-amz-aux/vector/municipalities_legal_amazon.zip) |
| **License** | CC0                                                                                                                                                                                                               |

**Instructions:** direct download — save the `.zip` to `data/raw/IBGE/` without extracting; the scripts read from inside the archive.

This layer is already clipped to the Legal Amazon boundary, which is why the 21 partially included Maranhão municipalities have a smaller area than their full territory. `starlink_results.Rmd` also reads it, for the variance-share map.

---

#### 2.2 Municipal population, 2022 Census

| **File**    | `IBGE/tabela4714.csv`                                                       |
| ----------------- | ----------------------------------------------------------------------------- |
| **Source**  | IBGE — SIDRA                                                                 |
| **URL**     | [https://sidra.ibge.gov.br/tabela/4714](https://sidra.ibge.gov.br/tabela/4714) |
| **License** | CC0                                                                           |

**Instructions:**

1. Open the URL. You will see a query interface called **SIDRA**.
2. Leave ticked only *População residente (Pessoas)* and *Município [5570/5570]*.
3. Click **Download** at the bottom of the page.
4. Under *Formato*, select **CSV (US)**.
5. Tick **Exibir códigos de territórios** ("show territory codes") — this adds the numeric municipality code the scripts key on.
6. Save as `tabela4714.csv` in `data/raw/IBGE/`.

---

#### 2.3 Census tracts and population aggregates, 2022

| **Files**   | `IBGE/MA_setores_CD2022.gpkg`, `IBGE/Agregados_por_setores_basico_BR_20260520.zip` |
| ----------------- | -------------------------------------------------------------------------------------- |
| **Source**  | IBGE — Censo Demográfico 2022                                                        |
| **License** | CC0                                                                                    |

Used to estimate population inside the Legal Amazon portion of the 21 Maranhão municipalities the boundary cuts, by area overlay over census tracts.

**Instructions:** the pipeline downloads both automatically if absent. To fetch them by hand:

```
https://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_de_setores_censitarios__divisoes_intramunicipais/censo_2022/setores/gpkg/UF/MA/MA_setores_CD2022.gpkg
https://ftp.ibge.gov.br/Censos/Censo_Demografico_2022/Agregados_por_Setores_Censitarios/Agregados_por_Setor_csv/Agregados_por_setores_basico_BR_20260520.zip
```

Use the **definitive** 2026-05-20 aggregates, not the 2024-03 preliminaries.

---

#### 2.4 Municipal seats and Brasília

| **File**    | `IBGE/Localidades_Municipios_kml.zip`                                                                                                                                                                                 |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Source**  | IBGE                                                                                                                                                                                                                    |
| **URL**     | [https://www.ibge.gov.br/geociencias/organizacao-do-territorio/estrutura-territorial/27385-localidades.html](https://www.ibge.gov.br/geociencias/organizacao-do-territorio/estrutura-territorial/27385-localidades.html) |
| **License** | CC0                                                                                                                                                                                                                     |

**Instructions:**

1. Open the URL. The page is titled *Localidades do Brasil*.
2. Scroll to **Localidades do Brasil - Municípios (kml)** and click **kml**.
3. Save to `data/raw/IBGE/` without extracting. All municipal-seat coordinates and the distance-to-Brasília control come from this archive.

---

#### 2.5 Immediate geographic regions (RGI 2017)

| **File**    | `IBGE/regioes_geograficas_composicao_por_municipios_2017_20180911.xlsx`                                                                                                                                                                       |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Source**  | IBGE                                                                                                                                                                                                                                            |
| **URL**     | [https://www.ibge.gov.br/geociencias/organizacao-do-territorio/divisao-regional/15778-divisoes-regionais-do-brasil.html](https://www.ibge.gov.br/geociencias/organizacao-do-territorio/divisao-regional/15778-divisoes-regionais-do-brasil.html) |
| **License** | CC0                                                                                                                                                                                                                                             |

**Instructions:** open the URL, go to *por municípios das Regiões Geográficas Imediatas e Intermediárias do Brasil*, download the composition spreadsheet (XLSX) and save it to `data/raw/IBGE/` under the name above. This defines `microreg`, the cluster unit for every reported standard error.

---

#### 2.6 South America coastline

| **File**    | `ANA/geoft_bho_2017_linha_costa.gpkg`                                                                                                                                                                                           |
| ----------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Source**  | ANA — National Water and Sanitation Agency                                                                                                                                                                                       |
| **URL**     | [https://metadados.snirh.gov.br/geonetwork/srv/por/catalog.search#/metadata/0f57c8a0-6a0f-4283-8ce3-114ba904b9fe](https://metadados.snirh.gov.br/geonetwork/srv/por/catalog.search#/metadata/0f57c8a0-6a0f-4283-8ce3-114ba904b9fe) |
| **License** | CC0                                                                                                                                                                                                                               |

**Instructions:** open the URL, scroll to **Linha de Costa (gpkg)**, click **Baixar**, and save the `.gpkg` to `data/raw/ANA/`.

---

### Land tenure

#### 2.7 SICAR rural property registry

| **Files**   | `SICAR/AREA_IMOVEL_<UF>.zip` for AC, AM, AP, MA, MT, PA, RO, RR, TO                                                       |
| ----------------- | --------------------------------------------------------------------------------------------------------------------------- |
| **Source**  | SICAR — Sistema Nacional de Cadastro Ambiental Rural                                                                       |
| **URL**     | [https://consultapublica.car.gov.br/publico/estados/downloads](https://consultapublica.car.gov.br/publico/estados/downloads) |
| **License** | Public data, free use                                                                                                       |

**Instructions:**

1. Open the URL. The page is titled *Downloads por estado*.
2. For each of the nine Legal Amazon states, select the state and download the **Perímetros dos imóveis** shapefile.

- Acre, AC
- Amapá, AP
- Amazonas, AM
- Maranhão, MA
- Mato Grosso, MT
- Pará, PA
- Rondônia, RO
- Roraima, RR
- Tocantins, TO

3. Save each as `AREA_IMOVEL_<UF>.zip` in `data/raw/SICAR/`, where `UF` is the two-letter abbreviation of the state name (see above).

The tenure build reads these directly and is the longest stage of the pipeline.

---

#### 2.8 Conservation units

| **File**    | `ICMBio/conservation_units_legal_amazon.zip`                                                                                                                                                                            |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Source**  | TerraBrasilis — INPE                                                                                                                                                                                                     |
| **URL**     | [https://terrabrasilis.dpi.inpe.br/download/dataset/legal-amz-aux/vector/conservation_units_legal_amazon.zip](https://terrabrasilis.dpi.inpe.br/download/dataset/legal-amz-aux/vector/conservation_units_legal_amazon.zip) |
| **License** | CC BY-SA 4.0                                                                                                                                                                                                              |

**Instructions:** direct download to `data/raw/ICMBio/`, without extracting.

---

#### 2.9 Indigenous territories

| **File**    | `FUNAI/indigenous_area_legal_amazon.zip`                                                                                                                                                                          |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Source**  | TerraBrasilis — INPE                                                                                                                                                                                               |
| **URL**     | [https://terrabrasilis.dpi.inpe.br/download/dataset/legal-amz-aux/vector/indigenous_area_legal_amazon.zip](https://terrabrasilis.dpi.inpe.br/download/dataset/legal-amz-aux/vector/indigenous_area_legal_amazon.zip) |
| **License** | CC BY-SA 4.0                                                                                                                                                                                                        |

**Instructions:** direct download to `data/raw/FUNAI/`, without extracting.

---

#### 2.10 Settlement perimeters

| **File**    | `INCRA/Assentamento Brasil.zip`                                                                                 |
| ----------------- | ----------------------------------------------------------------------------------------------------------------- |
| **Source**  | INCRA — Certificação de Imóveis Rurais                                                                        |
| **URL**     | [https://certificacao.incra.gov.br/csv_shp/export_shp.py](https://certificacao.incra.gov.br/csv_shp/export_shp.py) |
| **License** | CC0                                                                                                               |

The exact archive used for the analysis is supplied at `data/raw/INCRA/Assentamento Brasil.zip`. The official URL is retained for provenance, but downloading from it requires authenticated Brazilian gov.br credentials, which may be unavailable to foreign referees. Supplying the archive keeps the construction pipeline reproducible without requiring that account.

---

#### 2.11 Undesignated public forests

| **File**    | `CNFP/CNFP_2020.zip`                                                                                                                                                    |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Source**  | Serviço Florestal Brasileiro — Cadastro Nacional de Florestas Públicas                                                                                                 |
| **URL**     | [https://www.gov.br/florestal/pt-br/assuntos/cadastro-nacional-de-florestas-publicas](https://www.gov.br/florestal/pt-br/assuntos/cadastro-nacional-de-florestas-publicas) |
| **License** | CC0                                                                                                                                                                       |

**Instructions:** open the URL, scroll down to **Atualizações**, click **Atualização 2020**, and then click **Download** on the page that opens. Save the archive as `CNFP_2020.zip` in `data/raw/CNFP/`, without extracting. The pipeline uses only TIPO B (undesignated) polygons.

---

### Deforestation and degradation

#### 2.12 PRODES annual deforestation

| **File**    | `INPE/yearly_deforestation_amazonia_legal.zip`                                            |
| ----------------- | ------------------------------------------------------------------------------------------- |
| **Source**  | TerraBrasilis — INPE                                                                       |
| **URL**     | [https://terrabrasilis.dpi.inpe.br/downloads/](https://terrabrasilis.dpi.inpe.br/downloads/) |
| **License** | CC BY-SA 4.0                                                                                |

**Instructions:** open the URL, find **Amazônia Legal — PRODES (Desmatamento)**, and download the yearly-deforestation shapefile for the **Legal Amazon** product. Save to `data/raw/INPE/` without extracting.

This must be the *administrative Legal Amazon* product, not the Amazon-biome one: the estimation sample is the administrative region, matching DETER and the municipal panel. The Amazon-biome archive and the supplemental product for polygons smaller than 6.25 hectares are not used.

---

#### 2.13 DETER degradation alerts

| **File**    | `INPE/deter-amz-public-2025set01.zip`                                                     |
| ----------------- | ------------------------------------------------------------------------------------------- |
| **Source**  | TerraBrasilis — INPE                                                                       |
| **URL**     | [https://terrabrasilis.dpi.inpe.br/downloads/](https://terrabrasilis.dpi.inpe.br/downloads/) |
| **License** | CC BY-SA 4.0                                                                                |

**Instructions:** use the September 2025 public DETER release shown above and save it to `data/raw/INPE/` without extracting. The pipeline reads `deter-amz-deter-public.shp` inside this archive. Its reusable `deter_map.RDS` clips alerts to the merged panel geography and dissolves them by municipality, year, and degradation class. It contains only fire scar, selective logging, and other degradation, never DETER deforestation classes. All three degradation classes are retained for 2022/2024 and fire scars for 2021--2024; the other municipality-time DETER files are aggregate tables without geometry. Later DETER vintages and the INPE `FireRisk` products are not inputs to this replication package.

---

#### 2.14 VIIRS active-fire hotspots

| **Files**   | `INPE/focos_br_todos-sats_YYYY.zip`, 2019–2025                                                                                                                                 |
| ----------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Source**  | INPE — Programa Queimadas                                                                                                                                                        |
| **URL**     | [https://dataserver-coids.inpe.br/queimadas/queimadas/focos/csv/anual/Brasil_todos_sats/](https://dataserver-coids.inpe.br/queimadas/queimadas/focos/csv/anual/Brasil_todos_sats/) |
| **License** | CC BY-SA 4.0                                                                                                                                                                      |

**Instructions:** open the annual **Brasil_todos_sats** directory, download `focos_br_todos-sats_YYYY.zip` for every year from 2019 through 2025, and save the archives to `data/raw/INPE/` without extracting. Fire ignitions are built by clustering these with `spotoroo`; the pipeline uses the NOAA-20, NPP-375 and NPP-375D sensors and excludes AQUA.

---

#### 2.15 MapBiomas annual land cover

| **Files**   | `MapBiomas/brazil_coverage_YYYY.tif`, 2016–2024 |
| ----------------- | -------------------------------------------------- |
| **Source**  | MapBiomas, Collection 10                           |
| **License** | CC BY 4.0                                          |

**Instructions:** download each year from the URL pattern below, replacing `YYYY`, and save to `data/raw/MapBiomas/`.

```
https://storage.googleapis.com/mapbiomas-public/initiatives/brasil/collection_10/lulc/coverage/brazil_coverage_YYYY.tif
```

---

### Transport infrastructure

#### 2.16 Roads and railways

| **Files**   | `DNIT/202201B.zip`, `DNIT/vw_cide_rod_2021.zip`, `DNIT/BaseFerro.zip`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Source**  | DNIT — Departamento Nacional de Infraestrutura de Transportes                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| **URLs**    | SNV:[https://servicos.dnit.gov.br/dnitcloud/index.php/s/oTpPRmYs5AAdiNr?path=%2FSNV%20Bases%20Geom%C3%A9tricas%20%282013-Atual%29%20%28SHP%29](<https://servicos.dnit.gov.br/dnitcloud/index.php/s/oTpPRmYs5AAdiNr?path=%2FSNV%20Bases%20Geom%C3%A9tricas%20%282013-Atual%29%20%28SHP%29>)  State roads: [https://servicos.dnit.gov.br/vgeo/](https://servicos.dnit.gov.br/vgeo/)  Railways: [https://www.gov.br/transportes/pt-br/assuntos/dados-de-transportes/bit/Base-GEO/BaseFerro.zip](https://www.gov.br/transportes/pt-br/assuntos/dados-de-transportes/bit/Base-GEO/BaseFerro.zip) |
| **License** | CC0                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |

**Instructions:**

1. For federal highways, open the SNV cloud directory, select `202201B.zip`,    and save it to `data/raw/DNIT/`. The surface field the scripts read is    `ds_sup_fed`.
2. For state highways, open **VGeo** and select **Layers → Rodoviário →    Rodovias Estaduais**. Click the layer name, use its download button, retain the Shapefile format, and save the result as `vw_cide_rod_2021.zip` in `data/raw/DNIT/`. The surface field the scripts read is `Superficie`.
3. Download the railway archive from its direct URL and save it as `BaseFerro.zip` in `data/raw/DNIT/`. Do not extract any of the three archives.

---

### Enforcement

#### 2.17 IBAMA infraction notices

| **File**    | `IBAMA/auto_infracao_csv.zip`                                                                                                                     |
| ----------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Source**  | IBAMA                                                                                                                                               |
| **URL**     | [https://dados.gov.br/dados/conjuntos-dados/fiscalizacao-auto-de-infracao](https://dados.gov.br/dados/conjuntos-dados/fiscalizacao-auto-de-infracao) |
| **License** | CC0                                                                                                                                                 |

**Instructions:** open the URL, click **Recursos**, find *Autos de infração* and click **Acessar o recurso**. Save the ZIP to `data/raw/IBAMA/` without extracting.

---

#### 2.18 ICMBio infraction notices

| **File**    | `ICMBio/autos_infracao_icmbio_shp.zip`                                                                                                                                                                                                                                        |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Source**  | ICMBio                                                                                                                                                                                                                                                                          |
| **URL**     | [https://www.gov.br/icmbio/pt-br/assuntos/dados_geoespaciais/mapa-tematico-e-dados-geoestatisticos-das-unidades-de-conservacao-federais](https://www.gov.br/icmbio/pt-br/assuntos/dados_geoespaciais/mapa-tematico-e-dados-geoestatisticos-das-unidades-de-conservacao-federais) |
| **License** | CC0                                                                                                                                                                                                                                                                             |

**Instructions:** open the URL, scroll to **Autos de Infração ICMBio - shp**, download, and save to `data/raw/ICMBio/` without extracting.

---

### Broadband and mobile coverage

#### 2.19 Fixed broadband subscriptions

| **File**    | `ANATEL/acessos_banda_larga_fixa.zip`                                                                                                       |
| ----------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| **Source**  | ANATEL                                                                                                                                        |
| **URL**     | [https://dados.gov.br/dados/conjuntos-dados/acessos---banda-larga-fixa](https://dados.gov.br/dados/conjuntos-dados/acessos---banda-larga-fixa) |
| **License** | CC BY                                                                                                                                         |

**Instructions:** open the URL, under **Recursos** find *Dados de Acessos de Comunicação Multimídia*, click **Acessar o recurso**, and save the ZIP to `data/raw/ANATEL/` without extracting.

This is the source of both the Starlink subscription counts (the treatment) and the other geostationary satellite providers used as a control.

---

#### 2.20 Mobile network coverage

##### 2.20a Mobile coverage (tabular)

| **File**    | `ANATEL/cobertura_movel.zip`                                                                                          |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------- |
| **Source**  | ANATEL                                                                                                                  |
| **URL**     | [https://dados.gov.br/dados/conjuntos-dados/cobertura_movel](https://dados.gov.br/dados/conjuntos-dados/cobertura_movel) |
| **License** | CC BY                                                                                                                   |

**Instructions:** open the URL, click **Recursos**, find *Cobertura Móvel* and download the ZIP as `cobertura_movel.zip` to `data/raw/ANATEL/` without extracting. The pipeline reads the 2021 municipal coverage variables from this archive.

##### 2.20b Coverage polygons by municipality

| **File**    | `ANATEL/areas_cobertas.zip`                                                                                           |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------- |
| **Source**  | ANATEL                                                                                                                  |
| **URL**     | [https://dados.gov.br/dados/conjuntos-dados/cobertura_movel](https://dados.gov.br/dados/conjuntos-dados/cobertura_movel) |
| **License** | CC BY                                                                                                                   |

**Instructions:** On the same page under **Recursos**, find *Áreas Cobertas* (Coverage Areas) and download the ZIP as `areas_cobertas.zip` to `data/raw/ANATEL/` without extracting it. This is for figure plotting only, as it is the most recent spatial mobile coverage dataset.

---

### Climate, pollution and mortality

#### 2.21 CAMS particulate-matter reanalysis

| **File**    | `CAMS/data_sfc.nc`                                                                                                                                                            |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Source**  | Copernicus Atmosphere Monitoring Service (CAMS)                                                                                                                                 |
| **URL**     | [https://ads.atmosphere.copernicus.eu/datasets/cams-global-reanalysis-eac4?tab=download](https://ads.atmosphere.copernicus.eu/datasets/cams-global-reanalysis-eac4?tab=download) |
| **License** | CC BY 4.0                                                                                                                                                                       |

**Instructions:**

1. You need a free [Copernicus account](https://ads.atmosphere.copernicus.eu/user/register).
2. Log in and open the dataset URL — **CAMS global reanalysis (EAC4)**.
3. Under **Variable → Single level** select **PM1**, **PM2.5** and **PM10**.
4. Set temporal coverage **2017-01-01** to **2024-12-31**, and select all times    from 00:00 to 21:00.
5. Under **Geographical area**, choose **Sub-region extraction**: 6°N to −19°S,    −75°W to −43°W.
6. Under **Format**, choose **Zipped netCDF (experimental)**.
7. Submit; processing can take an hour. Download and unzip to `data/raw/CAMS/data_sfc.nc`.

---

#### 2.22 Temperature and precipitation

| **Files**   | `CHC/CHIRTS-ERA5_Tmax/CHIRTS-ERA5.monthly_Tmax.YYYY.MM.tif` and `CHC/CHIRPS-v3_latam/chirps-v3.0.YYYY.MM.tif[f]`                                                                                                                                                                   |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Source**  | Climate Hazards Center, UC Santa Barbara                                                                                                                                                                                                                                               |
| **URLs**    | [https://data.chc.ucsb.edu/experimental/CHIRTS-ERA5/tmax/tifs/monthly/](https://data.chc.ucsb.edu/experimental/CHIRTS-ERA5/tmax/tifs/monthly/)  [https://data.chc.ucsb.edu/products/CHIRPS/v3.0/monthly/latam/tifs/](https://data.chc.ucsb.edu/products/CHIRPS/v3.0/monthly/latam/tifs/) |
| **License** | CC BY 4.0                                                                                                                                                                                                                                                                              |

**Instructions:** download the 108 monthly GeoTIFFs for each product from **August 2016 through July 2025**. Put CHIRTS-ERA5 files in `data/raw/CHC/CHIRTS-ERA5_Tmax/` and CHIRPS files in `data/raw/CHC/CHIRPS-v3_latam/`. Keep the `.tif` or `.tiff` extensions as published. This range is the exact union required for calendar years 2017–2024 and August–July PRODES years 2017–2025; files outside it are ignored.

#### 2.22a Copernicus ERA5-Drought SPEI-12

| **File**    | `CAMS/SPEI-12_Amazon_2017_2025.zip`                                                                                                                                  |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Source**  | Copernicus Climate Data Store, ERA5-Drought monthly indices                                                                                                            |
| **Dataset** | [Monthly drought indices from 1940 to present derived from ERA5 reanalysis](https://cds.climate.copernicus.eu/datasets/derived-drought-historical-monthly?tab=download) |
| **DOI**     | [https://doi.org/10.24381/9bea5e16](https://doi.org/10.24381/9bea5e16)                                                                                                  |

**Instructions:** register for or log in to a Copernicus Climate Data Store account, open the dataset link, and accept the CC-BY license. Select:

- **Standardised indices:** Standardised precipitation evapotranspiration index only (do not select the Standardised precipitation index).
- **Accumulation period:** 12 only.
- **Product type:** Reanalysis only (do not select Ensemble members).
- **Dataset type:** Consolidated dataset.
- **Years:** 2017 through 2025.
- **Months:** January through December.
- Under **Geographical area**, choose **Sub-region extraction**: 6°N to −19°S,    −75°W to −43°W.

Submit the request, download the resulting ZIP of monthly NetCDF files, and save it to `data/raw/CAMS/` as `SPEI-12_Amazon_2017_2025.zip` without extracting it.

---

#### 2.23 Mortality microdata

| **Files**   | `DATASUS/Mortalidade_Geral_YYYY_csv.zip` and `DATASUS/DOYYOPEN_csv.zip`                                         |
| ----------------- | ------------------------------------------------------------------------------------------------------------------- |
| **Source**  | Ministério da Saúde — DATASUS, SIM                                                                               |
| **URL**     | [https://dados.gov.br/dados/conjuntos-dados/sim-1979-2019](https://dados.gov.br/dados/conjuntos-dados/sim-1979-2019) |
| **License** | CC BY-ND 3.0                                                                                                        |

**Instructions:** open the URL, and under **Recursos** download *Mortalidade Geral* for each year 2017–2024. Provider filenames and whether the download is already compressed can differ by year. Arrange the files in `data/raw/DATASUS/` as follows so they match the names read by the pipeline:

- 2017–2021: `Mortalidade_Geral_YYYY_csv.zip`, containing   `Mortalidade_Geral_YYYY.csv`.
- 2022–2024: `DOYYOPEN_csv.zip`, containing `DOYYOPEN.csv`, where `YY` is the two-digit year.

If a CSV is downloaded uncompressed, place it in a ZIP archive with the corresponding name above. If the provider supplies the same contents under a different archive name, rename the archive. Do not rename the CSV inside it to anything other than the corresponding name above.

---

### Agriculture

#### 2.24 Soy yield potential and pasture suitability

| **Files**   | `FAO-GAEZ/DATA_GAEZ-V5_MAPSET_RES05-YXX_GAEZ-V5.RES05-YXX.HP0120.AGERA5.HIST.SOY.HRLM.tif`, `FAO-GAEZ/fggd_pasture/`                                                                                                                                                                                                                                                                                                                            |
| ----------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Source**  | FAO — Global Agro-Ecological Zones v5, and FGGD pasture suitability                                                                                                                                                                                                                                                                                                                                                                                |
| **URLs**    | Soy:[https://storage.googleapis.com/fao-gismgr-gaez-v5-data/DATA/GAEZ-V5/MAPSET/RES05-YXX/GAEZ-V5.RES05-YXX.HP0120.AGERA5.HIST.SOY.HRLM.tif](https://storage.googleapis.com/fao-gismgr-gaez-v5-data/DATA/GAEZ-V5/MAPSET/RES05-YXX/GAEZ-V5.RES05-YXX.HP0120.AGERA5.HIST.SOY.HRLM.tif)  Pasture: [https://data.fao.org/catalog/dataset/2b357400-891a-11db-b9b2-000d939bc5d8](https://data.fao.org/catalog/dataset/2b357400-891a-11db-b9b2-000d939bc5d8) |
| **License** | CC BY-NC-SA 3.0 IGO                                                                                                                                                                                                                                                                                                                                                                                                                                 |

**Instructions:** download the soy raster and save it to `data/raw/FAO-GAEZ/` as `DATA_GAEZ-V5_MAPSET_RES05-YXX_GAEZ-V5.RES05-YXX.HP0120.AGERA5.HIST.SOY.HRLM.tif`. For pasture suitability, download `Map6_56.zip` (**Suitability of global land area for pasture**) from the FAO catalog. Extract it under `data/raw/FAO-GAEZ/fggd_pasture/` so the ArcInfo grid is located at `fggd_pasture/pasture_si/` and its sibling `fggd_pasture/info/` directory is retained. Both are heterogeneity splitters, not controls.

---

#### 2.25 Commodity prices

| **Dataset** | **Cotação diária — Histórico Sima** (daily wholesale purchase-intention quotations)                                                 |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| **Files**   | `SEAB-PR/sima_2016.rar`, `SEAB-PR/sima_2017.rar`, and `SEAB-PR/sima_2018.zip` through `SEAB-PR/sima_2024.zip`                          |
| **Source**  | SEAB-PR — Secretaria da Agricultura e do Abastecimento do Paraná                                                                             |
| **URLs**    | [Price reports page](https://www.agricultura.pr.gov.br/deral/precos); [Histórico Sima](https://www.agricultura.pr.gov.br/Pagina/Historico-Sima) |
| **License** | Public data, free use                                                                                                                          |

**Instructions:**

1. Open the **Price reports page**. In the first section, **Cotação diária**, click **Histórico** beside **Cotação Atual**. Do not use either **Histórico** link under **Preços Recebidos pelo Produtor** or **Preços de Venda no Atacado e no Varejo**; those are different monthly series.
2. Download the nine annual archives from the **Histórico Sima** page and rename only the archive, following the table below. Save all nine directly in `data/raw/SEAB-PR/`. Do not extract them, create year subfolders, or change their file formats; in particular, keep the 2016 and 2017 files as RAR archives.

| Year | Downloaded filename and direct link                                                                                                    | Rename to         |
| ---- | -------------------------------------------------------------------------------------------------------------------------------------- | ----------------- |
| 2016 | [`sima_2016.rar`](https://www.agricultura.pr.gov.br/sites/default/arquivos_restritos/files/documento/2019-09/sima_2016.rar)           | `sima_2016.rar` |
| 2017 | [`sima_2017.rar`](https://www.agricultura.pr.gov.br/sites/default/arquivos_restritos/files/documento/2019-09/sima_2017.rar)           | `sima_2017.rar` |
| 2018 | [`sima_2018.zip`](https://www.agricultura.pr.gov.br/sites/default/arquivos_restritos/files/documento/2019-09/sima_2018.zip)           | `sima_2018.zip` |
| 2019 | [`SIMA_2019.zip`](https://www.agricultura.pr.gov.br/sites/default/arquivos_restritos/files/documento/2020-02/SIMA_2019.zip)           | `sima_2019.zip` |
| 2020 | [`2020.zip`](https://www.agricultura.pr.gov.br/sites/default/arquivos_restritos/files/documento/2021-04/2020.zip)                     | `sima_2020.zip` |
| 2021 | [`2021.zip`](https://www.agricultura.pr.gov.br/sites/default/arquivos_restritos/files/documento/2022-01/2021.zip)                     | `sima_2021.zip` |
| 2022 | [`2022.zip`](https://www.agricultura.pr.gov.br/sites/default/arquivos_restritos/files/documento/2023-01/2022.zip)                     | `sima_2022.zip` |
| 2023 | [`2023_1.zip`](https://www.agricultura.pr.gov.br/sites/default/arquivos_restritos/files/documento/2023-12/2023_1.zip)                 | `sima_2023.zip` |
| 2024 | [`historico_2024.zip`](https://www.agricultura.pr.gov.br/sites/default/arquivos_restritos/files/documento/2025-03/historico_2024.zip) | `sima_2024.zip` |

3. The `archive` R package extracts each archive into the R session's temporary directory, including the two RAR files, and deletes the temporary copy after parsing that year. The validated 2024 archive contains 242 workbooks; the pipeline uses 241 after excluding the `31-07-2024-impressao.xls` print duplicate.
4. The pipeline reads the internal `.xls`, `.xlsx`, and `.xlsm` files recursively, removes `-impressao` print copies and files marked `Copia` or `Cópia`, and retains the daily quotations for **Boi, Soja, Mandioca, Arroz, and Milho** used to construct the cattle and soy price controls.

---

#### 2.26 IPCA deflator

| **File**    | `data/raw/IBGE/ipca_mensal_sidra.csv` |
| ----------------- | --------------------------------------- |
| **Source**  | IBGE — SIDRA table 1737, variable 63   |
| **License** | CC0                                     |

Fetched directly from the SIDRA API by `work_dataframe.Rmd` for January 2016 through December 2024 and cached with the other raw IBGE inputs. The pipeline uses it to deflate nominal SEAB-PR prices and merges the resulting current and one-year-lagged real price levels into the final panels. Prices are in December 2024 BRL. Delete the CSV only when deliberately refreshing the source vintage.

---

### Faction presence

#### 2.27 Cartografias da Violência na Amazônia

| **File**    | `FBSP/amazon_factions_2023_2024.csv` (included)                                       |
| ----------------- | --------------------------------------------------------------------------------------- |
| **Source**  | Fórum Brasileiro de Segurança Pública / Instituto Mãe Crioula                       |
| **URL**     | [https://forumseguranca.org.br/publicacoes/](https://forumseguranca.org.br/publicacoes/) |
| **License** | CC BY 4.0                                                                               |

**Construction:** the included CSV records municipal faction presence from the 2023 and 2024 editions, with one row per municipality, faction, and report year. The pipeline pools the two editions into a single time-invariant indicator: a municipality is classified as faction-present in every panel year if either edition documents a faction there. The `report_year` column is retained for provenance and is not used to create a time-varying measure. No transcription from the reports is required to run the replication. Only verbatim explicit alliance statements are coded; co-occurrence is not treated as evidence of alliance.

---

## 3. Steps to run

1. **Install the packages** listed under Session info below.
2. **Download the raw data** per section 2 into `data/raw/<PROVIDER>/`.
3. **Check `DATA_DIR` and `DRAW`** at the top of `work_dataframe.Rmd`, and `DATA_DIR` in `starlink_results.Rmd`. If the raw downloads already exist somewhere, point `DRAW` there instead of copying them. Nothing else needs editing.
4. **Verify the pinned DETER input** is named `deter-amz-public-2025set01.zip` as specified in section 2.13; do not substitute another vintage.
5. **Build the panels** by knitting `code/work_dataframe.Rmd`. Allow many hours and roughly 32 GB of RAM; the SICAR tenure build alone runs for hours. Worker counts are set by `max_workers` in chunk 0.
6. **Produce the selected results** by knitting `code/starlink_results.Rmd`. One knit reads the included panels (or the ones rebuilt in step 5) and renders every table and figure into `code/starlink_results.html`. There are no parameters or active render variants.

Step 6 alone reproduces every number in the paper from the included panels, so a reader who only wants the tables can skip steps 2, 4 and 5.

Step 6 took about 4 minutes on a 24-core, 64 GB Windows machine. The leave-one-out sweeps re-estimate every outcome once per dropped unit and run on up to 16 parallel workers (by default, one less than the machine's logical cores); set `STARLINK_ROBUST_MAX_WORKERS` to change that. Each worker needs about 110 MB, but the main R session peaks at about 14 GB, so allow roughly 16 GB of free memory.

## 4. Sample definition

The main results use the calendar-year panel, which covers 2017–2024 and has a January 2022 to December 2024 treatment period. The separate PRODES-year panel is used only for the appendix analysis of native PRODES deforestation polygons of 6.25 ha or larger. This appendix panel uses August-to-July years and ends with PRODES year 2025, which closes in July 2025. Nothing from August 2025 onward enters either panel.

The appendix PRODES-year panel contains six native municipal outcomes in both polygon counts and mapped area: total deforestation, combined clear-cut, clear-cut with exposed soil, clear-cut with vegetation, deforestation by progressive degradation, and mining-pattern deforestation. All polygons meet PRODES's 6.25 ha minimum mapping unit. This panel does not construct August--July versions of DETER degradation, enforcement, pollution, mortality, MapBiomas transitions, ignition, dispersion, or heterogeneity outcomes. Those analyses use the main calendar-year panel only.

Outcomes are normalized by municipal **forest** area. The headline degradation outcome is DETER alert counts (flags), reported per 100 km². Degraded area is retained as supporting evidence.

Mojuí dos Campos was split from Santarém in 2013 and is merged back into it throughout, giving 772 minimum-comparable units against the 773 polygons the IBGE shapefile ships.

## 5. Session info

Recorded from the machine that produced the shipped results. Versions matter most for `sf`, which sits on GEOS/GDAL: a version change there can move geometry results slightly. In particular, the cross-source road de-duplication samples points against a 50 m buffer, and its split between municipalities is approximate — totals are exact, but the per-municipality allocation can shift by around a tenth of a percent across GEOS versions.

```
R 4.4.3 (Windows)

Core:       tidyverse, sf, terra, exactextractr, lwgeom, units
Estimation: fixest, ivDiag, lfe, broom, fastDummies
Spatial:    spotoroo, spatstat.geom, spatstat.explore, surveillance, vegan
IO:         haven, readxl, openxlsx, archive, tiff, httr, jsonlite
Parallel:   future, future.apply, tictoc
Output:     knitr, kableExtra, ggplot2, ggpubr, ggnewscale, patchwork, scales
```

`archive` is used to extract the compressed SEAB-PR annual files into the R session's temporary directory. `httr` and `jsonlite` are used only for the one-off SIDRA deflator fetch.

## 6. Notes on the data

`dataset_normalyr.RDS`, the main-results panel, has 103 columns: the previous 99-column contract plus contemporaneous and one-year-lagged real soybean and cattle prices. `dataset_prodesyr.RDS`, used only in the appendix, has 37 columns: the previous 35-column contract plus the two lagged real price controls. Both carry the full variable names. The `.dta` twins the pipeline also writes are abbreviated — Stata caps variable names at 32 characters — so the `.RDS` files are authoritative and are what the results script reads.

MapBiomas land-cover extraction uses pixel counts rather than area-weighted coverage. The area-weighted validation covered forest area and all nine originally considered transitions and gives the same results. The replication pipeline constructs only the seven transition outcomes still used by `starlink_results.Rmd`. See the note in chunk 10 of the pipeline.

The maps use three compact spatial inputs in `data/processed/`: the panel-matched municipal geometry, the reusable 2021 mobile-coverage layer, and one reusable DETER layer dissolved by municipality, year, and alert class. Starlink rates and SPEI values come from the calendar panel. The municipality-month and municipality-year DETER intermediates cannot replace `deter_map.RDS` because aggregation removes polygon geometry.

Road kilometres are de-duplicated twice: within each source, where one roadbed carrying several BR designations is stored once per designation with identical geometry; and across sources, where a state road running within 50 m of a federal line for at least 300 m is dropped in favour of the federal record. Together these remove 3.9% of drivable kilometres.

## License

Code MIT, data CC BY 4.0. See `LICENSE`. Raw sources listed above are covered by their own providers' terms.
