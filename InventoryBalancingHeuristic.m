clear
clc
W1=18; %inventory for the first product
W2=32; %inventory for the second product
N=25; %number of customers subscribed
v=5; %virtual closet size
for j=1:N
    demandfirstproduct(j)=binornd(v,0.5); %generated demand for the first product
    demandsecondproduct(j)=v-demandfirstproduct(j); %generated demand for the second product
end

w=transpose(cat(1,demandfirstproduct,demandsecondproduct)); %demand
T1=0; %type 1 customer initialization
T2=0; %type 2 customer initialization
T3=0; %type 3 customer initialization
T4=0; %type 4 customer initialization
T5=0; %type 5 customer initialization


for i=1:length(w)
  if(w(i,1)==v)
      T1=T1+1;
  elseif (w(i,1)==v-1)
      T2=T2+1;
  elseif (w(i,1)==1)
      T4=T4+1;
  elseif (w(i,1)==0)
      T5=T5+1;
  else 
      T3=T3+1;
  end
end

count=0;
stop=0;
while(stop==0 && W1>0 && W2>0)
    if W1>=W2+1
        if T1~=0 %if there are customers of type 1
            W1=W1-2; %allocate them 2,0
            T1=T1-1;%and update the number
            count=count+1;
        elseif T2~=0 %else if there are customers of type 2
            W1=W1-2; %allocate them 2,0
            T2=T2-1; 
            count=count+1;
        elseif T3~=0 %else if there are customers of type 3
            W1=W1-2; %allocate them 2,0
            T3=T3-1;
            count=count+1;
        elseif T4~=0 %else if there are customers of type 4
            W1=W1-1; %allocate them 1,1
            W2=W2-1;
            T4=T4-1;
            count=count+1;
        elseif T5~=0 %else if there are customers of type 5
            W2=W2-2;%allocate them 0,2
            T5=T5-1;
            count=count+1;
        else 
            stop=1; %else if there is no customer left, stop.
        end
    elseif W2>=W1+1
        if T5~=0 %if there are customers of type 5
            W2=W2-2; %allocate them 0,2
            T5=T5-1; %and update the number
            count=count+1;
        elseif T4~=0 %else if there are customers of type 4
            W2=W2-2; %allocate them 0,2
            T4=T4-1; 
            count=count+1;
        elseif T3~=0 %else if there are customers of type 3
            W2=W2-2; %allocate them 0,2
            T3=T3-1;
            count=count+1;
        elseif T2~=0 %else if there are customers of type 2
            W1=W1-1; %allocate them 1,1
            W2=W2-1; %allocate them 1,1
            T2=T2-1;
            count=count+1;
        elseif T1~=0 %else if there are customers of type 1
            W1=W1-2; %allocate them 2,0
            T1=T1-1; 
            count=count+1;
        else 
            stop=1;
        end
    else
        if T2>0 && T4>0
            if T2>=T4
                W1=W1-1;
                W2=W2-1;
                T2=T2-1;
                count=count+1;
            else
                W1=W1-1;
                W2=W2-1;
                T4=T4-1;
                count=count+1;
            end
        elseif T2>0 && T4==0
            W1=W1-1;
            W2=W2-1;
            T2=T2-1;
            count=count+1;
        elseif T2==0 && T4>0
            W1=W1-1;
            W2=W2-1;
            T4=T4-1;
            count=count+1;
        else 
            stop=1;
        end
    end
end

