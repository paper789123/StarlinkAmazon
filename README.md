# The Effects of Starlink Adoption on Forest Degradation in the Amazon

Replication package for constructing municipality-level panels for 772 units in the Brazilian Legal Amazon and reproducing the included tables and figures.

## 1. Overview

Run these scripts in order:

```
code/work_dataframe.Rmd     raw provider files  ->  calendar-year and PRODES-year panels
code/starlink_results.Rmd   included inputs     ->  every table and figure
```

- `work_dataframe.Rmd` extracts December and July SPEI-12 values into the calendar-year and PRODES-year panels.
- `starlink_results.Rmd` assembles the maps from the included panel and spatial files.

Both resolve every path relative to their own folder, so the package can sit anywhere. Two settings near the top of `work_dataframe.Rmd` control where data is read from and written to:

```
DATA_DIR = "../data/"            # what the pipeline WRITES: intermediates + panels
DRAW     = paste0(DATA_DIR, "raw/")   # where the raw provider downloads ARE
```

If the raw downloads already exist elsewhere, point `DRAW` at that directory:

```
DRAW = "D:/data/starlink-raw/"        # absolute paths are fine
```

- `work_dataframe.Rmd` reads provider files under `DRAW` and writes intermediates and panels under `DATA_DIR`.
- The only file it may create under `DRAW` is `IBGE/ipca_mensal_sidra.csv`.
- `starlink_results.Rmd` reads the two panels and three processed spatial files listed below.

Run each script from the folder that contains it. Both stop with a clear message if they cannot locate themselves, rather than resolving relative paths against the wrong directory.

## Repository structure

```
code/
  work_dataframe.Rmd           raw provider files -> calendar and PRODES-year panels
  starlink_results.Rmd         included inputs -> every table and figure
  starlink_results.html        rendered output, readable without running anything
data/
  dataset_normalyr.RDS         calendar-year panel, 772 municipalities, 2017-2024
  dataset_prodesyr.RDS         PRODES-year panel, 772 municipalities, 2017-2025
  processed/
    deter_map.RDS                       DETER polygons used by both maps
    mobile_coverage_2021.RDS            mobile-coverage area used by both maps
    mun_zone.RDS                        merged municipal boundaries for the maps
  raw/
    FBSP/amazon_factions_2023_2024.csv  faction presence, hand-coded (2.27)
    INCRA/Assentamento Brasil.zip       settlement polygons, included (2.10)
```

- `starlink_results.Rmd` requires the two panel files and the three files under `data/processed/`.
- `work_dataframe.Rmd` requires the raw provider inputs in section 2 and writes its intermediates to `data/processed/`.
- The included INCRA and FBSP files are construction inputs and are not read by `starlink_results.Rmd`.

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
├── FAO/          GAEZ soy-yield .tif, FGGD Map6_56.zip
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

- The repository supplies all eighteen provider folders and the two CHC subfolders.
- Raw provider files remain excluded except for `INCRA/Assentamento Brasil.zip` and `FBSP/amazon_factions_2023_2024.csv`.
- The INCRA archive is included because its official download requires authenticated Brazilian gov.br credentials; the FBSP CSV is the hand-coded construction input.
- Download the remaining inputs into the folders shown above. The pipeline stops before construction if any provider folder is missing or contains no input other than `.gitkeep`.

> **Note for non-Portuguese speakers:** several datasets are hosted on Brazilian government portals whose interfaces are entirely in Portuguese. Step-by-step instructions in English are given for each of those.

The required source paths total **14.16 GiB across 302 files**. The largest components are MapBiomas (6.61 GiB), CHIRTS/CHIRPS (3.09 GiB), ANATEL (1.15 GiB), and INPE (1.13 GiB). These totals exclude unrelated files stored in the same provider folders.

---

### Geographic base

#### 2.1 Legal Amazon municipalities

| **File**    | `IBGE/municipalities_legal_amazon.zip`                                                                                                                                                                          |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Source**  | TerraBrasilis — INPE                                                                                                                                                                                             |
| **URL**     | [https://terrabrasilis.dpi.inpe.br/download/dataset/legal-amz-aux/vector/municipalities_legal_amazon.zip](https://terrabrasilis.dpi.inpe.br/download/dataset/legal-amz-aux/vector/municipalities_legal_amazon.zip) |
| **License** | CC0                                                                                                                                                                                                               |

**Instructions:** direct download — save the `.zip` to `data/raw/IBGE/` without extracting; the scripts read from inside the archive.

This layer is already clipped to the Legal Amazon boundary. Its area field therefore contains clipped rather than full-territory area for 21 Maranhão municipalities.

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

The pipeline overlays tract population on the Legal Amazon boundary for the 21 partially included Maranhão municipalities.

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
3. Save to `data/raw/IBGE/` without extracting. The pipeline reads the municipal-seat and Brasília coordinates from the archive.

---

#### 2.5 Immediate geographic regions (RGI 2017)

| **File**    | `IBGE/regioes_geograficas_composicao_por_municipios_2017_20180911.xlsx`                                                                                                                                                                       |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Source**  | IBGE                                                                                                                                                                                                                                            |
| **URL**     | [https://www.ibge.gov.br/geociencias/organizacao-do-territorio/divisao-regional/15778-divisoes-regionais-do-brasil.html](https://www.ibge.gov.br/geociencias/organizacao-do-territorio/divisao-regional/15778-divisoes-regionais-do-brasil.html) |
| **License** | CC0                                                                                                                                                                                                                                             |

**Instructions:**

- Open the URL and go to *por municípios das Regiões Geográficas Imediatas e Intermediárias do Brasil*.
- Download the composition spreadsheet (XLSX) and save it to `data/raw/IBGE/` under the name above.
- The pipeline writes the immediate-region code as `microreg`.

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

The exact archive is supplied as `data/raw/INCRA/Assentamento Brasil.zip`. The official URL is retained for provenance but requires authenticated Brazilian gov.br credentials.

---

#### 2.11 Undesignated public forests

| **File**    | `CNFP/CNFP_2020.zip`                                                                                                                                                    |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Source**  | Serviço Florestal Brasileiro — Cadastro Nacional de Florestas Públicas                                                                                                 |
| **URL**     | [https://www.gov.br/florestal/pt-br/assuntos/cadastro-nacional-de-florestas-publicas](https://www.gov.br/florestal/pt-br/assuntos/cadastro-nacional-de-florestas-publicas) |
| **License** | CC0                                                                                                                                                                       |

**Instructions:**

- Open the URL, scroll to **Atualizações**, select **Atualização 2020**, and click **Download** on the page that opens.
- Save the archive as `data/raw/CNFP/CNFP_2020.zip` without extracting it.
- The pipeline retains only TIPO B (undesignated) polygons.

---

### Deforestation and degradation

#### 2.12 PRODES annual deforestation

| **File**    | `INPE/yearly_deforestation_amazonia_legal.zip`                                            |
| ----------------- | ------------------------------------------------------------------------------------------- |
| **Source**  | TerraBrasilis — INPE                                                                       |
| **URL**     | [https://terrabrasilis.dpi.inpe.br/downloads/](https://terrabrasilis.dpi.inpe.br/downloads/) |
| **License** | CC BY-SA 4.0                                                                                |

**Instructions:** open the URL, find **Amazônia Legal — PRODES (Desmatamento)**, and download the yearly-deforestation shapefile for the **Legal Amazon** product. Save to `data/raw/INPE/` without extracting.

Use the *administrative Legal Amazon* product. Do not download the Amazon-biome archive or the supplemental product for polygons smaller than 6.25 hectares.

---

#### 2.13 DETER degradation alerts

| **File**    | `INPE/deter-amz-public-2025set01.zip`                                                     |
| ----------------- | ------------------------------------------------------------------------------------------- |
| **Source**  | TerraBrasilis — INPE                                                                       |
| **URL**     | [https://terrabrasilis.dpi.inpe.br/downloads/](https://terrabrasilis.dpi.inpe.br/downloads/) |
| **License** | CC BY-SA 4.0                                                                                |

**Instructions:** save the September 2025 public release shown above to `data/raw/INPE/` without extracting it.

- The pipeline reads `deter-amz-deter-public.shp` inside the archive.
- It keeps only fire scar, selective logging, and other degradation. DETER deforestation classes are excluded.
- It writes `deter_map.RDS` after clipping alerts to the panel geography and dissolving them by municipality, year, and degradation class.
- `deter_map.RDS` retains all three classes for 2022 and 2024 and fire scars for 2021–2024. The other DETER intermediates are aggregate tables without geometry.
- Do not substitute a later DETER release or an INPE `FireRisk` product.

---

#### 2.14 VIIRS active-fire hotspots

| **Files**   | `INPE/focos_br_todos-sats_YYYY.zip`, 2019–2025                                                                                                                                 |
| ----------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Source**  | INPE — Programa Queimadas                                                                                                                                                        |
| **URL**     | [https://dataserver-coids.inpe.br/queimadas/queimadas/focos/csv/anual/Brasil_todos_sats/](https://dataserver-coids.inpe.br/queimadas/queimadas/focos/csv/anual/Brasil_todos_sats/) |
| **License** | CC BY-SA 4.0                                                                                                                                                                      |

**Instructions:**

- Open the annual **Brasil_todos_sats** directory and download `focos_br_todos-sats_YYYY.zip` for every year from 2019 through 2025.
- Save the archives to `data/raw/INPE/` without extracting them.
- The pipeline retains NOAA-20, NPP-375, and NPP-375D observations, excludes AQUA, and clusters the retained observations with `spotoroo`.

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
2. For state highways, open **VGeo** and select **Layers → Rodoviário → Rodovias Estaduais**. Click the layer name, use its download button, retain the Shapefile format, and save the result as `vw_cide_rod_2021.zip` in `data/raw/DNIT/`.
3. The state-road surface field read by the scripts is `Superficie`.
4. Download the railway archive from its direct URL and save it as `BaseFerro.zip` in `data/raw/DNIT/`. Do not extract any of the three archives.

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

The pipeline reads Starlink and other geostationary-provider subscription series from this archive.

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

**Instructions:** on the same page under **Recursos**, find *Áreas Cobertas* (Coverage Areas) and download the ZIP as `areas_cobertas.zip` to `data/raw/ANATEL/` without extracting it. The pipeline reads the polygon geometry directly from this archive.

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

**Instructions:**

- Download the 108 monthly GeoTIFFs for each product from August 2016 through July 2025.
- Put CHIRTS-ERA5 files in `data/raw/CHC/CHIRTS-ERA5_Tmax/` and CHIRPS files in `data/raw/CHC/CHIRPS-v3_latam/`.
- Keep the `.tif` or `.tiff` extensions as published.
- Files outside this date range are ignored.

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

**Instructions:** open the URL and, under **Recursos**, download *Mortalidade Geral* for each year from 2017 through 2024. Arrange the files in `data/raw/DATASUS/` as follows:

- 2017–2021: `Mortalidade_Geral_YYYY_csv.zip`, containing   `Mortalidade_Geral_YYYY.csv`.
- 2022–2024: `DOYYOPEN_csv.zip`, containing `DOYYOPEN.csv`, where `YY` is the two-digit year.

- If a CSV is uncompressed, place it in a ZIP archive with the corresponding name above.
- If the archive has a different provider filename, rename only the archive.
- Keep the internal CSV name shown above.

---

### Agriculture

#### 2.24 Soy yield potential and pasture suitability

| **Files**   | `FAO/DATA_GAEZ-V5_MAPSET_RES05-YXX_GAEZ-V5.RES05-YXX.HP0120.AGERA5.HIST.SOY.HRLM.tif`, `FAO/Map6_56.zip`                                                                                                                                                                                                                                                                                                                                             |
| ----------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Source**  | FAO Global Agro-Ecological Zones v5 (soy) and FGGD pasture suitability                                                                                                                                                                                                                                                                                                                                                                               |
| **URLs**    | Soy:[https://storage.googleapis.com/fao-gismgr-gaez-v5-data/DATA/GAEZ-V5/MAPSET/RES05-YXX/GAEZ-V5.RES05-YXX.HP0120.AGERA5.HIST.SOY.HRLM.tif](https://storage.googleapis.com/fao-gismgr-gaez-v5-data/DATA/GAEZ-V5/MAPSET/RES05-YXX/GAEZ-V5.RES05-YXX.HP0120.AGERA5.HIST.SOY.HRLM.tif)  Pasture: [https://data.fao.org/catalog/dataset/2b357400-891a-11db-b9b2-000d939bc5d8](https://data.fao.org/catalog/dataset/2b357400-891a-11db-b9b2-000d939bc5d8) |
| **License** | CC BY-NC-SA 3.0 IGO                                                                                                                                                                                                                                                                                                                                                                                                                                 |

**Instructions:**

- Download the soy raster as `data/raw/FAO/DATA_GAEZ-V5_MAPSET_RES05-YXX_GAEZ-V5.RES05-YXX.HP0120.AGERA5.HIST.SOY.HRLM.tif`.
- Download `Map6_56.zip` (**Suitability of global land area for pasture**) from the FGGD catalog and save it unchanged as `data/raw/FAO/Map6_56.zip`.
- Do not extract `Map6_56.zip`; the builder reads `pasture_si/hdr.adf` through GDAL's `/vsizip/` virtual filesystem.
- The pasture product is from FGGD, not GAEZ.

---

#### 2.25 Commodity prices

| **Dataset** | **Cotação diária — Histórico Sima** (daily wholesale purchase-intention quotations)                                                 |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| **Files**   | `SEAB-PR/sima_2016.rar`, `SEAB-PR/sima_2017.rar`, and `SEAB-PR/sima_2018.zip` through `SEAB-PR/sima_2024.zip`                          |
| **Source**  | SEAB-PR — Secretaria da Agricultura e do Abastecimento do Paraná                                                                             |
| **URLs**    | [Price reports page](https://www.agricultura.pr.gov.br/deral/precos); [Histórico Sima](https://www.agricultura.pr.gov.br/Pagina/Historico-Sima) |
| **License** | Public data, free use                                                                                                                          |

**Instructions:**

1. Open the **Price reports page**.
2. In the first section, **Cotação diária**, click **Histórico** beside **Cotação Atual**.
3. Do not use the **Histórico** links under **Preços Recebidos pelo Produtor** or **Preços de Venda no Atacado e no Varejo**; those are different monthly series.
4. Download the nine annual archives from the **Histórico Sima** page and rename only the archive as shown below.
5. Save all nine directly in `data/raw/SEAB-PR/`. Do not extract them or create year subfolders. Keep the 2016 and 2017 files in RAR format.

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

6. The `archive` R package extracts each archive into the R session's temporary directory and deletes the temporary copy after parsing that year.
7. The validated 2024 archive contains 242 workbooks; the pipeline retains 241 after excluding `31-07-2024-impressao.xls`.
8. The pipeline reads `.xls`, `.xlsx`, and `.xlsm` files recursively, removes `-impressao` print copies and files marked `Copia` or `Cópia`, and retains daily quotations for **Boi, Soja, Mandioca, Arroz, and Milho**.

---

#### 2.26 IPCA deflator

| **File**    | `data/raw/IBGE/ipca_mensal_sidra.csv` |
| ----------------- | --------------------------------------- |
| **Source**  | IBGE — SIDRA table 1737, variable 63   |
| **License** | CC0                                     |

- `work_dataframe.Rmd` fetches SIDRA table 1737, variable 63, for January 2016 through December 2024 when the CSV is absent.
- The downloaded CSV is cached under `data/raw/IBGE/`.
- SEAB-PR prices are converted to December 2024 BRL before current and one-year-lagged values are joined to the panels.
- Delete the CSV only to fetch the source again.

---

### Faction presence

#### 2.27 Cartografias da Violência na Amazônia

| **File**    | `FBSP/amazon_factions_2023_2024.csv` (included)                                       |
| ----------------- | --------------------------------------------------------------------------------------- |
| **Source**  | Fórum Brasileiro de Segurança Pública / Instituto Mãe Crioula                       |
| **URL**     | [https://forumseguranca.org.br/publicacoes/](https://forumseguranca.org.br/publicacoes/) |
| **License** | CC BY 4.0                                                                               |

**Construction:**

- The included CSV has one row per municipality, faction, and report year from the 2023 and 2024 editions.
- The pipeline pools both editions into one time-invariant municipal indicator.
- `report_year` is retained for provenance and does not create a time-varying series.
- Alliance fields contain only explicit statements from the reports; co-occurrence is not coded as an alliance.
- No report transcription is required to run the pipeline.

---

## 3. Steps to run

1. **Install the packages** listed under Session info below.
2. **Download the raw data** per section 2 into `data/raw/<PROVIDER>/`.
3. **Check `DATA_DIR` and `DRAW`** at the top of `work_dataframe.Rmd`, and `DATA_DIR` in `starlink_results.Rmd`. If the raw downloads already exist somewhere, point `DRAW` there instead of copying them. Nothing else needs editing.
4. **Verify the pinned DETER input** is named `deter-amz-public-2025set01.zip` as specified in section 2.13; do not substitute another vintage.
5. **Build the panels** by knitting `code/work_dataframe.Rmd`. Allow many hours and roughly 32 GB of RAM; the SICAR tenure build alone runs for hours. Worker counts are set by `max_workers` in chunk 0.
6. **Render the outputs** by knitting `code/starlink_results.Rmd`. One knit reads the included panels and processed spatial files and writes every table and figure to `code/starlink_results.html`. There are no parameters or active render variants.

To render from the included files, run only step 6. Steps 2, 4, and 5 are required only to rebuild the panels and processed spatial files.

- Observed render time: about 4 minutes on a 24-core, 64 GB Windows machine.
- Parallel limit: up to 16 workers by default, or one fewer than the available logical cores when fewer are available.
- Override: set `STARLINK_ROBUST_MAX_WORKERS`.
- Memory: allow about 16 GB free; the main R session peaks near 14 GB and each worker uses about 110 MB.

## 4. Panel coverage and units

- `dataset_normalyr.RDS` covers calendar years 2017–2024.
- `dataset_prodesyr.RDS` covers August–July PRODES years 2017–2025. `starlink_results.Rmd` reads this panel only in its appendix block.
- The PRODES input is the administrative Legal Amazon product and excludes polygons smaller than 6.25 hectares. No observation after July 2025 enters either panel.
- Mojuí dos Campos is merged into Santarém, reducing the 773 source polygons to 772 comparable municipal units.

## 5. Session info

- The versions below were recorded on the machine that produced the included outputs.
- Changes to the GEOS/GDAL versions used by `sf` can shift the municipal allocation of de-duplicated road length by about 0.1%; total length remains unchanged.

```
R 4.4.3 (Windows)

Core:       tidyverse, sf, terra, exactextractr, lwgeom, units
Estimation: fixest, ivDiag, lfe, broom, fastDummies
Spatial:    spotoroo, spatstat.geom, spatstat.explore, surveillance, vegan
IO:         haven, readxl, openxlsx, archive, tiff, httr, jsonlite
Parallel:   future, future.apply, tictoc
Output:     knitr, kableExtra, ggplot2, ggpubr, ggnewscale, patchwork, scales
```

- `archive` extracts the SEAB-PR annual files into the R session's temporary directory.
- `httr` and `jsonlite` fetch the SIDRA deflator when its cached CSV is absent.

## 6. Notes on the data

- `dataset_normalyr.RDS` has 103 columns, including current and one-year-lagged real soybean and cattle prices.
- `dataset_prodesyr.RDS` has 37 columns, including one-year-lagged real soybean and cattle prices.
- The `.RDS` panels retain full variable names and are read by `starlink_results.Rmd`. The `.dta` copies use abbreviated names because Stata limits names to 32 characters.
- MapBiomas extraction uses pixel counts and materializes the seven transition columns read by `starlink_results.Rmd`; see chunk 10 of the builder.
- The three map files under `data/processed/` retain municipal geometry, 2021 mobile-coverage geometry, and DETER polygons dissolved by municipality, year, and alert class.
- The aggregated municipality-month and municipality-year DETER files cannot replace `deter_map.RDS` because they contain no polygon geometry.

Road de-duplication removes 3.9% of drivable road length:

- Within each source, identical geometries with multiple road designations are counted once.
- Across sources, a state segment is removed when it runs within 50 m of a federal line for at least 300 m.

## License

Code MIT, data CC BY 4.0. See `LICENSE`. Raw sources listed above are covered by their own providers' terms.
