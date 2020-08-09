function [optval] = translucent(b,N,W1,W2,w)


%Virtual closet size=Virtual Closet Size
%B=Basket Size
%N=Total number of customers we have
%W1=Starting inventory of the first product
%W2=Starting inventory of the second product
%w=demand

v=ones(1,N);
n=length(v);

for i=1:n+1
    for j=1:W1+1
        for k=1:W2+1
            if(i==1 || (j==1) && (k==1))
                V(i,j,k)=0; %boundary condition.
            end
        end
    end
end

for i=1:b+1
    allocation1(i)=b+1-i; %creating the allocation matrix for the first product
    allocation2(i)=i-1; %creating the allocation matrix for the second product
end



if(W1==0)
  for i=2:n+1
    for k=2:W2+1
        countinventoryno=0;
        countfeasible=0;
        a=[V(i-1,1,k)]; %allocations that fit for inventory for indices i,j,k
            for t=1:b+1
                if(allocation1(t)<=w(i-1,1) && allocation2(t)<=w(i-1,2)) %checking whether the allocation 
                    %is feasible according to the demand
                    countfeasible=countfeasible+1;
                    if ((allocation1(t)>=1) || (allocation2(t)>=k))%whether the feasible allocation can
                        %be given at the current state or not.
                        countinventoryno=countinventoryno+1;
                    else
                    c=[v(i-1)+V(i-1,1,k-allocation2(t))];
                    a=[a c];
                    end
                end
            end
            if  (countfeasible==countinventoryno)
                V(i,1,k)=V(i-1,1,k);
            else
                V(i,1,k)=max(a); 
            end
        end
    end  
elseif(W2==0)
    for i=2:n+1
        for j=2:W1+1
                countinventoryno=0;
                countfeasible=0;
                a=[V(i-1,j,1)]; %allocations that fit for inventory for indices i,j,k
                for t=1:b+1
                    if(allocation1(t)<=w(i-1,1) && allocation2(t)<=w(i-1,2)) %checking whether the allocation 
                    %is feasible according to the demand
                    countfeasible=countfeasible+1;
                        if ((allocation1(t)>=j) || (allocation2(t)>=1))%whether the feasible allocation can
                        %be given at the current state or not.
                            countinventoryno=countinventoryno+1;
                        else
                            c=[v(i-1)+V(i-1,j-allocation1(t),1)];
                            a=[a c];
                        end
                    end
                end
                if  (countfeasible==countinventoryno)
                    V(i,j,1)=V(i-1,j,1);
                else
                    V(i,j,1)=max(a); 
                end
        end
    end
else
    for i=2:n+1
        for j=2:W1+1
            for k=2:W2+1
                countinventoryno=0;
                countfeasible=0;
                a=[V(i-1,j,k)]; %%allocations that fit for inventory for indices i,j,k
                for t=1:b+1
                    if(allocation1(t)<=w(i-1,1) && allocation2(t)<=w(i-1,2)) %checking whether the allocation 
                    %is feasible according to the demand
                    countfeasible=countfeasible+1;
                        if ((allocation1(t)>=j) || (allocation2(t)>=k))%whether the feasible allocation can
                            %be given at the current state or not.
                            countinventoryno=countinventoryno+1;
                        else
                            c=[v(i-1)+V(i-1,j-allocation1(t),k-allocation2(t))];
                            a=[a c];
                        end
                    end
                end
                if  (countfeasible==countinventoryno)
                    V(i,j,k)=V(i-1,j,k);
                else
                    V(i,j,k)=max(a);
                end
            end
        end
    end
end

optval=V(n+1,W1+1,W2+1);

end
