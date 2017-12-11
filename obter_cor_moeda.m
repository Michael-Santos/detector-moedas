function [cor] = obter_cor_moeda(imagem, tamanho_janela, centro_x, centro_y)

% converte para inteiro
centro_x = uint16(centro_x);
centro_y = uint16(centro_y);

ponto_superior_x = fix(centro_x-(tamanho_janela/2));
ponto_superior_y = fix(centro_y-(tamanho_janela/2));
ponto_inferior_x = fix(centro_x+(tamanho_janela/2));
ponto_inferior_y = fix(centro_y+(tamanho_janela/2));

% encontra a cor da moeda por meio da mediana dos elementos do template
m = 1;
for i = ponto_superior_x : ponto_inferior_x
    l=1;
    for j = ponto_superior_y: ponto_inferior_y
        vetor_mediana(m) = imagem(j, i, 1);
        m = m+1;
    end
end

vetor_mediana = sort(vetor_mediana);
cor = vetor_mediana(fix(length(vetor_mediana)/2)+1);