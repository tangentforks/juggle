/*
 *  Tests on integer and real data types.
 *  Tests that 'long long' and 'long double' can store more than
 *  'long' and 'double'.
 */

#include <ifdefs.h>

#include <stdlib.h>
#include <limits.h>
#include <float.h>

int
main (int argc, char **argv)
{
    int i;
    long l;
#if HAVE_LONG_LONG
    long long ll, ll2;
#endif
    float f;
    double d;
#if HAVE_LONG_DOUBLE
    long double ld, ld2;
#endif

/*
 *  Instructions
 *  ------------
 *  1) Put a breakpoint on the call to 'exit()' at the end of the code
 *     then press the 'Start' button.
 *  2) Display each of the variables.
 *     'ld2' may display or may give an error - this is expected.
 */

    i = INT_MAX;
    l = LONG_MAX;
#if HAVE_LONG_LONG
    ll = l;
    ll2 = ll * 2;
    ll += 1;
#endif

    f = FLT_MAX;
    d = DBL_MAX;
#if HAVE_LONG_DOUBLE
    ld = LDBL_MAX;
    ld2 = ld * 2;
    ld = ld + 1;
#endif

    exit (0);

}

