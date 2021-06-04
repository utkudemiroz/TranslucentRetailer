%This code implements the flexible return with unlimited exchange.
clear
clc

Q=300; %number of items
T=5; %Rental duration
C=0; %Number of customers
B=4; %Basket Size
LIMIT = 25; %When limit = 1 it is fixed return time
vij=rand(Q,C); %Values-random vector with dimension rand(n,C)

customerjbasket = zeros(B,C); %current basket of customer j.
customerjbooked = T*ones(1,C); %last time customer j has rented with some randomness.
customerjtried = zeros(B,C); %A 0-1 matrix showing whether customers tried those products before or not.
customerjvaluerealization = zeros(B,C); %A 0-1 matrix showing the realization of products for the customer.
NumberOfExchanges = zeros(1,C); %Number of exchanges per customer.

periods = 5000; %number of periods
available = ones(1,Q); %initial availability of all products.

numberOfCustomersEveryPeriod=[];

inv=[]; %inventory on hand at the end of period t.
HappinessAV=[]; %average happiness at period t.
HappinessVar=[]; %vector of individual happiness.
exchanges = []; %Exchange
totalShipmentsPeriod = []; %number of shipments at period t.

for t=1:periods
    shipment = 0;
    fprintf('The available inventory in the beginning of the period %i\n', t)
    disp(available)
    lambda=0.8;
    join=rand()<lambda;
    if join %randomly a new customer will join
        if lambda > 1
            customeradded = lambda;
        else
            customeradded = 1;
        end
        for m = 1:customeradded
            C=C+1; %adding the new customer
            newcustomer = zeros(B,1); %creating new customer basket (which is empty)
            customerjbasket=horzcat(customerjbasket, newcustomer); %adding new customer basket (which is empty)
            vij(:,C) = rand(Q,1); %Drawing utility values for the new customer.
            customerjbooked=horzcat(customerjbooked, T); %customer booking added.
            customerjtried(:,C) = zeros(B,1); %adding the tried values to the customer.
            customerjvaluerealization(:,C) = zeros(B,1); %adding all the initial realizations as 0.
            fprintf('Customer %i joins in period %i\n',C,t)
        end
    else
        fprintf('No customer joined in period %i\n',t)
    end        
    j=1;
    while (j<=C)
        if sum(available(:))<B %if inventory of available is lower than the basket size,
        %but some comes to the system back, then number of customers is reduced.
            if customerjbooked(1,j)==T %if customer j booked T periods before last time
                fprintf('There are not enough products, customer %i leaves\n',j)
                customerjbooked(1,j)=1; %make the last periods booked zero so that waits until this gets to T.
                if sum(customerjbasket(:,j))~=0 %if there are some products on customers hand before.
                    returnback=customerjbasket(:,j);%index(product) of what customer have currently.
                    fprintf('Customer %i leaves the products\n',j)
                    disp(customerjbasket(:,j))
                    available(returnback)=1; %make those products available.
                    shipment = shipment + 1;
                    disp(available)
                end
                %Removing the customer since not enough inventory.
                customerjbasket(:,j)=[];
                customerjbooked(:,j)=[];
                customerjtried(:,j)=[];
                customerjvaluerealization(:,j)=[];
                vij(:,j)=[];
                C=C-1;
            else %it's not customer j's turn. Then we move to the next customer.
                customerjbooked(1,j)=customerjbooked(1,j)+1; %increasing the last time he booked by one.
                j=j+1;
            end
        else %if there is enough inventory for customer j
            if customerjbooked(1,j)==T %if customer j booked T periods before last time
                customerjbooked(1,j)=1; %make the last periods booked zero so that waits until this gets to T.
                customerj=vij(:,j); %values for customer j
                if sum(customerjbasket(:,j))~=0 %if there are some products on customers hand before
                    happiness = (sum(customerjvaluerealization(:,j))/B); %realized happiness
                    fprintf('Customer %i has happiness %i\n',j,happiness)
                    b = rand();
                    if b <= happiness %if customer is happy
                        fprintf('Customer %i is happy\n',j)
                        customerjtried(:,j)= 0;
                        customerjvaluerealization(:,j) = 0;
                        returnback = customerjbasket(:,j); %these will be added to the available soon.
                        available(returnback) = 1; %make those products available.
                        shipment = shipment + 1;
                        for u=1:Q %going through all the products
                            if available(u)==0 || ismember(u,customerjbasket(:,j))%if that product is not available then customer cannot select it.
                                customerj(u)=0; %determining the available products for customer j, if not giving zero.
                                %Here we determined the best available product values that are not in customer's basket.
                            end
                        end
                        [val, ind]=sort(customerj,'descend'); %indeces of his values sorted
                        customerjbasket(:,j)=ind(1:B); %assigning the top B selection of customer.
                        fprintf('Customer %i picks\n',j)
                        disp(customerjbasket(:,j))
                        available(ind(1:B)) = 0; %Making the selected products unavailable.
                        shipment = shipment + 1;
                        disp(available)
                        exchanged = 0;
                        while sum(customerjvaluerealization(:,j))~=B && exchanged <= LIMIT
                            if sum(customerjtried(:,j))~= B
                                fprintf('Customer %i will select initial basket\n',j)
                                for k=1:B
                                    randomNumber = rand();
                                    if randomNumber < vij(customerjbasket(k,j)) %If customer likes the product k,assign value of 1.
                                        customerjvaluerealization(k,j) = 1; %update realization.
                                        customerjtried(k,j) = 1;
                                        fprintf('%i is realized as 1\n',customerjbasket(k,j))
                                    else
                                        customerjvaluerealization(k,j) = 0; %If customer does not like the product k
                                        customerjtried(k,j) = 1; %mark the product as tried product.
                                        fprintf('%i is realized as 0\n',customerjbasket(k,j))
                                    end 
                                end
                            else %customer has already tried her basket
                                dislikecounter = 0; %number of products she dislikes for this trial.
                                dislikematrix = []; %the list of products she dislike for this quarter.
                                for k = 1:B
                                    if customerjvaluerealization(k,j) == 0 %if customer did not like this product
                                        dislikecounter = dislikecounter+1;
                                        dislikematrix = [dislikematrix customerjbasket(k,j)];
                                    end
                                end 
                                
                                for u=1:length(customerj)
                                    if (available(u)==0) || ismember(u,customerjbasket(:,j)) %if that product is not available or
                                        customerj(u) = 0;
                                    end 
                                end
                                if ~(sum(customerj) == 0) %if there are products available to select
                                    [val ind] = sort(customerj,'descend');
                                    newitems = ind(1:dislikecounter);
                                    fprintf('Customer %i will select\n',j)
                                    disp(newitems)
                                    available(newitems) = 0;
                                    available(dislikematrix) = 1;
                                    shipment = shipment + 2;
                                    for k = 1:B
                                        if customerjvaluerealization(k,j)== 0 %if customer disliked this product 
                                            fprintf('Customer %i changes items %i with item %i\n',j,customerjbasket(k,j),newitems(1))
                                            customerjbasket(k,j) = newitems(1);
                                            newitems(1) = [];
                                            customerjtried(k,j) = 0; %This product will be realized again
                                        end
                                    end
                                    fprintf('Current customer %i basket\n',j)
                                    disp(customerjbasket(:,j))
                                    for k = 1:B
                                        if customerjtried(k,j) == 0 %only realizing the ones she newly acquired
                                            randomNumber = rand();
                                            if randomNumber < vij(customerjbasket(k,j))
                                                customerjvaluerealization(k,j) = 1; %update realization.
                                                customerjtried(k,j) = 1;
                                                fprintf('%i is realized as 1\n',customerjbasket(k,j))
                                            else
                                                customerjvaluerealization(k,j) = 0; %If customer does not like the product k
                                                customerjtried(k,j) = 1; %mark the product as tried product.
                                                fprintf('%i is realized as 0\n',customerjbasket(k,j))
                                            end 
                                        end
                                    end 
                                else
                                    exchanged = LIMIT+1;
                                end
                            end %if sum(customerjtried(:,j))~= B
                            exchanged = exchanged + 1;
                        end %while
                    else %customer is not happy, he will leave.
                        returnback = customerjbasket(:,j); %these will be added to the available soon.
                        available(returnback) = 1; %make those products available.
                        shipment = shipment + 1;
                        fprintf('Customer %i is not happy and leaves.\n',j)
                        fprintf('Customer %i returns the on-hand products\n',j)
                        disp(available)
                        customerjbasket(:,j)=[];
                        customerjbooked(:,j)=[];
                        customerjtried(:,j)= [];
                        customerjvaluerealization(:,j) = [];
                        vij(:,j)=[];
                        C=C-1;
                    end %if happy
                else %if customer basket is empty, she picks the best available ones.
                    for u=1:Q %going through all the products
                        if available(u)==0 || ismember(u,customerjbasket(:,j))%if that product is not available then customer cannot select it.
                            customerj(u)=0; %determining the available products for customer j, if not giving zero.
                            %Here we determined the best available product values that are not in customer's basket.
                        end
                    end
                    [val, ind]=sort(customerj,'descend'); %indeces of his values sorted
                    customerjbasket(:,j)=ind(1:B); %assigning the top B selection of customer.
                    fprintf('Customer %i picks\n',j)
                    disp(customerjbasket(:,j))
                    available(ind(1:B)) = 0; %Making the selected products unavailable.
                    shipment = shipment + 1;
                    disp(available)
                    exchanged = 0;
                    while sum(customerjvaluerealization(:,j))~=B && exchanged <= LIMIT
                        if sum(customerjtried(:,j))~= B
                            fprintf('Customer %i will select initial basket\n',j)
                            for k=1:B
                                randomNumber = rand();
                                if randomNumber < vij(customerjbasket(k,j)) %If customer likes the product k,assign value of 1.
                                    customerjvaluerealization(k,j) = 1; %update realization.
                                    customerjtried(k,j) = 1;
                                    fprintf('%i is realized as 1\n',customerjbasket(k,j))
                                else
                                    customerjvaluerealization(k,j) = 0; %If customer does not like the product k
                                    customerjtried(k,j) = 1; %mark the product as tried product.
                                    fprintf('%i is realized as 0\n',customerjbasket(k,j))
                                end 
                            end %for
                        else %customer has already tried her basket
                            dislikecounter = 0; %number of products she dislikes for this trial.
                            dislikematrix = []; %the list of products she dislike for this quarter.
                            for k = 1:B
                                if customerjvaluerealization(k,j) == 0 %if customer did not like this product
                                    dislikecounter = dislikecounter+1;
                                    dislikematrix = [dislikematrix customerjbasket(k,j)];
                                end
                            end
                            fprintf('Customer %i dislikes %i products\n',j,dislikecounter)
                            for u=1:length(customerj)
                                if (available(u)==0) || ismember(u,customerjbasket(:,j)) %if that product is not available or
                                    customerj(u) = 0;
                                end 
                            end
                            if ~(sum(customerj) == 0) %if there are products available to select
                                [val ind] = sort(customerj,'descend');
                                newitems = ind(1:dislikecounter);
                                fprintf('Customer %i will select\n',j)
                                disp(newitems)
                                available(newitems) = 0;
                                available(dislikematrix) = 1;
                                shipment = shipment + 2;
                                for k = 1:B
                                    if customerjvaluerealization(k,j)== 0 %if customer disliked this product 
                                        fprintf('Customer %i changes item %i with %i\n',j,customerjbasket(k,j),newitems(1))
                                        customerjbasket(k,j) = newitems(1);
                                        newitems(1) = [];
                                        customerjtried(k,j) = 0; %This product will be realized again
                                    end
                                end
                                fprintf('Current customer %i basket\n',j)
                                disp(customerjbasket(:,j))
                                for k = 1:B
                                    if customerjtried(k,j) == 0 %only realizing the ones she newly acquired
                                        randomNumber = rand();
                                        if randomNumber < vij(customerjbasket(k,j))
                                            customerjvaluerealization(k,j) = 1; %update realization.
                                            customerjtried(k,j) = 1;
                                            fprintf('%i is realized as 1\n',customerjbasket(k,j))
                                        else
                                            customerjvaluerealization(k,j) = 0; %If customer does not like the product k
                                            customerjtried(k,j) = 1; %mark the product as tried product.
                                            fprintf('%i is realized as 0\n',customerjbasket(k,j))
                                        end 
                                    end
                                end 
                            else
                                exchanged = LIMIT+1;
                            end
                        end %if sum(customerjtried(:,j))~= B
                        exchanged = exchanged + 1;
                    end %while
                end
            else %It's not customer j's turn. Then we move to the next customer.
                customerjbooked(1,j) = customerjbooked(1,j)+1;  %increasing the last time he booked by one.
                j=j+1;
            end %Inventory-CustomerTurn-If  
        end %Inventory-If
    end %While
    count=0; %initializing number of customers 
    for j=1:C %counting number of columns in the system.
        if sum(customerjbasket(:,j))~=0 %if customer has something in hand
            count=count+1;
        end
    end
    numberOfCustomersEveryPeriod=[numberOfCustomersEveryPeriod count];
    fprintf('The number of customers at the end of period %i is %i\n',t,count)
    totalHappinessPeriodt=0;
    happinessPeriodt=[];
    if C~=0
        for j=1:C
            if sum(customerjbasket(:,j))~=0 %if customer has something on this hand 
                happiness = (sum(customerjvaluerealization(:,j))/B);
                totalHappinessPeriodt=totalHappinessPeriodt+happiness; %cumulative happiness for period t.
                happinessPeriodt=[happinessPeriodt happiness];
            end
        end
        averageHappinessPeriodt=totalHappinessPeriodt/C;
        varianceHappinessPeriodt=var(happinessPeriodt);
        HappinessAV=[HappinessAV averageHappinessPeriodt];
        HappinessVar=[HappinessVar  varianceHappinessPeriodt];
    else
        HappinessAV=[HappinessAV 0];
        HappinessVar=[HappinessVar  0];
    end
    inv=[inv sum(available(:))];
    totalShipmentsPeriod = [totalShipmentsPeriod shipment];
end %Periods

ht=mean(HappinessAV);
I=mean(inv);
E=(2*I-B+1)/(2*(I+1));
dif1=E-ht;


C_sim1=mean(numberOfCustomersEveryPeriod) %from the simulation
C_sim2=(lambda*T)/(1-mean(HappinessAV)); %from the simulation with the balance equation
C_balance=(2*lambda*T*Q)/(B+1+2*lambda*B*T); %from order statistics by using the balance equation

totalShipments = mean(totalShipmentsPeriod)
I
ht