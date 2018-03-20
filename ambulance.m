
X = zeros (12000, 1);
Y = zeros (12000, 1);
Dist = zeros ();
Dist2 = zeros();
X(1,1) = [0];
Y(1,1) = [0];
Xvalue = 0;
Yvalue = 0;
clock = 0;
   N = 1;
   Scale = 100;
   Prob = 0.1; //probability of an incoming call every hour

for T = 2 : length(X);    
    
    R = rand;
RN = round (5*R);


    if RN == 1;
        if Xvalue > Scale
            X(T,1) = X(T-1,1);
        else
        Xvalue = Xvalue +1;
   X(T,1) = Xvalue;
        end
    else X(T,1) = X(T-1,1);
    end
   
   if RN == 2;
       if Xvalue < - Scale
           X(T,1) = X(T-1,1);
        else
       Xvalue = Xvalue -1;
       X(T,1) = Xvalue;
       end
       else X(T,1) = X(T-1,1);
   end
    if RN == 3;
        if Yvalue > Scale
            Y(T,1) = Y(T-1,1);
        else
        Yvalue = Yvalue +1;
       Y(T,1) = Yvalue;
        end
       else Y(T,1) = Y(T-1,1);
    end
    if RN == 4;
        if Yvalue < - Scale
            Y(T,1) = Y(T-1,1);
        else
        Yvalue = Yvalue - 1;
       Y(T,1) = Yvalue;
        end
       else Y(T,1) = Y(T-1,1);
    end
  clock = clock +1;
  if clock == 61;
      r = binornd(1,Prob)
      if r > R;
          position (1,1) = (rand-.5)*2*Scale;
        position (1,2) = (rand-.5)*2*Scale;
     X(T,1) = position (1,1);
     Y(T,1) = position (1,2);
  Dist_Random(N,1) = sqrt((position(1,1)- X(T-1,1)).^2 + (position(1,2)- Y(T-1,1)).^2);
  Dist_Nonrandom(N,1) = sqrt((position(1,1)- 0).^2 + (position(1,2)- 0).^2);
  N = N+1;
  T = T+ 1;
  X(T,1) = 0;
  Y(T,1) = 0;
  T = T+1
  
  Xvalue =0;

 Yvalue =0;
      end
  clock = 0;    
  end
  
          
    
end

X;
Y;
 comet (X,Y);
 position = zeros (1,2);
 figure;
 plot(Dist_Random(:,1));
 hold on;
 plot(Dist_Nonrandom(:,1));
 legend('Dist_Random', 'Dist_Nonrandom');
 
 mean(Dist_Random)
 mean(Dist_Nonrandom)

    

    

