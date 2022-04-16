function [vector] = getMeasures( hist )
%getMeasures: This function calculates the statistical measures
% that compose the ADCN feature vector (see equations in Table 1).
%
%author: Leonardo Scabini
%
% Usage: receives an angular histogram ("hist").
%
% Returns: [vector], containing 6 statistical measures.

format long;

entropia = 0;
desvio = 0;
contraste =0;
homogeneidade =0;
energia =0;
variancia=0;
correlation=0;
media=0;

n= sum(hist);
for i=1: length(hist)
    media = media + (hist(i) * (i-1));   
end
if n==0
    media=0;
else
    media = media/n;
end
hist = hist/n;
for i=1: length(hist)
    variancia = variancia +(((i-1)^2)*hist(i));
    
    if(hist(i)> 0)
        entropia = entropia + (hist(i) * log2(hist(i)));
        energia = energia + (hist(i) * hist(i));
        contraste = contraste + ((i-1)*(i-1) *hist(i));
        if(i>1)
            homogeneidade = homogeneidade + (hist(i) / (i-1));
        else
            homogeneidade = homogeneidade + hist(i);        
        end
    end
    correlation = correlation +(hist(i) * (i-1)) - media;
end

if variancia - media^2 >=0
   desvio = sqrt(variancia - media^2);
else
    desvio=0;
end

entropia = - entropia;

if(desvio > 0)
    correlation = correlation / desvio;
else
    correlation = 0;
end

%vector =[entropia, desvio, contraste, homogeneidade, energia, correlation];
vector =[entropia, desvio, contraste, homogeneidade, energia, media];
%vector =[entropia, desvio, contraste, homogeneidade, energia];
end

