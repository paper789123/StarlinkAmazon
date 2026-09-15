# Submission code cleanup

## Resume point

- [x] Review the current uncommitted changes in `code/work_dataframe.Rmd` before making additional edits. The setup was simplified, the raw-provider folder scan was removed, all 41 `stopifnot()` calls were removed, and a disabled fire-concentration block plus its unused helpers were deleted.
- [x] Restore the count columns in the streamlined ignition summaries so the output schemas remain unchanged: `conc_igni_n` in `conc_igni_normalyr.RDS` and `disp_n` in `disp_igni_normalyr.RDS`.
- [x] Repeat the ignition-output comparison after restoring those columns. The AP rebuild matched the baseline municipality-year keys, values, and four-column schemas exactly.

## Remaining cleanup

- [x] Remove the fully commented-out monthly panel export at the end of `code/work_dataframe.Rmd`.
- [x] Reassess the pre-join validation block (`stale_premerge`, `normal_required`, `prodes_required`, `needed`, and `missing_dv`). Only the guard against silently joining pre-Mojui/Santarem intermediates remains.
- [x] Review the remaining explicit `stop()` calls. Keep input-parsing and geometry errors that provide information unavailable from the failing operation itself, and remove redundant existence or schema checks.
- [x] Shorten historical and methodological comments. Keep comments that explain file formats, unusual source quirks, spatial operations, or non-obvious transformations required to reproduce the build.
- [x] Audit remaining one-use variables and helpers. Inline simple expressions, but retain helpers used by parallel workers and cohesive multi-step operations such as SICAR geometry classification and archive parsing.
- [x] Complete a second lean-code audit of both notebooks. Remove inactive cache outputs and compatibility branches, unused model objects, hidden estimates, one-model loops, dynamic object naming, and stale commented code while retaining only diagnostics and specifications used by the manuscript.
- [x] Check for orphaned objects and package requirements after deleting the legacy concentration code. The unused `spatstat.geom`, `spatstat.explore`, `surveillance`, and `vegan` dependencies are absent from the README package list.
- [x] Purl and parse both complete R Markdown files after cleanup.
- [x] Remove the leave-one-microregion sampling switch. Always run the full sweep and cap the default parallel workers at `min(8, n_threads - 1)`.

## Validation before raw-data migration

- [x] Preserve the current processed outputs and run every validation build in isolated temporary directories.
- [x] Run the affected construction chunks and compare every regenerated intermediary with its baseline. Lightweight chunks were run in full; heavy spatial chunks used AP or narrow month/year samples.
- [x] Before correcting CAMS month handling, rebuild `dataset_normalyr.RDS` and `dataset_prodesyr.RDS` in temporary storage. Both matched their pre-refactor objects exactly, establishing that the general code cleanup was output-neutral.
- [x] Before correcting CAMS month handling, run `code/starlink_results.Rmd` against the rebuilt panels. All 56 chunks completed, substantive text and tables were unchanged, and all embedded figures were byte-identical.
- [x] Remove the legacy substitution that reproduced partial CAMS months for September 2019 and May 2022. Every month now follows the same complete-month extraction and direct-save path.
- [x] Validate the affected CAMS caches against direct full- and partial-month extractions for Amapa. The existing caches are much closer to full-month values, so raw spatial extraction does not need to be repeated.
- [x] Build a corrected calendar panel from the complete monthly caches and run all 56 results chunks in temporary storage. Model II pollution estimates remain similar, but the PM1 joint pre-trend p-value changes from 0.273 to 0.063.
- [x] Replace the submitted CAMS annual intermediary, calendar panel, Stata copy, and results HTML with the complete-month versions. Regenerate the unchanged PRODES RDS and Stata panels from the same final joining chunk.
- [ ] Update the manuscript's pollution estimates, descriptive statistics, robustness results, and PM1 event-study figure using the complete-month results.
- [x] Review the README after the code is final. Remove the stale provider-folder-preflight claim and update the documented worker cap.
- [x] Record `sessionInfo()` at the end of both rendered notebooks. Do not add a separate environment manager or external-library reporting layer.

## Final raw-data migration

- [ ] Only after the preceding validation passes, move the required raw inputs into the submission data tree and update the paths. Do not perform this migration during the cleanup stage.
- [ ] Run a second clean validation using only the repository-supplied files and documented downloads, preferably from a fresh clone or an isolated copy of the submission folder.
- [ ] Inspect the final diff, commit, and push only after both validations pass.
