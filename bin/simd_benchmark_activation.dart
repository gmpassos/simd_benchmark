import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:statistics/statistics.dart';

final Float32x4 oneFloat32x4 = Float32x4.splat(1.0);
final Float64x2 oneFloat64x2 = Float64x2.splat(1.0);

Chronometer benchmark(String name, int retries, int loops,
    double Function(int loops) f, Map<String, Chronometer> bestBenchmark) {
  var chronometer = Chronometer(name);
  chronometer.start();

  var sum = 0.0;

  for (var retry = 0; retry < retries; ++retry) {
    sum += f(loops);
  }

  chronometer.stop(operations: retries * loops);

  print('$name> sum: $sum');

  print('$chronometer\n');

  bestBenchmark.update(
      name, (v) => v.compareTo(chronometer) > 0 ? v : chronometer,
      ifAbsent: () => chronometer);

  return chronometer;
}

Float32x4 expFloat32x4(Float32x4 n) =>
    Float32x4(exp(n.x), exp(n.y), exp(n.z), exp(n.w));

Float64x2 expFloat64x2(Float64x2 n) => Float64x2(exp(n.x), exp(n.y));

Float32x4 sigmoidFloat32x4(x) =>
    oneFloat32x4 / (oneFloat32x4 + expFloat32x4(-x));

Float64x2 sigmoidFloat64x2(x) =>
    oneFloat64x2 / (oneFloat64x2 + expFloat64x2(-x));

var in1F32 = Float32x4(0.0, 0.25, 0.50, 1.0);
var in2F32 = Float32x4(1.0, 0.50, 0.25, 0.10);
var in3F32 = Float32x4(-6.0, -3.0, 3.0, 6.0);
var in4F32 = Float32x4(-2.0, -1.0, 1.0, 2.0);
var in5F32 = Float32x4(-12.0, -6.0, 6.0, 12.0);

double caseActivationFunctionSigmoidFloat32x4(int loops) =>
    caseActivationFunctionFloat32x4(
        loops, ActivationFunctionSigmoidFloat32x4());

double caseActivationFunctionFloat32x4(
    int loops, ActivationFunction<double, Float32x4> activationFunction) {
  var result = in1F32;

  for (var i = 0; i < loops; ++i) {
    result = result * activationFunction.activateEntry(in1F32);
    result = result * activationFunction.activateEntry(in2F32);
    result = result * activationFunction.activateEntry(in3F32);
    result = result * activationFunction.activateEntry(in4F32);
    result = result + activationFunction.activateEntry(in5F32);
  }

  return result.sumLane;
}

double case10B(int loops) => caseSigmoidFloat32x4(loops);

double caseSigmoidFloat32x4(int loops) {
  var result = in1F32;

  for (var i = 0; i < loops; ++i) {
    result = result * sigmoidFloat32x4(in1F32);
    result = result * sigmoidFloat32x4(in2F32);
    result = result * sigmoidFloat32x4(in3F32);
    result = result * sigmoidFloat32x4(in4F32);
    result = result + sigmoidFloat32x4(in5F32);
  }

  return result.sumLane;
}

var in1F64 = Float64x2(0.0, 0.25);
var in2F64 = Float64x2(1.0, 0.50);
var in3F64 = Float64x2(-6.0, -3.0);
var in4F64 = Float64x2(-2.0, -1.0);
var in5F64 = Float64x2(-12.0, -6.0);

double caseActivationFunctionSigmoidFloat64x2(int loops) =>
    caseActivationFunctionFloat64x2(
        loops, ActivationFunctionSigmoidFloat64x2());

double caseActivationFunctionFloat64x2(
    int loops, ActivationFunction<double, Float64x2> activationFunction) {
  var result = in1F64;

  for (var i = 0; i < loops; ++i) {
    result = result * activationFunction.activateEntry(in1F64);
    result = result * activationFunction.activateEntry(in2F64);
    result = result * activationFunction.activateEntry(in3F64);
    result = result * activationFunction.activateEntry(in4F64);
    result = result + activationFunction.activateEntry(in5F64);
  }

  return result.x + result.y;
}

double caseSigmoidFloat64x2(int loops) {
  var result = in1F64;

  for (var i = 0; i < loops; ++i) {
    result = result * sigmoidFloat64x2(in1F64);
    result = result * sigmoidFloat64x2(in2F64);
    result = result * sigmoidFloat64x2(in3F64);
    result = result * sigmoidFloat64x2(in4F64);
    result = result + sigmoidFloat64x2(in5F64);
  }

  return result.x + result.y;
}

abstract class ActivationFunction<N extends num, E> {
  final String name;

  const ActivationFunction(this.name);

  N activate(N x);

  E activateEntry(E entry);
}

abstract class ActivationFunctionFloat32x4
    extends ActivationFunction<double, Float32x4> {
  const ActivationFunctionFloat32x4(String name) : super(name);
}

class ActivationFunctionSigmoidFloat32x4 extends ActivationFunctionFloat32x4 {
  const ActivationFunctionSigmoidFloat32x4() : super('Sigmoid');

  @override
  double activate(double x) {
    return 1 / (1 + exp(-x));
  }

  @override
  Float32x4 activateEntry(Float32x4 entry) {
    return oneFloat32x4 / (oneFloat32x4 + expFloat32x4(-entry));
  }
}

abstract class ActivationFunctionFloat64x2
    extends ActivationFunction<double, Float64x2> {
  const ActivationFunctionFloat64x2(String name) : super(name);
}

class ActivationFunctionSigmoidFloat64x2 extends ActivationFunctionFloat64x2 {
  const ActivationFunctionSigmoidFloat64x2() : super('Sigmoid');

  @override
  double activate(double x) {
    return 1 / (1 + exp(-x));
  }

  @override
  Float64x2 activateEntry(Float64x2 entry) {
    return oneFloat64x2 / (oneFloat64x2 + expFloat64x2(-entry));
  }
}

void main(List<String> arguments) {
  print('Dart version: ${Platform.version}');

  var bestBenchmark = <String, Chronometer>{};

  for (var session = 1; session <= 3; ++session) {
    print('--------------------------------------------------------[$session]');

    benchmark('caseActivationFunctionSigmoidFloat32x4', 10, 10000000,
        caseActivationFunctionSigmoidFloat32x4, bestBenchmark);
    benchmark('caseSigmoidFloat32x4', 10, 10000000, caseSigmoidFloat32x4,
        bestBenchmark);
    benchmark('caseActivationFunctionSigmoidFloat64x2', 10, 10000000,
        caseActivationFunctionSigmoidFloat64x2, bestBenchmark);
    benchmark('caseSigmoidFloat64x2', 10, 10000000, caseSigmoidFloat64x2,
        bestBenchmark);
  }

  print(
      '======================================================================');

  for (var e in bestBenchmark.entries) {
    print('${e.key}> ${e.value}');
  }

  print('Dart version: ${Platform.version}');
}
