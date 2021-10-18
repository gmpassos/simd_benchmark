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

double case1(int loops) {
  var total = oneFloat32x4;

  for (var loop = 1; loop <= loops; ++loop) {
    var m = Float32x4.splat(loop.toDouble());
    for (var i = 1; i <= 20; ++i) {
      var n = Float32x4.splat(i.toDouble());
      m = m * n;
    }
    total += m;
  }

  return total.sumLane;
}

double case2(int loops) {
  var total = oneFloat32x4;

  var lng = 8;

  for (var loop = 1; loop <= loops; ++loop) {
    var m = Float32x4List(lng);
    for (var i = 0; i < lng; ++i) {
      m[i] = Float32x4.splat((1 + i).toDouble());
    }

    for (var i = 1; i <= 20; ++i) {
      var n = Float32x4List(lng);
      for (var i = 0; i < lng; ++i) {
        n[i] = Float32x4.splat(lng - i.toDouble());
      }

      for (var i = 0; i < lng; ++i) {
        m[i] = m[i] * n[i];
      }
    }

    for (var i = 0; i < lng; ++i) {
      total += m[i];
    }
  }

  return total.sumLane;
}

double case3(int loops) {
  var total = oneFloat32x4;

  var lng = 8;

  for (var loop = 1; loop <= loops; ++loop) {
    var m =
        generateFloat32x4List(lng, (i) => Float32x4.splat((1 + i).toDouble()));

    for (var i = 1; i <= 20; ++i) {
      var n = generateFloat32x4List(
          lng, (i) => Float32x4.splat(lng - i.toDouble()));

      for (var i = 0; i < lng; ++i) {
        m[i] = m[i] * n[i];
      }
    }

    for (var i = 0; i < lng; ++i) {
      total += m[i];
    }
  }

  return total.sumLane;
}

double case4(int loops) {
  var total = oneFloat32x4;

  var lng = 8;

  for (var loop = 1; loop <= loops; ++loop) {
    var m = DecimalsFloat32x4.generate(
        lng, (i) => Float32x4.splat((1 + i).toDouble()));

    for (var i = 1; i <= 20; ++i) {
      var n = DecimalsFloat32x4.generate(
          lng, (i) => Float32x4.splat(lng - i.toDouble()));

      for (var i = 0; i < lng; ++i) {
        m[i] = m[i] * n[i];
      }
    }

    for (var i = 0; i < lng; ++i) {
      total += m[i];
    }
  }

  return total.sumLane;
}

double case5(int loops) => caseDecimal<Float32x4, DecimalsFloat32x4>(
    loops,
    (length, val) => DecimalsFloat32x4.generate(length, val),
    (i) => Float32x4.splat((1 + i).toDouble()),
    (length, i) => Float32x4.splat(length - i.toDouble()),
    oneFloat32x4,
    (n) => n.sumLane);

double case6(int loops) => caseDecimal<Float64x2, DecimalsFloat64x2>(
    loops,
    (length, val) => DecimalsFloat64x2.generate(length, val),
    (i) => Float64x2.splat((1 + i).toDouble()),
    (length, i) => Float64x2.splat(length - i.toDouble()),
    oneFloat64x2,
    (n) => n.x + n.y);

double case7(int loops) => caseDecimal<double, DecimalsListDouble>(
    loops,
    (length, val) => DecimalsListDouble.generate(length, val),
    (i) => (1 + i).toDouble(),
    (length, i) => length - i.toDouble(),
    1.0,
    (n) => n);

double caseDecimal<T, D extends Decimals<T>>(
    int loops,
    D Function(int length, T Function(int i) val) genList,
    T Function(int i) genVal1,
    T Function(int length, int i) genVal2,
    T one,
    double Function(T n) sumLane) {
  var total = one;

  var lng = 64;

  for (var loop = 1; loop <= loops; ++loop) {
    var m = genList(lng, genVal1);

    for (var i = 1; i <= 20; ++i) {
      var n = genList(lng, (i) => genVal2(lng, i));

      for (var i = 0; i < lng; ++i) {
        m[i] = m.multiplyOther(n, i);
      }
    }

    for (var i = 0; i < lng; ++i) {
      total = m.sumWith(i, total);
    }
  }

  return sumLane(total);
}

double sigmoid(double x) => 1 / (1 + exp(-x));

Float32x4 expFloat32x4(Float32x4 n) =>
    Float32x4(exp(n.x), exp(n.y), exp(n.z), exp(n.w));

Float32x4 expFloat32x4Negative(Float32x4 n) =>
    Float32x4(exp(-n.x), exp(-n.y), exp(-n.z), exp(-n.w));

Float64x2 expFloat64x2(Float64x2 n) =>
    Float64x2(exp(n.x), exp(n.y));

Float32x4 sigmoidFloat32x4(x) =>
    oneFloat32x4 / (oneFloat32x4 + expFloat32x4(-x));

Float32x4 sigmoidFloat32x4B(x) =>
    oneFloat32x4 / (oneFloat32x4 + expFloat32x4Negative(x));

double case8(int loops) {
  var total = oneFloat32x4;

  var d = Float32x4.splat(1000000000000.0);

  var lng = 32;

  for (var loop = 1; loop <= loops; ++loop) {
    var m = DecimalsFloat32x4.generate(
        lng, (i) => Float32x4.splat((1 + i).toDouble()));

    for (var i = 1; i <= 20; ++i) {
      var n = DecimalsFloat32x4.generate(
          lng, (i) => Float32x4.splat(lng - i.toDouble()));

      for (var i = 0; i < lng; ++i) {
        m[i] = m[i] * n[i];
      }
    }

    for (var i = 0; i < lng; ++i) {
      total += sigmoidFloat32x4(m[i] / d);
    }
  }

  return total.sumLane;
}

var in1 = Float32x4(0.0, 0.25, 0.50, 1.0);
var in2 = Float32x4(1.0, 0.50, 0.25, 0.10);
var in3 = Float32x4(-6.0, -3.0, 3.0, 6.0);
var in4 = Float32x4(-2.0, -1.0, 1.0, 2.0);
var in5 = Float32x4(-12.0, -6.0, 6.0, 12.0);

double case10(int loops) => caseActivationFunction(loops, ActivationFunctionSigmoid());

double caseActivationFunction(
    int loops, ActivationFunction<double, Float32x4> activationFunction) {
  var result = in1;

  for (var i = 0; i < loops; ++i) {
    result = result * activationFunction.activateEntry(in1);
    result = result * activationFunction.activateEntry(in2);
    result = result * activationFunction.activateEntry(in3);
    result = result * activationFunction.activateEntry(in4);
    result = result + activationFunction.activateEntry(in5);
  }

  return result.sumLane;
}

Float32x4List generateFloat32x4List(int length, Float32x4 Function(int i) val) {
  var m = Float32x4List(length);
  for (var i = 0; i < length; ++i) {
    m[i] = val(i);
  }
  return m;
}

Float64x2List generateFloat64x2List(int length, Float64x2 Function(int i) val) {
  var m = Float64x2List(length);
  for (var i = 0; i < length; ++i) {
    m[i] = val(i);
  }
  return m;
}

abstract class Decimals<T> {
  T multiply(T a, T b);

  T multiplyOther(Decimals<T> other, int index);

  T sum(T a, T b);

  T sumOther(Decimals<T> other, int index);

  T sumWith(int index, T n);

  T operator [](int index);

  void operator []=(int index, T val);
}

class DecimalsFloat32x4 extends Decimals<Float32x4> {
  final Float32x4List ns;

  DecimalsFloat32x4(this.ns);

  DecimalsFloat32x4.length(int length) : ns = Float32x4List(length);

  DecimalsFloat32x4.generate(int length, Float32x4 Function(int i) val)
      : ns = generateFloat32x4List(length, val);

  @override
  Float32x4 multiply(Float32x4 a, Float32x4 b) => a * b;

  @override
  Float32x4 multiplyOther(Decimals<Float32x4> other, int index) =>
      this[index] * other[index];

  @override
  Float32x4 sum(Float32x4 a, Float32x4 b) => a + b;

  @override
  Float32x4 sumOther(Decimals<Float32x4> other, int index) =>
      this[index] + other[index];

  @override
  Float32x4 sumWith(int index, Float32x4 n) => this[index] + n;

  @override
  Float32x4 operator [](int index) => ns[index];

  @override
  void operator []=(int index, Float32x4 val) => ns[index] = val;
}

class DecimalsFloat64x2 extends Decimals<Float64x2> {
  final Float64x2List ns;

  DecimalsFloat64x2(this.ns);

  DecimalsFloat64x2.length(int length) : ns = Float64x2List(length);

  DecimalsFloat64x2.generate(int length, Float64x2 Function(int i) val)
      : ns = generateFloat64x2List(length, val);

  @override
  Float64x2 multiply(Float64x2 a, Float64x2 b) => a * b;

  @override
  Float64x2 multiplyOther(Decimals<Float64x2> other, int index) =>
      this[index] * other[index];

  @override
  Float64x2 sum(Float64x2 a, Float64x2 b) => a + b;

  @override
  Float64x2 sumOther(Decimals<Float64x2> other, int index) =>
      this[index] + other[index];

  @override
  Float64x2 sumWith(int index, Float64x2 n) => this[index] + n;

  @override
  Float64x2 operator [](int index) => ns[index];

  @override
  void operator []=(int index, Float64x2 val) => ns[index] = val;
}

class DecimalsListDouble extends Decimals<double> {
  final List<double> ns;

  DecimalsListDouble(this.ns);

  DecimalsListDouble.length(int length)
      : ns = List<double>.generate(length, (i) => 0.0);

  DecimalsListDouble.generate(int length, double Function(int i) val)
      : ns = List<double>.generate(length, val);

  @override
  double multiply(double a, double b) => a * b;

  @override
  double multiplyOther(Decimals<double> other, int index) =>
      this[index] * other[index];

  @override
  double sum(double a, double b) => a + b;

  @override
  double sumOther(Decimals<double> other, int index) =>
      this[index] + other[index];

  @override
  double sumWith(int index, double n) => this[index] + n;

  @override
  double operator [](int index) => ns[index];

  @override
  void operator []=(int index, double val) => ns[index] = val;
}

abstract class ActivationFunction<N extends num, E> {
  final String name;

  const ActivationFunction(this.name);

  N activate(N x);

  E activateEntry(E entry);
}

abstract class ActivationFunctionFloat32x4
    extends ActivationFunction<double, Float32x4> {
  ActivationFunctionFloat32x4(String name) : super(name);
}

class ActivationFunctionSigmoid extends ActivationFunctionFloat32x4 {
  ActivationFunctionSigmoid() : super('Sigmoid');

  @override
  double activate(double x) {
    return 1 / (1 + exp(-x));
  }

  @override
  Float32x4 activateEntry(Float32x4 entry) {

    return oneFloat32x4 /
        (oneFloat32x4 + expFloat32x4(-entry));
  }
}

void main(List<String> arguments) {
  print('Dart version: ${Platform.version}');

  var bestBenchmark = <String, Chronometer>{};

  for (var session = 1; session <= 3; ++session) {
    print('--------------------------------------------------------[$session]');

    // benchmark('case1', 10, 1000000, case1, bestBenchmark);
    // benchmark('case2', 10, 1000000, case2, bestBenchmark);
    // benchmark('case3', 10, 1000000, case3, bestBenchmark);
    //benchmark('case4', 10, 300000, case4, bestBenchmark);
    //benchmark('case5', 10, 10000, case5, bestBenchmark);
    // benchmark('case6', 10, 600000, case6, bestBenchmark);
    // benchmark('case7', 10, 120000, case7, bestBenchmark);
    //benchmark('case8', 10, 20000, case8, bestBenchmark);

    benchmark('case10', 10, 10000000, case10, bestBenchmark);
  }

  print(
      '======================================================================');

  for (var e in bestBenchmark.entries) {
    print('${e.key}> ${e.value}');
  }

  print('Dart version: ${Platform.version}');
}
