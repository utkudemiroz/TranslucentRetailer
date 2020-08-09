clear
clc 
virtuallow=3; %lower bound for the virtual closet size
virtualhigh=15; %upper bound for the virtual closet size
b=3; %basket size
N=16; %number of customers
W1=18; %inventory for the first product
W2=32; %inventory for the second product

sim=100; %number of simulations

for v=virtuallow:1:virtualhigh 
    numberofsatisfied=zeros(1,sim);
    for i=1:1:sim
        for j=1:N
            demandfirstproduct(j)=binornd(v,0.8); %generated demand for the first product
            demandsecondproduct(j)=v-demandfirstproduct(j); %generated demand for the second product
        end
        
        w=transpose(cat(1,demandfirstproduct,demandsecondproduct)); %demand vector
        numberofsatisfied(i)=translucent(b,N,W1,W2,w);
    end
    meansatisfied=mean(numberofsatisfied);
    data(v)=meansatisfied;
end
x=virtuallow:virtualhigh;
data=data(:,[virtuallow:end]);
figure
plot(x,data)
xlabel('Virtual Closet Size')
ylabel('Number of customer Served')
title('Asymmetric Demand-Asymmetric Inventory(Second is more than first)-Total Inventory More than Total Demand')
grid on 
axis equal
