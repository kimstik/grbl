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
      float square=m*m, moment=3.0f*square-7.0f;
      float delta=h*sqrtf(moment*.05f), side=(5.0f/6.0f)*(square-1.0f)/moment;
      float g[2]={3*scale,12*scale}, e0[2]={7*scale,-36*scale}, d0[2]={-20*scale,72*scale};
      float v[2], minus[2], plus[2];
      for (int axis=0; axis<2; axis++) {
        float d=d0[axis], e=e0[axis];
        v[axis]=g[axis]+2.0f*t*e+(t*t+h*h/12.0f)*d;
        float base=v[axis]+delta*delta*d;
        float offset=2.0f*delta*(e+t*d);
        minus[axis]=base-offset;
        plus[axis]=base+offset;
      }
      estimate += 3.0f*m*h*(side*(sqrtf(minus[0]*minus[0]+minus[1]*minus[1])
                                +sqrtf(plus[0]*plus[0]+plus[1]*plus[1]))
                            +(1.0f-2.0f*side)*sqrtf(v[0]*v[0]+v[1]*v[1]));
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
  return !(worst <= .002);
}
int main(void) { int failed=check(124,1,30); failed |= check(1238,100,500); return failed; }
