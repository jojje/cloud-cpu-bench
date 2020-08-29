# cloud-cpu-bench
Benchmark script to use for comparing cloud provider CPU performance.

[![](https://img.shields.io/docker/build/jojje/cloud-cpu-bench.svg)](https://hub.docker.com/r/jojje/cloud-cpu-bench/builds/)

The script uses the benchmark program [starve-check][1] by Doug Gale, which performs tight loop computation without waits, to stress the CPU, and counts the number of iteration per unit of time (per second in _this_ project) that each thread managed within that duration.

This project adds statistics to the test runs, so that it gets easier to:

* Reason about the CPU performance of a given cloud provider.
* Contrast the different compute characteristics of different sizes of cloud servers.
* Discern the variability in CPU capacity the providers give their customers.
* Compare offerings, so you get the most CPU cycles per $ spent.

## Usage:

    $ docker run --rm jojje/cloud-cpu-bench --help

    usage: cloud-cpu-bench [OPTIONS]

    Cloud CPU benchmark. Calculates how many millions of operations per second are
    being performed on each CPU on a linux machine. The CPU metrics are averaged
    so that one can gauge per-core scalability and compare those figures between
    cloud providers, and between differently sized machines on the same provider,
    to gain most bang for the buck. After sampling completes, variance statistics
    are provided, to highlight how (un)reliable the provider's offering is. The
    benchmark program used is the following: https://github.com/doug65536/starve-
    check

    optional arguments:
      -h, --help         show this help message and exit
      -t N, --threads N  Number of threads to use. Defaults the same number as
                         there are "cpus" reported for the system (default: 4)
      -s N, --samples N  Number of samples to grab during the test (one sample
                         every second). Must be at least 2 samples (default: 100)
      --version          show program's version number and exit

### Run a short test on all cores for one minute 40 seconds (100 samples)

    $ docker run --rm jojje/cloud-cpu-bench

    73M    72M    74M    77M
    79M    74M    80M    74M
    ...

    ==[ CPU PERFORMANCE (Mops/cpu) ]======================================

    P99          63.25
    P95          65.0
    P90          66.75
    Mean         72.55
    StDev        3.614
    Median       73.5

    ==[ CPU INFO ]========================================================

    CPUs         4
    Model        Intel(R) Xeon(R) Gold 6140 CPU @ 2.30GHz
    MHz          2494.138
    Cache        4096 KB
    BogoMips     4988.27

    ==[ TEST INFO ]=======================================================

    Samples      100
    Threads      4
    Generated    2020-08-29 17:26:59 +0000
    Kernal       Linux 6e1200833bea 5.4.0-42-generic #46-Ubuntu SMP Fri Jul 10 00:24:02 UTC 2020 x86_64 Linux

    Version      0.1.3
    Starve-check f14d7ba8152c8e09179fea3f47fd6b3a93f13cae


The stats are computed by averaging the number of ops all CPUs process each
second. The unit is Mega ops / second and CPU. So for the example above, the
mean total number of ops per second for all VCPUs engaged is the mean per vcpu
score times the number of threads. I.e. ~72.55 * 4 = 290 Mop/s

For those seeking guaranteed performance (lowest expected), the percentile
figure is more relevant. P99 means that 99% of all samples were able to
perform just north of 63 Mop/s.

What this communicates is that this particular vm type may not be suitable
for workloads that require more than a stable 63 Mop/s, or workloads that are
sensitive to latency, since the variance is rather high.

[1]: https://github.com/doug65536/starve-check
