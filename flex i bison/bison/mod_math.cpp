#include "mod_math.h"
int mod(int a)
{
	if (a < 0) return BASE-(-a)%BASE;
	else return a%BASE;
}
int sum_mod(int a, int b)
{
	return mod(mod(a)+mod(b));
}
int dif_mod(int a, int b)
{
	return mod(a-b);
}
int mul_mod(int a, int b)
{
	a = mod(a);
	b = mod(b);
	int r = 0;
	for (int i = 0; i < b; i++)
	{
		r = sum_mod(r, a);
	}
	return r;
}
int gcdExtended(int a, int b, int *x, int *y)
{
    if (a == 0)
    {
        *x = 0;
        *y = 1;
        return b;
    }
 
    int x1, y1; 
    int gcd = gcdExtended(b%a, a, &x1, &y1);
 
    *x = y1 - b/a * x1;
    *y = x1;
 
    return gcd;
}
int div_mod(int a, int b)
{
	int x, y;
	if (gcdExtended(b, BASE, &x, &y) == 1)
	{
		return mul_mod(a,x);
	}
	return 0;
}
int neg_mod(int a)
{
	return mod(-a);
}
int pow_mod(int a, int b)
{
	int r = 1;
	for (int i = 0; i < b; i++)
	{
		r = mul_mod(r, a);
	}
	return r;
}
