// RandomMain3.cpp

#include <Rcpp.h>
#include "SimpleMC8.h"
#include "ParkMiller.h"
#include "Vanilla3.h"
#include "MCStatistics.h"
#include "ConvergenceTable.h"
#include "ConfLimits.h"
#include "AntiThetic.h"
#include "VecMeanStdDev.h"
#include <ctime>
#include <cstdlib>
#include <cmath>
#include <string>

using namespace Rcpp;
using namespace std;

// [[Rcpp::export]]
double MCEuropeanOptionPricer(
    std::string optType = "C",
    double Expiry = 0.5,
    double Strike = 100,
    double Spot = 95,
    double Vol = 0.2,
    double r = 0.06,
    bool antithetic = false,
    unsigned long NumberOfPaths = 1000000,
    unsigned long seed = 0
)
{
    srand(time(NULL));
    unsigned long baseSeed = (seed == 0) ? rand() : seed;

    PayOff* thePayOff;

    if (optType == "C") {
        thePayOff = new PayOffCall(Strike);
    } else {
        thePayOff = new PayOffPut(Strike);
    }

    VanillaOption theOption(*thePayOff, Expiry);
    ParametersConstant VolParam(Vol);
    ParametersConstant rParam(r);
    StatisticsMean gatherer1;
    RandomBase* generator1a;

    if (antithetic) {
        RandomParkMiller generator1(1);
        generator1.SetSeed(baseSeed);
        generator1a = new AntiThetic(generator1);
    } else {
        generator1a = new RandomParkMiller(1);
        generator1a->SetSeed(baseSeed);
    }

    SimpleMonteCarlo6(theOption,
                      Spot,
                      VolParam,
                      rParam,
                      NumberOfPaths,
                      gatherer1,
                      *generator1a);
    auto result = gatherer1.GetResultsSoFar()[0][0];

    // auto results = gatherer1.GetResultsSoFar();
    // Rcpp::Rcout << "Results size: " << results.size() << std::endl;
    // if (!results.empty()) {
    //     Rcpp::Rcout << "First result: " << results[0][0] << std::endl;
    // }

    delete generator1a;
    return result;

    // return results.empty() ? 0.0 : results[0][0];
}
