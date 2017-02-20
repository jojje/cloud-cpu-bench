# cloud-cpu-bench
Benchmark script to use for comparing cloud provider CPU performance.

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
                         every second). Must be at least 2 samples (default: 60)
      --version          show program's version number and exit

### Run a short test on all VCPUs for one minute (60 samples)

    $ docker run --rm jojje/cloud-cpu-bench

    53M    90M    91M    92M
    55M    95M    95M    96M
    ...

    ==[ CPU PERFORMANCE (Mops/cpu) ]======================================

    95%          81.25
    90%          82.75
    Mean         86.7833
    Median       88.25
    StDev        3.2824
    Variance     10.7743

    ==[ CPU INFO ]========================================================

    CPUs         4
    Model        Intel(R) Core(TM) i5-2500 CPU @ 3.30GHz
    MHz          3292.677
    Cache        6144 KB
    BogoMips     6585.04

    ==[ TEST INFO ]=======================================================

    Samples      60
    Threads      4
    Generated    2017-02-19 22:56:18 +0000
    Kernal       Linux 1437b8d66ba1 4.8.0-36-generic #36~16.04.1-Ubuntu
                 SMP Sun Feb 5 09:39:57 UTC 2017 x86_64 Linux

    Version      0.1.0
    Starve-check f14d7ba8152c8e09179fea3f47fd6b3a93f13cae


The stats are computed by averaging the number of ops all CPUs process each
second.  The unit is Mega ops / second and CPU. So for the example above, the
average number of ops for all VCPUs engaged is the average mean times number of
threads. I.e. ~86.8 * 4 = 347 Mops/s 

For those who seek guaranteed performance (lowest expected), the percentile
figure is more relevant.  95% means that 95% of all samples were able to
perform little over 81 Mops/s.

[1]: https://github.com/doug65536/starve-check
