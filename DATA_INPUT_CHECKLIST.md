# Data Input Checklist

Use this checklist to verify the instructions and availability of each input newly added to the submission pipeline.

| Status | New input | Main variables/purpose | Reader action |
|---|---|---|---|
| [ ] | IBGE census tracts and aggregates | Population within the clipped Legal Amazon boundary | Automatic download; check fallback instructions |
| [ ] | IBGE RGI composition | `microreg` clustering unit | Manual download |
| [ ] | SICAR rural properties | Property and claim-size tenure measures | Manual download |
| [ ] | Conservation units | UC tenure outcomes | Manual download |
| [ ] | Indigenous territories | TI tenure outcomes | Manual download |
| [ ] | INCRA settlements | Settlement tenure outcomes | Manual download |
| [ ] | CNFP 2020 | Undesignated public forests | Manual download |
| [ ] | PRODES annual deforestation | PRODES-year deforestation outcomes | Manual download |
| [ ] | VIIRS hotspots | Fire ignitions and concentration/dispersion outcomes | Manual download |
| [ ] | DNIT roads, railways, waterways | Paved/unpaved road and operating-rail controls; waterway panel variable | Manual download |
| [ ] | Copernicus ERA5-Drought SPEI-12 | December and July drought controls | Manual account-based request |
| [ ] | FGGD pasture suitability | Pasture heterogeneity and cattle-price interaction | Manual download and extraction |
| [ ] | SEAB-PR commodity prices | Lagged soybean- and cattle-price controls | Manual multi-year download |
| [ ] | IPCA deflator | Real-price conversion | Automatic API download and committed cache |
| [ ] | FBSP faction records | Faction-presence heterogeneity | Already included; no reader download |

