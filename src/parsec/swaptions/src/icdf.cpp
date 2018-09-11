#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "HJM_type.h"


// ALEX: embedding LibC functions: log
#include <stdint.h>
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


void icdf_baseline(const int N, FTYPE *in, FTYPE *out){

  register FTYPE z, r;

 const FTYPE
    a1 = -3.969683028665376e+01,
    a2 =  2.209460984245205e+02,
    a3 = -2.759285104469687e+02,
    a4 =  1.383577518672690e+02,
    a5 = -3.066479806614716e+01,
    a6 =  2.506628277459239e+00;

  const FTYPE
    b1 = -5.447609879822406e+01,
    b2 =  1.615858368580409e+02,
    b3 = -1.556989798598866e+02,
    b4 =  6.680131188771972e+01,
    b5 = -1.328068155288572e+01;

   const FTYPE
    c1 = -7.784894002430293e-03,
    c2 = -3.223964580411365e-01,
    c3 = -2.400758277161838e+00,
    c4 = -2.549732539343734e+00,
    c5 =  4.374664141464968e+00,
    c6 =  2.938163982698783e+00;

  const FTYPE
    //d0 =  0.0,
    d1 =  7.784695709041462e-03,
    d2 =  3.224671290700398e-01,
    d3 =  2.445134137142996e+00,
    d4 =  3.754408661907416e+00;

  // Limits of the approximation region.
#define U_LOW 0.02425

  const FTYPE u_low   = U_LOW, u_high  = 1.0 - U_LOW;

  for(int i=0; i<N; i++){
    FTYPE u = in[i];
    // Rational approximation for the lower region. ( 0 < u < u_low )
    if( u < u_low ){
      z = sqrt(-2.0*my_log(u));
      z = (((((c1*z+c2)*z+c3)*z+c4)*z+c5)*z+c6) / ((((d1*z+d2)*z+d3)*z+d4)*z+1.0);
    }
    // Rational approximation for the central region. ( u_low <= u <= u_high )
    else if( u <= u_high ){
      z = u - 0.5;
      r = z*z;
      z = (((((a1*r+a2)*r+a3)*r+a4)*r+a5)*r+a6)*z / (((((b1*r+b2)*r+b3)*r+b4)*r+b5)*r+1.0);
    }
    // Rational approximation for the upper region. ( u_high < u < 1 )
    else {
      z = sqrt(-2.0*my_log(1.0-u));
      z = -(((((c1*z+c2)*z+c3)*z+c4)*z+c5)*z+c6) /  ((((d1*z+d2)*z+d3)*z+d4)*z+1.0);
    }
    out[i] = z;
  }
  return;
}

