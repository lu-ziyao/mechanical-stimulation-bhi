# Directional brain-heart interaction

MATLAB implementation of the IPFM and ARX models used to estimate brain-to-heart and heart-to-brain indices.

## Requirements

MATLAB R2023a or later. The implementation uses base MATLAB functions.

## Quick start

```matlab
cd('path/to/code')
setup
run_tests
[summary, models] = run_validation_data;
```

## Layout

```text
config/       Model parameters and electrode groups
src/          Alignment, IPFM, directional estimation and diagnostics
simulations/  Saved validation records and simulation code
tests/       Numerical checks
```

## Input

Pass one recording as a structure with these fields:

| Field | Format |
|---|---|
| `eeg_time` | EEG feature timestamps in seconds |
| `eeg_power` | Structure containing six channel-by-time power matrices |
| `hrv_time` | HRV feature timestamps in seconds |
| `lf_power`, `hf_power` | HRV power vectors |
| `rr_intervals` | Corrected RR intervals in seconds |
| `rr_time` | Recording timestamps of the ending R peaks for those intervals |
| `channel_labels` | Electrode labels in the matrix row order |

All timestamps use the same recording clock. Preserve the STFT output timestamps and ECG event timestamps when preparing inputs.

```matlab
cfg = bhi_config(0.20*ones(1,6));
result = bhi_compute(data, cfg);
```

A common low-amplitude threshold of 0.20 is used for all six EEG bands. For experimental data, the threshold is expressed in the units of the EEG band amplitude. For the supplied simulations and validation signals, the threshold is defined on the fixed simulation amplitude scale.

## Model

- Bands: delta 0-4, theta 4-8, alpha 8-12, beta 13-20, high beta 20-35 and gamma 45-90 Hz.
- Feature grid: 4 Hz. BHI windows: 5 s with a 1 s step.
- IPFM: trailing 15 s RR windows, updated every second; LF and HF representative frequencies are 0.1 and 0.25 Hz.
- Heart-to-brain: EEG amplitude and HRV power are standardized across each aligned recording; a first-order ARX model is fitted without an intercept. The input coefficient is the index.
- Brain-to-heart: IPFM parameters are standardized across the aligned recording. Each index is the median ratio of cardiac modulation to the preceding sample's trailing 5 s median EEG amplitude.
- Alignment uses the shared time range of EEG, HRV and complete RR parameter windows. Linear interpolation aligns EEG/HRV features; spline interpolation aligns IPFM parameters within their time range.

## Output

`result.channel.<band>` contains `LToB`, `HToB`, `BToL` and `BToH`, together with their time vectors. Coefficients are timestamped at the end of each estimation window. `result.roi.<band>` contains the same indices averaged within the eight regions defined in `bhi_rois`.

`LToB` and `HToB` are dimensionless. `BToL` and `BToH` have inverse EEG amplitude units. Model predictions, residuals and AR coefficients are stored in `result.model.<band>`.

```matlab
metrics = bhi_diagnostics(result.model.beta.heart_to_brain, cfg);
```

Residual diagnostics use every fifth 1 s output, giving a 5 s interval and a maximum Ljung-Box lag of 10 s.

## Saved validation data

```matlab
[summary, models] = run_validation_data;
```

`simulations/simulation_results.mat` is the original saved simulation file. Its `examples` variable contains four records: no coupling, brain-to-heart, heart-to-brain and bidirectional coupling. Each record contains EEG band amplitude, cardiac modulation and timestamps. The coupled records use strength 0.45 and noise SD 0.50. This entry reads these records and estimates both directions with the shared model functions.

## Full simulation sweep

```matlab
cfg = simulation_config;
results = run_simulation(cfg);
```

The default run evaluates 1,560 feature simulations across four direction conditions, three noise levels and 40 repetitions per parameter combination. An additional 40 no-coupling records per noise level provide independent null calibration. Each evaluation also uses 25 circular-shift surrogates. The cardiac simulation variable is expressed on a fixed reference modulation scale. Both directions call the same estimation functions used by the recording pipeline.

Results are written to `outputs/`.

## Reference and source

Catrambone V, Greco A, Vanello N, Scilingo EP, Valenza G. Time-resolved directional brain-heart interplay measurement through synthetic data generation models. Annals of Biomedical Engineering. 2019;47:1479-1489.

The IPFM calculation was adapted from code by Vincenzo Catrambone and Gaetano Valenza (2019). See `NOTICE`.
