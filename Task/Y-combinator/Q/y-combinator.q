> Y: {{x x} {({y {(x x) y} x} y) x} x}
> fac: {{$[y<2; 1; y*x y-1]} x}
> (Y fac) 6
720j
> fib: {{$[y<2; y;  (x y-1) + (x y-2)]} x}
> (Y fib) each til 20
0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181
