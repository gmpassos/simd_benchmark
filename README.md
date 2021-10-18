## Simple Dart SIMD Benchmarks

Run the benchmark:

```shell
dart run bin/simd_benchmark_severe.dart
```

## Status

Performance degradation:
- Dart/2.14.4 (stable): OK
- Dart/2.15.x (beta): 10-20x SLOWER

------------------------------------------------------------------------------------------------------------------------

## Device 1 (macOS)

- macOS Big Sur 11.4
- MacBook Pro (13-inch, 2019, Two Thunderbolt 3 ports)

```
uname -a
Darwin *REDACTED* 20.5.0 Darwin Kernel Version 20.5.0: Sat May  8 05:10:33 PDT 2021; root:xnu-7195.121.3~9/RELEASE_X86_64 x86_64
```

### Output (macOS: Dart/2.14.4)

```
Dart version: 2.14.4 (stable) (Wed Oct 13 11:11:32 2021 +0200) on "macos_x64"
--------------------------------------------------------[SESSION: 1]
caseSigmoidFloat32x4> sum: 28.301810507828122
caseSigmoidFloat32x4{ elapsedTime: 602 ms, hertz: 166,112,956 Hz, ops: 100,000,000, startTime: 2021-10-18 05:51:49.312036 .. +602 ms }

caseSigmoidFloat64x2> sum: 0.024898535462366082
caseSigmoidFloat64x2{ elapsedTime: 624 ms, hertz: 160,256,410 Hz, ops: 100,000,000, startTime: 2021-10-18 05:51:49.943757 .. +624 ms }

--------------------------------------------------------[SESSION: 2]
caseSigmoidFloat32x4> sum: 28.301810507828122
caseSigmoidFloat32x4{ elapsedTime: 541 ms, hertz: 184,842,883 Hz, ops: 100,000,000, startTime: 2021-10-18 05:51:50.567987 .. +541 ms }

caseSigmoidFloat64x2> sum: 0.024898535462366082
caseSigmoidFloat64x2{ elapsedTime: 529 ms, hertz: 189,035,916 Hz, ops: 100,000,000, startTime: 2021-10-18 05:51:51.108908 .. +529 ms }

--------------------------------------------------------[SESSION: 3]
caseSigmoidFloat32x4> sum: 28.301810507828122
caseSigmoidFloat32x4{ elapsedTime: 529 ms, hertz: 189,035,916 Hz, ops: 100,000,000, startTime: 2021-10-18 05:51:51.639621 .. +529 ms }

caseSigmoidFloat64x2> sum: 0.024898535462366082
caseSigmoidFloat64x2{ elapsedTime: 531 ms, hertz: 188,323,917 Hz, ops: 100,000,000, startTime: 2021-10-18 05:51:52.168584 .. +531 ms }

======================================================================
BEST RESULTS:
caseSigmoidFloat32x4> caseSigmoidFloat32x4{ elapsedTime: 529 ms, hertz: 189,035,916 Hz, ops: 100,000,000, startTime: 2021-10-18 05:51:51.639621 .. +529 ms }
caseSigmoidFloat64x2> caseSigmoidFloat64x2{ elapsedTime: 529 ms, hertz: 189,035,916 Hz, ops: 100,000,000, startTime: 2021-10-18 05:51:51.108908 .. +529 ms }
======================================================================
Dart version: 2.14.4 (stable) (Wed Oct 13 11:11:32 2021 +0200) on "macos_x64"
```

### Output (macOS: Dart/2.15.0-178.1.beta)

```
Dart version: 2.15.0-178.1.beta (beta) (Tue Oct 12 11:11:28 2021 +0200) on "macos_x64"
--------------------------------------------------------[SESSION: 1]
caseSigmoidFloat32x4> sum: 28.301810507828122
caseSigmoidFloat32x4{ elapsedTime: 14325 ms, hertz: 6,980,802 Hz, ops: 100,000,000, startTime: 2021-10-18 05:52:53.488748 .. +14 sec }

caseSigmoidFloat64x2> sum: 0.024898535462366082
caseSigmoidFloat64x2{ elapsedTime: 6688 ms, hertz: 14,952,153 Hz, ops: 100,000,000, startTime: 2021-10-18 05:53:07.862010 .. +6 sec }

--------------------------------------------------------[SESSION: 2]
caseSigmoidFloat32x4> sum: 28.301810507828122
caseSigmoidFloat32x4{ elapsedTime: 14240 ms, hertz: 7,022,471 Hz, ops: 100,000,000, startTime: 2021-10-18 05:53:14.550626 .. +14 sec }

caseSigmoidFloat64x2> sum: 0.024898535462366082
caseSigmoidFloat64x2{ elapsedTime: 6643 ms, hertz: 15,053,439 Hz, ops: 100,000,000, startTime: 2021-10-18 05:53:28.793301 .. +6 sec }

--------------------------------------------------------[SESSION: 3]
caseSigmoidFloat32x4> sum: 28.301810507828122
caseSigmoidFloat32x4{ elapsedTime: 14209 ms, hertz: 7,037,792 Hz, ops: 100,000,000, startTime: 2021-10-18 05:53:35.437365 .. +14 sec }

caseSigmoidFloat64x2> sum: 0.024898535462366082
caseSigmoidFloat64x2{ elapsedTime: 6671 ms, hertz: 14,990,256 Hz, ops: 100,000,000, startTime: 2021-10-18 05:53:49.647064 .. +6 sec }

======================================================================
BEST RESULTS:
caseSigmoidFloat32x4> caseSigmoidFloat32x4{ elapsedTime: 14209 ms, hertz: 7,037,792 Hz, ops: 100,000,000, startTime: 2021-10-18 05:53:35.437365 .. +14 sec }
caseSigmoidFloat64x2> caseSigmoidFloat64x2{ elapsedTime: 6643 ms, hertz: 15,053,439 Hz, ops: 100,000,000, startTime: 2021-10-18 05:53:28.793301 .. +6 sec }
======================================================================
Dart version: 2.15.0-178.1.beta (beta) (Tue Oct 12 11:11:28 2021 +0200) on "macos_x64"
```

## Contribution

If you want to contribute to this issue, run the benchmark
in your device and edit this README, adding your results
with the same information above, and send your `Pull Request`.
