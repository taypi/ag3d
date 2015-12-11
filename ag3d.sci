clear
function z = funcao(x, y)
    z = cos(x+y);
endfunction

//--------------------------------------------------------
function grafico()    
    [x,y] = meshgrid(minvalx:0.1:maxvalx,minvaly:0.1:maxvaly);
    
    z = funcao(x,y)
    
    //printf("max: %f", max(z));
    
    surf(x,y,z)
endfunction

//--------------------------------------------------------
function [maxZ, minZ] = support()
    [x,y] = meshgrid(minvalx:0.1:maxvalx,minvaly:0.1:maxvaly);  
    z = funcao(x,y)
    
    maxZ = max(z);
    minZ = min(z);
endfunction

//--------------------------------------------------------
function [filhoGeradoX, filhoGeradoY] = gerarFilho()
    for(i = 1:1:nGens)
        if (rand(1) > porcentagemGenetica) then
            filhoGeradoX(1, $+1) = 1;
        else
            filhoGeradoX(1, $+1) = 0;
        end
        if (rand(1) > porcentagemGenetica) then
            filhoGeradoY(1, $+1) = 1;
        else
            filhoGeradoY(1, $+1) = 0;
        end
    end
endfunction

//--------------------------------------------------------
function dec = binarioToDecimal(binario)
    aux = '';
    for (i = 1:1:nGens)
        if (binario(i) == 1 ) then
            aux = aux + '1';
        else
            aux = aux + '0';
        end                   
    end
    dec = bin2dec(aux);
endfunction

//--------------------------------------------------------
function x = normalizar(decimal, maxval, minval)
    interval = maxval-minval;
    x = minval + interval * decimal / (2^(nGens)-1);
endfunction

//--------------------------------------------------------
function val = aptidao(decX, decY)
    normalizadoX = normalizar(decX, maxvalx, minvalx);
    normalizadoY = normalizar(decY, maxvaly, minvaly);
    //printf("x: %f, y: %f\n", normalizadoX, normalizadoY)
    val = funcao(normalizadoX, normalizadoY);
    if val > maxZ then
        maxZ = val;
    end
    //printf("val: %f\n", val)
    //disp(val);
    val = 100 * (val - minZ)/(maxZ - minZ);
endfunction

//--------------------------------------------------------
function taxaAptidaoIndividual = taxaAptidao(popX, popY, ind)
    total = 0;
    for (i = 1:1:nIndividuos)    
        total = total + aptidao(binarioToDecimal(popX(i,:)), binarioToDecimal(popY(i,:)));
    end
    taxaAptidaoIndividual = aptidao(binarioToDecimal(popX(ind,:)), binarioToDecimal(popY(ind,:)))/total;
endfunction

//--------------------------------------------------------
function [respostaX, respostaY] = roleta(popX, popY)
    respostaX = [];
    respostaY = [];
    for (i=1:2:nIndividuos)
        r1 = rand(1);
        r2 = rand(1);
        
        indiceMarido = 0;
        indiceEsposa = 0;
        acumulado = 0;
        
        for i=1:nIndividuos
            taxa = taxaAptidao(popX, popY, i);
            
            if(acumulado < r1) & (r1<=(acumulado + taxa)) then
                indiceMarido = i;
            end
            if(acumulado < r2) & (r2<=(acumulado + taxa)) then
                indiceEsposa = i;
            end
            acumulado = acumulado + taxa;
        end
        //disp(indiceMarido, indiceEsposa);
        respostaX = [respostaX; popX(indiceMarido, :)];
        respostaX = [respostaX; popX(indiceEsposa, :)];
        respostaY = [respostaY; popY(indiceMarido, :)];
        respostaY = [respostaY; popY(indiceEsposa, :)];
    end
endfunction

//--------------------------------------------------------
function [filhosX, filhosY] = crossover(pai1X, pai2X, pai1Y, pai2Y)
    posicaoAux = rand() * nGens;
    posicao = ceil(posicaoAux);
    r = rand();
    if(r < porcentagemCross) then
        for(i=posicao:1:nGens)
            aux = pai1X(i);
            pai1X(i) = pai2X(i);
            pai2X(i)= aux;
        end
    
        posicaoAux = rand() * nGens;
        posicao = ceil(posicaoAux);
        for(i=posicao:1:nGens)
            aux = pai1Y(i);
            pai1Y(i) = pai2Y(i);
            pai2Y(i)= aux;
        end
    end
    filhosX = [pai1X; pai2X];
    filhosY = [pai1Y; pai2Y];     
endfunction

//------------------------------------------------------
function xman = mutacao(pessoa)
    for (i=1:1:nGens)
        if (rand(1) < porcentagemMutacao) then
            if (pessoa(i) == 1) then
                pessoa(i) = 0;
            else 
                pessoa(i) = 1;
            end
        end
    end
    xman = pessoa;
endfunction

//------------------------------------------------------
function [xman, yman] = mutacaoTaynara(pessoaX, pessoaY)
    if (rand(1) < porcentagemMutacao) then
        posicaoAux = rand(1)*nGens;
        posicao = ceil(posicaoAux)
        if (pessoaX(posicao) == 1) then
             pessoaX(posicao) = 0;
        else 
            pessoaX(posicao) = 1;
        end
    end
    if (rand(1) < porcentagemMutacao) then
        posicaoAux = rand(1)*nGens;
        posicao = ceil(posicaoAux)
        if (pessoaY(posicao) == 1) then
             pessoaY(posicao) = 0;
        else 
            pessoaY(posicao) = 1;
        end
    end
    xman = pessoaX;
    yman = pessoaY;
endfunction

function [popX, popY] = gerarPopulacao()
    [popX, popY] = gerarFilho();
    for(i=1:1:nIndividuos - 1)
        [auxX, auxY] = gerarFilho();
        popX = [popX; auxX];
        popY = [popY; auxY];
    end    
endfunction

//------------------------------------------------------
function [newPopulacaoX, newPopulacaoY] = formarNovaGeracao(casaisX, casaisY)
    for (i=1:2:nIndividuos)
        //disp(casaisX(i+1,:))
        [filhosX, filhosY] = crossover(casaisX(i,:), casaisX(i+1,:), casaisY(i,:), casaisY(i+1,:))
        [newPopulacaoX(i,:), newPopulacaoY(i,:)] = mutacaoTaynara(filhosX(1,:), filhosY(1,:));
        [newPopulacaoX(i+1,:), newPopulacaoY(i+1,:)] = mutacaoTaynara(filhosX(2,:), filhosY(2,:));
    end
endfunction

//------------------------------------------------------
function [val, vetorApt] = mediaAdaptacao(popX, popY)
    val = 0;
    for (i = 1:1:nIndividuos)
        dx = binarioToDecimal(popX(i,:));
        dy= binarioToDecimal(popY(i,:));
        val = val + aptidao(dx, dy);
        vetorApt(i) = aptidao(dx, dy);
    end
    val = val/nIndividuos;
    //printf('media aptidao = %f \n', val);
endfunction

function [z, x, y, val] = maxApt(popX, popY)
    [val, vetorApt] = mediaAdaptacao(popX, popY);
    [maxValue, ind] = max(vetorApt);
    x = normalizar(binarioToDecimal(popX(ind,:)), maxvalx, minvalx);
    y = normalizar(binarioToDecimal(popY(ind,:)), maxvaly, minvaly);
    z = funcao(x,y);
    printf("z = %f, x = %f, y = %f \n, media = %f \n", z, x, y, val);
endfunction

//------------------------------------------------------
function [z, x, y, val] = final()
    [popX, popY] = gerarPopulacao();
    for (i=1:geracoes)
         [casaisX, casaisY] = roleta(popX, popY);
         [popX, popY] = formarNovaGeracao(casaisX, casaisY);
         //mediaAdaptacao(popX, popY)
         //disp(populacao)
    end
    [z, x, y, val] = maxApt(popX, popY);
endfunction

geracoes = 30;
porcentagemMutacao = 0.01;
porcentagemCross = 0.8;
maxvalx = 1;
minvalx = -1;
maxvaly = 1;
minvaly = -1;
porcentagemGenetica = 0.5;
nGens = 30;
nIndividuos = 30;
[maxZ, minZ] = support();

//grafico();
[z, x, y, val] = final();
//disp (popY)
