clear all; close all; clc;

% pull=[3 5 7 9 11];
% start=1:20;
% q=abs(start-pull(1));
% [x,n2]=min(q);
% 
% for j=1:4
%    q=abs(start-pull(j));
%    [x,n2]=min(q)
%    start=start([1:n2-1 n2+1:(20-j)]);
%    start'
% end
%     
% break



%%
L=10; x3=-L:0.1:L; n=length(x3)-1; % define domain
x2=x3(1:n); k=(2*pi/(2*L))*[0:n/2-1 -n/2:-1]; % k-vector
ye=exp(-(x2.^2)); ye2=exp((x2.^2)/2); % define Gaussians
for j=0:9      % loop through 10 modes
  yd=real(ifft(((i*k).^j).*fft(ye))); % 2nd derivative 
  mode=((-1)^(j))*(((2^j)*factorial(j)*sqrt(pi))^(-0.5))*ye2.*yd;
  y(:,j+1)=(mode).';  % store modes as columns
end

x=x2(n/2+1-40:n/2+1+40);  % keep only -4<x<4
yharm=y(n/2+1-40:n/2+1+40,:); 


%%
n=length(x); 
f=(exp(-(x-0.5).^2)+3*exp(-2*(x+1.5).^2))';

for j=1:10  % full reconstruction
  a(j,1)=trapz(x,f.*yharm(:,j));
end
f2=yharm*a;
Efull(1)=log(norm(f2-f)+1);  % reconstruction error

for j=1:10  % matrix M reconstruction
   for jj=1:j
       Area=trapz(x,yharm(:,j).*yharm(:,jj));
       M(j,jj)=Area;
       M(jj,j)=Area;
   end
end
Cfull=cond(M)   % get condition number

%%  Willcox alg.

% 23    52    37    79

% sensor 1
for jloop=1:81

s=zeros(n,1); 
s(jloop)=1;


for j=1:10
   for jj=1:j
       Area=trapz(x,s.*(yharm(:,j).*yharm(:,jj)));
       M2(j,jj)=Area; M2(jj,j)=Area;
   end
end
%figure(3), subplot(2,2,1), pcolor(10:-1:1,1:10,(M2'));, colormap(hot)


for j=1:10  % reconstruction using gappy
  ftild(j,1)=trapz(x,s.*(f.*yharm(:,j)));
end
atild=M2\ftild;   % compute error
f1=yharm*atild;
Er(1)=norm(f1-f);

con1(jloop)=cond(M2);


end

[s1,n1]=min(con1)



% sensor 2
jlook=[1:n1-1 n1+1:81];
for jloop=jlook

s=zeros(n,1); 
s(n1)=1;
s(jloop)=1;


for j=1:10
   for jj=1:j
       Area=trapz(x,s.*(yharm(:,j).*yharm(:,jj)));
       M2(j,jj)=Area; M2(jj,j)=Area;
   end
end
%figure(3), subplot(2,2,2), pcolor(10:-1:1,1:10,(M2'));, colormap(hot)


for j=1:10  % reconstruction using gappy
  ftild(j,1)=trapz(x,s.*(f.*yharm(:,j)));
end
atild=M2\ftild;   % compute error
f2=yharm*atild;
Er(2)=norm(f2-f);

con2(jloop)=cond(M2);

end
[s2,n2]=min(con2(jlook))


% sensor 3
if n2>n1
   jlook=[1:n1-1 n1+1:n2-1 n2+1:81];
else
   jlook=[1:n2-1 n2+1:n1-1 n1+1:81];
end

for jloop=jlook

s=zeros(n,1); 
s(n1)=1; s(n2)=1;
s(jloop)=1;


for j=1:10
   for jj=1:j
       Area=trapz(x,s.*(yharm(:,j).*yharm(:,jj)));
       M2(j,jj)=Area; M2(jj,j)=Area;
   end
end
%figure(3), subplot(2,2,3), pcolor(10:-1:1,1:10,(M2'));, colormap(hot)


for j=1:10  % reconstruction using gappy
  ftild(j,1)=trapz(x,s.*(f.*yharm(:,j)));
end
atild=M2\ftild;   % compute error
f3=yharm*atild;
Er(3)=norm(f3-f);

con3(jloop)=cond(M2);

end
[s3,n3]=min(con3(jlook))

% sensor 4
jlook=[1:n1-1 n1+1:n3-1 n3+1:n2-1 n2+1:81];
for jloop=jlook

s=zeros(n,1); 
s(n1)=1; s(n2)=1;
s(jloop)=1;


for j=1:10
   for jj=1:j
       Area=trapz(x,s.*(yharm(:,j).*yharm(:,jj)));
       M2(j,jj)=Area; M2(jj,j)=Area;
   end
end
%figure(3), subplot(2,2,4),pcolor(10:-1:1,1:10,(M2'));, colormap(hot)

for j=1:10  % reconstruction using gappy
  ftild(j,1)=trapz(x,s.*(f.*yharm(:,j)));
end
atild=M2\ftild;   % compute error
f4=yharm*atild;
Er(4)=norm(f4-f);

con4(jloop)=cond(M2);

end
[s4,n4]=min(con4(jlook))



figure(1)
subplot(4,1,1), bar(log(con1),'Facecolor',[0.7 0.7 0.7]), axis([1 81 0 100])
subplot(4,1,2), bar(log(con2),'Facecolor',[0.7 0.7 0.7]), axis([1 81 0 100])
subplot(4,1,3), bar(log(con3),'Facecolor',[0.7 0.7 0.7]), axis([1 81 0 100]) 
subplot(4,1,4), bar(log(con4),'Facecolor',[0.7 0.7 0.7]), axis([1 81 0 100]) 

temp=zeros(n,1), temp(n1)=s1; subplot(4,1,1),hold on, bar(log(temp),'r')
temp=zeros(n,1), temp(n2)=s2; subplot(4,1,2),hold on, bar(log(temp),'r')
temp=zeros(n,1), temp(n3)=s3; subplot(4,1,3),hold on, bar(log(temp),'r')
temp=zeros(n,1), temp(n4)=s4; subplot(4,1,4),hold on, bar(log(temp),'r')


subplot(4,1,1), set(gca,'Xtick',[0 40 80],'Ytick',[0 50 100],'Xticklabel',{'','',''},'Yticklabel',{'','',''})
subplot(4,1,2), set(gca,'Xtick',[0 40 80],'Ytick',[0 50 100],'Xticklabel',{'','',''},'Yticklabel',{'','',''})
subplot(4,1,3), set(gca,'Xtick',[0 40 80],'Ytick',[0 50 100],'Xticklabel',{'','',''},'Yticklabel',{'','',''})
subplot(4,1,4), set(gca,'Xtick',[0 40 80],'Ytick',[0 50 100],'Xticklabel',{'','',''},'Yticklabel',{'','',''})



break

figure(2)
subplot(4,1,1), plot(x,f1,'k',x,f,'r','Linewidth',[2])
subplot(4,1,2), plot(x,f2,'k',x,f,'r','Linewidth',[2])
subplot(4,1,3), plot(x,f3,'k',x,f,'r','Linewidth',[2])
subplot(4,1,4), plot(x,f4,'k',x,f,'r','Linewidth',[2])



%%  Willcox:  condition number

% pull=[3 5 7 9 11];
% start=1:20;
% q=abs(start-pull(1));
% [x,n2]=min(q);
% 
% for j=1:4
%    q=abs(start-pull(j));
%    [x,n2]=min(q)
%    start=start([1:n2-1 n2+1:(20-j)]);
%    start'
% end
%     
% break
clear f1
clear f2
clear ns
ns=[];            % vector to keep track of measurement locations
jlook=1:81;   % loop over 81 positions

count=1;
for jsense=1:20   %  loop for 20 sensors

for jloop=1:(82-jsense)   % loop from 81 to 61 locations
s=zeros(n,1); s(ns)=1;
s(jlook(jloop))=1; 

for j=1:10
   for jj=1:j    % matrix M
       Area=trapz(x,s.*(yharm(:,j).*yharm(:,jj)));
       M2(j,jj)=Area; M2(jj,j)=Area;
   end
end
con(jloop)=cond(M2);  % compute condition number

end

[s1,n1]=min(con);   % find minimum condition number location
kond(jsense)=s1; clear con
ns=[ns n1];  % add sensor location

jlook=jlook([1:n1-1 n1+1:(81-count+1)]);
count=count+1;

% reconstruct
s=zeros(n,1);  s(ns)=1;

for j=1:10
   for jj=1:j
       Area=trapz(x,s.*(yharm(:,j).*yharm(:,jj)));
       M2(j,jj)=Area; M2(jj,j)=Area;
   end
end

for j=1:10  % reconstruction using gappy
  ftild(j,1)=trapz(x,s.*(f.*yharm(:,j)));
end
atild=M2\ftild;   % compute error
f1(:,jsense)=yharm*atild;  % iterative reconstruction
Errr(jsense)=norm(f1(:,jsense)-f);  % iterative error
scum(:,jsense)=s;     % track iterative sensing matrix

end

figure(4)
subplot(2,1,2), bar(log(Errr+1))
subplot(2,1,1), bar(log(kond))

subplot(2,1,2), set(gca,'Xlim',[0 21],'Xtick',[1 5 10 15 20],'Xticklabel',{'','','','',''},'Ylim',[0 12],'Ytick',[0 4 8 12],'Yticklabel',{'','','',''})
subplot(2,1,1), set(gca,'Xlim',[0 21],'Xtick',[1 5 10 15 20],'Xticklabel',{'','','','',''},'Ylim',[0 42],'Ytick',[0 20 40],'Yticklabel',{'','',''})

%figure(6), bar(s)


figure(7), 
titer=[1:20 25]; f1=[f1 f]; titer2=[9:20 25], f2=[f1(:,9:20) f];
subplot(2,2,1), waterfall(x,titer,f1.'), colormap([0 0 0]), view(-150,50)
subplot(2,2,2), waterfall(x,titer2,f2.'), colormap([0 0 0]), view(-150,50)


subplot(2,2,1), set(gca,'Zlim',[-2 8],'Xlim',[-4 4],'Xtick',[-4 0 4],'Xticklabel',{'','',''}, ...
    'Ylim',[0 25],'Ytick',[1 10 20],'Yticklabel',{'','',''},'Ztick',[-2 0 4 8],'Zticklabel',{'','','',''})
subplot(2,2,2), set(gca,'Zlim',[-.2 3],'Xlim',[-4 4],'Xtick',[-4 0 4],'Xticklabel',{'','',''}, ...
    'Ylim',[0 25],'Ytick',[1 10 20],'Yticklabel',{'','',''},'Ztick',[0 1 2 3],'Zticklabel',{'','','',''})


figure(8)
%bar3(scum)
axes('position',[.05 .05 .9 .35])
scum2=[scum(:,[1:11 13:19])];
pcolor(-scum2.'), colormap(hot), axis off

%bar3(scum2)

%caxis([0 1]), axis off








