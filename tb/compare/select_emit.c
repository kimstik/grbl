/* Export actual host-parser targets, without treating a loose policy as a bound. */
#define main vector_main
#include "../host/tb.c"
#undef main

static void bits(float value)
{
  uint32_t word;
  memcpy(&word, &value, sizeof word);
  printf(" %u", (unsigned)word);
}

int main(int argc, char **argv)
{
  if (argc != 2) { return 2; }
  FILE *fp = fopen(argv[1], "r");
  if (!fp) { return 2; }
  char raw[256];
  quiet = 1;
  machine_reset();
  memset(&m, 0, sizeof m);
  memset(steps, 0, sizeof steps);
  memcpy(sys_position, steps, sizeof steps);
  plan_sync_position();
  gc_sync_position();
  while (fgets(raw, sizeof raw, fp)) {
    raw[strcspn(raw, "\r\n")] = 0;
    if (!*raw || *raw == '#') { continue; }
    int measured = *raw == '*';
    char *line = raw + measured;
    float start[N_AXIS];
    memcpy(start, gc_state.position, sizeof start);
    nseg = 0;
    parsed.ok = 0;
    tb_realtime_calls = 0;
    memset(&bezier_z_trace, 0, sizeof bezier_z_trace);
    uint8_t status = gc_execute_line(line);
    tb_drain();
    if (!measured) {
      if (status) { fprintf(stderr, "unmeasured status %u: %s\n", status, line); return 3; }
      continue;
    }
    printf("line %s\nstart", line);
    for (unsigned k = 0; k < N_AXIS; k++) { bits(start[k]); }
    printf("\nnet");
    for (unsigned k = 0; k < 4; k++) {
      for (unsigned a = 0; a < N_AXIS; a++) { bits((float)parsed.p[k][a]); }
    }
    putchar('\n');
    if (nseg > MAXSEG) { fclose(fp); return 4; }
    for (int k = 0; k < nseg; k++) {
      printf("p");
      for (unsigned a = 0; a < N_AXIS; a++) { bits(seg[k][a]); }
      bits(seg_feed[k]);
      printf(" %u\n", seg_cond[k]);
    }
    printf("end %u %d %u %u %u %u %u %u %u", status, nseg, parsed.ok,
           bezier_z_trace.estimates, bezier_z_trace.sums, bezier_z_trace.open,
           bezier_z_trace.ends, bezier_z_trace.pieces, bezier_z_trace.summed);
    bits(bezier_z_trace.bound);
    bits(bezier_z_trace.time);
    bits(bezier_z_trace.half);
    putchar('\n');
  }
  if (ferror(fp)) { fclose(fp); return 5; }
  fclose(fp);
  return 0;
}
