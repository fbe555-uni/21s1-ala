% case3gplotdemo.m
%
%

% the format of D is [x1 y1; x2 y2; ...]
% here [x1 x2... ; y1 y2 ...]' is used
D=[1 3 3 1;
   1 1 2 2]';



ADJ=[0 1 1 1;
     1 0 1 0;
     0 1 0 1;
     1 0 1 0];
 
gplot(ADJ,D,'*r-')
axis([-2 10 -2 10]);