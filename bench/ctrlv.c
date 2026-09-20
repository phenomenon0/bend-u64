#include <stdio.h>
int main(void){ volatile unsigned long long a=0; for(long i=0;i<10000000;i++) a=a+1ULL; printf("%llu\n",(unsigned long long)a); return 0; }
