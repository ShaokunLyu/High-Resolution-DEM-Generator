function X1=SVD(C,L)
[U S V]=svd(C,0);
 index1=find(S>=0.001);
 index2=find(S<0.001);
 S(index1)=1./S(index1);
 S(index2)=0;
 X1=V*S'*U'*L;

