function [out,a,count,jjj]=extrac_t(g,a,k,jjj,totalbits,count);
if g>=64;
    bits=6;
    
    h=32;
elseif g<64 & g>=32;
    bits=5;
   
    h=16;
elseif g<32 & g>=16;
    bits=4;
    
    h=8;
elseif g<16
    bits=3;
       h=4;
end
l=bits;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:l;
    if bitand(g,h)==h;
        k= bitor(k,a);
    end
    count=count+1;
    a=a/2;
    h=h/2;
    if a<1;
        s=k;
        ff=data_1(s,jjj);
        jjj=jjj+1;
        k=0;
        a=128;
    else ff=0;
    end
    if count>totalbits;
        break;
    end
end
ff=0;
out=k;
%%%%%%%%%%%%%%%DATA%%%%%%%%%%%%%%%%
