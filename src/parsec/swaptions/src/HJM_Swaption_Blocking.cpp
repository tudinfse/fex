//HJM_Swaption_Blocking.cpp
//Routines to compute various security prices using HJM framework (via Simulation).
//Authors: Mark Broadie, Jatin Dewanwala
//Collaborator: Mikhail Smelyanskiy, Intel, Jike Chong (Berkeley)

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <sys/types.h>
       #include <unistd.h>

#include "nr_routines.h"
#include "HJM_Securities.h"
#include "HJM.h"
#include "HJM_type.h"

// ALEX: embedding LibC functions: exp and log
#include <stdint.h>
// exp:

static const double
half[2] = {0.5,-0.5},
ln2hi = 6.93147180369123816490e-01, /* 0x3fe62e42, 0xfee00000 */
ln2lo = 1.90821492927058770002e-10, /* 0x3dea39ef, 0x35793c76 */
invln2 = 1.44269504088896338700e+00, /* 0x3ff71547, 0x652b82fe */
P1   =  1.66666666666666019037e-01, /* 0x3FC55555, 0x5555553E */
P2   = -2.77777777770155933842e-03, /* 0xBF66C16C, 0x16BEBD93 */
P3   =  6.61375632143793436117e-05, /* 0x3F11566A, 0xAF25DE2C */
P4   = -1.65339022054652515390e-06, /* 0xBEBBBD41, 0xC5D26BF1 */
P5   =  4.13813679705723846039e-08; /* 0x3E663769, 0x72BEA4D0 */

#define GET_HIGH_WORD(hi,d)                       \
do {                                              \
  union {double f; uint64_t i;} __u;              \
  __u.f = (d);                                    \
  (hi) = __u.i >> 32;                             \
} while (0)

#define FORCE_EVAL(x) do {                        \
	if (sizeof(x) == sizeof(float)) {         \
		volatile float __x;               \
		__x = (x);                        \
	} else if (sizeof(x) == sizeof(double)) { \
		volatile double __x;              \
		__x = (x);                        \
	} else {                                  \
		volatile long double __x;         \
		__x = (x);                        \
	}                                         \
} while(0)

static __inline unsigned __FLOAT_BITS(float __f)
{
	union {float __f; unsigned __i;} __u;
	__u.__f = __f;
	return __u.__i;
}
static __inline unsigned long long __DOUBLE_BITS(double __f)
{
	union {double __f; unsigned long long __i;} __u;
	__u.__f = __f;
	return __u.__i;
}

#define isnan(x) ( \
	sizeof(x) == sizeof(float) ? (__FLOAT_BITS(x) & 0x7fffffff) > 0x7f800000 : \
	sizeof(x) == sizeof(double) ? (__DOUBLE_BITS(x) & -1ULL>>1) > 0x7ffULL<<52 : \
	__fpclassifyl(x) == FP_NAN)

static double my_exp(double x)
{
	double_t hi, lo, c, xx, y;
	int k, sign;
	uint32_t hx;

	GET_HIGH_WORD(hx, x);
	sign = hx>>31;
	hx &= 0x7fffffff;  /* high word of |x| */

	/* special cases */
	if (hx >= 0x4086232b) {  /* if |x| >= 708.39... */
		if (isnan(x))
			return x;
		if (x > 709.782712893383973096) {
			/* overflow if x!=inf */
			x *= 0x1p1023;
			return x;
		}
		if (x < -708.39641853226410622) {
			/* underflow if x!=-inf */
			FORCE_EVAL((float)(-0x1p-149/x));
			if (x < -745.13321910194110842)
				return 0;
		}
	}

	/* argument reduction */
	if (hx > 0x3fd62e42) {  /* if |x| > 0.5 ln2 */
		if (hx >= 0x3ff0a2b2)  /* if |x| >= 1.5 ln2 */
			k = (int)(invln2*x + half[sign]);
		else
			k = 1 - sign - sign;
		hi = x - k*ln2hi;  /* k*ln2hi is exact here */
		lo = k*ln2lo;
		x = hi - lo;
	} else if (hx > 0x3e300000)  {  /* if |x| > 2**-28 */
		k = 0;
		hi = x;
		lo = 0;
	} else {
		/* inexact if x!=0 */
		FORCE_EVAL(0x1p1023 + x);
		return 1 + x;
	}

	/* x is now in primary range */
	xx = x*x;
	c = x - xx*(P1+xx*(P2+xx*(P3+xx*(P4+xx*P5))));
	y = 1 + (x*c/(2-c) - lo + hi);
	if (k == 0)
		return y;
	return scalbn(y, k);
}

// log
static const double
ln2_hi = 6.93147180369123816490e-01,  /* 3fe62e42 fee00000 */
ln2_lo = 1.90821492927058770002e-10,  /* 3dea39ef 35793c76 */
Lg1 = 6.666666666666735130e-01,  /* 3FE55555 55555593 */
Lg2 = 3.999999999940941908e-01,  /* 3FD99999 9997FA04 */
Lg3 = 2.857142874366239149e-01,  /* 3FD24924 94229359 */
Lg4 = 2.222219843214978396e-01,  /* 3FCC71C5 1D8E78AF */
Lg5 = 1.818357216161805012e-01,  /* 3FC74664 96CB03DE */
Lg6 = 1.531383769920937332e-01,  /* 3FC39A09 D078C69F */
Lg7 = 1.479819860511658591e-01;  /* 3FC2F112 DF3E5244 */

static double my_log(double x)
{
	union {double f; uint64_t i;} u = {x};
	double_t hfsq,f,s,z,R,w,t1,t2,dk;
	uint32_t hx;
	int k;

	hx = u.i>>32;
	k = 0;
	if (hx < 0x00100000 || hx>>31) {
		if (u.i<<1 == 0)
			return -1/(x*x);  /* log(+-0)=-inf */
		if (hx>>31)
			return (x-x)/0.0; /* log(-#) = NaN */
		/* subnormal number, scale x up */
		k -= 54;
		x *= 0x1p54;
		u.f = x;
		hx = u.i>>32;
	} else if (hx >= 0x7ff00000) {
		return x;
	} else if (hx == 0x3ff00000 && u.i<<32 == 0)
		return 0;

	/* reduce x into [sqrt(2)/2, sqrt(2)] */
	hx += 0x3ff00000 - 0x3fe6a09e;
	k += (int)(hx>>20) - 0x3ff;
	hx = (hx&0x000fffff) + 0x3fe6a09e;
	u.i = (uint64_t)hx<<32 | (u.i&0xffffffff);
	x = u.f;

	f = x - 1.0;
	hfsq = 0.5*f*f;
	s = f/(2.0+f);
	z = s*s;
	w = z*z;
	t1 = w*(Lg2+w*(Lg4+w*Lg6));
	t2 = z*(Lg1+w*(Lg3+w*(Lg5+w*Lg7)));
	R = t2 + t1;
	dk = k;
	return s*(hfsq+R) + dk*ln2_lo - hfsq + f + dk*ln2_hi;
}

// end LibC


int HJM_Swaption_Blocking(FTYPE *pdSwaptionPrice, //Output vector that will store simulation results in the form:
			  //Swaption Price
			  //Swaption Standard Error
			  //Swaption Parameters
			  FTYPE dStrike,
			  FTYPE dCompounding,     //Compounding convention used for quoting the strike (0 => continuous,
			  //0.5 => semi-annual, 1 => annual).
			  FTYPE dMaturity,	      //Maturity of the swaption (time to expiration)
			  FTYPE dTenor,	      //Tenor of the swap
			  FTYPE dPaymentInterval, //frequency of swap payments e.g. dPaymentInterval = 0.5 implies a swap payment every half
			  //year
			  //HJM Framework Parameters (please refer HJM.cpp for explanation of variables and functions)
			  int iN,
			  int iFactors,
			  FTYPE dYears,
			  FTYPE *pdYield,
			  FTYPE **ppdFactors,
			  //Simulation Parameters
			  long iRndSeed,
			  long lTrials,
			  int BLOCKSIZE, int tid)

{
  int iSuccess = 0;
  int i;
  int b; //block looping variable
  long l; //looping variables

  FTYPE ddelt = (FTYPE)(dYears/iN);				//ddelt = HJM matrix time-step width. e.g. if dYears = 5yrs and
                                                                //iN = no. of time points = 10, then ddelt = step length = 0.5yrs
  int iFreqRatio = (int)(dPaymentInterval/ddelt + 0.5);		// = ratio of time gap between swap payments and HJM step-width.
                                                                //e.g. dPaymentInterval = 1 year. ddelt = 0.5year. This implies that a swap
                                                                //payment will be made after every 2 HJM time steps.

  FTYPE dStrikeCont;				//Strike quoted in continuous compounding convention.
                                                //As HJM rates are continuous, the K in max(R-K,0) will be dStrikeCont and not dStrike.
  if(dCompounding==0) {
    dStrikeCont = dStrike;		//by convention, dCompounding = 0 means that the strike entered by user has been quoted
                                        //using continuous compounding convention
  } else {
    //converting quoted strike to continuously compounded strike
    dStrikeCont = (1/dCompounding)*my_log(1+dStrike*dCompounding);
  }
                                         //e.g., let k be strike quoted in semi-annual convention. Therefore, 1$ at the end of
                                         //half a year would earn = (1+k/2). For converting to continuous compounding,
                                         //(1+0.5*k) = exp(K*0.5)
                                         // => K = (1/0.5)*ln(1+0.5*k)

  //HJM Framework vectors and matrices
  int iSwapVectorLength;  // Length of the HJM rate path at the time index corresponding to swaption maturity.

  FTYPE **ppdHJMPath;    // **** per Trial data **** //

  FTYPE *pdForward;
  FTYPE **ppdDrifts;
  FTYPE *pdTotalDrift;

  // *******************************
  // ppdHJMPath = dmatrix(0,iN-1,0,iN-1);
//fprintf(stderr, "%d : 1****************/n", getpid());
  ppdHJMPath = dmatrix(0,iN-1,0,iN*BLOCKSIZE-1);    // **** per Trial data **** //
//fprintf(stderr, "%d : 2****************/n", getpid());
  pdForward = dvector(0, iN-1);
  ppdDrifts = dmatrix(0, iFactors-1, 0, iN-2);
  pdTotalDrift = dvector(0, iN-2);

  //==================================
  // **** per Trial data **** //
  FTYPE *pdDiscountingRatePath;	  //vector to store rate path along which the swaption payoff will be discounted
  FTYPE *pdPayoffDiscountFactors;  //vector to store discount factors for the rate path along which the swaption
  //payoff will be discounted
  FTYPE *pdSwapRatePath;			  //vector to store the rate path along which the swap payments made will be discounted
  FTYPE *pdSwapDiscountFactors;	  //vector to store discount factors for the rate path along which the swap
  //payments made will be discounted
  FTYPE *pdSwapPayoffs;			  //vector to store swap payoffs


  int iSwapStartTimeIndex;
  int iSwapTimePoints;
  FTYPE dSwapVectorYears;

  FTYPE dSwaptionPayoff;
  FTYPE dDiscSwaptionPayoff;
  FTYPE dFixedLegValue;

  // Accumulators
  FTYPE dSumSimSwaptionPrice;
  FTYPE dSumSquareSimSwaptionPrice;

  // Final returned results
  FTYPE dSimSwaptionMeanPrice;
  FTYPE dSimSwaptionStdError;

  // *******************************
  pdPayoffDiscountFactors = dvector(0, iN*BLOCKSIZE-1);
  pdDiscountingRatePath = dvector(0, iN*BLOCKSIZE-1);
  // *******************************

  iSwapVectorLength = (int) (iN - dMaturity/ddelt + 0.5);	//This is the length of the HJM rate path at the time index
  //corresponding to swaption maturity.
  // *******************************
  pdSwapRatePath = dvector(0, iSwapVectorLength*BLOCKSIZE - 1);
  pdSwapDiscountFactors  = dvector(0, iSwapVectorLength*BLOCKSIZE - 1);
  // *******************************
  pdSwapPayoffs = dvector(0, iSwapVectorLength - 1);


//fprintf(stderr, "%d : 3****************/n", getpid());
  iSwapStartTimeIndex = (int) (dMaturity/ddelt + 0.5);	//Swap starts at swaption maturity
  iSwapTimePoints = (int) (dTenor/ddelt + 0.5);			//Total HJM time points corresponding to the swap's tenor
  dSwapVectorYears = (FTYPE) (iSwapVectorLength*ddelt);



  //now we store the swap payoffs in the swap payoff vector
  for (i=0;i<=iSwapVectorLength-1;++i)
    pdSwapPayoffs[i] = 0.0; //initializing to zero
  for (i=iFreqRatio;i<=iSwapTimePoints;i+=iFreqRatio)
    {
      if(i != iSwapTimePoints)
	pdSwapPayoffs[i] = my_exp(dStrikeCont*dPaymentInterval) - 1; //the bond pays coupon equal to this amount
      if(i == iSwapTimePoints)
	pdSwapPayoffs[i] = my_exp(dStrikeCont*dPaymentInterval); //at terminal time point, bond pays coupon plus par amount
    }

  //generating forward curve at t=0 from supplied yield curve
  iSuccess = HJM_Yield_to_Forward(pdForward, iN, pdYield);
  if (iSuccess!=1)
    return iSuccess;

  //computation of drifts from factor volatilities
  iSuccess = HJM_Drifts(pdTotalDrift, ppdDrifts, iN, iFactors, dYears, ppdFactors);
  if (iSuccess!=1)
    return iSuccess;

  dSumSimSwaptionPrice = 0.0;
  dSumSquareSimSwaptionPrice = 0.0;

//fprintf(stderr, "%d : 4****************/n", getpid());
  //Simulations begin:
  for (l=0;l<=lTrials-1;l+=BLOCKSIZE) {
      //For each trial a new HJM Path is generated
      iSuccess = HJM_SimPath_Forward_Blocking(ppdHJMPath, iN, iFactors, dYears, pdForward, pdTotalDrift,ppdFactors, &iRndSeed, BLOCKSIZE); /* GC: 51% of the time goes here */
       if (iSuccess!=1)
	return iSuccess;

      //now we compute the discount factor vector

      for(i=0;i<=iN-1;++i){
	for(b=0;b<=BLOCKSIZE-1;b++){
	  pdDiscountingRatePath[BLOCKSIZE*i + b] = ppdHJMPath[i][0 + b];
	}
      }
      iSuccess = Discount_Factors_Blocking(pdPayoffDiscountFactors, iN, dYears, pdDiscountingRatePath, BLOCKSIZE); /* 15% of the time goes here */

     if (iSuccess!=1)
	return iSuccess;

      //now we compute discount factors along the swap path
      for (i=0;i<=iSwapVectorLength-1;++i){
	for(b=0;b<BLOCKSIZE;b++){
	  pdSwapRatePath[i*BLOCKSIZE + b] =
	    ppdHJMPath[iSwapStartTimeIndex][i*BLOCKSIZE + b];
	}
      }
      iSuccess = Discount_Factors_Blocking(pdSwapDiscountFactors, iSwapVectorLength, dSwapVectorYears, pdSwapRatePath, BLOCKSIZE);
      if (iSuccess!=1)
	return iSuccess;


      // ========================
      // Simulation
      for (b=0;b<BLOCKSIZE;b++){
	dFixedLegValue = 0.0;
	for (i=0;i<=iSwapVectorLength-1;++i){
	  dFixedLegValue += pdSwapPayoffs[i]*pdSwapDiscountFactors[i*BLOCKSIZE + b];
	}
	dSwaptionPayoff = dMax(dFixedLegValue - 1.0, 0);

	dDiscSwaptionPayoff = dSwaptionPayoff*pdPayoffDiscountFactors[iSwapStartTimeIndex*BLOCKSIZE + b];

	// ========= end simulation ======================================

	// accumulate into the aggregating variables =====================
	dSumSimSwaptionPrice += dDiscSwaptionPayoff;
	dSumSquareSimSwaptionPrice += dDiscSwaptionPayoff*dDiscSwaptionPayoff;
      } // END BLOCK simulation
    }

  // Simulation Results Stored
  dSimSwaptionMeanPrice = dSumSimSwaptionPrice/lTrials;
  dSimSwaptionStdError = sqrt((dSumSquareSimSwaptionPrice-dSumSimSwaptionPrice*dSumSimSwaptionPrice/lTrials)/
			      (lTrials-1.0))/sqrt((FTYPE)lTrials);

  //results returned
  pdSwaptionPrice[0] = dSimSwaptionMeanPrice;
  pdSwaptionPrice[1] = dSimSwaptionStdError;

  iSuccess = 1;
  return iSuccess;
}

