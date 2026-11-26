/* Binary32 estimator model: not a model of rounded absolute XY emission. */
#include <math.h>
#include <stdio.h>

static float speed(float t, float h, float scale)
{
  float x = 3.0f*scale + 2.0f*t*7.0f*scale + (t*t + h*h/12.0f)*(-20.0f*scale);
  float y = 12.0f*scale + 2.0f*t*(-36.0f*scale) + (t*t + h*h/12.0f)*72.0f*scale;
  return sqrtf(x*x + y*y);
}

static int check(int n, float scale, float dz)
{
  float h = 1.0f/n, estimate = 1e-30f;
  double exact = 0.0, cumulative = 0.0, worst = 0.0;
  int step = (n + 15)/16;
  if (step < 5) step = 5;
  for (int j = 0; j < n; j++) exact += 3.0f*h*speed((j + .5f)*h, h, scale);
  for (int j = 0; j < n; j += step) {
    int count = n-j < step ? n-j : step;
    float m = count, t = (j + .5f*m)*h;
    if (count < 3) {
      for (int k = 0; k < count; k++) estimate += 3.0f*h*speed((j+k+.5f)*h,h,scale);
    } else {
      float delta=h*sqrtf(.15f*(m*m-1.0f));
      estimate += 3.0f*m*h*((5.0f/18.0f)*(speed(t-delta,h,scale)+speed(t+delta,h,scale))
                            +(4.0f/9.0f)*speed(t,h,scale));
    }
  }
  float rest=estimate, u=dz*.9999999f;
  for(int j=0;j<n-1;j++) {
    float c=3.0f*h*speed((j+.5f)*h,h,scale), f=c/rest;
    if(f<.999999f) {rest-=c;u-=f*u;} else u=0;
    cumulative+=c;
    double error=fabs((double)(dz-u)-dz*cumulative/exact);
    if(error>worst) worst=error;
  }
  printf("n=%d estimate=%.9g local_chords=%.12g max_local_Z_error=%.9g\n",n,estimate,exact,worst);
  printf("reference .002=%s .003=%s .004=%s\n", worst<=.002?"within":"over", worst<=.003?"within":"over", worst<=.004?"within":"over");
  return !isfinite(worst);
}
int main(void) { int failed = check(124,1,30); failed |= check(1238,100,500); return failed; }
