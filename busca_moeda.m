clc
clear

%-----------------------------------------------
% realiza a leitura da imagem
%-----------------------------------------------

cam = ipcam('http://10.0.0.100:8080/video', '', '', 'Timeout', 100);
im = snapshot(cam);
%im = imread('moedas_fundo_preto.jpeg');
figure(1);
subplot(2,2,1);
imshow(im); 
title('Imagem Original');

%-----------------------------------------------
% realiza a conversão apara escala de cinza
%-----------------------------------------------
im_cinza = rgb2gray(im);
subplot(2,2,2);
imshow(im_cinza);
title('Tons de Cinza');

%-----------------------------------------------
% realiza suavização meio do filtro gaussiano
%-----------------------------------------------
%h1 = fspecial('gaussian', [15 15], 6);
h1 = ones (4,4)/16;

im_suavizada = imfilter (im_cinza, h1);
subplot(2,2,3);
imshow(im_suavizada);
title('Suavizada');

%-----------------------------------------------
% realiza detecção das bordas por
% meio do filtro de canny
%-----------------------------------------------
limiar = [0.1 0.45];
im_binarizada = edge(im_suavizada(:,:,1), 'canny', limiar);
subplot(2,2,4);
imshow(im_binarizada);
title('Bordas');

%-----------------------------------------------
% realiza a divisão da imagem
%-----------------------------------------------
[lin, col] = size(im_binarizada);
masccrop = [0 0 col/2 lin];
esquerda = imcrop(im_binarizada, masccrop);
masccrop = [col/2+1 0 col lin];
direita = imcrop(im_binarizada,masccrop);

%-----------------------------------------------
% busca as moedas em cada lado da figura
%-----------------------------------------------
[centro_moedas_esquerda, raio_moedas_esquerda, medida_moedas_esquerda] = imfindcircles(esquerda,[8 100]);
[centro_moedas_direita, raio_moedas_direita, medida_moedas_direita] = imfindcircles(direita,[8 100]);

figure(2);
subplot(1,2,1);
imshow(esquerda);
title('Detecção cículos - Esquerda');

viscircles(centro_moedas_esquerda, raio_moedas_esquerda,'EdgeColor','g');

subplot(1,2,2);
imshow(direita);
title('Detecção cículos - Direita');

viscircles(centro_moedas_direita, raio_moedas_direita,'EdgeColor','g');

%-----------------------------------------------
% busca moedas com o raio mais próximo
%-----------------------------------------------
raio = raio_moedas_esquerda(1);

vetor_diferenca = abs(raio_moedas_direita - raio);
[vetor_diferenca_ordenado, vetor_diferenca_indice] =  sort(vetor_diferenca);

mais_proximo1 = vetor_diferenca_indice(1);
mais_proximo2 = vetor_diferenca_indice(2);

centro_mais_proximas = [centro_moedas_direita(vetor_diferenca_indice(1), 1)+col/2 centro_moedas_direita(vetor_diferenca_indice(1), 2);
                        centro_moedas_direita(vetor_diferenca_indice(2), 1)+col/2 centro_moedas_direita(vetor_diferenca_indice(2), 2)];
                    
raio_mais_proximas  = [raio_moedas_direita(vetor_diferenca_indice(1)); raio_moedas_direita(vetor_diferenca_indice(2))]

figure(3);
subplot(1,2,1);
imshow(im);
title('Moedas com raio mais próximo');

viscircles(centro_mais_proximas, raio_mais_proximas,'EdgeColor','b');

%-----------------------------------------------
% Utiliza a cor como critério de desempate
%-----------------------------------------------

subplot(1,2,2);
imshow(im);
title('Determina pela cor a moeda correta');

cor_mais_proximo1 = obter_cor_moeda(im, 15, centro_mais_proximas(1,1), centro_mais_proximas(1,2));
cor_mais_proximo2 = obter_cor_moeda(im, 15, centro_mais_proximas(2,1), centro_mais_proximas(2,2));
cor_alvo = obter_cor_moeda(im, 15, centro_moedas_esquerda(1,1), centro_moedas_esquerda(1,2));

if abs(cor_mais_proximo1 - cor_alvo) < abs(cor_mais_proximo2 - cor_alvo)  
    mais_proximo = mais_proximo1;
else
    mais_proximo = mais_proximo2;
end

centro_moeda = [centro_moedas_direita(mais_proximo, 1)+col/2 centro_moedas_direita(mais_proximo, 2)];
raio_moeda = [raio_moedas_direita(mais_proximo)];
viscircles(centro_moeda, raio_moeda,'EdgeColor','g');